###*
# @fileoverview Report when a DOM element is using both children and dangerouslySetInnerHTML
# @author David Petersen
###
'use strict'

variableUtil = require '../util/react/variable'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'
{isDeclarationAssignment} = require '../util/ast-utils'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------
module.exports =
  meta:
    docs:
      description:
        'Report when a DOM element is using both children and dangerouslySetInnerHTML'
      category: ''
      recommended: yes
      url: docsUrl 'no-danger-with-children'
    schema: [] # no options
  create: (context) ->
    findSpreadVariable = (name) ->
      variableUtil
      .variablesInScope context
      .find (item) -> item.name is name
    ###*
    # Takes a ObjectExpression and returns the value of the prop if it has it
    # @param {object} node - ObjectExpression node
    # @param {string} propName - name of the prop to look for
    ###
    findObjectProp = (node, propName, seenProps) ->
      return no unless node.properties
      node.properties.find (prop) ->
        if prop.type is 'Property'
          return prop.key.name is propName
        else if prop.type in ['ExperimentalSpreadProperty', 'SpreadElement']
          variable = findSpreadVariable prop.argument.name
          if (
            (val =
              variable.defs[0]?.node.init ?
              (isDeclarationAssignment(variable?.defs[0]?.node.parent) and
                variable.defs[0].node.parent.right))
          )
            return no if seenProps.indexOf(prop.argument.name) > -1
            newSeenProps = seenProps.concat prop.argument.name or []
            return findObjectProp val, propName, newSeenProps
        no

    ###*
    # Takes a JSXElement and returns the value of the prop if it has it
    # @param {object} node - JSXElement node
    # @param {string} propName - name of the prop to look for
    ###
    findJsxProp = (node, propName) ->
      {attributes} = node.openingElement
      attributes.find (attribute) ->
        if attribute.type is 'JSXSpreadAttribute'
          variable = findSpreadVariable attribute.argument.name
          return findObjectProp variable.defs[0].node.init, propName, [] if (
            variable.defs[0]?.node.init
          )
          return findObjectProp(
            variable.defs[0].node.parent.right
            propName
            []
          ) if isDeclarationAssignment variable?.defs[0]?.node.parent
        attribute.name and attribute.name.name is propName

    ###*
    # Checks to see if a node is a line break
    # @param {ASTNode} node The AST node being checked
    # @returns {Boolean} True if node is a line break, false if not
    ###
    isLineBreak = (node) ->
      isLiteral = node.type in ['Literal', 'JSXText']
      # isMultiline = node.loc.start.line isnt node.loc.end.line
      isMultiline = /\n/.test node.value
      isWhiteSpaces = /^\s*$/.test node.value

      isLiteral and isMultiline and isWhiteSpaces

    JSXElement: (node) ->
      hasChildren = no

      if node.children.length and not isLineBreak node.children[0]
        hasChildren = yes
      else if findJsxProp node, 'children'
        hasChildren = yes

      if (
        node.openingElement.attributes and
        hasChildren and
        findJsxProp node, 'dangerouslySetInnerHTML'
      )
        context.report(
          node
          'Only set one of `children` or `props.dangerouslySetInnerHTML`'
        )
    CallExpression: (node) ->
      if (
        node.callee and
        node.callee.type is 'MemberExpression' and
        node.callee.property.name is 'createElement' and
        node.arguments.length > 1
      )
        hasChildren = no

        props = node.arguments[1]

        if props.type is 'Identifier'
          variable = variableUtil
          .variablesInScope context
          .find (item) -> item.name is props.name
          if variable?.defs[0]?.node.init
            props = variable.defs[0].node.init
          else if isDeclarationAssignment variable?.defs[0]?.node.parent
            props = variable.defs[0].node.parent.right

        dangerously = findObjectProp props, 'dangerouslySetInnerHTML', []

        if node.arguments.length is 2
          if findObjectProp props, 'children', [] then hasChildren = yes
        else
          hasChildren = yes

        if dangerously and hasChildren
          context.report(
            node
            'Only set one of `children` or `props.dangerouslySetInnerHTML`'
          )
