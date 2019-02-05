###*
# @fileoverview Rule to flag declared but unused variables
# @author Ilya Volodin
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

lodash = require 'lodash'
astUtils = require '../eslint-ast-utils'
utils = require '../util/ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow unused variables'
      category: 'Variables'
      recommended: yes
      url: 'https://eslint.org/docs/rules/no-unused-vars'

    schema: [
      oneOf: [
        enum: ['all', 'local']
      ,
        type: 'object'
        properties:
          vars:
            enum: ['all', 'local']
          varsIgnorePattern:
            type: 'string'
          args:
            enum: ['all', 'after-used', 'none']
          ignoreRestSiblings:
            type: 'boolean'
          argsIgnorePattern:
            type: 'string'
          caughtErrors:
            enum: ['all', 'none']
          caughtErrorsIgnorePattern:
            type: 'string'
      ]
    ]

  create: (context) ->
    sourceCode = context.getSourceCode()

    REST_PROPERTY_TYPE = /^(?:RestElement|(?:Experimental)?RestProperty)$/

    config =
      vars: 'all'
      args: 'after-used'
      ignoreRestSiblings: no
      caughtErrors: 'none'

    firstOption = context.options[0]

    if firstOption
      if typeof firstOption is 'string'
        config.vars = firstOption
      else
        config.vars = firstOption.vars or config.vars
        config.args = firstOption.args or config.args
        config.ignoreRestSiblings =
          firstOption.ignoreRestSiblings or config.ignoreRestSiblings
        config.caughtErrors = firstOption.caughtErrors or config.caughtErrors

        if firstOption.varsIgnorePattern
          config.varsIgnorePattern = new RegExp firstOption.varsIgnorePattern

        if firstOption.argsIgnorePattern
          config.argsIgnorePattern = new RegExp firstOption.argsIgnorePattern

        if firstOption.caughtErrorsIgnorePattern
          config.caughtErrorsIgnorePattern = new RegExp(
            firstOption.caughtErrorsIgnorePattern
          )

    ###*
    # Generate the warning message about the variable being
    # defined and unused, including the ignore pattern if configured.
    # @param {Variable} unusedVar - eslint-scope variable object.
    # @returns {string} The warning message to be used with this unused variable.
    ###
    getDefinedMessage = (unusedVar) ->
      defType = unusedVar.defs?[0] and unusedVar.defs[0].type
      if defType is 'CatchClause' and config.caughtErrorsIgnorePattern
        type = 'args'
        pattern = config.caughtErrorsIgnorePattern.toString()
      else if defType is 'Parameter' and config.argsIgnorePattern
        type = 'args'
        pattern = config.argsIgnorePattern.toString()
      else if defType isnt 'Parameter' and config.varsIgnorePattern
        type = 'vars'
        pattern = config.varsIgnorePattern.toString()

      additional =
        if type then " Allowed unused #{type} must match #{pattern}." else ''

      "'{{name}}' is defined but never used.#{additional}"

    ###*
    # Generate the warning message about the variable being
    # assigned and unused, including the ignore pattern if configured.
    # @returns {string} The warning message to be used with this unused variable.
    ###
    getAssignedMessage = ->
      additional =
        if config.varsIgnorePattern
          " Allowed unused vars must match #{config.varsIgnorePattern.toString()}."
        else
          ''

      "'{{name}}' is assigned a value but never used.#{additional}"

    #--------------------------------------------------------------------------
    # Helpers
    #--------------------------------------------------------------------------

    STATEMENT_TYPE = /(?:Statement|Declaration)$/

    ###*
    # Determines if a given variable is being exported from a module.
    # @param {Variable} variable - eslint-scope variable object.
    # @returns {boolean} True if the variable is exported, false if not.
    # @private
    ###
    isExported = (variable) ->
      definition = variable.defs[0]

      if definition
        {node} = definition

        if node.declaration
          node = node.parent
        else
          return no if definition.type is 'Parameter'

        return node.parent.type.indexOf('Export') is 0
      no

    ###*
    # Determines if a variable has a sibling rest property
    # @param {Variable} variable - eslint-scope variable object.
    # @returns {boolean} True if the variable is exported, false if not.
    # @private
    ###
    hasRestSpreadSibling = (variable) ->
      if config.ignoreRestSiblings
        return variable.defs.some (def) ->
          propertyNode = def.name.parent
          patternNode = propertyNode.parent

          propertyNode.type is 'Property' and
            patternNode.type is 'ObjectPattern' and
            REST_PROPERTY_TYPE.test(
              patternNode.properties[patternNode.properties.length - 1].type
            )

      no

    ###*
    # Determines if a reference is a read operation.
    # @param {Reference} ref - An eslint-scope Reference
    # @returns {boolean} whether the given reference represents a read operation
    # @private
    ###
    isReadRef = (ref) -> ref.isRead()

    ###*
    # Determine if an identifier is referencing an enclosing function name.
    # @param {Reference} ref - The reference to check.
    # @param {ASTNode[]} nodes - The candidate function nodes.
    # @returns {boolean} True if it's a self-reference, false if not.
    # @private
    ###
    isSelfReference = (ref, nodes) ->
      scope = ref.from

      while scope
        for node in nodes
          return yes if scope.block is node.parent.right

        scope = scope.upper

      no

    ###*
    # Checks the position of given nodes.
    #
    # @param {ASTNode} inner - A node which is expected as inside.
    # @param {ASTNode} outer - A node which is expected as outside.
    # @returns {boolean} `true` if the `inner` node exists in the `outer` node.
    # @private
    ###
    isInside = (inner, outer) ->
      inner.range[0] >= outer.range[0] and inner.range[1] <= outer.range[1]

    ###*
    # If a given reference is left-hand side of an assignment, this gets
    # the right-hand side node of the assignment.
    #
    # In the following cases, this returns null.
    #
    # - The reference is not the LHS of an assignment expression.
    # - The reference is inside of a loop.
    # - The reference is inside of a function scope which is different from
    #   the declaration.
    #
    # @param {eslint-scope.Reference} ref - A reference to check.
    # @param {ASTNode} prevRhsNode - The previous RHS node.
    # @returns {ASTNode|null} The RHS node or null.
    # @private
    ###
    getRhsNode = (ref, prevRhsNode) ->
      id = ref.identifier
      {parent} = id
      granpa = parent.parent
      refScope = ref.from.variableScope
      varScope = ref.resolved.scope.variableScope
      canBeUsedLater = refScope isnt varScope or utils.isInLoop id

      ###
      # Inherits the previous node if this reference is in the node.
      # This is for `a = a + a`-like code.
      ###
      return prevRhsNode if prevRhsNode and isInside id, prevRhsNode

      return parent.right if (
        parent.type is 'AssignmentExpression' and
        granpa.type is 'ExpressionStatement' and
        id is parent.left and
        not canBeUsedLater
      )
      null

    ###*
    # Checks whether a given function node is stored to somewhere or not.
    # If the function node is stored, the function can be used later.
    #
    # @param {ASTNode} funcNode - A function node to check.
    # @param {ASTNode} rhsNode - The RHS node of the previous assignment.
    # @returns {boolean} `true` if under the following conditions:
    #      - the funcNode is assigned to a variable.
    #      - the funcNode is bound as an argument of a function call.
    #      - the function is bound to a property and the object satisfies above conditions.
    # @private
    ###
    isStorableFunction = (funcNode, rhsNode) ->
      node = funcNode
      {parent} = funcNode

      while parent and isInside parent, rhsNode
        switch parent.type
          when 'SequenceExpression'
            return no unless (
              parent.expressions[parent.expressions.length - 1] is node
            )

          when 'CallExpression', 'NewExpression'
            return parent.callee isnt node

          when 'AssignmentExpression', 'TaggedTemplateExpression', 'YieldExpression'
            return yes

          else
            ###
            # If it encountered statements, this is a complex pattern.
            # Since analyzeing complex patterns is hard, this returns `true` to avoid false positive.
            ###
            return yes if STATEMENT_TYPE.test parent.type

        node = parent
        {parent} = parent

      no

    ###*
    # Checks whether a given Identifier node exists inside of a function node which can be used later.
    #
    # "can be used later" means:
    # - the function is assigned to a variable.
    # - the function is bound to a property and the object can be used later.
    # - the function is bound as an argument of a function call.
    #
    # If a reference exists in a function which can be used later, the reference is read when the function is called.
    #
    # @param {ASTNode} id - An Identifier node to check.
    # @param {ASTNode} rhsNode - The RHS node of the previous assignment.
    # @returns {boolean} `true` if the `id` node exists inside of a function node which can be used later.
    # @private
    ###
    isInsideOfStorableFunction = (id, rhsNode) ->
      funcNode = astUtils.getUpperFunction id

      funcNode and
        isInside(funcNode, rhsNode) and
        isStorableFunction funcNode, rhsNode

    ###*
    # Checks whether a given reference is a read to update itself or not.
    #
    # @param {eslint-scope.Reference} ref - A reference to check.
    # @param {ASTNode} rhsNode - The RHS node of the previous assignment.
    # @returns {boolean} The reference is a read to update itself.
    # @private
    ###
    isReadForItself = (ref, rhsNode) ->
      id = ref.identifier
      {parent} = id
      granpa = parent.parent

      ref.isRead() and
        # self update. e.g. `a += 1`, `a++`
        ((parent.type is 'AssignmentExpression' and
          not parent.returns and
          granpa.type is 'ExpressionStatement' and
          parent.left is id) or
          (parent.type is 'UpdateExpression' and
            granpa.type is 'ExpressionStatement') or
          # in RHS of an assignment for itself. e.g. `a = a + 1`
          (rhsNode and
            isInside(id, rhsNode) and
            not isInsideOfStorableFunction id, rhsNode))

    ###*
    # Determine if an identifier is used either in for-in loops.
    #
    # @param {Reference} ref - The reference to check.
    # @returns {boolean} whether reference is used in the for-in loops
    # @private
    ###
    isForInRef = (ref) ->
      target = ref.identifier.parent

      # "for (var ...) { return; }"
      if target.type is 'VariableDeclarator' then target = target.parent.parent

      return no unless target.type is 'ForInStatement'

      # "for (...) { return; }"
      if target.body.type is 'BlockStatement'
        target = target.body.body[0]

        # "for (...) return;"
      else
        target = target.body

      # For empty loop body
      return no unless target

      target.type is 'ReturnStatement'

    isIife = (functionNodes) ->
      functionNodes.every ({parent: funcAssignment}) ->
        {parent} = funcAssignment
        return yes if (
          parent.type is 'UnaryExpression' and parent.operator is 'do'
        )
        return yes if (
          parent.type is 'CallExpression' and parent.callee is funcAssignment
        )
        no

    ###*
    # Determines if the variable is used.
    # @param {Variable} variable - The variable to check.
    # @returns {boolean} True if the variable is used
    # @private
    ###
    isUsedVariable = (variable) ->
      functionNodes = variable.defs
      .filter ({node}) ->
        node.type is 'Identifier' and
        node.declaration and
        node.parent.type is 'AssignmentExpression' and
        node.parent.right.type is 'FunctionExpression'
      .map (def) -> def.node
      isFunctionDefinition = functionNodes.length > 0
      rhsNode = null

      variable.references.some (ref) ->
        return yes if isForInRef ref

        forItself = isReadForItself ref, rhsNode

        rhsNode = getRhsNode ref, rhsNode

        isReadRef(ref) and
          not forItself and
          not (
            isFunctionDefinition and
            isSelfReference(ref, functionNodes) and
            not isIife functionNodes
          )

    ###*
    # Checks whether the given variable is after the last used parameter.
    #
    # @param {eslint-scope.Variable} variable - The variable to check.
    # @returns {boolean} `true` if the variable is defined after the last
    # used parameter.
    ###
    isAfterLastUsedArg = (variable) ->
      def = variable.defs[0]
      params = context.getDeclaredVariables def.node
      posteriorParams = params.slice params.indexOf(variable) + 1

      # If any used parameters occur after this parameter, do not report.
      not posteriorParams.some (v) -> v.references.length > 0

    ###*
    # Gets an array of variables without read references.
    # @param {Scope} scope - an eslint-scope Scope object.
    # @param {Variable[]} unusedVars - an array that saving result.
    # @returns {Variable[]} unused variables of the scope and descendant scopes.
    # @private
    ###
    collectUnusedVariables = (scope, unusedVars) ->
      {variables, childScopes} = scope
      if (
        scope.type isnt 'TDZ' and
        (scope.type isnt 'global' or config.vars is 'all')
      )
        for variable in variables
          # skip a variable of class itself name in the class scope
          continue if (
            scope.type is 'class' and scope.block.id is variable.identifiers[0]
          )

          # skip function expression names and variables marked with markVariableAsUsed()
          continue if scope.functionExpressionScope or variable.eslintUsed

          # skip implicit "arguments" variable
          continue if (
            scope.type is 'function' and
            variable.name is 'arguments' and
            variable.identifiers.length is 0
          )

          # explicit global variables don't have definitions.
          def = variable.defs[0]

          if def
            {type} = def

            # skip catch variables
            if type is 'CatchClause'
              continue if config.caughtErrors is 'none'

              # skip ignored parameters
              continue if config.caughtErrorsIgnorePattern?.test def.name.name

            if type is 'Parameter'
              # skip any setter argument
              continue if (
                def.node.parent.type in ['Property', 'MethodDefinition'] and
                def.node.parent.kind is 'set'
              )

              # if "args" option is "none", skip any parameter
              continue if config.args is 'none'

              # skip ignored parameters
              continue if config.argsIgnorePattern?.test def.name.name

              # if "args" option is "after-used", skip used variables
              continue if (
                config.args is 'after-used' and
                astUtils.isFunction(def.name.parent) and
                not isAfterLastUsedArg variable
              )
            # skip ignored variables
            else if config.varsIgnorePattern?.test def.name.name
              continue

          if (
            not isUsedVariable(variable) and
            not isExported(variable) and
            not hasRestSpreadSibling variable
          )
            unusedVars.push variable

      collectUnusedVariables(
        childScope
        unusedVars
      ) for childScope in childScopes

      unusedVars

    ###*
    # Gets the index of a given variable name in a given comment.
    # @param {eslint-scope.Variable} variable - A variable to get.
    # @param {ASTNode} comment - A comment node which includes the variable name.
    # @returns {number} The index of the variable name's location.
    # @private
    ###
    getColumnInComment = (variable, comment) ->
      namePattern = new RegExp(
        "[\\s,]#{lodash.escapeRegExp variable.name}(?:$|[\\s,:])"
        'g'
      )

      # To ignore the first text "global".
      namePattern.lastIndex = comment.value.indexOf('global') + 6

      # Search a given variable name.
      match = namePattern.exec comment.value

      if match then match.index + 1 else 0

    ###*
    # Creates the correct location of a given variables.
    # The location is at its name string in a `/*global` comment.
    #
    # @param {eslint-scope.Variable} variable - A variable to get its location.
    # @returns {{line: number, column: number}} The location object for the variable.
    # @private
    ###
    getLocation = (variable) ->
      comment = variable.eslintExplicitGlobalComment

      sourceCode.getLocFromIndex(
        comment.range[0] + 2 + getColumnInComment variable, comment
      )

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    'Program:exit': (programNode) ->
      unusedVars = collectUnusedVariables context.getScope(), []

      for unusedVar in unusedVars
        if unusedVar.eslintExplicitGlobal
          context.report
            node: programNode
            loc: getLocation unusedVar
            message: getDefinedMessage unusedVar
            data: unusedVar
        else if unusedVar.defs.length > 0
          context.report
            node: unusedVar.identifiers[0]
            message:
              if unusedVar.references.some (ref) -> ref.isWrite()
                getAssignedMessage()
              else
                getDefinedMessage unusedVar
            data: unusedVar
