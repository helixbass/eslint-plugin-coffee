###*
# @fileoverview Rule to disallow unnecessary computed property keys in object literals
# @author Burak Yigit Kaya
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

lodash = require 'lodash'
astUtils = require '../eslint-ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

MESSAGE_UNNECESSARY_COMPUTED =
  'Unnecessarily computed property [{{property}}] found.'

module.exports =
  meta:
    type: 'suggestion'

    docs:
      description:
        'disallow unnecessary computed property keys in objects and classes'
      category: 'ECMAScript 6'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-useless-computed-key'

    schema: [
      type: 'object'
      properties:
        enforceForClassMembers:
          type: 'boolean'
          default: no
      additionalProperties: no
    ]
    fixable: 'code'
  create: (context) ->
    sourceCode = context.getSourceCode()
    enforceForClassMembers = context.options[0]?.enforceForClassMembers

    ###*
    # Reports a given node if it violated this rule.
    # @param {ASTNode} node The node to check.
    # @returns {void}
    ###
    check = (node) ->
      return unless node.computed
      return if node.shorthand

      {key} = node
      nodeType = typeof key.value

      if node.type is 'MethodDefinition'
        allowedKey = if node.static then 'prototype' else 'constructor'
      else
        allowedKey = '__proto__'

      if (
        key.type is 'Literal' and
        nodeType in ['string', 'number'] and
        key.value isnt allowedKey
      )
        context.report {
          node
          message: MESSAGE_UNNECESSARY_COMPUTED
          data: property: sourceCode.getText key
          fix: (fixer) ->
            leftSquareBracket = sourceCode.getFirstToken(
              node
              astUtils.isOpeningBracketToken
            )
            rightSquareBracket = sourceCode.getFirstTokenBetween(
              node.key
              node.value
              astUtils.isClosingBracketToken
            )
            tokensBetween = sourceCode.getTokensBetween(
              leftSquareBracket
              rightSquareBracket
              1
            )

            # If there are comments between the brackets and the property name, don't do a fix.
            return null if tokensBetween
            .slice 0, -1
            .some (token, index) ->
              sourceCode
              .getText()
              .slice token.range[1], tokensBetween[index + 1].range[0]
              .trim()

            tokenBeforeLeftBracket = sourceCode.getTokenBefore leftSquareBracket

            # Insert a space before the key to avoid changing identifiers, e.g. ({ get[2]() {} }) to ({ get2() {} })
            needsSpaceBeforeKey =
              tokenBeforeLeftBracket.range[1] is leftSquareBracket.range[0] and
              not astUtils.canTokensBeAdjacent(
                tokenBeforeLeftBracket
                sourceCode.getFirstToken key
              )

            replacementKey = (if needsSpaceBeforeKey then ' ' else '') + key.raw

            fixer.replaceTextRange(
              [leftSquareBracket.range[0], rightSquareBracket.range[1]]
              replacementKey
            )
        }

    Property: check
    MethodDefinition: if enforceForClassMembers then check else lodash.noop
