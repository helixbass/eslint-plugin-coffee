###*
# @fileoverview Rule to flag unnecessary double negation in Boolean contexts
# @author Brandon Mills
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

# astUtils = require '../eslint-ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow unnecessary boolean casts'
      category: 'Possible Errors'
      recommended: yes
      url: 'https://eslint.org/docs/rules/no-extra-boolean-cast'

    schema: []

    # fixable: 'code'

    messages:
      unexpectedCall: 'Redundant Boolean call.'
      unexpectedNegation: 'Redundant double negation.'

  create: (context) ->
    # sourceCode = context.getSourceCode()

    # Node types which have a test which will coerce values to booleans.
    BOOLEAN_NODE_TYPES = [
      'IfStatement'
      'WhileStatement'
      'ConditionalExpression'
    ]

    ###*
    # Check if a node is in a context where its value would be coerced to a boolean at runtime.
    #
    # @param {Object} node The node
    # @param {Object} parent Its parent
    # @returns {boolean} If it is in a boolean context
    ###
    isInBooleanContext = (node, parent) ->
      (BOOLEAN_NODE_TYPES.indexOf(parent.type) isnt -1 and
        node is parent.test) or
      # !<bool>
      (parent.type is 'UnaryExpression' and parent.operator is '!')

    UnaryExpression: (node) ->
      ancestors = context.getAncestors()
      parent = ancestors.pop()
      grandparent = ancestors.pop()

      # Exit early if it's guaranteed not to match
      return if (
        node.operator isnt '!' or
        parent.type isnt 'UnaryExpression' or
        parent.operator isnt '!'
      )

      if (
        isInBooleanContext(parent, grandparent) or
        # Boolean(<bool>) and new Boolean(<bool>)
        (grandparent.type in ['CallExpression', 'NewExpression'] and
          grandparent.callee.type is 'Identifier' and
          grandparent.callee.name is 'Boolean')
      )
        context.report {
          node
          messageId: 'unexpectedNegation'
          # fix: (fixer) ->
          #   fixer.replaceText parent, sourceCode.getText node.argument
        }
    CallExpression: (node) ->
      {parent} = node

      return if (
        node.callee.type isnt 'Identifier' or node.callee.name isnt 'Boolean'
      )

      if isInBooleanContext node, parent
        context.report {
          node
          messageId: 'unexpectedCall'
          # fix: (fixer) ->
          #   return fixer.replaceText parent, 'true' unless node.arguments.length

          #   return null if (
          #     node.arguments.length > 1 or
          #     node.arguments[0].type is 'SpreadElement'
          #   )

          #   argument = node.arguments[0]

          #   return fixer.replaceText(
          #     node
          #     "(#{sourceCode.getText argument})"
          #   ) if (
          #     astUtils.getPrecedence(argument) <
          #     astUtils.getPrecedence node.parent
          #   )
          #   fixer.replaceText node, sourceCode.getText argument
        }
