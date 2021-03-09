'use strict'

convertComments = require './convertComments'

module.exports = (ast, traverse, code) ->
  state = source: code
  ast.range = [ast.start, ast.end]
  traverse ast, astTransformVisitor, null, state
  undefined

changeToLiteral = (node, state) ->
  node.type = 'Literal'
  unless node.raw
    if node.extra?.raw
      node.raw = node.extra.raw
    else
      node.raw = state.source.slice node.start, node.end

astTransformVisitor =
  noScope: yes
  enter: (path) ->
    {node} = path

    node.range = [node.start, node.end]

    # private var to track original node type
    node._babelType = node.type

    if node.innerComments
      node.trailingComments = node.innerComments
      delete node.innerComments

    if node.trailingComments
      convertComments node.trailingComments

    if node.leadingComments
      convertComments node.leadingComments

    # make '_paths' non-enumerable (babel-eslint #200)
    Object.defineProperty node, '_paths', value: node._paths, writable: yes
    undefined
  exit: (path, state) ->
    {node} = path

    # fixDirectives
    if path.isFunction() or path.isProgram()
      directivesContainer = node
      {body} = node
      unless node.type is 'Program'
        directivesContainer = body
        {body} = body
      if directivesContainer.directives
        i = directivesContainer.directives.length - 1
        while i >= 0
          directive = directivesContainer.directives[i]
          directive.type = 'ExpressionStatement'
          directive.expression = directive.value
          delete directive.value
          directive.expression.type = 'Literal'
          changeToLiteral directive.expression, state
          body.unshift directive
          i--
        delete directivesContainer.directives

    if path.isJSXText()
      node.type = 'Literal'
      node.raw = node.value

    if path.isNumericLiteral() or path.isStringLiteral()
      changeToLiteral node, state

    if path.isBooleanLiteral()
      node.type = 'Literal'
      node.raw = String node.value

    if path.isNullLiteral()
      node.type = 'Literal'
      node.raw = 'null'
      node.value = null

    if path.isRegExpLiteral()
      node.type = 'Literal'
      node.raw = node.extra.raw
      node.value = {}
      node.regex =
        pattern: node.pattern
        flags: node.flags
      delete node.extra
      delete node.pattern
      delete node.flags

    if path.isObjectProperty()
      node.type = 'Property'
      node.kind = 'init'

    if path.isClassMethod() or path.isObjectMethod()
      code = state.source.slice node.key.end, node.body.start
      offset = code.indexOf '('

      node.value =
        type: 'FunctionExpression'
        id: node.id
        params: node.params
        body: node.body
        async: node.async
        generator: node.generator
        expression: node.expression
        defaults: [] # basic support - TODO: remove (old esprima)
        loc:
          start:
            line: node.key.loc.start.line
            column: node.key.loc.end.column + offset # a[() {]
          end: node.body.loc.end
      # [asdf]() {
      node.value.range = [node.key.end + offset, node.body.end]

      node.value.start = node.value.range?[0] or node.value.loc.start.column
      node.value.end = node.value.range?[1] or node.value.loc.end.column

      if node.returnType
        node.value.returnType = node.returnType

      if node.typeParameters
        node.value.typeParameters = node.typeParameters

      if path.isClassMethod()
        node.type = 'MethodDefinition'

      if path.isObjectMethod()
        node.type = 'Property'
        if node.kind is 'method'
          node.kind = 'init'

      delete node.body
      delete node.id
      delete node.async
      delete node.generator
      delete node.expression
      delete node.params
      delete node.returnType
      delete node.typeParameters

    if path.isRestProperty() or path.isSpreadProperty()
      node.type = "Experimental#{node.type}"

    if path.isTypeParameter?()
      node.type = 'Identifier'
      node.typeAnnotation = node.bound
      delete node.bound

    # flow: prevent "no-undef"
    # for "Component" in: "let x: React.Component"
    if path.isQualifiedTypeIdentifier()
      delete node.id
    # for "b" in: "var a: { b: Foo }"
    if path.isObjectTypeProperty()
      delete node.key
    # for "indexer" in: "var a: {[indexer: string]: number}"
    if path.isObjectTypeIndexer()
      delete node.id
    # for "param" in: "var a: { func(param: Foo): Bar };"
    if path.isFunctionTypeParam()
      delete node.name

    # modules

    if path.isImportDeclaration()
      delete node.isType

    if path.isExportDeclaration()
      declar = path.get 'declaration'
      if declar.isClassExpression()
        node.declaration.type = 'ClassDeclaration'
      else if declar.isFunctionExpression()
        node.declaration.type = 'FunctionDeclaration'

    # TODO: remove (old esprima)
    if path.isFunction()
      unless node.defaults
        node.defaults = []

    # template string range fixes
    if path.isTemplateLiteral()
      j = 0
      while j < node.quasis.length
        q = node.quasis[j]
        q.range[0] -= 1
        if q.tail
          q.range[1] += 1
        else
          q.range[1] += 2
        q.loc.start.column -= 1
        if q.tail
          q.loc.end.column += 1
        else
          q.loc.end.column += 2
        j++
    undefined
