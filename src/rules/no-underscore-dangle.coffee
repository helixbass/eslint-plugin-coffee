###*
# @fileoverview Rule to flag trailing underscores in variable declarations.
# @author Matt DuVall <http://www.mattduvall.com>
###

'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow dangling underscores in identifiers'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-underscore-dangle'

    schema: [
      type: 'object'
      properties:
        allow:
          type: 'array'
          items:
            type: 'string'
        allowAfterThis:
          type: 'boolean'
        allowAfterSuper:
          type: 'boolean'
        enforceInMethodNames:
          type: 'boolean'
      additionalProperties: no
    ]

  create: (context) ->
    options = context.options[0] or {}
    ALLOWED_VARIABLES = if options.allow then options.allow else []
    allowAfterThis =
      unless typeof options.allowAfterThis is 'undefined'
        options.allowAfterThis
      else
        no
    allowAfterSuper =
      unless typeof options.allowAfterSuper is 'undefined'
        options.allowAfterSuper
      else
        no
    enforceInMethodNames =
      unless typeof options.enforceInMethodNames is 'undefined'
        options.enforceInMethodNames
      else
        no

    #-------------------------------------------------------------------------
    # Helpers
    #-------------------------------------------------------------------------

    ###*
    # Check if identifier is present inside the allowed option
    # @param {string} identifier name of the node
    # @returns {boolean} true if its is present
    # @private
    ###
    isAllowed = (identifier) ->
      ALLOWED_VARIABLES.some (ident) -> ident is identifier

    ###*
    # Check if identifier has a underscore at the end
    # @param {ASTNode} identifier node to evaluate
    # @returns {boolean} true if its is present
    # @private
    ###
    hasTrailingUnderscore = (identifier) ->
      len = identifier.length

      identifier isnt '_' and
        (identifier[0] is '_' or identifier[len - 1] is '_')

    ###*
    # Check if identifier is a special case member expression
    # @param {ASTNode} identifier node to evaluate
    # @returns {boolean} true if its is a special case
    # @private
    ###
    isSpecialCaseIdentifierForMemberExpression = (identifier) ->
      identifier is '__proto__'

    ###*
    # Check if identifier is a special case variable expression
    # @param {ASTNode} identifier node to evaluate
    # @returns {boolean} true if its is a special case
    # @private
    ###
    isSpecialCaseIdentifierInVariableExpression = (identifier) ->
      # Checks for the underscore library usage here
      identifier is '_'

    ###*
    # Check if function has a underscore at the end
    # @param {ASTNode} node node to evaluate
    # @returns {void}
    # @private
    ###
    checkForTrailingUnderscoreInFunctionDeclaration = (node) ->
      if node.id
        identifier = node.id.name

        if (
          typeof identifier isnt 'undefined' and
          hasTrailingUnderscore(identifier) and
          not isAllowed identifier
        )
          context.report {
            node
            message: "Unexpected dangling '_' in '{{identifier}}'."
            data: {
              identifier
            }
          }

    checkForTrailingUnderscoreInIdentifier = (node) ->
      return unless node.declaration
      identifier = node.name

      if (
        hasTrailingUnderscore(identifier) and
        not isSpecialCaseIdentifierInVariableExpression(identifier) and
        not isAllowed identifier
      )
        context.report {
          node
          message: "Unexpected dangling '_' in '{{identifier}}'."
          data: {
            identifier
          }
        }

    ###*
    # Check if variable expression has a underscore at the end
    # @param {ASTNode} node node to evaluate
    # @returns {void}
    # @private
    ###
    checkForTrailingUnderscoreInVariableExpression = (node) ->
      identifier = node.id.name

      if (
        typeof identifier isnt 'undefined' and
        hasTrailingUnderscore(identifier) and
        not isSpecialCaseIdentifierInVariableExpression(identifier) and
        not isAllowed identifier
      )
        context.report {
          node
          message: "Unexpected dangling '_' in '{{identifier}}'."
          data: {
            identifier
          }
        }

    ###*
    # Check if member expression has a underscore at the end
    # @param {ASTNode} node node to evaluate
    # @returns {void}
    # @private
    ###
    checkForTrailingUnderscoreInMemberExpression = (node) ->
      identifier = node.property.name
      isMemberOfThis = node.object.type is 'ThisExpression'
      isMemberOfSuper = node.object.type is 'Super'

      if (
        typeof identifier isnt 'undefined' and
        hasTrailingUnderscore(identifier) and
        not (isMemberOfThis and allowAfterThis) and
        not (isMemberOfSuper and allowAfterSuper) and
        not isSpecialCaseIdentifierForMemberExpression(identifier) and
        not isAllowed identifier
      )
        context.report {
          node
          message: "Unexpected dangling '_' in '{{identifier}}'."
          data: {
            identifier
          }
        }

    ###*
    # Check if method declaration or method property has a underscore at the end
    # @param {ASTNode} node node to evaluate
    # @returns {void}
    # @private
    ###
    checkForTrailingUnderscoreInMethod = (node) ->
      identifier = node.key.name
      isMethod =
        node.type is 'MethodDefinition' or
        (node.type is 'Property' and
          (node.method or node.value.type is 'FunctionExpression'))

      if (
        typeof identifier isnt 'undefined' and
        enforceInMethodNames and
        isMethod and
        hasTrailingUnderscore identifier
      )
        context.report {
          node
          message: "Unexpected dangling '_' in '{{identifier}}'."
          data: {
            identifier
          }
        }

    #--------------------------------------------------------------------------
    # Public API
    #--------------------------------------------------------------------------

    FunctionDeclaration: checkForTrailingUnderscoreInFunctionDeclaration
    VariableDeclarator: checkForTrailingUnderscoreInVariableExpression
    Identifier: checkForTrailingUnderscoreInIdentifier
    MemberExpression: checkForTrailingUnderscoreInMemberExpression
    MethodDefinition: checkForTrailingUnderscoreInMethod
    Property: checkForTrailingUnderscoreInMethod
