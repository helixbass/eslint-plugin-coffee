CoffeeScript = require 'coffeescript'
{
  jisonLocationDataToAstLocationData: locationDataToAst
  # traverseBabylonAst
} = require 'coffeescript/lib/coffeescript/nodes'
# babylonToEspree = require '../node_modules/babel-eslint/babylon-to-espree'
babylonToEspree = require 'babel-eslint/babylon-to-espree'
babelTraverse = require('babel-traverse').default
babylonTokenTypes = require('babylon').tokTypes
{flatten, assign: extend, repeat} = require 'lodash'
patchCodePathAnalysis = require './patch-code-path-analysis'
# patchReact = require './patch-react'
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
  INTERPOLATION_START: 'Punctuator'
  INTERPOLATION_END: 'Punctuator'
  STRING_START: 'Punctuator'
  STRING_END: 'Punctuator'
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
  '<': 'Punctuator'
  '>': 'Punctuator'
  '/': 'Punctuator'
  RELATION: 'Keyword'
  THEN: 'Keyword'
  LEADING_WHEN: 'Keyword'
  DO: 'Keyword'
  DO_IIFE: 'Keyword'
  WHILE: 'Keyword'
  UNTIL: 'Keyword'
  THROW: 'Keyword'
  SWITCH: 'Keyword'
  RETURN: 'Keyword'
  FOR: 'Keyword'
  FOROF: 'Keyword'
  IF: 'Keyword'
  ELSE: 'Keyword'
  POST_IF: 'Keyword'
  CLASS: 'Keyword'
  EXTENDS: 'Keyword'
  TRY: 'Keyword'
  CATCH: 'Keyword'
  FINALLY: 'Keyword'
  REGEX: 'RegularExpression'
  IDENTIFIER: 'Identifier'
  AWAIT: 'Identifier'
  PROPERTY: 'Identifier'
  STRING: 'String'
  NUMBER: 'Numeric'
getEspreeTokenType = (token) ->
  [type, value] = token
  {original} = value
  value = original if original?
  return 'JSX_COMMA' if type is ',' and value is 'JSX_COMMA'
  return 'JSXText' if type is 'STRING' and token.data?.jsx
  return 'JSXIdentifier' if (
    token.jsxIdentifier or
    (type is 'PROPERTY' and token.data?.jsx)
  )
  return 'Keyword' if (
    (type is 'UNARY' and value in ['typeof', 'new', 'delete', 'not']) or
    (type is 'COMPARE' and value in ['is', 'isnt'])
  )
  espreeTokenTypes[type] ? type

getTokenValue = (token) ->
  [type, value, {range}] = token
  if type is 'INTERPOLATION_START'
    return if range[1] - range[0] is 1 then '{' else '#{'
  return '}' if type is 'INTERPOLATION_END'
  return repeat '"', range[1] - range[0] if type in [
    'STRING_START'
    'STRING_END'
  ]
  return value[1...-1] if type is 'STRING' and token.data?.jsx
  return '=' if token.jsxColon
  value.original ? value.toString()

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
    ...(
      for token in tokens when (
        not (
          token.generated and
          not (
            token.fromThen or
            token.prevToken or
            token.data?.closingBracketToken or
            token.data?.closingTagClosingBracketToken
          )
        ) and
          # excluding INDENT/OUTDENT seems necessary to avoid eslint createIndexMap() potentially choking on comment/token with same start location
          not (token[0] is 'OUTDENT' and token.prevToken?[1] isnt ';') and
          # espree doesn't seem to include tokens for \n
          not (token[0] is 'TERMINATOR' and token[1] isnt ';') and
          not (token[0] is 'INDENT' and not token.fromThen) and
          not (
            token[0] is 'STRING' and
            token[1].length is 2 and
            token[2].range[1] - token[2].range[0] < 2
          )
      )
        token = token.prevToken if token.prevToken?[1] is ';'
        token = token.origin if token.fromThen
        spreadTokens =
          if token.data?.openingBracketToken
            if token.data.tagNameToken[1].length
              token.data.tagNameToken.jsxIdentifier = yes
              [token.data.openingBracketToken, token.data.tagNameToken]
            else
              [token.data.openingBracketToken]
          else if token.data?.selfClosingSlashToken
            [token.data.selfClosingSlashToken, token.data.closingBracketToken]
          else if token.data?.closingBracketToken
            [token.data.closingBracketToken]
          else if token.data?.closingTagClosingBracketToken
            if token.data.closingTagNameToken[1].length
              token.data.closingTagNameToken.jsxIdentifier = yes
              [
                token.data.closingTagOpeningBracketToken
                token.data.closingTagSlashToken
                token.data.closingTagNameToken
                token.data.closingTagClosingBracketToken
              ]
            else
              [
                token.data.closingTagOpeningBracketToken
                token.data.closingTagSlashToken
                token.data.closingTagClosingBracketToken
              ]
          else
            [token]
        for token in spreadTokens
          [, , locationData] = token
          {
            type: getEspreeTokenType token
            value: getTokenValue token
            ...locationDataToAst(locationData)
          }
    )
    # ...popExtraTokens(nextStart: 'END')
    {}
  ]

exports.getParser = getParser = (getAst) -> (code, opts) ->
  patchCodePathAnalysis() unless opts.eslintCodePathAnalyzer
  # patchReact()
  # ESLint replaces shebang #! with //, but leading // could be part of a heregex
  if /// ^ // ///.test code
    try
      ast = getAst code, opts
    catch
      code = code.replace /// ^ // ///, '#'
      ast = getAst code, opts
  else
    ast = getAst code, opts
  ast.tokens = tokensForESLint ast
  # dump {tokens, transformedTokens: ast.tokens}
  extendVisitorKeys()
  commentLocs =
    for comment in ast.comments ? []
      start: {...comment.loc.start}
      end: {...comment.loc.end}
  babylonToEspree ast, babelTraverse, babylonTokenTypes, code
  # babylonToEspree seems to like to change the file-leading comment's start line
  for comment, commentIndex in ast.comments ? []
    comment.loc = commentLocs[commentIndex]
  # ...and the Program's end range
  if ast.type is 'Program'
    ast.range[1] = ast.end
  else
    ast.program?.range[1] = ast.program.end
  # eslint-scope will fail eg on ImportDeclaration's unless treated as module
  ast.sourceType = 'module'
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
  CoffeeScript.compile code, {...opts, ast: yes}

# dump = (obj) -> console.log require('util').inspect obj, no, null
