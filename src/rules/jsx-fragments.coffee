###*
# @fileoverview Enforce shorthand or standard form for React fragments.
# @author Alex Zherdev
###

'use strict'

elementType = require 'jsx-ast-utils/elementType'
pragmaUtil = require 'eslint-plugin-react/lib/util/pragma'
variableUtil = require '../util/react/variable'
versionUtil = require 'eslint-plugin-react/lib/util/version'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

replaceNode = (source, node, text) ->
  "#{source.slice 0, node.range[0]}#{text}#{source.slice node.range[1]}"

module.exports =
  meta:
    docs:
      description: 'Enforce shorthand or standard form for React fragments'
      category: 'Stylistic Issues'
      recommended: no
      url: docsUrl 'jsx-fragments'
    fixable: 'code'

    schema: [enum: ['syntax', 'element']]

  create: (context) ->
    configuration = context.options[0] or 'syntax'
    reactPragma = pragmaUtil.getFromContext context
    fragmentPragma = pragmaUtil.getFragmentFromContext context
    openFragShort = '<>'
    closeFragShort = '</>'
    openFragLong = "<#{reactPragma}.#{fragmentPragma}>"
    closeFragLong = "</#{reactPragma}.#{fragmentPragma}>"

    reportOnReactVersion = (node) ->
      unless versionUtil.testReactVersion context, '16.2.0'
        context.report {
          node
          message:
            'Fragments are only supported starting from React v16.2. ' +
            'Please disable the `react/jsx-fragments` rule in ESLint settings or upgrade your version of React.'
        }
        return yes

      no

    getFixerToLong = (jsxFragment) ->
      sourceCode = context.getSourceCode()
      (fixer) ->
        source = sourceCode.getText()
        source = replaceNode source, jsxFragment.closingFragment, closeFragLong
        source = replaceNode source, jsxFragment.openingFragment, openFragLong
        lengthDiff =
          openFragLong.length -
          sourceCode.getText(jsxFragment.openingFragment).length +
          closeFragLong.length -
          sourceCode.getText(jsxFragment.closingFragment).length
        {range} = jsxFragment
        fixer.replaceTextRange(
          range
          source.slice range[0], range[1] + lengthDiff
        )

    getFixerToShort = (jsxElement) ->
      sourceCode = context.getSourceCode()
      (fixer) ->
        source = sourceCode.getText()
        if jsxElement.closingElement
          source = replaceNode source, jsxElement.closingElement, closeFragShort
          source = replaceNode source, jsxElement.openingElement, openFragShort
          lengthDiff =
            sourceCode.getText(jsxElement.openingElement).length -
            openFragShort.length +
            sourceCode.getText(jsxElement.closingElement).length -
            closeFragShort.length
        else
          source = replaceNode(
            source
            jsxElement.openingElement
            "#{openFragShort}#{closeFragShort}"
          )
          lengthDiff =
            sourceCode.getText(jsxElement.openingElement).length -
            openFragShort.length -
            closeFragShort.length

        {range} = jsxElement
        fixer.replaceTextRange(
          range
          source.slice range[0], range[1] - lengthDiff
        )

    refersToReactFragment = (name) ->
      variableInit = variableUtil.findVariableByName context, name
      return no unless variableInit

      # const { Fragment } = React;
      return yes if (
        variableInit.type is 'Identifier' and variableInit.name is reactPragma
      )

      # const Fragment = React.Fragment;
      return yes if (
        variableInit.type is 'MemberExpression' and
        variableInit.object.type is 'Identifier' and
        variableInit.object.name is reactPragma and
        variableInit.property.type is 'Identifier' and
        variableInit.property.name is fragmentPragma
      )

      # const { Fragment } = require('react');
      return yes if (
        variableInit.callee and
        variableInit.callee.name is 'require' and
        variableInit.arguments and
        variableInit.arguments[0] and
        variableInit.arguments[0].value is 'react'
      )

      no

    jsxElements = []
    fragmentNames = new Set ["#{reactPragma}.#{fragmentPragma}"]

    # --------------------------------------------------------------------------
    # Public
    # --------------------------------------------------------------------------

    JSXElement: (node) -> jsxElements.push node

    JSXFragment: (node) ->
      return if reportOnReactVersion node

      if configuration is 'element'
        context.report {
          node
          message: "Prefer #{reactPragma}.#{fragmentPragma} over fragment shorthand"
          fix: getFixerToLong node
        }

    ImportDeclaration: (node) ->
      if node.source and node.source.value is 'react'
        node.specifiers.forEach (spec) ->
          if spec.imported and spec.imported.name is fragmentPragma
            if spec.local then fragmentNames.add spec.local.name

    'Program:exit': ->
      jsxElements.forEach (node) ->
        openingEl = node.openingElement
        elName = elementType openingEl

        if fragmentNames.has(elName) or refersToReactFragment elName
          return if reportOnReactVersion node

          attrs = openingEl.attributes
          if configuration is 'syntax' and not (attrs and attrs.length > 0)
            context.report {
              node
              message: "Prefer fragment shorthand over #{reactPragma}.#{fragmentPragma}"
              fix: getFixerToShort node
            }
