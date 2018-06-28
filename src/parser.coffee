CoffeeScript = require 'coffeescript'
{locationDataToBabylon, traverseBabylonAst} = require 'coffeescript/lib/coffeescript/helpers'
babylonToEspree = require '../node_modules/babel-eslint/babylon-to-espree'
babelTraverse = require('babel-traverse').default
babylonTokenTypes = require('babylon').tokTypes
{flatten} = require 'lodash'

espreeTokenTypes =
  '{': 'Punctuator'
  '}': 'Punctuator'
  '[': 'Punctuator'
  ']': 'Punctuator'
  'INDEX_START': 'Punctuator'
  'INDEX_END':   'Punctuator'
  '+': 'Punctuator'
  'REGEX': 'RegularExpression'
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
    while (nextExtra = extraTokens[0]) and (nextStart is 'END' or nextExtra.start < nextStart)
      popped.push extraTokens.shift()
    popped
  flatten [
    ...(for [type, value, locationData] in tokens
      [
        ...(popExtraTokens {nextStart: locationData.range[0]})
        {
          type: getEspreeTokenType type
          value
          ...locationDataToBabylon(locationData)
        }
      ])
    ...popExtraTokens({nextStart: 'END'})
    {}
  ]

exports.getParser = getParser = (getAstAndTokens) -> (code, opts) ->
  {ast, tokens} = getAstAndTokens code, opts
  ast.tokens = tokensForESLint {tokens, ast}
  babylonToEspree ast, babelTraverse, babylonTokenTypes, code
  # dump espreeAst: ast
  {ast}

exports.parseForESLint = getParser (code, opts) -> CoffeeScript.ast code, {...opts, withTokens: yes}
