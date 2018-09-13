###*
# @fileoverview Rule to prefer ES6 to CJS
# @author Jamund Ferguson
###

# import docsUrl from '../docsUrl'

EXPORT_MESSAGE = 'Expected "export" or "export default"'
IMPORT_MESSAGE = 'Expected "import" instead of "require()"'

normalizeLegacyOptions = (options) ->
  return allowPrimitiveModules: yes if (
    options.indexOf('allow-primitive-modules') >= 0
  )
  options[0] or {}

allowPrimitive = (node, options) ->
  return no unless options.allowPrimitiveModules
  return no unless (
    node.parent.type is 'AssignmentExpression' and node is node.parent.left
  )
  node.parent.right.type isnt 'ObjectExpression'

allowRequire = (node, options) -> options.allowRequire

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

schemaString = enum: ['allow-primitive-modules']
schemaObject =
  type: 'object'
  properties:
    allowPrimitiveModules: type: 'boolean'
    allowRequire: type: 'boolean'
  additionalProperties: no

module.exports =
  meta:
    docs:
      # url: docsUrl 'no-commonjs'
      url: ''

    schema:
      anyOf: [
        type: 'array'
        items: [schemaString]
        additionalItems: no
      ,
        type: 'array'
        items: [schemaObject]
        additionalItems: no
      ]

  create: (context) ->
    options = normalizeLegacyOptions context.options

    MemberExpression: (node) ->
      # module.exports
      if node.object.name is 'module' and node.property.name is 'exports'
        return if allowPrimitive node, options
        context.report {node, message: EXPORT_MESSAGE}

      # exports.
      if node.object.name is 'exports'
        isInScope = context
        .getScope()
        .variables.some (variable) -> variable.name is 'exports'
        context.report {node, message: EXPORT_MESSAGE} unless isInScope
    CallExpression: (call) ->
      return unless context.getScope().type is 'module'
      return unless (
        call.parent.type in [
          'ExpressionStatement'
          'VariableDeclarator'
          'AssignmentExpression'
        ]
      )

      return unless call.callee.type is 'Identifier'
      return unless call.callee.name is 'require'

      return unless call.arguments.length is 1
      module = call.arguments[0]

      return unless module.type is 'Literal'
      return unless typeof module.value is 'string'

      return if allowRequire call, options

      # keeping it simple: all 1-string-arg `require` calls are reported
      context.report
        node: call.callee
        message: IMPORT_MESSAGE
