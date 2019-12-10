###*
# @fileoverview Enforce propTypes declarations alphabetical sorting
###
'use strict'

variableUtil = require '../util/react/variable'
propsUtil = require '../util/react/props'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'Enforce propTypes declarations alphabetical sorting'
      category: 'Stylistic Issues'
      recommended: no
      url: docsUrl 'sort-prop-types'

    fixable: 'code'

    schema: [
      type: 'object'
      properties:
        requiredFirst:
          type: 'boolean'
        callbacksLast:
          type: 'boolean'
        ignoreCase:
          type: 'boolean'
        # Whether alphabetical sorting should be enforced
        noSortAlphabetically:
          type: 'boolean'
        sortShapeProp:
          type: 'boolean'
      additionalProperties: no
    ]

  create: (context) ->
    sourceCode = context.getSourceCode()
    configuration = context.options[0] or {}
    requiredFirst = configuration.requiredFirst or no
    callbacksLast = configuration.callbacksLast or no
    ignoreCase = configuration.ignoreCase or no
    noSortAlphabetically = configuration.noSortAlphabetically or no
    sortShapeProp = configuration.sortShapeProp or no
    propWrapperFunctions = new Set context.settings.propWrapperFunctions or []

    getKey = (node) ->
      return node.key.value if node.key?.value
      sourceCode.getText node.key or node.argument

    getValueName = (node) ->
      node.type is 'Property' and
      node.value.property and
      node.value.property.name

    isCallbackPropName = (propName) -> /^on[A-Z]/.test propName

    isRequiredProp = (node) -> getValueName(node) is 'isRequired'

    isShapeProp = (node) ->
      Boolean(
        node?.callee and
          node.callee.property and
          node.callee.property.name is 'shape'
      )

    getShapeProperties = (node) ->
      node.arguments?[0] and node.arguments[0].properties

    sorter = (a, b) ->
      aKey = getKey a
      bKey = getKey b
      if requiredFirst
        return -1 if isRequiredProp(a) and not isRequiredProp b
        return 1 if not isRequiredProp(a) and isRequiredProp b

      if callbacksLast
        return 1 if isCallbackPropName(aKey) and not isCallbackPropName bKey
        return -1 if not isCallbackPropName(aKey) and isCallbackPropName bKey

      if ignoreCase
        aKey = aKey.toLowerCase()
        bKey = bKey.toLowerCase()

      return -1 if aKey < bKey
      return 1 if aKey > bKey
      0

    ###*
    # Checks if propTypes declarations are sorted
    # @param {Array} declarations The array of AST nodes being checked.
    # @returns {void}
    ###
    checkSorted = (declarations) ->
      # Declarations will be `undefined` if the `shape` is not a literal. For
      # example, if it is a propType imported from another file.
      return unless declarations

      fix = (fixer) ->
        sortInSource = (allNodes, source) ->
          originalSource = source
          nodeGroups = allNodes.reduce(
            (acc, curr) ->
              if curr.type in ['ExperimentalSpreadProperty', 'SpreadElement']
                acc.push []
              else
                acc[acc.length - 1].push curr
              acc
          ,
            [[]]
          )

          nodeGroups.forEach (nodes) ->
            sortedAttributes = nodes.slice().sort sorter

            for attr, i in nodes by -1
              sortedAttr = sortedAttributes[i]
              attr = nodes[i]
              sortedAttrText = sourceCode.getText sortedAttr
              if sortShapeProp and isShapeProp sortedAttr.value
                shape = getShapeProperties sortedAttr.value
                if shape
                  attrSource = sortInSource shape, originalSource
                  sortedAttrText = attrSource.slice(
                    sortedAttr.range[0]
                    sortedAttr.range[1]
                  )
              source ###:### = "#{source.slice(
                0
                attr.range[0]
              )}#{sortedAttrText}#{source.slice attr.range[1]}"
          source

        source = sortInSource declarations, context.getSourceCode().getText()

        rangeStart = declarations[0].range[0]
        rangeEnd = declarations[declarations.length - 1].range[1]
        fixer.replaceTextRange(
          [rangeStart, rangeEnd]
          source.slice rangeStart, rangeEnd
        )

      declarations.reduce(
        (prev, curr, idx, decls) ->
          return decls[idx + 1] if curr.type in [
            'ExperimentalSpreadProperty'
            'SpreadElement'
          ]

          prevPropName = getKey prev
          currentPropName = getKey curr
          previousIsRequired = isRequiredProp prev
          currentIsRequired = isRequiredProp curr
          previousIsCallback = isCallbackPropName prevPropName
          currentIsCallback = isCallbackPropName currentPropName

          if ignoreCase
            prevPropName = prevPropName.toLowerCase()
            currentPropName = currentPropName.toLowerCase()

          if requiredFirst
            # Transition between required and non-required. Don't compare for alphabetical.
            return curr if previousIsRequired and not currentIsRequired
            if not previousIsRequired and currentIsRequired
              # Encountered a non-required prop after a required prop
              context.report {
                node: curr
                message:
                  'Required prop types must be listed before all other prop types'
                fix
              }
              return curr

          if callbacksLast
            # Entering the callback prop section
            return curr if not previousIsCallback and currentIsCallback
            if previousIsCallback and not currentIsCallback
              # Encountered a non-callback prop after a callback prop
              context.report {
                node: prev
                message:
                  'Callback prop types must be listed after all other prop types'
                fix
              }
              return prev

          if not noSortAlphabetically and currentPropName < prevPropName
            context.report {
              node: curr
              message: 'Prop types declarations should be sorted alphabetically'
              fix
            }
            return prev

          curr
      ,
        declarations[0]
      )

    checkNode = (node) ->
      switch node?.type
        when 'ObjectExpression'
          checkSorted node.properties
        when 'Identifier'
          propTypesObject = variableUtil.findVariableByName context, node.name
          if propTypesObject?.properties
            checkSorted propTypesObject.properties
        when 'CallExpression'
          innerNode = node.arguments?[0]
          if propWrapperFunctions.has(node.callee.name) and innerNode
            checkNode innerNode

    CallExpression: (node) ->
      return if (
        not sortShapeProp or
        not isShapeProp(node) or
        not node.arguments?[0]
      )
      checkSorted node.arguments[0].properties

    ClassProperty: (node) ->
      return unless propsUtil.isPropTypesDeclaration node
      checkNode node.value

    MemberExpression: (node) ->
      return unless propsUtil.isPropTypesDeclaration node

      checkNode node.parent.right

    ObjectExpression: (node) ->
      node.properties.forEach (property) ->
        return unless property.key

        return unless propsUtil.isPropTypesDeclaration property
        if property.value.type is 'ObjectExpression'
          checkSorted property.value.properties
