###*
# @fileoverview Rule to flag on declaring variables already declared in the outer scope
# @author Ilya Volodin
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

astUtils = require 'eslint/lib/ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'disallow variable declarations from shadowing variables declared in the outer scope'
      category: 'Variables'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-shadow'

    schema: [
      type: 'object'
      properties:
        builtinGlobals: type: 'boolean'
        hoist: enum: ['all', 'functions', 'never']
        allow:
          type: 'array'
          items:
            type: 'string'
      additionalProperties: no
    ]

  create: (context) ->
    options =
      builtinGlobals: Boolean context.options[0]?.builtinGlobals
      hoist: context.options[0]?.hoist or 'functions'
      allow: context.options[0]?.allow or []

    ###*
    # Check if variable name is allowed.
    #
    # @param  {ASTNode} variable The variable to check.
    # @returns {boolean} Whether or not the variable name is allowed.
    ###
    isAllowed = (variable) -> options.allow.indexOf(variable.name) isnt -1

    isDoIifeParam = (variable) ->
      identifier = variable.identifiers?[0]
      identifier?.type is 'Identifier' and
        identifier.parent.type is 'FunctionExpression' and
        identifier in identifier.parent.params and
        identifier.parent.parent.type is 'UnaryExpression' and
        identifier.parent.parent.operator is 'do'

    ###*
    # Checks if a variable of the class name in the class scope of ClassDeclaration.
    #
    # ClassDeclaration creates two variables of its name into its outer scope and its class scope.
    # So we should ignore the variable in the class scope.
    #
    # @param {Object} variable The variable to check.
    # @returns {boolean} Whether or not the variable of the class name in the class scope of ClassDeclaration.
    ###
    isDuplicatedClassNameVariable = (variable) ->
      {block} = variable.scope

      return yes if (
        block.type is 'ClassDeclaration' and block.id is variable.identifiers[0]
      )
      return yes if (
        block.id?.type is 'Identifier' and
        block.parent.type is 'AssignmentExpression' and
        block.parent.left.type is 'Identifier' and
        block.id.name is block.parent.left.name
      )
      no

    ###*
    # Checks if a variable is inside the initializer of scopeVar.
    #
    # To avoid reporting at declarations such as `var a = function a() {};`.
    # But it should report `var a = function(a) {};` or `var a = function() { function a() {} };`.
    #
    # @param {Object} variable The variable to check.
    # @param {Object} scopeVar The scope variable to look for.
    # @returns {boolean} Whether or not the variable is inside initializer of scopeVar.
    ###
    isOnInitializer = (variable, scopeVar) ->
      outerScope = scopeVar.scope
      outerDef = scopeVar.defs[0]
      outer = outerDef?.parent and outerDef.parent.range
      innerScope = variable.scope
      innerDef = variable.defs[0]
      inner = innerDef?.name.range

      outer and
        inner and
        outer[0] < inner[0] and
        inner[1] < outer[1] and
        ((innerDef.type is 'FunctionName' and
          innerDef.node.type is 'FunctionExpression') or
          innerDef.node.type is 'ClassExpression') and
        outerScope is innerScope.upper

    ###*
    # Get a range of a variable's identifier node.
    # @param {Object} variable The variable to get.
    # @returns {Array|undefined} The range of the variable's identifier node.
    ###
    getNameRange = (variable) ->
      def = variable.defs[0]

      def?.name.range

    ###*
    # Checks if a variable is in TDZ of scopeVar.
    # @param {Object} variable The variable to check.
    # @param {Object} scopeVar The variable of TDZ.
    # @returns {boolean} Whether or not the variable is in TDZ of scopeVar.
    ###
    isInTdz = (variable, scopeVar) ->
      outerDef = scopeVar.defs[0]
      inner = getNameRange variable
      outer = getNameRange scopeVar

      inner and
        outer and
        inner[1] < outer[0] and
        # Excepts FunctionDeclaration if is {"hoist":"function"}.
        not (
          options.hoist is 'functions' and
          outerDef and
          (outerDef.node.type is 'FunctionDeclaration' or
            (outerDef.node.parent.type is 'AssignmentExpression' and
              outerDef.node.parent.right.type is 'FunctionExpression'))
        )

    ###*
    # Checks the current context for shadowed variables.
    # @param {Scope} scope - Fixme
    # @returns {void}
    ###
    checkForShadows = (scope) ->
      {variables} = scope

      for variable in variables
        # Skips "arguments" or variables of a class name in the class scope of ClassDeclaration.
        continue if (
          variable.identifiers.length is 0 or
          isDuplicatedClassNameVariable(variable) or
          isDoIifeParam(variable) or
          isAllowed variable
        )

        # Gets shadowed variable.
        shadowed = astUtils.getVariableByName scope.upper, variable.name

        if (
          shadowed and
          (shadowed.identifiers.length > 0 or
            (options.builtinGlobals and 'writeable' of shadowed)) and
          not isOnInitializer(variable, shadowed) and
          not (options.hoist isnt 'all' and isInTdz variable, shadowed)
        )
          context.report
            node: variable.identifiers[0]
            message: "'{{name}}' is already declared in the upper scope."
            data: variable

    'Program:exit': ->
      globalScope = context.getScope()
      stack = globalScope.childScopes.slice()

      while stack.length
        scope = stack.pop()

        stack.push ...scope.childScopes
        checkForShadows scope
