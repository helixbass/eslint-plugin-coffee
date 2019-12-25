{default: declaredScope} = require 'eslint-module-utils/declaredScope'
{default: Exports} = require '../eslint-plugin-import-export-map'
{default: docsUrl} = require 'eslint-plugin-import/lib/docsUrl'

message = (deprecation) ->
  "Deprecated#{
    if deprecation.description
      ": #{deprecation.description}"
    else
      '.'
  }"

getDeprecation = (metadata) ->
  return unless metadata?.doc

  deprecation = null
  return deprecation if metadata.doc.tags.some (t) ->
    t.title is 'deprecated' and (deprecation = t)

module.exports =
  meta:
    type: 'suggestion'
    docs:
      url: docsUrl 'no-deprecated'

  create: (context) ->
    deprecated = new Map()
    namespaces = new Map()

    checkSpecifiers = (node) ->
      unless node.type is 'ImportDeclaration' then return
      return unless node.source? # local export, ignore
      imports = Exports.get node.source.value, context
      return unless imports?

      moduleDeprecation = null
      if imports.doc?.tags.some((t) ->
        t.title is 'deprecated' and (moduleDeprecation = t)
      )
        context.report {node, message: message moduleDeprecation}

      if imports.errors.length
        imports.reportErrors context, node
        return

      node.specifiers.forEach (im) ->
        switch im.type
          when 'ImportNamespaceSpecifier'
            unless imports.size then return
            namespaces.set im.local.name, imports
            return

          when 'ImportDefaultSpecifier'
            imported = 'default'
            local = im.local.name

          when 'ImportSpecifier'
            imported = im.imported.name
            local = im.local.name

          else
            return # can't handle this one

        # unknown thing can't be deprecated
        exported = imports.get imported
        return unless exported?

        # capture import of deep namespace
        if exported.namespace then namespaces.set local, exported.namespace

        deprecation = getDeprecation imports.get imported
        unless deprecation then return

        context.report node: im, message: message deprecation

        deprecated.set local, deprecation

    Program: ({body}) -> body.forEach checkSpecifiers

    Identifier: (node) ->
      # handled by MemberExpression
      return if (
        node.parent.type is 'MemberExpression' and node.parent.property is node
      )

      # ignore specifier identifiers
      if node.parent.type.slice(0, 6) is 'Import' then return

      unless deprecated.has node.name then return

      unless declaredScope(context, node.name) is 'module' then return
      context.report {
        node
        message: message deprecated.get node.name
      }

    MemberExpression: (dereference) ->
      unless dereference.object.type is 'Identifier' then return
      unless namespaces.has dereference.object.name then return

      unless declaredScope(context, dereference.object.name) is 'module'
        return

      # go deep
      namespace = namespaces.get dereference.object.name
      namepath = [dereference.object.name]
      # while property is namespace and parent is member expression, keep validating
      while (
        namespace instanceof Exports and dereference.type is 'MemberExpression'
      )
        # ignore computed parts for now
        if dereference.computed then return

        metadata = namespace.get dereference.property.name

        unless metadata then break
        deprecation = getDeprecation metadata

        if deprecation
          context.report
            node: dereference.property, message: message deprecation

        # stash and pop
        namepath.push dereference.property.name
        {namespace} = metadata
        dereference = dereference.parent
