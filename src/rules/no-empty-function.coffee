###*
# @fileoverview Rule to disallow empty functions.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

astUtils = require 'eslint/lib/ast-utils'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

ALLOW_OPTIONS = Object.freeze [
  'functions'
  'methods'
  # 'getters'
  # 'setters'
  'constructors'
]

###*
# Gets the kind of a given function node.
#
# @param {ASTNode} node - A function node to get. This is one of
#      an ArrowFunctionExpression, a FunctionDeclaration, or a
#      FunctionExpression.
# @returns {string} The kind of the function. This is one of "functions",
#      "arrowFunctions", "generatorFunctions", "asyncFunctions", "methods",
#      "generatorMethods", "asyncMethods", "getters", "setters", and
#      "constructors".
###
getKind = (node) ->
  {parent} = node
  kind = ''

  return 'arrowFunctions' if node.type is 'ArrowFunctionExpression'

  # Detects main kind.
  if parent.type is 'Property'
    return 'getters' if parent.kind is 'get'
    return 'setters' if parent.kind is 'set'
    kind =
      if parent.method or parent.value.type is 'FunctionExpression'
        'methods'
      else
        'functions'
  else if parent.type is 'MethodDefinition'
    return 'getters' if parent.kind is 'get'
    return 'setters' if parent.kind is 'set'
    return 'constructors' if parent.kind is 'constructor'
    kind = 'methods'
  else
    kind = 'functions'

  # Detects prefix.
  prefix = ''

  if node.generator
    prefix = 'generator'
  else if node.async
    prefix = 'async'
  else
    return kind
  prefix + kind[0].toUpperCase() + kind.slice 1

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow empty functions'
      category: 'Best Practices'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-empty-function'

    schema: [
      type: 'object'
      properties:
        allow:
          type: 'array'
          items: enum: ALLOW_OPTIONS
          uniqueItems: yes
      additionalProperties: no
    ]

    messages:
      unexpected: 'Unexpected empty {{name}}.'

  create: (context) ->
    options = context.options[0] or {}
    allowed = options.allow or []

    sourceCode = context.getSourceCode()

    ###*
    # Reports a given function node if the node matches the following patterns.
    #
    # - Not allowed by options.
    # - The body is empty.
    # - The body doesn't have any comments.
    #
    # @param {ASTNode} node - A function node to report. This is one of
    #      an ArrowFunctionExpression, a FunctionDeclaration, or a
    #      FunctionExpression.
    # @returns {void}
    ###
    reportIfEmpty = (node) ->
      kind = getKind node
      name = astUtils.getFunctionNameWithKind node
      innerComments = sourceCode.getTokens node.body,
        includeComments: yes
        filter: astUtils.isCommentToken
      if node.body.loc.start.line is node.body.loc.end.line
        # Look for trailing comments that weren't included in body location data
        nextToken = sourceCode.getTokenAfter node.body
        unless nextToken
          comments = sourceCode.getTokensAfter node.body, includeComments: yes
        else if sourceCode.commentsExistBetween node.body, nextToken
          comments = sourceCode.getTokensBetween node.body, nextToken
        if comments?.length
          for comment in comments
            break unless comment.loc.start.line is node.body.loc.start.line
            innerComments.push comment

      if (
        allowed.indexOf(kind) is -1 and
        node.body.type is 'BlockStatement' and
        node.body.body.length is 0 and
        innerComments.length is 0
      )
        context.report {
          node
          loc: node.body.loc.start
          messageId: 'unexpected'
          data: {name}
        }

    ArrowFunctionExpression: reportIfEmpty
    FunctionDeclaration: reportIfEmpty
    FunctionExpression: reportIfEmpty
