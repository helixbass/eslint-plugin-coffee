{default: docsUrl} = require 'eslint-plugin-import/lib/docsUrl'

module.exports =
  meta:
    type: 'suggestion'
    docs: url: docsUrl 'no-named-export'

  create: (context) ->
    # ignore non-modules
    # TODO: this is the only change that was necessary for overriding this rule,
    # should this be getting set by us somehow?
    # return {} unless context.parserOptions.sourceType is 'module'

    message = 'Named exports are not allowed.'

    ExportAllDeclaration: (node) -> context.report {node, message}

    ExportNamedDeclaration: (node) ->
      return context.report {node, message} if node.specifiers.length is 0

      someNamed = node.specifiers.some (specifier) ->
        specifier.exported.name isnt 'default'
      if someNamed then context.report {node, message}
