###*
# @fileoverview Rule to enforce concise object methods and properties.
# @author Jamund Ferguson
###

'use strict'

OPTIONS =
  always: 'always'
  never: 'never'
  consistent: 'consistent'
  consistentAsNeeded: 'consistent-as-needed'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------
astUtils = require '../eslint-ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------
module.exports =
  meta:
    docs:
      description:
        'require or disallow property shorthand syntax for object literals'
      category: 'ECMAScript 6'
      recommended: no
      url: 'https://eslint.org/docs/rules/object-shorthand'

    schema:
      anyOf: [
        type: 'array'
        items: [enum: ['always', 'never', 'consistent', 'consistent-as-needed']]
        minItems: 0
        maxItems: 1
      ]

  create: (context) ->
    APPLY = context.options[0]
    APPLY_NEVER = APPLY is OPTIONS.never
    APPLY_CONSISTENT = APPLY is OPTIONS.consistent
    APPLY_CONSISTENT_AS_NEEDED = APPLY is OPTIONS.consistentAsNeeded
    APPLY_PROPERTIES = not APPLY or APPLY is OPTIONS.always

    #--------------------------------------------------------------------------
    # Helpers
    #--------------------------------------------------------------------------

    ###*
    # Determines if the property can have a shorthand form.
    # @param {ASTNode} property Property AST node
    # @returns {boolean} True if the property can have a shorthand form
    # @private
    #
    ###
    canHaveShorthand = (property) ->
      property.kind isnt 'set' and
      property.kind isnt 'get' and
      property.type isnt 'SpreadElement'

    ###*
    # Determines if the property is a shorthand or not.
    # @param {ASTNode} property Property AST node
    # @returns {boolean} True if the property is considered shorthand, false if not.
    # @private
    #
    ###
    isShorthand = (property) ->
      property.shorthand

    ###*
    # Determines if the property's key and method or value are named equally.
    # @param {ASTNode} property Property AST node
    # @returns {boolean} True if the key and value are named equally, false if not.
    # @private
    #
    ###
    isRedundant = (property) ->
      {value} = property

      return no unless value.type is 'Identifier'
      return astUtils.getStaticPropertyName(property) is value.name

    ###*
    # Ensures that an object's properties are consistently shorthand, or not shorthand at all.
    # @param   {ASTNode} node Property AST node
    # @param   {boolean} checkRedundancy Whether to check longform redundancy
    # @returns {void}
    #
    ###
    checkConsistency = (node, checkRedundancy) ->
      # We are excluding getters/setters and spread properties as they are considered neither longform nor shorthand.
      properties = node.properties.filter canHaveShorthand

      # Do we still have properties left after filtering the getters and setters?
      if properties.length > 0
        shorthandProperties = properties.filter isShorthand

        ###
        # If we do not have an equal number of longform properties as
        # shorthand properties, we are using the annotations inconsistently
        ###
        unless shorthandProperties.length is properties.length
          # We have at least 1 shorthand property
          if shorthandProperties.length > 0
            context.report {
              node
              message:
                'Unexpected mix of shorthand and non-shorthand properties.'
            }
          else if checkRedundancy
            ###
            # If all properties of the object contain a method or value with a name matching it's key,
            # all the keys are redundant.
            ###
            canAlwaysUseShorthand = properties.every isRedundant

            if canAlwaysUseShorthand
              context.report {
                node
                message: 'Expected shorthand for all properties.'
              }

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    ObjectExpression: (node) ->
      if APPLY_CONSISTENT
        checkConsistency node, no
      else if APPLY_CONSISTENT_AS_NEEDED
        checkConsistency node, yes

    'Property:exit': (node) ->
      isConciseProperty = node.shorthand

      # Ignore destructuring assignment
      return if node.parent.type is 'ObjectPattern'

      # getters and setters are ignored
      return if node.kind in ['get', 'set']

      # only computed methods can fail the following checks
      return if node.computed

      #--------------------------------------------------------------
      # Checks for property/method shorthand.
      if isConciseProperty
        if APPLY_NEVER
          # { x } should be written as { x: x }
          context.report {
            node
            message: 'Expected longform property syntax.'
          }
      else if (
        node.value.type is 'Identifier' and
        node.key.name is node.value.name and
        APPLY_PROPERTIES
      )
        # {x: x} should be written as {x}
        context.report {
          node
          message: 'Expected property shorthand.'
        }
      else if (
        node.value.type is 'Identifier' and
        node.key.type is 'Literal' and
        node.key.value is node.value.name and
        APPLY_PROPERTIES
      )
        # {"x": x} should be written as {x}
        context.report {
          node
          message: 'Expected property shorthand.'
        }
