###*
# @fileoverview Enforces capitalized class names.
# @author Julian Rosse
###
'use strict'

capitalizedRegex = /^_*[A-Z]/
isCapitalized = (name) -> capitalizedRegex.test name

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'enforce capitalized names for classes'
      category: 'Stylistic Issues'
      recommended: no
      # url: 'https://eslint.org/docs/rules/object-curly-spacing'

    schema: []

  create: (context) ->
    checkClass = (node) ->
      return unless node.id

      currentName = node.id
      # eslint-disable-next-line coffee/no-constant-condition
      loop
        switch currentName.type
          when 'Identifier'
            context.report {
              node
              message: 'Class names should be capitalized.'
            } unless isCapitalized currentName.name
            return
          when 'MemberExpression'
            currentName = currentName.property
          else
            return

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    ClassDeclaration: checkClass
    ClassExpression: checkClass
