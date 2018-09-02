###*
# @fileoverview Rule to flag non-camelcased identifiers
# @author Nicholas C. Zakas
###

'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'enforce camelcase naming convention'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/camelcase'

    schema: [
      type: 'object'
      properties:
        ignoreDestructuring:
          type: 'boolean'
        properties:
          enum: ['always', 'never']
      additionalProperties: no
    ]

    messages:
      notCamelCase: "Identifier '{{name}}' is not in camel case."

  create: (context) ->
    #--------------------------------------------------------------------------
    # Helpers
    #--------------------------------------------------------------------------

    # contains reported nodes to avoid reporting twice on destructuring with shorthand notation
    reported = []
    ALLOWED_PARENT_TYPES = new Set ['CallExpression', 'NewExpression']

    ###*
    # Checks if a string contains an underscore and isn't all upper-case
    # @param {string} name The string to check.
    # @returns {boolean} if the string is underscored
    # @private
    ###
    isUnderscored = (name) ->
      # if there's an underscore, it might be A_CONSTANT, which is okay
      name.indexOf('_') > -1 and name isnt name.toUpperCase()

    ###*
    # Checks if a parent of a node is an ObjectPattern.
    # @param {ASTNode} node The node to check.
    # @returns {boolean} if the node is inside an ObjectPattern
    # @private
    ###
    isInsideObjectPattern = (node) ->
      {parent} = node

      while parent
        return yes if parent.type is 'ObjectPattern'

        {parent} = parent

      no

    ###*
    # Reports an AST node as a rule violation.
    # @param {ASTNode} node The node to report.
    # @returns {void}
    # @private
    ###
    report = (node) ->
      if reported.indexOf(node) < 0
        reported.push node
        context.report {node, messageId: 'notCamelCase', data: name: node.name}

    options = context.options[0] or {}
    properties = options.properties or ''
    ignoreDestructuring = options.ignoreDestructuring or no

    if properties isnt 'always' and properties isnt 'never'
      properties = 'always'

    Identifier: (node) ->
      ###
      # Leading and trailing underscores are commonly used to flag
      # private/protected identifiers, strip them
      ###
      name = node.name.replace /^_+|_+$/g, ''
      effectiveParent =
        if node.parent.type is 'MemberExpression'
          node.parent.parent
        else
          node.parent

      # MemberExpressions get special rules
      if node.parent.type is 'MemberExpression'
        # "never" check properties
        return if properties is 'never'

        # Always report underscored object names
        if (
          node.parent.object.type is 'Identifier' and
          node.parent.object.name is node.name and
          isUnderscored name
        )
          report node

          # Report AssignmentExpressions only if they are the left side of the assignment
        else if (
          effectiveParent.type is 'AssignmentExpression' and
          isUnderscored(name) and
          (effectiveParent.right.type isnt 'MemberExpression' or
            (effectiveParent.left.type is 'MemberExpression' and
              effectiveParent.left.property.name is node.name))
        )
          report node

        ###
        # Properties have their own rules, and
        # AssignmentPattern nodes can be treated like Properties:
        # e.g.: const { no_camelcased = false } = bar;
        ###
      else if node.parent.type in ['Property', 'AssignmentPattern']
        if node.parent.parent and node.parent.parent.type is 'ObjectPattern'
          if (
            node.parent.shorthand and
            node.parent.value.left and
            isUnderscored name
          )
            report node

          assignmentKeyEqualsValue =
            node.parent.key.name is node.parent.value.name

          # prevent checking righthand side of destructured object
          return if node.parent.key is node and node.parent.value isnt node

          valueIsUnderscored = node.parent.value.name and isUnderscored name

          # ignore destructuring if the option is set, unless a new identifier is created
          if (
            valueIsUnderscored and
            not (assignmentKeyEqualsValue and ignoreDestructuring)
          )
            report node

        # "never" check properties or always ignore destructuring
        return if (
          properties is 'never' or
          (ignoreDestructuring and isInsideObjectPattern node)
        )

        # don't check right hand side of AssignmentExpression to prevent duplicate warnings
        if (
          isUnderscored(name) and
          not ALLOWED_PARENT_TYPES.has(effectiveParent.type) and
          not (node.parent.right is node)
        )
          report node

        # Check if it's an import specifier
      else if (
        [
          'ImportSpecifier'
          'ImportNamespaceSpecifier'
          'ImportDefaultSpecifier'
        ].indexOf(node.parent.type) >= 0
      )
        # Report only if the local imported identifier is underscored
        if (
          node.parent.local and
          node.parent.local.name is node.name and
          isUnderscored name
        )
          report node

        # Report anything that is underscored that isn't a CallExpression
      else if (
        isUnderscored(name) and
        not ALLOWED_PARENT_TYPES.has effectiveParent.type
      )
        report node
