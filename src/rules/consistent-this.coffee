###*
# @fileoverview Rule to enforce consistent naming of "this" context variables
# @author Raphael Pigulla
###
'use strict'

{isNullOrUndefined} = require 'eslint/lib/ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'enforce consistent naming when capturing the current execution context'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/consistent-this'

    schema:
      type: 'array'
      items:
        type: 'string'
        minLength: 1
      uniqueItems: yes

    messages:
      aliasNotAssignedToThis:
        "Designated alias '{{name}}' is not assigned to 'this'."
      unexpectedAlias: "Unexpected alias '{{name}}' for 'this'."

  create: (context) ->
    aliases = []

    if context.options.length is 0
      aliases.push 'that'
    else
      aliases = context.options

    ###*
    # Reports that a variable declarator or assignment expression is assigning
    # a non-'this' value to the specified alias.
    # @param {ASTNode} node - The assigning node.
    # @param {string}  name - the name of the alias that was incorrectly used.
    # @returns {void}
    ###
    reportBadAssignment = (node, name) ->
      context.report {node, messageId: 'aliasNotAssignedToThis', data: {name}}

    isNullAssignment = (node) ->
      currentNode = node
      while currentNode
        return yes if isNullOrUndefined currentNode
        # handle chained null assignment
        return no unless currentNode.type is 'AssignmentExpression'
        currentNode = currentNode.right

    ###*
    # Checks that an assignment to an identifier only assigns 'this' to the
    # appropriate alias, and the alias is only assigned to 'this'.
    # @param {ASTNode} node - The assigning node.
    # @param {Identifier} name - The name of the variable assigned to.
    # @param {Expression} value - The value of the assignment.
    # @returns {void}
    ###
    checkAssignment = (node, name, value) ->
      isThis = value.type is 'ThisExpression'

      isNullDeclaration = node.left.declaration and isNullAssignment value

      if name in aliases
        if (
          not (isThis or isNullDeclaration) or
          (node.operator and node.operator isnt '=')
        )
          reportBadAssignment node, name
      else if isThis
        context.report {node, messageId: 'unexpectedAlias', data: {name}}

    ###*
    # Ensures that a variable declaration of the alias in a program or function
    # is assigned to the correct value.
    # @param {string} alias alias the check the assignment of.
    # @param {Object} scope scope of the current code we are checking.
    # @private
    # @returns {void}
    ###
    checkWasAssigned = (alias, scope) ->
      variable = scope.set.get alias

      unless variable
        return unless (
          scope.type is 'global' and scope.childScopes[0]?.type is 'module'
        )
        return checkWasAssigned alias, scope.childScopes[0]

      return if variable.defs.some (def) ->
        def.node.type is 'Identifier' and
        not isNullAssignment def.node.parent.right

      ###
      # The alias has been declared and not assigned: check it was
      # assigned later in the same scope.
      ###
      # unless variable.references.some((reference) ->
      #   write = reference.writeExpr

      #   reference.from is scope and
      #     write and
      #     write.type is 'ThisExpression' and
      #     write.parent.operator is '='
      # )
      #   variable.defs
      #     .map (def) -> def.node
      #     .forEach (node) -> reportBadAssignment node, alias
      getsAssignedToThis = variable.references.some (reference) ->
        write = reference.writeExpr

        reference.from is scope and
          write and
          write.type is 'ThisExpression' and
          write.parent.operator is '='
      unless getsAssignedToThis
        variable.defs
        .map (def) -> def.node
        .forEach (node) -> reportBadAssignment node, alias

    ###*
    # Check each alias to ensure that is was assinged to the correct value.
    # @returns {void}
    ###
    ensureWasAssigned = ->
      scope = context.getScope()

      aliases.forEach (alias) -> checkWasAssigned alias, scope

    'Program:exit': ensureWasAssigned
    'FunctionExpression:exit': ensureWasAssigned
    'FunctionDeclaration:exit': ensureWasAssigned

    VariableDeclarator: (node) ->
      {id} = node
      isDestructuring = id.type in ['ArrayPattern', 'ObjectPattern']

      if node.init isnt null and not isDestructuring
        checkAssignment node, id.name, node.init

    AssignmentExpression: (node) ->
      if node.left.type is 'Identifier'
        checkAssignment node, node.left.name, node.right
