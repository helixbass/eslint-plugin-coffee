CoffeeScript = require 'coffeescript'
{
  locationDataToAst
  # traverseBabylonAst
} = require 'coffeescript/lib/coffeescript/helpers'
# babylonToEspree = require '../node_modules/babel-eslint/babylon-to-espree'
babylonToEspree = require 'babel-eslint/babylon-to-espree'
babelTraverse = require('babel-traverse').default
babylonTokenTypes = require('babylon').tokTypes
{flatten, assign: extend} = require 'lodash'
patchCodePathAnalysis = require './patch-code-path-analysis'
analyzeScope = require './analyze-scope'
CodePathAnalyzer = require './code-path-analysis/code-path-analyzer'
{KEYS} = require 'eslint-visitor-keys'

extendVisitorKeys = ->
  t = require 'babel-types'
  extend t.VISITOR_KEYS,
    For: ['index', 'name', 'source', 'step', 'guard', 'body']
    InterpolatedRegExpLiteral: ['expressions']
    Range: ['from', 'to']
espreeTokenTypes =
  '{': 'Punctuator'
  '}': 'Punctuator'
  '[': 'Punctuator'
  ']': 'Punctuator'
  '(': 'Punctuator'
  ')': 'Punctuator'
  CALL_START: 'Punctuator'
  CALL_END: 'Punctuator'
  PARAM_START: 'Punctuator'
  PARAM_END: 'Punctuator'
  INDEX_START: 'Punctuator'
  INDEX_END: 'Punctuator'
  '=>': 'Punctuator'
  '->': 'Punctuator'
  ',': 'Punctuator'
  ':': 'Punctuator'
  '.': 'Punctuator'
  '+': 'Punctuator'
  '++': 'Punctuator'
  '-': 'Punctuator'
  '--': 'Punctuator'
  '**': 'Punctuator'
  MATH: 'Punctuator'
  '=': 'Punctuator'
  '||': 'Punctuator'
  '&&': 'Punctuator'
  '|': 'Punctuator'
  'BIN?': 'Punctuator'
  COMPOUND_ASSIGN: 'Punctuator'
  UNARY_MATH: 'Punctuator'
  RELATION: 'Keyword'
  DO: 'Keyword'
  DO_IIFE: 'Keyword'
  REGEX: 'RegularExpression'
  IDENTIFIER: 'Identifier'
  AWAIT: 'Identifier'
  STRING: 'String'
getEspreeTokenType = (token) ->
  [type, value] = token
  {original} = value
  value = original if original?
  return 'JSX_COMMA' if type is ',' and value is 'JSX_COMMA'
  return 'Keyword' if (
    (type is 'UNARY' and value in ['typeof', 'new', 'delete', 'not']) or
    (type is 'COMPARE' and value in ['is', 'isnt'])
  )
  espreeTokenTypes[type] ? type

# extraTokensForESLint = (ast) ->
#   extraTokens = []
#   traverseBabylonAst ast, (node) ->
#     return unless node
#     {extra: {parenthesized} = {}, start, end} = node
#     return unless parenthesized
#     extraTokens.push
#       type: '('
#       value: '('
#       start: start - 1
#       end: start
#     ,
#       type: ')'
#       value: ')'
#       start: end
#       end: end + 1
#   extraTokens.sort ({start: firstStart}, {start: secondStart}) ->
#     if firstStart < secondStart then -1 else 1
# tokensForESLint = ({tokens, ast}) ->
tokensForESLint = ({tokens}) ->
  # extraTokens = extraTokensForESLint ast
  # popExtraTokens = ({nextStart}) ->
  #   popped = []
  #   while (
  #     (nextExtra = extraTokens[0]) and
  #     (nextStart is 'END' or nextExtra.start < nextStart)
  #   )
  #     popped.push extraTokens.shift()
  #   popped
  flatten [
    ...(for token in tokens when (
      not token.generated and
        token[0] not in [
          # excluding INDENT/OUTDENT seems necessary to avoid eslint createIndexMap() potentially choking on comment/token with same start location
          'INDENT'
          'OUTDENT'
          # espree doesn't seem to include tokens for \n
        ] and
        not (token[0] is 'TERMINATOR' and token[1] isnt ';')
    )
      [, value, locationData] = token
      [
        # ...popExtraTokens(nextStart: locationData.range[0])
        # ,
        {
          type: getEspreeTokenType token
          value: value.original ? value.toString()
          ...locationDataToAst(locationData)
        }
      ])
  ,
    # ...popExtraTokens(nextStart: 'END')
    {}
  ]

exports.getParser = getParser = (getAstAndTokens) -> (code, opts) ->
  patchCodePathAnalysis() unless opts.eslintCodePathAnalyzer
  # ESLint replace shebang #! with //
  code = code.replace /// ^ // ///, '#'
  {ast, tokens} = getAstAndTokens code, opts
  ast.tokens = tokensForESLint {tokens}
  extendVisitorKeys()
  commentLocs =
    for comment in ast.comments ? []
      start: {...comment.loc.start}
      end: {...comment.loc.end}
  babylonToEspree ast, babelTraverse, babylonTokenTypes, code
  # babylonToEspree seems to like to change the file-leading comment's start line
  for comment, commentIndex in ast.comments ? []
    comment.loc = commentLocs[commentIndex]
  # dump espreeAst: ast
  {
    ast
    scopeManager: analyzeScope ast, opts
    visitorKeys: {
      ...KEYS
      For: ['index', 'name', 'guard', 'step', 'source', 'body']
      # Identifier: [...KEYS.Identifier, 'declaration']
    }
    CodePathAnalyzer
  }

exports.parseForESLint = getParser (code, opts) ->
  CoffeeScript.ast code, {...opts, withTokens: yes}

# dump = (obj) -> console.log require('util').inspect obj, no, null
