###*
# @fileoverview Rule to disallow anonymous default exports.
# @author Duncan Beevers
###

# import docsUrl from '../docsUrl'
docsUrl = -> ''
{flow, map: fmap, fromPairs: ffromPairs} = require 'lodash/fp'

defs =
  ArrayExpression:
    option: 'allowArray'
    description: 'If `false`, will report default export of an array'
    message: 'Assign array to a variable before exporting as module default'
  ArrowFunctionExpression:
    option: 'allowArrowFunction'
    description: 'If `false`, will report default export of an arrow function'
    message:
      'Assign arrow function to a variable before exporting as module default'
  CallExpression:
    option: 'allowCallExpression'
    description: 'If `false`, will report default export of a function call'
    message:
      'Assign call result to a variable before exporting as module default'
    default: yes
  ClassDeclaration:
    option: 'allowAnonymousClass'
    description: 'If `false`, will report default export of an anonymous class'
    message: 'Unexpected default export of anonymous class'
    forbid: (node) -> not node.declaration.id
  FunctionDeclaration:
    option: 'allowAnonymousFunction'
    description:
      'If `false`, will report default export of an anonymous function'
    message: 'Unexpected default export of anonymous function'
    forbid: (node) -> not node.declaration.id
  FunctionExpression:
    option: 'allowAnonymousFunction'
    description:
      'If `false`, will report default export of an anonymous function'
    message: 'Unexpected default export of anonymous function'
    forbid: (node) -> not node.declaration.id
  Literal:
    option: 'allowLiteral'
    description: 'If `false`, will report default export of a literal'
    message: 'Assign literal to a variable before exporting as module default'
  ObjectExpression:
    option: 'allowObject'
    description:
      'If `false`, will report default export of an object expression'
    message: 'Assign object to a variable before exporting as module default'
  TemplateLiteral:
    option: 'allowLiteral'
    description: 'If `false`, will report default export of a literal'
    message: 'Assign literal to a variable before exporting as module default'

schemaProperties =
  flow(
    fmap ({option, description}) -> [option, {description, type: 'boolean'}]
    ffromPairs
  ) defs

defaults =
  flow(
    fmap ({option, default: defaultVal}) -> [option, defaultVal ? no]
    ffromPairs
  ) defs

module.exports =
  meta:
    docs:
      url: docsUrl('no-anonymous-default-export')

    schema: [
      type: 'object'
      properties: schemaProperties
      additionalProperties: no
    ]

  create: (context) ->
    options = Object.assign {}, defaults, context.options[0]

    ExportDefaultDeclaration: (node) ->
      def = defs[node.declaration.type]

      # Recognized node type and allowed by configuration,
      #   and has no forbid check, or forbid check return value is truthy
      if def and not options[def.option] and (not def.forbid or def.forbid node)
        context.report {node, message: def.message}
