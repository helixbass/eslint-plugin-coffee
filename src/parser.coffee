CoffeeScript = require 'coffeescript'
{
  locationDataToAst
  traverseBabylonAst
} = require 'coffeescript/lib/coffeescript/helpers'
# babylonToEspree = require '../node_modules/babel-eslint/babylon-to-espree'
babylonToEspree = require 'babel-eslint/babylon-to-espree'
babelTraverse = require('babel-traverse').default
babylonTokenTypes = require('babylon').tokTypes
{flatten} = require 'lodash'
# patchCodePathAnalysis = require './patch-code-path-analysis'
analyzeScope = require './analyze-scope'

extendVisitorKeys = ->
  t = require 'babel-types'
  t.VISITOR_KEYS.For = ['index', 'name', 'step', 'guard', 'body']
espreeTokenTypes =
  '{': 'Punctuator'
  '}': 'Punctuator'
  '[': 'Punctuator'
  ']': 'Punctuator'
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
      not token.generated and token[0] not in ['INDENT', 'OUTDENT'] # excluding INDENT/OUTDENT seems necessary to avoid eslint createIndexMap() potentially choking on comment/token with same start location
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
    babylonToEspree ast, babelTraverse, babylonTokenTypes, code
    # dump espreeAst: ast
    {
      ast
      scopeManager: analyzeScope ast, opts
    }

exports.parseForESLint = getParser (code, opts) ->
  CoffeeScript.ast code, {...opts, withTokens: yes}

# dump = (obj) -> console.log require('util').inspect obj, no, null
