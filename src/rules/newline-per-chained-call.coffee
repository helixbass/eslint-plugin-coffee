###*
# @fileoverview Rule to ensure newline per method call when chaining calls
# @author Rajendra Patil
# @author Burak Yigit Kaya
###

'use strict'

astUtils = require '../eslint-ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'require a newline after each call in a method chain'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/newline-per-chained-call'
    # fixable: 'whitespace'
    schema: [
      type: 'object'
      properties:
        ignoreChainWithDepth:
          type: 'integer'
          minimum: 1
          maximum: 10
      additionalProperties: no
    ]

  create: (context) ->
    options = context.options[0] or {}
    ignoreChainWithDepth = options.ignoreChainWithDepth or 2

    sourceCode = context.getSourceCode()

    ###*
    # Get the prefix of a given MemberExpression node.
    # If the MemberExpression node is a computed value it returns a
    # left bracket. If not it returns a period.
    #
    # @param  {ASTNode} node - A MemberExpression node to get
    # @returns {string} The prefix of the node.
    ###
    getPrefix = (node) -> if node.computed then '[' else '.'

    ###*
    # Gets the property text of a given MemberExpression node.
    # If the text is multiline, this returns only the first line.
    #
    # @param {ASTNode} node - A MemberExpression node to get.
    # @returns {string} The property text of the node.
    ###
    getPropertyText = (node) ->
      prefix = getPrefix node
      lines = sourceCode.getText(node.property).split astUtils.LINEBREAK_MATCHER
      suffix = if node.computed and lines.length is 1 then ']' else ''

      prefix + lines[0] + suffix

    'CallExpression:exit': (node) ->
      return unless (
        node.callee?.type is 'MemberExpression' and not node.callee.computed
      )

      {callee} = node
      parent = callee.object
      depth = 1

      while parent?.callee and not parent.callee.computed
        depth += 1
        parent = parent.callee.object

      if (
        depth > ignoreChainWithDepth and
        astUtils.isTokenOnSameLine callee.object, callee.property
      )
        context.report
          node: callee.property
          loc: callee.property.loc.start
          message: 'Expected line break before `{{callee}}`.'
          data:
            callee: getPropertyText callee
          # fix: (fixer) ->
          #   firstTokenAfterObject = sourceCode.getTokenAfter(
          #     callee.object
          #     astUtils.isNotClosingParenToken
          #   )

          #   fixer.insertTextBefore firstTokenAfterObject, '\n'
