module.exports =
  meta:
    docs: {}

  create: (context) ->
    # ignore non-modules
    # return {} unless context.parserOptions.sourceType is 'module'

    preferNamed = 'Prefer named exports.'
    noAliasDefault = ({local}) ->
      "Do not alias `#{local.name}` as `default`. Just export " +
      "`#{local.name}` itself instead."

    ExportDefaultDeclaration: (node) ->
      context.report {node, message: preferNamed}

    ExportNamedDeclaration: (node) ->
      node.specifiers.forEach (specifier) ->
        if (
          specifier.type is 'ExportDefaultSpecifier' and
          specifier.exported.name is 'default'
        )
          context.report {node, message: preferNamed}
        else if (
          specifier.type is 'ExportSpecifier' and
          specifier.exported.name is 'default'
        )
          context.report {node, message: noAliasDefault specifier}
