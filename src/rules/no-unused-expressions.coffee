###*
# @fileoverview Flag expressions in statement position that do not side effect
# @author Michael Ficarra
###
'use strict'

{last} = require 'lodash'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow unused expressions'
      category: 'Best Practices'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-unused-expressions'

    schema: [
      type: 'object'
      properties:
        allowShortCircuit: type: 'boolean'
        # allowTernary: type: 'boolean'
        allowTaggedTemplates: type: 'boolean'
      additionalProperties: no
    ]

  create: (context) ->
    config = context.options[0] or {}
    allowShortCircuit = config.allowShortCircuit or no
    # allowTernary = config.allowTernary or no
    allowTaggedTemplates = config.allowTaggedTemplates or no

    ###*
    # @param {ASTNode} node - any node
    # @returns {boolean} whether the given node structurally represents a directive
    ###
    looksLikeDirective = (node) ->
      node.type is 'ExpressionStatement' and
      node.expression.type is 'Literal' and
      typeof node.expression.value is 'string'

    ###*
    # @param {Function} predicate - ([a] -> Boolean) the function used to make the determination
    # @param {a[]} list - the input list
    # @returns {a[]} the leading sequence of members in the given list that pass the given predicate
    ###
    takeWhile = (predicate, list) ->
      i = 0
      while i < list.length
        return list.slice 0, i unless predicate list[i]
        ++i
      list.slice()

    ###*
    # @param {ASTNode} node - a Program or BlockStatement node
    # @returns {ASTNode[]} the leading sequence of directive nodes in the given node's body
    ###
    directives = (node) -> takeWhile looksLikeDirective, node.body

    ###*
    # @param {ASTNode} node - any node
    # @param {ASTNode[]} ancestors - the given node's ancestors
    # @returns {boolean} whether the given node is considered a directive in its current position
    ###
    isDirective = (node, ancestors) ->
      parent = ancestors[ancestors.length - 1]
      grandparent = ancestors[ancestors.length - 2]

      (parent.type is 'Program' or
        (parent.type is 'BlockStatement' and
          /Function/.test(grandparent.type))) and
        directives(parent).indexOf(node) >= 0

    shouldTreatAsConditional = (node) ->
      return yes if node.type is 'ConditionalExpression'
      return no unless node.type is 'IfStatement'
      return no if node.parent.type in ['BlockStatement', 'Program']
      return shouldTreatAsConditional node.parent if (
        node.parent.type is 'IfStatement'
      )
      yes

    isBlockWhereSequenceIsExpected = (node) ->
      return unless node.type is 'BlockStatement'
      return yes if node.parent.type is 'TemplateLiteral'
      return yes if shouldTreatAsConditional node.parent
      no

    ###*
    # Determines whether or not a given node is a valid expression. Recurses on short circuit eval and ternary nodes if enabled by flags.
    # @param {ASTNode} node - any node
    # @returns {boolean} whether the given node is a valid expression
    ###
    isValidExpression = (node) ->
      return yes if node.returns
      return yes if node.type is 'PassthroughLiteral'
      return yes if (
        node.parent.type is 'ExpressionStatement' and
        node.parent is last(node.parent.parent.body) and
        isBlockWhereSequenceIsExpected node.parent.parent
      )

      # if allowTernary
      # Recursive check for ternary and logical expressions
      return (
        isValidExpression(node.consequent) and
        (not node.alternate or isValidExpression node.alternate)
      ) if shouldTreatAsConditional node

      if allowShortCircuit
        return isValidExpression node.right if node.type is 'LogicalExpression'

      return yes if (
        allowTaggedTemplates and node.type is 'TaggedTemplateExpression'
      )

      /^(?:Optional)?(?:Assignment|Call|New|Update|Yield|Await)Expression$/.test(
        node.type
      ) or
        # our ConditionalExpression could have statements
        /Statement/.test(node.type) or
        (node.type is 'UnaryExpression' and
          ['delete', 'void', 'do'].indexOf(node.operator) >= 0)

    ExpressionStatement: (node) ->
      if (
        not isValidExpression(node.expression) and
        not isDirective node, context.getAncestors()
      )
        context.report {
          node
          message:
            'Expected an assignment or function call and instead saw an expression.'
        }
