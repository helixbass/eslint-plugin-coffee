###*
# @fileoverview This rule monitors usage of shorthand `@` for `this`
# @author Julian Rosse
###
'use strict'

isProperty = (node) ->
  {parent} = node
  parent.type is 'MemberExpression' and node is parent.object

isThisParam = (node) ->
  return no unless isProperty node
  {parent} = node
  parent.parent.type is 'FunctionExpression' and parent in parent.parent.params

isObjectShorthand = (node) ->
  return no unless isProperty node
  {parent} = node
  parent.parent.type is 'Property' and parent.parent.shorthand

isStaticProperty = (node) ->
  {parent} = node
  parent?.type is 'ClassProperty' and node is parent.staticClassName

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'monitor usage of shorthand "@" for "this"'
      category: 'Stylistic Issues'
      recommended: no
      # url: 'https://eslint.org/docs/rules/space-unary-ops'

    schema: [
      enum: ['always', 'never', 'allow']
    ,
      type: 'object'
      properties:
        forbidStandalone: type: 'boolean'
      additionalProperties: no
    ]

  create: (context) ->
    allowed = context.options?[0] ? 'always'
    {forbidStandalone} = context.options?[1] ? {}
    forbidLonghand = allowed is 'always'
    forbidLonghandStandalone = forbidLonghand and not forbidStandalone
    forbidShorthand = allowed is 'never'

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    ThisExpression: (node) ->
      isShorthand = !!node.shorthand
      isStandalone = not isProperty node
      return if (
        isThisParam(node) or
        isObjectShorthand(node) or
        isStaticProperty node
      )
      if isShorthand
        if forbidShorthand
          context.report {
            node
            message: "Use 'this' instead of '@'"
          }
          return
        if isStandalone and forbidStandalone
          context.report {
            node
            message: "Use 'this' instead of standalone '@'"
          }
      else if (
        (isStandalone and forbidLonghandStandalone) or
        (not isStandalone and forbidLonghand)
      )
        context.report {
          node
          message: "Use '@' instead of 'this'"
        }
