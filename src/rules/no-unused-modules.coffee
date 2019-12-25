###*
# @fileOverview Ensures that modules contain exports and/or all
# modules are consumed within other modules.
# @author René Fermann
###

{default: Exports} = require '../eslint-plugin-import-export-map'
{getFileExtensions} = require 'eslint-module-utils/ignore'
{default: resolve} = require 'eslint-module-utils/resolve'
{default: docsUrl} = require 'eslint-plugin-import/lib/docsUrl'
{dirname, join} = require 'path'
readPkgUp = require 'read-pkg-up'
values = require 'object.values'
includes = require 'array-includes'

# eslint/lib/util/glob-util has been moved to eslint/lib/util/glob-utils with version 5.3
# and has been moved to eslint/lib/cli-engine/file-enumerator in version 6
try
  FileEnumerator =
    require('eslint/lib/cli-engine/file-enumerator').FileEnumerator
  listFilesToProcess = (src, extensions) ->
    e = new FileEnumerator extensions: extensions
    Array.from e.iterateFiles(src), ({filePath, ignored}) -> {
      ignored
      filename: filePath
    }
catch e1
  # Prevent passing invalid options (extensions array) to old versions of the function.
  # https://github.com/eslint/eslint/blob/v5.16.0/lib/util/glob-utils.js#L178-L280
  # https://github.com/eslint/eslint/blob/v5.2.0/lib/util/glob-util.js#L174-L269
  try
    originalListFilesToProcess =
      require('eslint/lib/util/glob-utils').listFilesToProcess
    listFilesToProcess = (src, extensions) ->
      originalListFilesToProcess src, extensions: extensions
  catch e2
    originalListFilesToProcess =
      require('eslint/lib/util/glob-util').listFilesToProcess

    listFilesToProcess = (src, extensions) ->
      patterns = src.reduce(
        (carry, pattern) ->
          carry.concat(
            extensions.map (extension) ->
              if /\*\*|\*\./.test pattern
                pattern
              else
                "#{pattern}/**/*#{extension}"
          )
      ,
        src.slice()
      )

      originalListFilesToProcess patterns

EXPORT_DEFAULT_DECLARATION = 'ExportDefaultDeclaration'
EXPORT_NAMED_DECLARATION = 'ExportNamedDeclaration'
EXPORT_ALL_DECLARATION = 'ExportAllDeclaration'
IMPORT_DECLARATION = 'ImportDeclaration'
IMPORT_NAMESPACE_SPECIFIER = 'ImportNamespaceSpecifier'
IMPORT_DEFAULT_SPECIFIER = 'ImportDefaultSpecifier'
VARIABLE_DECLARATION = 'VariableDeclaration'
FUNCTION_DECLARATION = 'FunctionDeclaration'
CLASS_DECLARATION = 'ClassDeclaration'
ASSIGNMENT_EXPRESSION = 'AssignmentExpression'
IDENTIFIER = 'Identifier'
DEFAULT = 'default'
TYPE_ALIAS = 'TypeAlias'

importList = new Map()
exportList = new Map()
ignoredFiles = new Set()
filesOutsideSrc = new Set()

isNodeModule = (path) -> /\/(node_modules)\//.test path

###*
# read all files matching the patterns in src and ignoreExports
#
# return all files matching src pattern, which are not matching the ignoreExports pattern
###
resolveFiles = (src, ignoreExports, context) ->
  extensions = Array.from getFileExtensions context.settings

  srcFiles = new Set()
  srcFileList = listFilesToProcess src, extensions

  # prepare list of ignored files
  ignoredFilesList = listFilesToProcess ignoreExports, extensions
  ignoredFilesList.forEach ({filename}) -> ignoredFiles.add filename

  # prepare list of source files, don't consider files from node_modules
  srcFileList
  .filter ({filename}) -> not isNodeModule filename
  .forEach ({filename}) -> srcFiles.add filename
  srcFiles

###*
# parse all source files and build up 2 maps containing the existing imports and exports
###
prepareImportsAndExports = (srcFiles, context) ->
  exportAll = new Map()
  srcFiles.forEach (file) ->
    exports = new Map()
    imports = new Map()
    currentExports = Exports.get file, context
    if currentExports
      {
        dependencies
        reexports
        imports: localImportList
        namespace
      } = currentExports

      # dependencies === export * from
      currentExportAll = new Set()
      dependencies.forEach (getDependency) ->
        dependency = getDependency()
        return if dependency is null

        currentExportAll.add dependency.path
      exportAll.set file, currentExportAll

      reexports.forEach (value, key) ->
        if key is DEFAULT
          exports.set IMPORT_DEFAULT_SPECIFIER, whereUsed: new Set()
        else
          exports.set key, whereUsed: new Set()
        reexport = value.getImport()
        return unless reexport
        localImport = imports.get reexport.path
        if value.local is DEFAULT
          currentValue = IMPORT_DEFAULT_SPECIFIER
        else
          currentValue = value.local
        unless typeof localImport is 'undefined'
          localImport = new Set [...localImport, currentValue]
        else
          localImport = new Set [currentValue]
        imports.set reexport.path, localImport

      localImportList.forEach (value, key) ->
        return if isNodeModule key
        imports.set key, value.importedSpecifiers
      importList.set file, imports

      # build up export list only, if file is not ignored
      return if ignoredFiles.has file
      namespace.forEach (value, key) ->
        if key is DEFAULT
          exports.set IMPORT_DEFAULT_SPECIFIER, whereUsed: new Set()
        else
          exports.set key, whereUsed: new Set()
    exports.set EXPORT_ALL_DECLARATION, whereUsed: new Set()
    exports.set IMPORT_NAMESPACE_SPECIFIER, whereUsed: new Set()
    exportList.set file, exports
  exportAll.forEach (value, key) ->
    value.forEach (val) ->
      currentExports = exportList.get val
      currentExport = currentExports.get EXPORT_ALL_DECLARATION
      currentExport.whereUsed.add key

###*
# traverse through all imports and add the respective path to the whereUsed-list
# of the corresponding export
###
determineUsage = ->
  importList.forEach (listValue, listKey) ->
    listValue.forEach (value, key) ->
      exports = exportList.get key
      unless typeof exports is 'undefined'
        value.forEach (currentImport) ->
          if currentImport is IMPORT_NAMESPACE_SPECIFIER
            specifier = IMPORT_NAMESPACE_SPECIFIER
          else if currentImport is IMPORT_DEFAULT_SPECIFIER
            specifier = IMPORT_DEFAULT_SPECIFIER
          else
            specifier = currentImport
          unless typeof specifier is 'undefined'
            exportStatement = exports.get specifier
            unless typeof exportStatement is 'undefined'
              {whereUsed} = exportStatement
              whereUsed.add listKey
              exports.set specifier, {whereUsed}

getSrc = (src) ->
  return src if src
  [process.cwd()]

###*
# prepare the lists of existing imports and exports - should only be executed once at
# the start of a new eslint run
###
srcFiles = null
lastPrepareKey = null
doPreparation = (src, ignoreExports, context) ->
  prepareKey = JSON.stringify(
    src: (src or []).sort()
    ignoreExports: (ignoreExports or []).sort()
    extensions: Array.from(getFileExtensions context.settings).sort()
  )
  return if prepareKey is lastPrepareKey

  importList.clear()
  exportList.clear()
  ignoredFiles.clear()
  filesOutsideSrc.clear()

  srcFiles = resolveFiles getSrc(src), ignoreExports, context
  prepareImportsAndExports srcFiles, context
  determineUsage()
  lastPrepareKey = prepareKey

newNamespaceImportExists = (specifiers) ->
  specifiers.some ({type}) -> type is IMPORT_NAMESPACE_SPECIFIER

newDefaultImportExists = (specifiers) ->
  specifiers.some ({type}) -> type is IMPORT_DEFAULT_SPECIFIER

fileIsInPkg = (file) ->
  {path, pkg} = readPkgUp.sync cwd: file, normalize: no
  basePath = dirname path

  checkPkgFieldString = (pkgField) ->
    return yes if join(basePath, pkgField) is file

  checkPkgFieldObject = (pkgField) ->
    pkgFieldFiles = values(pkgField).map (value) -> join basePath, value
    return yes if includes pkgFieldFiles, file

  checkPkgField = (pkgField) ->
    return checkPkgFieldString pkgField if typeof pkgField is 'string'

    return checkPkgFieldObject pkgField if typeof pkgField is 'object'

  return no if pkg.private is yes

  if pkg.bin then return yes if checkPkgField pkg.bin

  if pkg.browser then return yes if checkPkgField pkg.browser

  if pkg.main then return yes if checkPkgFieldString pkg.main

  no

module.exports =
  meta:
    docs: url: docsUrl 'no-unused-modules'
    schema: [
      properties:
        src:
          description: 'files/paths to be analyzed (only for unused exports)'
          type: 'array'
          minItems: 1
          items:
            type: 'string'
            minLength: 1
        ignoreExports:
          description:
            'files/paths for which unused exports will not be reported (e.g module entry points)'
          type: 'array'
          minItems: 1
          items:
            type: 'string'
            minLength: 1
        missingExports:
          description: 'report modules without any exports'
          type: 'boolean'
        unusedExports:
          description: 'report exports without any usage'
          type: 'boolean'
      not:
        properties:
          unusedExports: enum: [no]
          missingExports: enum: [no]
      anyOf: [
        not:
          properties:
            unusedExports: enum: [yes]
        required: ['missingExports']
      ,
        not:
          properties:
            missingExports: enum: [yes]
        required: ['unusedExports']
      ,
        properties:
          unusedExports: enum: [yes]
        required: ['unusedExports']
      ,
        properties:
          missingExports: enum: [yes]
        required: ['missingExports']
      ]
    ]

  create: (context) ->
    {
      src
      ignoreExports = []
      missingExports
      unusedExports
    } = context.options[0] or {}

    if unusedExports then doPreparation src, ignoreExports, context

    file = context.getFilename()

    checkExportPresence = (node) ->
      return unless missingExports

      return if ignoredFiles.has file

      exportCount = exportList.get file
      exportAll = exportCount.get EXPORT_ALL_DECLARATION
      namespaceImports = exportCount.get IMPORT_NAMESPACE_SPECIFIER

      exportCount.delete EXPORT_ALL_DECLARATION
      exportCount.delete IMPORT_NAMESPACE_SPECIFIER
      if exportCount.size < 1
        # node.body[0] === 'undefined' only happens, if everything is commented out in the file
        # being linted
        context.report(
          if node.body[0] then node.body[0] else node
          'No exports found'
        )
      exportCount.set EXPORT_ALL_DECLARATION, exportAll
      exportCount.set IMPORT_NAMESPACE_SPECIFIER, namespaceImports

    checkUsage = (node, exportedValue) ->
      return unless unusedExports

      return if ignoredFiles.has file

      return if fileIsInPkg file

      return if filesOutsideSrc.has file

      # make sure file to be linted is included in source files
      unless srcFiles.has file
        srcFiles = resolveFiles getSrc(src), ignoreExports, context
        unless srcFiles.has file
          filesOutsideSrc.add file
          return

      exports = exportList.get file

      # special case: export * from
      exportAll = exports.get EXPORT_ALL_DECLARATION
      if (
        typeof exportAll isnt 'undefined' and
        exportedValue isnt IMPORT_DEFAULT_SPECIFIER
      )
        return if exportAll.whereUsed.size > 0

      # special case: namespace import
      namespaceImports = exports.get IMPORT_NAMESPACE_SPECIFIER
      unless typeof namespaceImports is 'undefined'
        return if namespaceImports.whereUsed.size > 0

      exportStatement = exports.get exportedValue

      value =
        if exportedValue is IMPORT_DEFAULT_SPECIFIER
          DEFAULT
        else
          exportedValue

      unless typeof exportStatement is 'undefined'
        if exportStatement.whereUsed.size < 1
          context.report(
            node
            "exported declaration '#{value}' not used within other modules"
          )
      else
        context.report(
          node
          "exported declaration '#{value}' not used within other modules"
        )

    ###*
    # only useful for tools like vscode-eslint
    #
    # update lists of existing exports during runtime
    ###
    updateExportUsage = (node) ->
      return if ignoredFiles.has file

      exports = exportList.get file

      # new module has been created during runtime
      # include it in further processing
      if typeof exports is 'undefined' then exports = new Map()

      newExports = new Map()
      newExportIdentifiers = new Set()

      node.body.forEach ({type, declaration, specifiers}) ->
        if type is EXPORT_DEFAULT_DECLARATION
          newExportIdentifiers.add IMPORT_DEFAULT_SPECIFIER
        if type is EXPORT_NAMED_DECLARATION
          if specifiers.length > 0
            specifiers.forEach (specifier) ->
              if specifier.exported
                newExportIdentifiers.add specifier.exported.name
          if declaration
            if declaration.type in [
              FUNCTION_DECLARATION
              CLASS_DECLARATION
              TYPE_ALIAS
            ]
              newExportIdentifiers.add declaration.id.name
            if declaration.type is VARIABLE_DECLARATION
              declaration.declarations.forEach ({id}) ->
                newExportIdentifiers.add id.name
            if (
              declaration.type is ASSIGNMENT_EXPRESSION and
              declaration.left.type is IDENTIFIER
            )
              newExportIdentifiers.add declaration.left.name

      # old exports exist within list of new exports identifiers: add to map of new exports
      exports.forEach (value, key) ->
        if newExportIdentifiers.has key then newExports.set key, value

      # new export identifiers added: add to map of new exports
      newExportIdentifiers.forEach (key) ->
        unless exports.has key then newExports.set key, whereUsed: new Set()

      # preserve information about namespace imports
      exportAll = exports.get EXPORT_ALL_DECLARATION
      namespaceImports = exports.get IMPORT_NAMESPACE_SPECIFIER

      if typeof namespaceImports is 'undefined'
        namespaceImports = whereUsed: new Set()

      newExports.set EXPORT_ALL_DECLARATION, exportAll
      newExports.set IMPORT_NAMESPACE_SPECIFIER, namespaceImports
      exportList.set file, newExports

    ###*
    # only useful for tools like vscode-eslint
    #
    # update lists of existing imports during runtime
    ###
    updateImportUsage = (node) ->
      return unless unusedExports

      oldImportPaths = importList.get file
      if typeof oldImportPaths is 'undefined' then oldImportPaths = new Map()

      oldNamespaceImports = new Set()
      newNamespaceImports = new Set()

      oldExportAll = new Set()
      newExportAll = new Set()

      oldDefaultImports = new Set()
      newDefaultImports = new Set()

      oldImports = new Map()
      newImports = new Map()
      oldImportPaths.forEach (value, key) ->
        if value.has EXPORT_ALL_DECLARATION then oldExportAll.add key
        if value.has IMPORT_NAMESPACE_SPECIFIER then oldNamespaceImports.add key
        if value.has IMPORT_DEFAULT_SPECIFIER then oldDefaultImports.add key
        value.forEach (val) ->
          if (
            val isnt IMPORT_NAMESPACE_SPECIFIER and
            val isnt IMPORT_DEFAULT_SPECIFIER
          )
            oldImports.set val, key

      node.body.forEach (astNode) ->
        # support for export { value } from 'module'
        if astNode.type is EXPORT_NAMED_DECLARATION
          if astNode.source
            resolvedPath = resolve(
              astNode.source.raw.replace /('|")/g, ''
              context
            )
            astNode.specifiers.forEach (specifier) ->
              if specifier.exported.name is DEFAULT
                name = IMPORT_DEFAULT_SPECIFIER
              else
                name = specifier.local.name
              newImports.set name, resolvedPath

        if astNode.type is EXPORT_ALL_DECLARATION
          resolvedPath = resolve(
            astNode.source.raw.replace /('|")/g, ''
            context
          )
          newExportAll.add resolvedPath

        if astNode.type is IMPORT_DECLARATION
          resolvedPath = resolve(
            astNode.source.raw.replace /('|")/g, ''
            context
          )
          return unless resolvedPath

          return if isNodeModule resolvedPath

          if newNamespaceImportExists astNode.specifiers
            newNamespaceImports.add resolvedPath

          if newDefaultImportExists astNode.specifiers
            newDefaultImports.add resolvedPath

          astNode.specifiers.forEach (specifier) ->
            return if specifier.type in [
              IMPORT_DEFAULT_SPECIFIER
              IMPORT_NAMESPACE_SPECIFIER
            ]
            newImports.set specifier.imported.name, resolvedPath

      newExportAll.forEach (value) ->
        unless oldExportAll.has value
          imports = oldImportPaths.get value
          if typeof imports is 'undefined' then imports = new Set()
          imports.add EXPORT_ALL_DECLARATION
          oldImportPaths.set value, imports

          exports = exportList.get value
          unless typeof exports is 'undefined'
            currentExport = exports.get EXPORT_ALL_DECLARATION
          else
            exports = new Map()
            exportList.set value, exports

          unless typeof currentExport is 'undefined'
            currentExport.whereUsed.add file
          else
            whereUsed = new Set()
            whereUsed.add file
            exports.set EXPORT_ALL_DECLARATION, {whereUsed}

      oldExportAll.forEach (value) ->
        unless newExportAll.has value
          imports = oldImportPaths.get value
          imports.delete EXPORT_ALL_DECLARATION

          exports = exportList.get value
          unless typeof exports is 'undefined'
            currentExport = exports.get EXPORT_ALL_DECLARATION
            unless typeof currentExport is 'undefined'
              currentExport.whereUsed.delete file

      newDefaultImports.forEach (value) ->
        unless oldDefaultImports.has value
          imports = oldImportPaths.get value
          if typeof imports is 'undefined' then imports = new Set()
          imports.add IMPORT_DEFAULT_SPECIFIER
          oldImportPaths.set value, imports

          exports = exportList.get value
          unless typeof exports is 'undefined'
            currentExport = exports.get IMPORT_DEFAULT_SPECIFIER
          else
            exports = new Map()
            exportList.set value, exports

          unless typeof currentExport is 'undefined'
            currentExport.whereUsed.add file
          else
            whereUsed = new Set()
            whereUsed.add file
            exports.set IMPORT_DEFAULT_SPECIFIER, {whereUsed}

      oldDefaultImports.forEach (value) ->
        unless newDefaultImports.has value
          imports = oldImportPaths.get value
          imports.delete IMPORT_DEFAULT_SPECIFIER

          exports = exportList.get value
          unless typeof exports is 'undefined'
            currentExport = exports.get IMPORT_DEFAULT_SPECIFIER
            unless typeof currentExport is 'undefined'
              currentExport.whereUsed.delete file

      newNamespaceImports.forEach (value) ->
        unless oldNamespaceImports.has value
          imports = oldImportPaths.get value
          if typeof imports is 'undefined' then imports = new Set()
          imports.add IMPORT_NAMESPACE_SPECIFIER
          oldImportPaths.set value, imports

          exports = exportList.get value
          unless typeof exports is 'undefined'
            currentExport = exports.get IMPORT_NAMESPACE_SPECIFIER
          else
            exports = new Map()
            exportList.set value, exports

          unless typeof currentExport is 'undefined'
            currentExport.whereUsed.add file
          else
            whereUsed = new Set()
            whereUsed.add file
            exports.set IMPORT_NAMESPACE_SPECIFIER, {whereUsed}

      oldNamespaceImports.forEach (value) ->
        unless newNamespaceImports.has value
          imports = oldImportPaths.get value
          imports.delete IMPORT_NAMESPACE_SPECIFIER

          exports = exportList.get value
          unless typeof exports is 'undefined'
            currentExport = exports.get IMPORT_NAMESPACE_SPECIFIER
            unless typeof currentExport is 'undefined'
              currentExport.whereUsed.delete file

      newImports.forEach (value, key) ->
        unless oldImports.has key
          imports = oldImportPaths.get value
          if typeof imports is 'undefined' then imports = new Set()
          imports.add key
          oldImportPaths.set value, imports

          exports = exportList.get value
          unless typeof exports is 'undefined'
            currentExport = exports.get key
          else
            exports = new Map()
            exportList.set value, exports

          unless typeof currentExport is 'undefined'
            currentExport.whereUsed.add file
          else
            whereUsed = new Set()
            whereUsed.add file
            exports.set key, {whereUsed}

      oldImports.forEach (value, key) ->
        unless newImports.has key
          imports = oldImportPaths.get value
          imports.delete key

          exports = exportList.get value
          unless typeof exports is 'undefined'
            currentExport = exports.get key
            unless typeof currentExport is 'undefined'
              currentExport.whereUsed.delete file

    'Program:exit': (node) ->
      updateExportUsage node
      updateImportUsage node
      checkExportPresence node
    ExportDefaultDeclaration: (node) ->
      checkUsage node, IMPORT_DEFAULT_SPECIFIER
    ExportNamedDeclaration: (node) ->
      node.specifiers.forEach (specifier) ->
        checkUsage node, specifier.exported.name
      if node.declaration
        if node.declaration.type in [
          FUNCTION_DECLARATION
          CLASS_DECLARATION
          TYPE_ALIAS
        ]
          checkUsage node, node.declaration.id.name
        if node.declaration.type is VARIABLE_DECLARATION
          node.declaration.declarations.forEach (declaration) ->
            checkUsage node, declaration.id.name
        if (
          node.declaration.type is ASSIGNMENT_EXPRESSION and
          node.declaration.left.type is IDENTIFIER
        )
          checkUsage node, node.declaration.left.name
