{default: declaredScope} = require 'eslint-module-utils/declaredScope'
{default: Exports} = require '../eslint-plugin-import-export-map'
{
  default: importDeclaration
} = require 'eslint-plugin-import/lib/importDeclaration'
{default: docsUrl} = require 'eslint-plugin-import/lib/docsUrl'

module.exports =
  meta:
    type: 'problem'
    docs:
      url: docsUrl 'namespace'

    schema: [
      type: 'object'
      properties:
        allowComputed:
          description:
            'If `false`, will report computed (and thus, un-lintable) references ' +
            'to namespace members.'
          type: 'boolean'
          default: no
      additionalProperties: no
    ]

  create: (context) ->
    # read options
    {allowComputed = no} = context.options[0] or {}

    namespaces = new Map()

    makeMessage = (last, namepath) ->
      "'#{last.name}' not found in #{
        if namepath.length > 1
          'deeply '
        else
          ''
      }imported namespace '#{namepath.join '.'}'."

    # DFS traverse child namespaces
    testKey = (pattern, namespace, path) ->
      unless namespace instanceof Exports then return

      unless pattern.type is 'ObjectPattern' then return

      for property from pattern.properties
        if (
          property.type in ['ExperimentalRestProperty', 'RestElement'] or
          not property.key
        )
          continue

        unless property.key.type is 'Identifier'
          context.report
            node: property
            message: 'Only destructure top-level names.'
          continue

        unless namespace.has property.key.name
          context.report
            node: property
            message: makeMessage property.key, path
          continue

        path.push property.key.name
        dependencyExportMap = namespace.get property.key.name
        # could be null when ignored or ambiguous
        unless dependencyExportMap is null
          testKey property.value, dependencyExportMap.namespace, path
        path.pop()

    # pick up all imports at body entry time, to properly respect hoisting
    Program: ({body}) ->
      processBodyStatement = (declaration) ->
        unless declaration.type is 'ImportDeclaration' then return

        if declaration.specifiers.length is 0 then return

        imports = Exports.get declaration.source.value, context
        return null unless imports?

        if imports.errors.length
          imports.reportErrors context, declaration
          return

        for specifier from declaration.specifiers then switch specifier.type
          when 'ImportNamespaceSpecifier'
            unless imports.size
              context.report(
                specifier
                "No exported names found in module '#{
                  declaration.source.value
                }'."
              )
            namespaces.set specifier.local.name, imports
          when 'ImportDefaultSpecifier', 'ImportSpecifier'
            meta = imports.get(
              # default to 'default' for default http://i.imgur.com/nj6qAWy.jpg
              if specifier.imported then specifier.imported.name else 'default'
            )
            break unless meta?.namespace
            namespaces.set specifier.local.name, meta.namespace
      body.forEach processBodyStatement

    # same as above, but does not add names to local map
    ExportNamespaceSpecifier: (namespace) ->
      declaration = importDeclaration context

      imports = Exports.get declaration.source.value, context
      return null unless imports?

      if imports.errors.length
        imports.reportErrors context, declaration
        return

      unless imports.size
        context.report(
          namespace
          "No exported names found in module '#{declaration.source.value}'."
        )

    # todo: check for possible redefinition

    MemberExpression: (dereference) ->
      unless dereference.object.type is 'Identifier' then return
      unless namespaces.has dereference.object.name then return

      if (
        dereference.parent.type is 'AssignmentExpression' and
        dereference.parent.left is dereference
      )
        context.report(
          dereference.parent
          "Assignment to member of namespace '#{dereference.object.name}'."
        )

      # go deep
      namespace = namespaces.get dereference.object.name
      namepath = [dereference.object.name]
      # while property is namespace and parent is member expression, keep validating
      while (
        namespace instanceof Exports and dereference.type is 'MemberExpression'
      )
        if dereference.computed
          unless allowComputed
            context.report(
              dereference.property
              "Unable to validate computed reference to imported namespace '#{
                dereference.object.name
              }'."
            )
          return

        unless namespace.has dereference.property.name
          context.report(
            dereference.property
            makeMessage dereference.property, namepath
          )
          break

        exported = namespace.get dereference.property.name
        return unless exported?

        # stash and pop
        namepath.push dereference.property.name
        {namespace} = exported
        dereference = dereference.parent

    VariableDeclarator: ({id, init}) ->
      return unless init?
      return unless init.type is 'Identifier'
      return unless namespaces.has init.name

      # check for redefinition in intermediate scopes
      return unless declaredScope(context, init.name) is 'module'

      testKey id, namespaces.get(init.name), [init.name]

    AssignmentExpression: ({left, right}) ->
      return unless right.type is 'Identifier'
      return unless namespaces.has right.name

      # check for redefinition in intermediate scopes
      return unless declaredScope(context, right.name) is 'module'

      testKey left, namespaces.get(right.name), [right.name]

    JSXMemberExpression: ({object, property}) ->
      unless namespaces.has object.name then return
      namespace = namespaces.get object.name
      unless namespace.has property.name
        context.report
          node: property
          message: makeMessage property, [object.name]
