###*
# @fileoverview Rule to check for jsdoc presence.
# @author Gyandeep Singh
###
'use strict'

module.exports =
  meta:
    docs:
      description: 'require JSDoc comments'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/require-jsdoc'

    schema: [
      type: 'object'
      properties:
        require:
          type: 'object'
          properties:
            ClassDeclaration:
              type: 'boolean'
            MethodDefinition:
              type: 'boolean'
            FunctionDeclaration:
              type: 'boolean'
            ArrowFunctionExpression:
              type: 'boolean'
            FunctionExpression:
              type: 'boolean'
          additionalProperties: no
      additionalProperties: no
    ]

  create: (context) ->
    source = context.getSourceCode()
    DEFAULT_OPTIONS =
      FunctionDeclaration: yes
      MethodDefinition: no
      ClassDeclaration: no
      ArrowFunctionExpression: no
      FunctionExpression: no
    options = Object.assign DEFAULT_OPTIONS, context.options[0]?.require or {}

    ###*
    # Report the error message
    # @param {ASTNode} node node to report
    # @returns {void}
    ###
    report = (node) -> context.report {node, message: 'Missing JSDoc comment.'}

    ###*
    # Check if the jsdoc comment is present or not.
    # @param {ASTNode} node node to examine
    # @returns {void}
    ###
    checkJsDoc = (node) ->
      jsdocComment = source.getJSDocComment node

      unless jsdocComment then report node

    FunctionDeclaration: (node) ->
      if options.FunctionDeclaration then checkJsDoc node
    FunctionExpression: (node) ->
      if (
        (options.MethodDefinition and node.parent.type is 'MethodDefinition') or
        (options.FunctionExpression and
          (node.parent.type is 'VariableDeclarator' or
            (node.parent.type is 'AssignmentExpression' and
              node.parent.left.declaration) or
            (node.parent.type is 'Property' and node is node.parent.value)))
      )
        checkJsDoc node
    ClassDeclaration: (node) -> if options.ClassDeclaration then checkJsDoc node
    ArrowFunctionExpression: (node) ->
      if (
        options.ArrowFunctionExpression and
        node.parent.type is 'VariableDeclarator'
      )
        checkJsDoc node
