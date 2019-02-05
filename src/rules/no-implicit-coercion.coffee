###*
# @fileoverview A rule to disallow the type conversions with shorter notations.
# @author Toru Nagashima
###

'use strict'

astUtils = require '../eslint-ast-utils'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

INDEX_OF_PATTERN = /^(?:i|lastI)ndexOf$/
ALLOWABLE_OPERATORS = ['~', '!!', '+', '*']

###*
# Parses and normalizes an option object.
# @param {Object} options - An option object to parse.
# @returns {Object} The parsed and normalized option object.
###
parseOptions = (options) ->
  boolean: if 'boolean' of options then Boolean options.boolean else yes
  number: if 'number' of options then Boolean options.number else yes
  string: if 'string' of options then Boolean options.string else yes
  allow: options.allow or []

###*
# Checks whether or not a node is a double logical nigating.
# @param {ASTNode} node - An UnaryExpression node to check.
# @returns {boolean} Whether or not the node is a double logical nigating.
###
isDoubleLogicalNegating = (node) ->
  node.operator is '!' and
  node.argument.type is 'UnaryExpression' and
  node.argument.operator is '!'

###*
# Checks whether or not a node is a binary negating of `.indexOf()` method calling.
# @param {ASTNode} node - An UnaryExpression node to check.
# @returns {boolean} Whether or not the node is a binary negating of `.indexOf()` method calling.
###
isBinaryNegatingOfIndexOf = (node) ->
  node.operator is '~' and
  node.argument.type is 'CallExpression' and
  node.argument.callee.type is 'MemberExpression' and
  node.argument.callee.property.type is 'Identifier' and
  INDEX_OF_PATTERN.test node.argument.callee.property.name

###*
# Checks whether or not a node is a multiplying by one.
# @param {BinaryExpression} node - A BinaryExpression node to check.
# @returns {boolean} Whether or not the node is a multiplying by one.
###
isMultiplyByOne = (node) ->
  node.operator is '*' and
  ((node.left.type is 'Literal' and node.left.value is 1) or
    (node.right.type is 'Literal' and node.right.value is 1))

###*
# Checks whether the result of a node is numeric or not
# @param {ASTNode} node The node to test
# @returns {boolean} true if the node is a number literal or a `Number()`, `parseInt` or `parseFloat` call
###
isNumeric = (node) ->
  (node.type is 'Literal' and typeof node.value is 'number') or
  (node.type is 'CallExpression' and
    node.callee.name in ['Number', 'parseInt', 'parseFloat'])

###*
# Returns the first non-numeric operand in a BinaryExpression. Designed to be
# used from bottom to up since it walks up the BinaryExpression trees using
# node.parent to find the result.
# @param {BinaryExpression} node The BinaryExpression node to be walked up on
# @returns {ASTNode|null} The first non-numeric item in the BinaryExpression tree or null
###
getNonNumericOperand = (node) ->
  {left} = node
  {right} = node

  return right if right.type isnt 'BinaryExpression' and not isNumeric right

  return left if left.type isnt 'BinaryExpression' and not isNumeric left

  null

###*
# Checks whether a node is an empty string literal or not.
# @param {ASTNode} node The node to check.
# @returns {boolean} Whether or not the passed in node is an
# empty string literal or not.
###
isEmptyString = (node) ->
  astUtils.isStringLiteral(node) and
  (node.value is '' or
    (node.type is 'TemplateLiteral' and
      node.quasis.length is 1 and
      node.quasis[0].value.cooked is ''))

###*
# Checks whether or not a node is a concatenating with an empty string.
# @param {ASTNode} node - A BinaryExpression node to check.
# @returns {boolean} Whether or not the node is a concatenating with an empty string.
###
isConcatWithEmptyString = (node) ->
  node.operator is '+' and
  ((isEmptyString(node.left) and not astUtils.isStringLiteral(node.right)) or
    (isEmptyString(node.right) and not astUtils.isStringLiteral node.left))

###*
# Checks whether or not a node is appended with an empty string.
# @param {ASTNode} node - An AssignmentExpression node to check.
# @returns {boolean} Whether or not the node is appended with an empty string.
###
isAppendEmptyString = (node) ->
  node.operator is '+=' and isEmptyString node.right

###*
# Returns the operand that is not an empty string from a flagged BinaryExpression.
# @param {ASTNode} node - The flagged BinaryExpression node to check.
# @returns {ASTNode} The operand that is not an empty string from a flagged BinaryExpression.
###
getNonEmptyOperand = (node) ->
  if isEmptyString node.left then node.right else node.left

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow shorthand type conversions'
      category: 'Best Practices'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-implicit-coercion'

    fixable: 'code'
    schema: [
      type: 'object'
      properties:
        boolean: type: 'boolean'
        number: type: 'boolean'
        string: type: 'boolean'
        allow:
          type: 'array'
          items: enum: ALLOWABLE_OPERATORS
          uniqueItems: yes
      additionalProperties: no
    ]

  create: (context) ->
    options = parseOptions context.options[0] or {}
    sourceCode = context.getSourceCode()

    ###*
    # Reports an error and autofixes the node
    # @param {ASTNode} node - An ast node to report the error on.
    # @param {string} recommendation - The recommended code for the issue
    # @param {bool} shouldFix - Whether this report should fix the node
    # @returns {void}
    ###
    report = (node, recommendation, shouldFix) ->
      context.report {
        node
        message: 'use `{{recommendation}}` instead.'
        data: {recommendation}
        fix: (fixer) ->
          return null unless shouldFix

          tokenBefore = sourceCode.getTokenBefore node

          return fixer.replaceText node, " #{recommendation}" if (
            tokenBefore and
            tokenBefore.range[1] is node.range[0] and
            not astUtils.canTokensBeAdjacent tokenBefore, recommendation
          )
          fixer.replaceText node, recommendation
      }

    UnaryExpression: (node) ->
      # !!foo
      operatorAllowed = options.allow.indexOf('!!') >= 0
      if (
        not operatorAllowed and
        options.boolean and
        isDoubleLogicalNegating node
      )
        recommendation = "Boolean(#{sourceCode.getText node.argument.argument})"

        report node, recommendation, yes

      # ~foo.indexOf(bar)
      operatorAllowed = options.allow.indexOf('~') >= 0
      if (
        not operatorAllowed and
        options.boolean and
        isBinaryNegatingOfIndexOf node
      )
        recommendation = "#{sourceCode.getText node.argument} isnt -1"

        report node, recommendation, no

      # +foo
      operatorAllowed = options.allow.indexOf('+') >= 0
      if (
        not operatorAllowed and
        options.number and
        node.operator is '+' and
        not isNumeric node.argument
      )
        recommendation = "Number(#{sourceCode.getText node.argument})"

        report node, recommendation, yes

    # Use `:exit` to prevent double reporting
    'BinaryExpression:exit': (node) ->
      # 1 * foo
      operatorAllowed = options.allow.indexOf('*') >= 0
      nonNumericOperand =
        not operatorAllowed and
        options.number and
        isMultiplyByOne(node) and
        getNonNumericOperand node

      if nonNumericOperand
        recommendation = "Number(#{sourceCode.getText nonNumericOperand})"

        report node, recommendation, yes

      # "" + foo
      operatorAllowed = options.allow.indexOf('+') >= 0
      if not operatorAllowed and options.string and isConcatWithEmptyString node
        recommendation = "String(#{sourceCode.getText getNonEmptyOperand node})"

        report node, recommendation, yes

    AssignmentExpression: (node) ->
      # foo += ""
      operatorAllowed = options.allow.indexOf('+') >= 0

      if not operatorAllowed and options.string and isAppendEmptyString node
        code = sourceCode.getText getNonEmptyOperand node
        recommendation = "#{code} = String(#{code})"

        report node, recommendation, yes
