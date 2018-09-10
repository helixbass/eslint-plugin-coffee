{
  default: ExportMap
  recursivePatternCapture
} = require 'eslint-plugin-import/lib/ExportMap'
# import docsUrl from '../docsUrl'

module.exports =
  meta:
    docs:
      # url: docsUrl 'export'
      url: ''

  create: (context) ->
    named = new Map()

    addNamed = (name, node) ->
      nodes = named.get name

      unless nodes?
        nodes = new Set()
        named.set name, nodes

      nodes.add node

    ExportDefaultDeclaration: (node) -> addNamed 'default', node

    ExportSpecifier: (node) -> addNamed node.exported.name, node.exported

    ExportNamedDeclaration: (node) ->
      return unless node.declaration?

      if node.declaration.id?
        addNamed node.declaration.id.name, node.declaration.id

      if node.declaration.declarations?
        for declaration from node.declaration.declarations
          recursivePatternCapture declaration.id, (v) ->
            addNamed v.name, v

      if node.declaration.type is 'AssignmentExpression'
        recursivePatternCapture node.declaration.left, (v) ->
          addNamed v.name, v

    ExportAllDeclaration: (node) ->
      return unless node.source? # not sure if this is ever true
      remoteExports = ExportMap.get node.source.value, context
      return unless remoteExports?

      if remoteExports.errors.length
        remoteExports.reportErrors context, node
        return
      any = no
      remoteExports.forEach (
        v
        name # poor man's filter
      ) -> name isnt 'default' and (any ###:### = yes) and addNamed name, node

      unless any
        context.report(
          node.source
          "No named exports found in module '#{node.source.value}'."
        )

    'Program:exit': ->
      for [name, nodes] from named when nodes.size > 1
        for node from nodes
          if name is 'default'
            context.report node, 'Multiple default exports.'
          else
            context.report node, "Multiple exports of name '#{name}'."
