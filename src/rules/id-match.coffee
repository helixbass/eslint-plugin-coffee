###*
# @fileoverview Rule to flag non-matching identifiers
# @author Matthieu Larcher
###

'use strict'

{isDeclarationAssignment} = require '../util/ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'require identifiers to match a specified regular expression'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/id-match'

    schema: [
      type: 'string'
    ,
      type: 'object'
      properties:
        properties:
          type: 'boolean'
    ]

  create: (context) ->
    #--------------------------------------------------------------------------
    # Helpers
    #--------------------------------------------------------------------------

    pattern = context.options[0] or '^.+$'
    regexp = new RegExp pattern

    options = context.options[1] or {}
    properties = !!options.properties
    onlyDeclarations = !!options.onlyDeclarations

    ###*
    # Checks if a string matches the provided pattern
    # @param {string} name The string to check.
    # @returns {boolean} if the string is a match
    # @private
    ###
    isInvalid = (name) -> not regexp.test name

    ###*
    # Verifies if we should report an error or not based on the effective
    # parent node and the identifier name.
    # @param {ASTNode} effectiveParent The effective parent node of the node to be reported
    # @param {string} name The identifier name of the identifier node
    # @returns {boolean} whether an error should be reported or not
    ###
    shouldReport = (effectiveParent, name) ->
      effectiveParent.type isnt 'CallExpression' and
      effectiveParent.type isnt 'NewExpression' and
      isInvalid name

    ###*
    # Reports an AST node as a rule violation.
    # @param {ASTNode} node The node to report.
    # @returns {void}
    # @private
    ###
    report = (node) ->
      context.report {
        node
        message:
          "Identifier '{{name}}' does not match the pattern '{{pattern}}'."
        data: {
          name: node.name
          pattern
        }
      }

    Identifier: (node) ->
      {name, parent} = node
      effectiveParent =
        if parent.type is 'MemberExpression'
          parent.parent
        else
          parent

      switch parent.type
        when 'MemberExpression'
          return unless properties

          # Always check object names
          if parent.object.type is 'Identifier' and parent.object.name is name
            if isInvalid name then report node

            # Report AssignmentExpressions only if they are the left side of the assignment
          else if (
            effectiveParent.type is 'AssignmentExpression' and
            (effectiveParent.right.type isnt 'MemberExpression' or
              (effectiveParent.left.type is 'MemberExpression' and
                effectiveParent.left.property.name is name))
          )
            if isInvalid name then report node
        when 'Property'
          return unless properties and parent.key.name is name

          if shouldReport effectiveParent, name then report node
        when 'ClassDeclaration'
          return unless parent.id is node

          if shouldReport effectiveParent, name then report node
        else
          isDeclaration =
            effectiveParent.type in [
              'FunctionDeclaration'
              'VariableDeclarator'
            ] or isDeclarationAssignment effectiveParent

          return if onlyDeclarations and not isDeclaration

          if shouldReport effectiveParent, name then report node
