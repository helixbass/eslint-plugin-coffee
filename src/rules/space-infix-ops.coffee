###*
# @fileoverview Require spaces around infix operators
# @author Michael Ficarra
###
'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'require spacing around infix operators'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/space-infix-ops'

    fixable: 'whitespace'

    schema: [
      type: 'object'
      properties:
        int32Hint:
          type: 'boolean'
      additionalProperties: no
    ]

  create: (context) ->
    int32Hint =
      if context.options[0]
        context.options[0].int32Hint is yes
      else
        no

    OPERATORS = [
      '*'
      '/'
      '%'
      '+'
      '-'
      '<<'
      '>>'
      '>>>'
      '<'
      '<='
      '>'
      '>='
      'not in'
      'in'
      'not of'
      'of'
      'instanceof'
      '=='
      '!='
      'is'
      'isnt'
      '&'
      '^'
      '|'
      '&&'
      'and'
      '||'
      'or'
      '?'
      '='
      '+='
      '-='
      '*='
      '/='
      '%='
      '<<='
      '>>='
      '>>>='
      '&='
      '^='
      '|='
      '&&='
      'and='
      '||='
      'or='
      '?='
      ','
      '**'
      '%%'
    ]

    sourceCode = context.getSourceCode()

    ###*
    # Returns the first token which violates the rule
    # @param {ASTNode} left - The left node of the main node
    # @param {ASTNode} right - The right node of the main node
    # @returns {Object} The violator token or null
    # @private
    ###
    getFirstNonSpacedToken = (left, right) ->
      tokens = sourceCode.getTokensBetween left, right, 1

      for i in [1...(tokens.length - 1)]
        op = tokens[i]

        return op if (
          op.type in ['Punctuator', 'Keyword'] and
          OPERATORS.indexOf(op.value) >= 0 and
          (tokens[i - 1].range[1] >= op.range[0] or
            op.range[1] >= tokens[i + 1].range[0])
        )
      null

    ###*
    # Reports an AST node as a rule violation
    # @param {ASTNode} mainNode - The node to report
    # @param {Object} culpritToken - The token which has a problem
    # @returns {void}
    # @private
    ###
    report = (mainNode, culpritToken) ->
      context.report
        node: mainNode
        loc: culpritToken.loc.start
        message: 'Infix operators must be spaced.'
        fix: (fixer) ->
          previousToken = sourceCode.getTokenBefore culpritToken
          afterToken = sourceCode.getTokenAfter culpritToken
          fixString = ''

          if culpritToken.range[0] - previousToken.range[1] is 0
            fixString = ' '

          fixString +=
            if culpritToken.value in ['in', 'of']
              # could actually be `not in` or `not of`
              sourceCode.getText culpritToken
            else
              culpritToken.value

          if afterToken.range[0] - culpritToken.range[1] is 0
            fixString += ' '

          fixer.replaceText culpritToken, fixString

    ###*
    # Check if the node is binary then report
    # @param {ASTNode} node node to evaluate
    # @returns {void}
    # @private
    ###
    checkBinary = (node) ->
      leftNode =
        if node.left.typeAnnotation
          node.left.typeAnnotation
        else
          node.left
      rightNode = node.right

      nonSpacedNode = getFirstNonSpacedToken leftNode, rightNode

      if nonSpacedNode
        unless int32Hint and sourceCode.getText(node).endsWith '|0'
          report node, nonSpacedNode

    ###*
    # Check if the node is a variable
    # @param {ASTNode} node node to evaluate
    # @returns {void}
    # @private
    ###
    checkVar = (node) ->
      leftNode =
        if node.id.typeAnnotation
          node.id.typeAnnotation
        else
          node.id
      rightNode = node.init

      if rightNode
        nonSpacedNode = getFirstNonSpacedToken leftNode, rightNode

        if nonSpacedNode then report node, nonSpacedNode

    AssignmentExpression: checkBinary
    AssignmentPattern: checkBinary
    BinaryExpression: checkBinary
    LogicalExpression: checkBinary
    VariableDeclarator: checkVar
