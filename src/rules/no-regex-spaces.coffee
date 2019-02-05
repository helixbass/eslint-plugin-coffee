###*
# @fileoverview Rule to count multiple spaces in regular expressions
# @author Matt DuVall <http://www.mattduvall.com/>
###

'use strict'

astUtils = require '../eslint-ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow multiple spaces in regular expressions'
      category: 'Possible Errors'
      recommended: yes
      url: 'https://eslint.org/docs/rules/no-regex-spaces'

    schema: []

    fixable: 'code'

  create: (context) ->
    sourceCode = context.getSourceCode()

    ###*
    # Validate regular expressions
    # @param {ASTNode} node node to validate
    # @param {string} value regular expression to validate
    # @param {number} valueStart The start location of the regex/string literal. It will always be the case that
    # `sourceCode.getText().slice(valueStart, valueStart + value.length) === value`
    # @returns {void}
    # @private
    ###
    checkRegex = (node, value, valueStart) ->
      multipleSpacesRegex = /( {2,})( [+*{?]|[^+*{?]|$)/
      regexResults = multipleSpacesRegex.exec value

      unless regexResults is null
        count = regexResults[1].length

        context.report {
          node
          message: 'Spaces are hard to count. Use {{{count}}}.'
          data: {count}
          fix: (fixer) ->
            fixer.replaceTextRange(
              [
                valueStart + regexResults.index
                valueStart + regexResults.index + count
              ]
              " {#{count}}"
            )
        }

        ###
        # TODO: (platinumazure) Fix message to use rule message
        # substitution when api.report is fixed in lib/eslint.js.
        ###

    ###*
    # Validate regular expression literals
    # @param {ASTNode} node node to validate
    # @returns {void}
    # @private
    ###
    checkLiteral = (node) ->
      token = sourceCode.getFirstToken node
      nodeType = token.type
      nodeValue = node.raw

      if nodeType is 'RegularExpression'
        checkRegex node, nodeValue, token.range[0]

    ###*
    # Check if node is a string
    # @param {ASTNode} node node to evaluate
    # @returns {boolean} True if its a string
    # @private
    ###
    isString = (node) ->
      node and node.type is 'Literal' and typeof node.value is 'string'

    ###*
    # Validate strings passed to the RegExp constructor
    # @param {ASTNode} node node to validate
    # @returns {void}
    # @private
    ###
    checkFunction = (node) ->
      scope = context.getScope()
      regExpVar = astUtils.getVariableByName scope, 'RegExp'
      shadowed = regExpVar and regExpVar.defs.length > 0

      if (
        node.callee.type is 'Identifier' and
        node.callee.name is 'RegExp' and
        isString(node.arguments[0]) and
        not shadowed
      )
        checkRegex node, node.arguments[0].value, node.arguments[0].range[0] + 1

    Literal: checkLiteral
    CallExpression: checkFunction
    NewExpression: checkFunction
