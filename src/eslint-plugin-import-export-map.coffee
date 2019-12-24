fs = require 'fs'

{default: doctrine} = require 'doctrine'

{default: debug} = require 'debug'

{SourceCode} = require 'eslint'

{default: parse} = require 'eslint-module-utils/parse'
{default: resolve} = require 'eslint-module-utils/resolve'
{default: isIgnored, hasValidExtension} = require 'eslint-module-utils/ignore'

{hashObject} = require 'eslint-module-utils/hash'
unambiguous = require 'eslint-module-utils/unambiguous'

log = debug 'eslint-plugin-import:ExportMap'

exportCache = new Map()

class ExportMap
  constructor: (path) ->
    @path = path
    @namespace = new Map()
    # todo: restructure to key on path, value is resolver + map of names
    @reexports = new Map()
    ###*
    # star-exports
    # @type {Set} of () => ExportMap
    ###
    @dependencies = new Set()
    ###*
    # dependencies of this module that are not explicitly re-exported
    # @type {Map} from path = () => ExportMap
    ###
    @imports = new Map()
    @errors = []

  hasDefault: -> @get('default')? # stronger than this.has
  size: ->
    size = @namespace.size + @reexports.size
    @dependencies.forEach (dep) ->
      d = dep()
      # CJS / ignored dependencies won't exist (#717)
      return unless d?
      size += d.size
    size

  ###*
  # Note that this does not check explicitly re-exported names for existence
  # in the base namespace, but it will expand all `export * from '...'` exports
  # if not found in the explicit namespace.
  # @param  {string}  name
  # @return {Boolean} true if `name` is exported by this module.
  ###
  has: (name) ->
    if @namespace.has name then return yes
    if @reexports.has name then return yes

    # default exports must be explicitly re-exported (#328)
    unless name is 'default'
      for dep from @dependencies
        innerMap = dep()

        # todo: report as unresolved?
        unless innerMap then continue

        if innerMap.has name then return yes

    no

  ###*
  # ensure that imported name fully resolves.
  # @param  {[type]}  name [description]
  # @return {Boolean}      [description]
  ###
  hasDeep: (name) ->
    if @namespace.has name then return found: yes, path: [@]

    if @reexports.has name
      reexports = @reexports.get name
      imported = reexports.getImport()

      # if import is ignored, return explicit 'null'
      return found: yes, path: [@] unless imported?

      # safeguard against cycles, only if name matches
      return found: no, path: [@] if (
        imported.path is @path and reexports.local is name
      )

      deep = imported.hasDeep reexports.local
      deep.path.unshift @

      return deep

    # default exports must be explicitly re-exported (#328)
    unless name is 'default'
      for dep from @dependencies
        innerMap = dep()
        # todo: report as unresolved?
        unless innerMap then continue

        # safeguard against cycles
        if innerMap.path is @path then continue

        innerValue = innerMap.hasDeep name
        if innerValue.found
          innerValue.path.unshift @
          return innerValue

    found: no, path: [@]

  get: (name) ->
    if @namespace.has name then return @namespace.get name

    if @reexports.has name
      reexports = @reexports.get name
      imported = reexports.getImport()

      # if import is ignored, return explicit 'null'
      return null unless imported?

      # safeguard against cycles, only if name matches
      if imported.path is @path and reexports.local is name
        return undefined

      return imported.get reexports.local

    # default exports must be explicitly re-exported (#328)
    unless name is 'default'
      for dep from @dependencies
        innerMap = dep()
        # todo: report as unresolved?
        unless innerMap then continue

        # safeguard against cycles
        if innerMap.path is @path then continue

        innerValue = innerMap.get name
        unless innerValue is undefined then return innerValue

    undefined

  forEach: (callback, thisArg) ->
    @namespace.forEach (v, n) -> callback.call thisArg, v, n, @

    @reexports.forEach (reexports, name) ->
      reexported = reexports.getImport()
      # can't look up meta for ignored re-exports (#348)
      callback.call thisArg, reexported?.get(reexports.local), name, @

    @dependencies.forEach (dep) ->
      d = dep()
      # CJS / ignored dependencies won't exist (#717)
      return unless d?

      d.forEach (v, n) -> n isnt 'default' and callback.call thisArg, v, n, @

  # todo: keys, values, entries?

  reportErrors: (context, declaration) ->
    getErrorLineNumber = (e) ->
      return e.lineNumber if e.lineNumber?
      return unless e.location?
      e.location.first_line + 1

    getErrorColumnNumber = (e) ->
      return e.column if e.column?
      return unless e.location?
      e.location.first_column + 1

    context.report
      node: declaration.source
      message:
        "Parse errors in imported module '#{declaration.source.value}': " +
        "#{@errors
        .map (e) ->
          "#{e.message} (#{getErrorLineNumber e}:#{getErrorColumnNumber e})"
        .join ', '}"

###*
# parse docs from the first node that has leading comments
###
captureDoc = (source, docStyleParsers, ...nodes) ->
  metadata = {}

  # 'some' short-circuits on first 'true'
  nodes.some (n) ->
    try
      # n.leadingComments is legacy `attachComments` behavior
      if 'leadingComments' of n
        {leadingComments} = n
      else if n.range
        leadingComments = source.getCommentsBefore n

      if not leadingComments or leadingComments.length is 0 then return no

      for name, docStyleParser of docStyleParsers
        doc = docStyleParser leadingComments
        if doc then metadata.doc = doc

      return yes
    catch err then return no

  metadata

availableDocStyleParsers =
  jsdoc: captureJsDoc
  tomdoc: captureTomDoc

###*
# parse JSDoc from leading comments
# @param  {...[type]} comments [description]
# @return {{doc: object}}
###
captureJsDoc = (comments) ->
  doc = undefined

  # capture XSDoc
  comments.forEach (comment) ->
    # skip non-block comments
    unless comment.type is 'Block' then return
    try
      doc = doctrine.parse comment.value, unwrap: yes
    catch err
      ### don't care, for now? maybe add to `errors?` ###

  doc

###*
# parse TomDoc section from comments
###
captureTomDoc = (comments) ->
  # collect lines up to first paragraph break
  lines = []
  i = 0
  while i < comments.length
    comment = comments[i]
    if comment.value.match /^\s*$/ then break
    lines.push comment.value.trim()
    i++

  # return doctrine-like object
  statusMatch = lines.join(' ').match /^(Public|Internal|Deprecated):\s*(.+)/
  return {
    description: statusMatch[2]
    tags: [
      title: statusMatch[1].toLowerCase()
      description: statusMatch[2]
    ]
  } if statusMatch

ExportMap.get = (source, context) ->
  path = resolve source, context
  return null unless path?

  ExportMap.for childContext path, context

ExportMap.for = (context) ->
  {path} = context

  cacheKey = hashObject(context).digest 'hex'
  exportMap = exportCache.get cacheKey

  # return cached ignore
  if exportMap is null then return null

  stats = fs.statSync path
  if exportMap?
    # date equality check
    return exportMap if exportMap.mtime - stats.mtime is 0
    # future: check content equality?

  # check valid extensions first
  unless hasValidExtension path, context
    exportCache.set cacheKey, null
    return null

  # check for and cache ignore
  if isIgnored path, context
    log 'ignored path due to ignore settings:', path
    exportCache.set cacheKey, null
    return null

  content = fs.readFileSync path, encoding: 'utf8'

  # check for and cache unambigious modules
  unless unambiguous.test content
    log 'ignored path due to unambiguous regex:', path
    exportCache.set cacheKey, null
    return null

  log 'cache miss', cacheKey, 'for path', path
  exportMap = ExportMap.parse path, content, context

  # ambiguous modules return null
  return null unless exportMap?

  exportMap.mtime = stats.mtime

  exportCache.set cacheKey, exportMap
  exportMap

ExportMap.parse = (path, content, context) ->
  m = new ExportMap path

  try
    ast = parse path, content, context
  catch err
    log 'parse error:', path, err
    m.errors.push err
    return m # can't continue

  unless unambiguous.isModule ast then return null

  docstyle = context.settings?['import/docstyle'] or ['jsdoc']
  docStyleParsers = {}
  docstyle.forEach (style) ->
    docStyleParsers[style] = availableDocStyleParsers[style]

  # attempt to collect module doc
  if ast.comments
    ast.comments.some (c) ->
      unless c.type is 'Block' then return no
      try
        doc = doctrine.parse c.value, unwrap: yes
        if doc.tags.some((t) -> t.title is 'module')
          m.doc = doc
          return yes
      catch err
        ### ignore ###
      no

  namespaces = new Map()

  remotePath = (value) -> resolve.relative value, path, context.settings

  resolveImport = (value) ->
    rp = remotePath value
    return null unless rp?
    ExportMap.for childContext rp, context

  getNamespace = (identifier) ->
    unless namespaces.has identifier.name then return

    -> resolveImport namespaces.get identifier.name

  addNamespace = (object, identifier) ->
    nsfn = getNamespace identifier
    if nsfn then Object.defineProperty object, 'namespace', get: nsfn

    object

  captureDependency = (declaration) ->
    return null unless declaration.source?
    return null if declaration.importKind is 'type' # skip Flow type imports
    importedSpecifiers = new Set()
    supportedTypes = new Set [
      'ImportDefaultSpecifier'
      'ImportNamespaceSpecifier'
    ]
    hasImportedType = no
    if declaration.specifiers
      declaration.specifiers.forEach (specifier) ->
        isType = specifier.importKind is 'type'
        hasImportedType or= isType

        if supportedTypes.has(specifier.type) and not isType
          importedSpecifiers.add specifier.type
        if specifier.type is 'ImportSpecifier' and not isType
          importedSpecifiers.add specifier.imported.name

    # only Flow types were imported
    if hasImportedType and importedSpecifiers.size is 0 then return null

    p = remotePath declaration.source.value
    return null unless p?
    existing = m.imports.get p
    return existing.getter if existing?

    getter = thunkFor p, context
    m.imports.set p, {
      getter
      source:
        # capturing actual node reference holds full AST in memory!
        value: declaration.source.value
        loc: declaration.source.loc
      importedSpecifiers
    }
    getter

  source = makeSourceCode content, ast

  ast.body.forEach (n) ->
    if n.type is 'ExportDefaultDeclaration'
      exportMeta = captureDoc source, docStyleParsers, n
      if n.declaration.type is 'Identifier'
        addNamespace exportMeta, n.declaration
      m.namespace.set 'default', exportMeta
      return

    if n.type is 'ExportAllDeclaration'
      getter = captureDependency n
      if getter then m.dependencies.add getter
      return

    # capture namespaces in case of later export
    if n.type is 'ImportDeclaration'
      captureDependency n
      ns = null
      if n.specifiers.some((s) ->
        s.type is 'ImportNamespaceSpecifier' and (ns = s)
      )
        namespaces.set ns.local.name, n.source.value
      return

    if n.type is 'ExportNamedDeclaration'
      # capture declaration
      if n.declaration?
        switch n.declaration.type
          when 'FunctionDeclaration', 'ClassDeclaration', 'TypeAlias', 'InterfaceDeclaration', 'DeclareFunction', 'TSDeclareFunction', 'TSEnumDeclaration', 'TSTypeAliasDeclaration', 'TSInterfaceDeclaration', 'TSAbstractClassDeclaration', 'TSModuleDeclaration'
            m.namespace.set(
              n.declaration.id.name
              captureDoc source, docStyleParsers, n
            ) # flowtype with babel-eslint parser
          when 'VariableDeclaration'
            n.declaration.declarations.forEach (d) ->
              recursivePatternCapture d.id, (id) ->
                m.namespace.set(
                  id.name
                  captureDoc source, docStyleParsers, d, n
                )
          when 'AssignmentExpression'
            {left} = n.declaration
            if left.type is 'Identifier'
              m.namespace.set left.name, captureDoc source, docStyleParsers, n

      nsource = n.source?.value
      n.specifiers.forEach (s) ->
        exportMeta = {}
        switch s.type
          when 'ExportDefaultSpecifier'
            unless n.source then return
            local = 'default'
          when 'ExportNamespaceSpecifier'
            m.namespace.set(
              s.exported.name
              Object.defineProperty exportMeta, 'namespace',
                get: -> resolveImport nsource
            )
            return
          when 'ExportSpecifier'
            unless n.source
              m.namespace.set s.exported.name, addNamespace exportMeta, s.local
              return
            local = s.local.name
          else
            local = s.local.name

        # todo: JSDoc
        m.reexports.set s.exported.name, {
          local
          getImport: -> resolveImport nsource
        }

    # This doesn't declare anything, but changes what's being exported.
    if n.type is 'TSExportAssignment'
      moduleDecls = ast.body.filter (bodyNode) ->
        bodyNode.type is 'TSModuleDeclaration' and
        bodyNode.id.name is n.expression.name
      moduleDecls.forEach (moduleDecl) ->
        if moduleDecl?.body and moduleDecl.body.body
          moduleDecl.body.body.forEach (moduleBlockNode) ->
            # Export-assignment exports all members in the namespace, explicitly exported or not.
            exportedDecl =
              if moduleBlockNode.type is 'ExportNamedDeclaration'
                moduleBlockNode.declaration
              else
                moduleBlockNode

            if exportedDecl.type is 'VariableDeclaration'
              exportedDecl.declarations.forEach (decl) ->
                recursivePatternCapture decl.id, (id) ->
                  m.namespace.set(
                    id.name
                    captureDoc(
                      source
                      docStyleParsers
                      decl
                      exportedDecl
                      moduleBlockNode
                    )
                  )
            else
              m.namespace.set(
                exportedDecl.id.name
                captureDoc source, docStyleParsers, moduleBlockNode
              )

  m

###*
# The creation of this closure is isolated from other scopes
# to avoid over-retention of unrelated variables, which has
# caused memory leaks. See #1266.
###
thunkFor = (p, context) -> -> ExportMap.for childContext p, context

###*
# Traverse a pattern/identifier node, calling 'callback'
# for each leaf identifier.
# @param  {node}   pattern
# @param  {Function} callback
# @return {void}
###
recursivePatternCapture = (pattern, callback) ->
  switch pattern.type
    when 'Identifier' # base case
      callback pattern

    when 'ObjectPattern'
      pattern.properties.forEach (p) ->
        recursivePatternCapture p.value, callback

    when 'ArrayPattern'
      pattern.elements.forEach (element) ->
        return unless element?
        recursivePatternCapture element, callback

    when 'AssignmentPattern'
      callback pattern.left

###*
# don't hold full context object in memory, just grab what we need.
###
childContext = (path, context) ->
  {settings, parserOptions, parserPath} = context
  {
    settings
    parserOptions
    parserPath
    path
  }

###*
# sometimes legacy support isn't _that_ hard... right?
###
makeSourceCode = (text, ast) ->
  if SourceCode.length > 1
    # ESLint 3
    return new SourceCode text, ast
  else
    # ESLint 4, 5
    return new SourceCode {text, ast}

module.exports = default: ExportMap
