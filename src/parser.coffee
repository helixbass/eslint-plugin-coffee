CoffeeScript = require 'coffeescript'
{
  locationDataToAst
  traverseBabylonAst
} = require 'coffeescript/lib/coffeescript/helpers'
# babylonToEspree = require '../node_modules/babel-eslint/babylon-to-espree'
babylonToEspree = require 'babel-eslint/babylon-to-espree'
babelTraverse = require('babel-traverse').default
babylonTokenTypes = require('babylon').tokTypes
{flatten, assign: extend} = require 'lodash'
# patchCodePathAnalysis = require './patch-code-path-analysis'
analyzeScope = require './analyze-scope'
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
  INDEX_START: 'Punctuator'
  INDEX_END: 'Punctuator'
  '+': 'Punctuator'
  REGEX: 'RegularExpression'
getEspreeTokenType = (type) ->
  espreeTokenTypes[type] ? type

extraTokensForESLint = (ast) ->
  return []
  extraTokens = []
  traverseBabylonAst ast, (node) ->
    return unless node
    {extra: {parenthesized} = {}, start, end} = node
    return unless parenthesized
    extraTokens.push
      type: '('
      value: '('
      start: start - 1
      end: start
    ,
      type: ')'
      value: ')'
      start: end
      end: end + 1
  extraTokens.sort ({start: firstStart}, {start: secondStart}) ->
    if firstStart < secondStart then -1 else 1
tokensForESLint = ({tokens, ast}) ->
  extraTokens = extraTokensForESLint ast
  popExtraTokens = ({nextStart}) ->
    popped = []
    while (
      (nextExtra = extraTokens[0]) and
      (nextStart is 'END' or nextExtra.start < nextStart)
    )
      popped.push extraTokens.shift()
    popped
  flatten [
    ...(for token in tokens when (
      not token.generated and
        token[0] not in
          [
            # excluding INDENT/OUTDENT seems necessary to avoid eslint createIndexMap() potentially choking on comment/token with same start location
            'INDENT'
            'OUTDENT'
            # espree doesn't seem to include tokens for \n
            'TERMINATOR'
          ]
    )
      [type, value, locationData] = token
      [
        ...popExtraTokens(nextStart: locationData.range[0])
      ,
        {
          type: getEspreeTokenType type
          value: value.original ? value.toString()
          ...locationDataToAst(locationData)
        }
      ])
    ...popExtraTokens(nextStart: 'END')
  ,
    {}
  ]

exports.getParser =
  getParser = (getAstAndTokens) -> (code, opts) ->
    # patchCodePathAnalysis()
    {ast, tokens} = getAstAndTokens code, opts
    ast.tokens = tokensForESLint {tokens, ast}
    extendVisitorKeys()
    firstCommentLine = ast.comments?[0]?.loc.start.line
    babylonToEspree ast, babelTraverse, babylonTokenTypes, code
    # babylonToEspree seems to like to change the file-leading comment's start line
    ast.comments?[0]?.loc.start.line = firstCommentLine
    # dump espreeAst: ast
    {
      ast
      scopeManager: analyzeScope ast, opts
      visitorKeys: {
        ...KEYS
        For: ['index', 'name', 'guard', 'step', 'source', 'body']
        # Identifier: [...KEYS.Identifier, 'declaration']
      }
    }

exports.parseForESLint = getParser (code, opts) ->
  CoffeeScript.ast code, {...opts, withTokens: yes}

# dump = (obj) -> console.log require('util').inspect obj, no, null
