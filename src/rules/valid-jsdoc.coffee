###*
# @fileoverview Validates JSDoc comments are syntactically correct
# @author Nicholas C. Zakas
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

doctrine = require 'doctrine'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'enforce valid JSDoc comments'
      category: 'Possible Errors'
      recommended: no
      url: 'https://eslint.org/docs/rules/valid-jsdoc'

    schema: [
      type: 'object'
      properties:
        prefer:
          type: 'object'
          additionalProperties:
            type: 'string'
        preferType:
          type: 'object'
          additionalProperties:
            type: 'string'
        # requireReturn:
        #   type: 'boolean'
        requireParamDescription:
          type: 'boolean'
        requireReturnDescription:
          type: 'boolean'
        matchDescription:
          type: 'string'
        requireReturnType:
          type: 'boolean'
        requireParamType:
          type: 'boolean'
      additionalProperties: no
    ]

    fixable: 'code'

  create: (context) ->
    options = context.options[0] or {}
    prefer = options.prefer or {}
    sourceCode = context.getSourceCode()

    # these both default to true, so you have to explicitly make them false
    # requireReturn = options.requireReturn isnt no
    requireParamDescription = options.requireParamDescription isnt no
    requireReturnDescription = options.requireReturnDescription isnt no
    requireReturnType = options.requireReturnType isnt no
    requireParamType = options.requireParamType isnt no
    preferType = options.preferType or {}
    checkPreferType = Object.keys(preferType).length isnt 0

    #--------------------------------------------------------------------------
    # Helpers
    #--------------------------------------------------------------------------

    # Using a stack to store if a function returns or not (handling nested functions)
    fns = []

    ###*
    # Check if node type is a Class
    # @param {ASTNode} node node to check.
    # @returns {boolean} True is its a class
    # @private
    ###
    isTypeClass = (node) -> node.type in ['ClassExpression', 'ClassDeclaration']

    ###*
    # When parsing a new function, store it in our function stack.
    # @param {ASTNode} node A function node to check.
    # @returns {void}
    # @private
    ###
    startFunction = (node) ->
      fns.push
        returnPresent:
          (node.type is 'ArrowFunctionExpression' and
            node.body.type isnt 'BlockStatement') or
          isTypeClass(node) or
          node.async

    ###*
    # Indicate that return has been found in the current function.
    # @param {ASTNode} node The return node.
    # @returns {void}
    # @private
    ###
    addReturn = (node) ->
      functionState = fns[fns.length - 1]

      if functionState and node.argument isnt null
        functionState.returnPresent = yes

    ###*
    # Check if return tag type is void or undefined
    # @param {Object} tag JSDoc tag
    # @returns {boolean} True if its of type void or undefined
    # @private
    ###
    isValidReturnType = (tag) ->
      tag.type is null or
      tag.type.name is 'void' or
      tag.type.type is 'UndefinedLiteral'

    ###*
    # Check if type should be validated based on some exceptions
    # @param {Object} type JSDoc tag
    # @returns {boolean} True if it can be validated
    # @private
    ###
    canTypeBeValidated = (type) ->
      type isnt 'UndefinedLiteral' and # {undefined} as there is no name property available.
      type isnt 'NullLiteral' and # {null}
      type isnt 'NullableLiteral' and # {?}
      type isnt 'FunctionType' and # {function(a)}
      type isnt 'AllLiteral' # {*}

    ###*
    # Extract the current and expected type based on the input type object
    # @param {Object} type JSDoc tag
    # @returns {{currentType: Doctrine.Type, expectedTypeName: string}} The current type annotation and
    # the expected name of the annotation
    # @private
    ###
    getCurrentExpectedTypes = (type) ->
      if type.name
        currentType = type
      else if type.expression
        currentType = type.expression

      {
        currentType
        expectedTypeName: currentType and preferType[currentType.name]
      }

    ###*
    # Gets the location of a JSDoc node in a file
    # @param {Token} jsdocComment The comment that this node is parsed from
    # @param {{range: number[]}} parsedJsdocNode A tag or other node which was parsed from this comment
    # @returns {{start: SourceLocation, end: SourceLocation}} The 0-based source location for the tag
    ###
    getAbsoluteRange = (jsdocComment, parsedJsdocNode) ->
      start: sourceCode.getLocFromIndex(
        jsdocComment.range[0] + '###'.length + parsedJsdocNode.range[0]
      )
      end: sourceCode.getLocFromIndex(
        jsdocComment.range[0] + '###'.length + parsedJsdocNode.range[1]
      )

    ###*
    # Validate type for a given JSDoc node
    # @param {Object} jsdocNode JSDoc node
    # @param {Object} type JSDoc tag
    # @returns {void}
    # @private
    ###
    validateType = (jsdocNode, type) ->
      return if not type or not canTypeBeValidated type.type

      typesToCheck = []
      elements = []

      switch type.type
        when 'TypeApplication' # {Array.<String>}
          elements =
            if type.applications[0].type is 'UnionType'
              type.applications[0].elements
            else
              type.applications
          typesToCheck.push getCurrentExpectedTypes type
        when 'RecordType' # {{20:String}}
          elements = type.fields
        when 'UnionType', 'ArrayType' # {[String, number, Test]}
          {elements} = type # {String|number|Test}
        when 'FieldType' # Array.<{count: number, votes: number}>
          if type.value
            typesToCheck.push getCurrentExpectedTypes type.value
        else
          typesToCheck.push getCurrentExpectedTypes type

      elements.forEach validateType.bind null, jsdocNode

      typesToCheck.forEach (typeToCheck) ->
        if (
          typeToCheck.expectedTypeName and
          typeToCheck.expectedTypeName isnt typeToCheck.currentType.name
        )
          context.report
            node: jsdocNode
            message:
              "Use '{{expectedTypeName}}' instead of '{{currentTypeName}}'."
            loc: getAbsoluteRange jsdocNode, typeToCheck.currentType
            data:
              currentTypeName: typeToCheck.currentType.name
              expectedTypeName: typeToCheck.expectedTypeName
            fix: (fixer) ->
              fixer.replaceTextRange(
                typeToCheck.currentType.range.map (indexInComment) ->
                  jsdocNode.range[0] + '###'.length + indexInComment
              ,
                typeToCheck.expectedTypeName
              )

    convertToJsStyleJsdoc = (comment) ->
      comment.replace /^(\s*)#/gm, '$1*'

    ###*
    # Validate the JSDoc node and output warnings if anything is wrong.
    # @param {ASTNode} node The AST node to check.
    # @returns {void}
    # @private
    ###
    checkJSDoc = (node) ->
      jsdocNode = sourceCode.getJSDocComment node
      # eslint-disable-next-line coffee/no-unused-vars
      functionData = fns.pop()
      paramTagsByName = Object.create null
      paramTags = []
      returnsTag = null
      hasReturns = no
      hasConstructor = no
      isInterface = no
      isOverride = no
      # eslint-disable-next-line coffee/no-unused-vars
      isAbstract = no

      # make sure only to validate JSDoc comments
      if jsdocNode
        try
          jsdoc = doctrine.parse convertToJsStyleJsdoc(jsdocNode.value),
            strict: yes
            unwrap: yes
            sloppy: yes
            range: yes
        catch ex
          if /braces/i.test ex.message
            context.report node: jsdocNode, message: 'JSDoc type missing brace.'
          else
            context.report node: jsdocNode, message: 'JSDoc syntax error.'

          return

        jsdoc.tags.forEach (tag) ->
          switch tag.title.toLowerCase()
            when 'param', 'arg', 'argument'
              paramTags.push tag

            when 'return', 'returns'
              hasReturns ###:### = yes
              returnsTag = tag

            when 'constructor', 'class'
              hasConstructor ###:### = yes

            when 'override', 'inheritdoc'
              isOverride ###:### = yes

            when 'abstract', 'virtual'
              isAbstract ###:### = yes

            when 'interface'
              isInterface ###:### = yes

            # no default

          # check tag preferences
          if (
            Object.prototype.hasOwnProperty.call(prefer, tag.title) and
            tag.title isnt prefer[tag.title]
          )
            entireTagRange = getAbsoluteRange jsdocNode, tag

            context.report
              node: jsdocNode
              message: 'Use @{{name}} instead.'
              loc:
                start: entireTagRange.start
                end:
                  line: entireTagRange.start.line
                  column: entireTagRange.start.column + "@#{tag.title}".length
              data: name: prefer[tag.title]
              fix: (fixer) ->
                fixer.replaceTextRange(
                  [
                    jsdocNode.range[0] +
                      tag.range[0] +
                      '###'.length +
                      '@'.length
                    jsdocNode.range[0] +
                      tag.range[0] +
                      tag.title.length +
                      '###'.length +
                      '@'.length
                  ]
                  prefer[tag.title]
                )

          # validate the types
          if checkPreferType and tag.type then validateType jsdocNode, tag.type

        paramTags.forEach (param) ->
          if requireParamType and not param.type
            context.report
              node: jsdocNode
              message: "Missing JSDoc parameter type for '{{name}}'."
              loc: getAbsoluteRange jsdocNode, param
              data: name: param.name
          if not param.description and requireParamDescription
            context.report
              node: jsdocNode
              message: "Missing JSDoc parameter description for '{{name}}'."
              loc: getAbsoluteRange jsdocNode, param
              data: name: param.name
          if paramTagsByName[param.name]
            context.report
              node: jsdocNode
              message: "Duplicate JSDoc parameter '{{name}}'."
              loc: getAbsoluteRange jsdocNode, param
              data: name: param.name
          else if param.name.indexOf('.') is -1
            paramTagsByName[param.name] = param

        if hasReturns
          # if (
          #   not requireReturn and
          #   not functionData.returnPresent and
          #   (returnsTag.type is null or not isValidReturnType(returnsTag)) and
          #   not isAbstract
          # )
          #   context.report
          #     node: jsdocNode
          #     message:
          #       'Unexpected @{{title}} tag; function has no return statement.'
          #     loc: getAbsoluteRange jsdocNode, returnsTag
          #     data:
          #       title: returnsTag.title
          # else
          if requireReturnType and not returnsTag.type
            context.report
              node: jsdocNode, message: 'Missing JSDoc return type.'

          if (
            not isValidReturnType(returnsTag) and
            not returnsTag.description and
            requireReturnDescription
          )
            context.report
              node: jsdocNode, message: 'Missing JSDoc return description.'

        # check for functions missing @returns
        if (
          not isOverride and
          not hasReturns and
          not hasConstructor and
          not isInterface and
          node.parent.kind isnt 'get' and
          node.parent.kind isnt 'constructor' and
          node.parent.kind isnt 'set' and
          not isTypeClass node
        )
          # if requireReturn or (functionData.returnPresent and not node.async)
          context.report
            node: jsdocNode
            message: 'Missing JSDoc @{{returns}} for function.'
            data:
              returns: prefer.returns or 'returns'

        # check the parameters
        jsdocParamNames = Object.keys paramTagsByName

        if node.params
          node.params.forEach (param, paramsIndex) ->
            bindingParam =
              if param.type is 'AssignmentPattern'
                param.left
              else
                param

            if (
              bindingParam.type is 'MemberExpression' and
              bindingParam.object.type is 'ThisExpression'
            )
              bindingParam = bindingParam.property
            # TODO(nzakas): Figure out logical things to do with destructured, default, rest params
            if bindingParam.type is 'Identifier'
              {name} = bindingParam

              if (
                jsdocParamNames[paramsIndex] and
                name isnt jsdocParamNames[paramsIndex]
              )
                context.report
                  node: jsdocNode
                  message:
                    "Expected JSDoc for '{{name}}' but found '{{jsdocName}}'."
                  loc: getAbsoluteRange(
                    jsdocNode
                    paramTagsByName[jsdocParamNames[paramsIndex]]
                  )
                  data: {
                    name
                    jsdocName: jsdocParamNames[paramsIndex]
                  }
              else if not paramTagsByName[name] and not isOverride
                context.report
                  node: jsdocNode
                  message: "Missing JSDoc for parameter '{{name}}'."
                  data: {
                    name
                  }

        if options.matchDescription
          regex = new RegExp options.matchDescription

          unless regex.test jsdoc.description
            context.report
              node: jsdocNode
              message: 'JSDoc description does not satisfy the regex pattern.'

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    ArrowFunctionExpression: startFunction
    FunctionExpression: startFunction
    FunctionDeclaration: startFunction
    ClassExpression: startFunction
    ClassDeclaration: startFunction
    'ArrowFunctionExpression:exit': checkJSDoc
    'FunctionExpression:exit': checkJSDoc
    'FunctionDeclaration:exit': checkJSDoc
    'ClassExpression:exit': checkJSDoc
    'ClassDeclaration:exit': checkJSDoc
    ReturnStatement: addReturn
