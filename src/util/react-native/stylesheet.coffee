'use strict'

###*
# StyleSheets represents the StyleSheets found in the source code.
# @constructor
###
class StyleSheets
  constructor: ->
    @styleSheets = {}

  ###*
  # Add adds a StyleSheet to our StyleSheets collections.
  #
  # @param {string} styleSheetName - The name of the StyleSheet.
  # @param {object} properties - The collection of rules in the styleSheet.
  ###
  add: (styleSheetName, properties) ->
    @styleSheets[styleSheetName] = properties

  ###*
  # MarkAsUsed marks a rule as used in our source code by removing it from the
  # specified StyleSheet rules.
  #
  # @param {string} fullyQualifiedName - The fully qualified name of the rule.
  # for example 'styles.text'
  ###
  markAsUsed: (fullyQualifiedName) ->
    nameSplit = fullyQualifiedName.split '.'
    styleSheetName = nameSplit[0]
    styleSheetProperty = nameSplit[1]

    if @styleSheets[styleSheetName]
      @styleSheets[styleSheetName] = @styleSheets[styleSheetName].filter (
        property
      ) ->
        property.key.name isnt styleSheetProperty

  ###*
  # GetUnusedReferences returns all collected StyleSheets and their
  # unmarked rules.
  ###
  getUnusedReferences: -> @styleSheets

  ###*
  # AddColorLiterals adds an array of expressions that contain color literals
  # to the ColorLiterals collection
  # @param {array} expressions - an array of expressions containing color literals
  ###
  addColorLiterals: (expressions) ->
    @colorLiterals = (@colorLiterals ? []).concat expressions

  ###*
  # GetColorLiterals returns an array of collected color literals expressions
  # @returns {Array}
  ###
  getColorLiterals: -> @colorLiterals

  ###*
  # AddObjectexpressions adds an array of expressions to the ObjectExpressions collection
  # @param {Array} expressions - an array of expressions containing ObjectExpressions in
  # inline styles
  ###
  addObjectExpressions: (expressions) ->
    @objectExpressions = (@objectExpressions ? []).concat expressions

  ###*
  # GetObjectExpressions returns an array of collected object expressiosn used in inline styles
  # @returns {Array}
  ###
  getObjectExpressions: -> @objectExpressions

currentContent = null
getSourceCode = (node) -> currentContent.getSourceCode(node).getText node

astHelpers =
  containsStyleSheetObject: (node) ->
    right = node?.init ? node?.right
    right?.callee?.object?.name is 'StyleSheet'

  containsCreateCall: (node) ->
    right = node?.init ? node?.right
    right?.callee?.property?.name is 'create'

  isStyleSheetDeclaration: (node) ->
    Boolean(
      astHelpers.containsStyleSheetObject(node) and
        astHelpers.containsCreateCall node
    )

  getStyleSheetName: (node) ->
    node?.id?.name ? node?.left?.name

  getStyleDeclarations: (node) ->
    right = node?.init ? node?.right
    if right?.arguments?[0]?.properties
      return right.arguments[0].properties.filter (property) ->
        property.type is 'Property'

    []

  isStyleAttribute: (node) ->
    Boolean(
      node.type is 'JSXAttribute' and
        node.name and
        node.name.name and
        node.name.name.toLowerCase().includes 'style'
    )

  collectStyleObjectExpressions: (node, context) ->
    currentContent = context
    if astHelpers.hasArrayOfStyleReferences node
      styleReferenceContainers = node.expression.elements

      return astHelpers.collectStyleObjectExpressionFromContainers(
        styleReferenceContainers
      )
    return astHelpers.getStyleObjectExpressionFromNode node.expression if (
      node?.expression
    )

    []

  collectColorLiterals: (node, context) ->
    return [] unless node

    currentContent ###:### = context
    if astHelpers.hasArrayOfStyleReferences node
      styleReferenceContainers = node.expression.elements

      return astHelpers.collectColorLiteralsFromContainers(
        styleReferenceContainers
      )

    return astHelpers.getColorLiteralsFromNode node if (
      node.type is 'ObjectExpression'
    )

    astHelpers.getColorLiteralsFromNode node.expression

  collectStyleObjectExpressionFromContainers: (nodes) ->
    objectExpressions = []
    nodes.forEach (node) ->
      objectExpressions ###:### = objectExpressions.concat(
        astHelpers.getStyleObjectExpressionFromNode node
      )

    objectExpressions

  collectColorLiteralsFromContainers: (nodes) ->
    colorLiterals = []
    nodes.forEach (node) ->
      colorLiterals ###:### = colorLiterals.concat(
        astHelpers.getColorLiteralsFromNode node
      )

    colorLiterals

  getStyleReferenceFromNode: (node) ->
    return [] unless node

    switch node.type
      when 'MemberExpression'
        styleReference = astHelpers.getStyleReferenceFromExpression node
        return [styleReference]
      when 'LogicalExpression'
        leftStyleReferences = astHelpers.getStyleReferenceFromNode node.left
        rightStyleReferences = astHelpers.getStyleReferenceFromNode node.right
        return [].concat(leftStyleReferences).concat rightStyleReferences
      when 'ConditionalExpression'
        leftStyleReferences = astHelpers.getStyleReferenceFromNode(
          node.consequent
        )
        rightStyleReferences = astHelpers.getStyleReferenceFromNode(
          node.alternate
        )
        return [].concat(leftStyleReferences).concat rightStyleReferences
      else
        return []

  getStyleObjectExpressionFromNode: (node) ->
    return [] unless node

    return [astHelpers.getStyleObjectFromExpression node] if (
      node.type is 'ObjectExpression'
    )

    switch node.type
      when 'LogicalExpression'
        leftStyleObjectExpression = astHelpers.getStyleObjectExpressionFromNode(
          node.left
        )
        rightStyleObjectExpression = astHelpers.getStyleObjectExpressionFromNode(
          node.right
        )
        return []
        .concat(leftStyleObjectExpression)
        .concat rightStyleObjectExpression
      when 'ConditionalExpression'
        leftStyleObjectExpression = astHelpers.getStyleObjectExpressionFromNode(
          node.consequent
        )
        rightStyleObjectExpression = astHelpers.getStyleObjectExpressionFromNode(
          node.alternate
        )
        return []
        .concat(leftStyleObjectExpression)
        .concat rightStyleObjectExpression
      else
        return []

  getColorLiteralsFromNode: (node) ->
    return [] unless node

    return [astHelpers.getColorLiteralsFromExpression node] if (
      node.type is 'ObjectExpression'
    )

    switch node.type
      when 'LogicalExpression'
        leftColorLiterals = astHelpers.getColorLiteralsFromNode node.left
        rightColorLiterals = astHelpers.getColorLiteralsFromNode node.right
        return [].concat(leftColorLiterals).concat rightColorLiterals
      when 'ConditionalExpression'
        leftColorLiterals = astHelpers.getColorLiteralsFromNode node.consequent
        rightColorLiterals = astHelpers.getColorLiteralsFromNode node.alternate
        return [].concat(leftColorLiterals).concat rightColorLiterals
      else
        return []

  hasArrayOfStyleReferences: (node) ->
    node and
    Boolean(
      node.type is 'JSXExpressionContainer' and
        node.expression and
        node.expression.type is 'ArrayExpression'
    )

  getStyleReferenceFromExpression: (node) ->
    result = []
    name = astHelpers.getObjectName node
    if name then result.push name

    property = astHelpers.getPropertyName node
    if property then result.push property

    result.join '.'

  getStyleObjectFromExpression: (node) ->
    obj = {}
    invalid = no
    if node.properties?.length
      node.properties.forEach (p) ->
        return if not p.value or not p.key
        if p.value.type is 'Literal'
          invalid ###:### = yes
          obj[p.key.name] = p.value.value
        else if p.value.type is 'ConditionalExpression'
          innerNode = p.value
          if (
            innerNode.consequent.type is 'Literal' or
            innerNode.alternate.type is 'Literal'
          )
            invalid ###:### = yes
            obj[p.key.name] = getSourceCode innerNode
        else if (
          p.value.type is 'UnaryExpression' and
          p.value.operator is '-' and
          p.value.argument.type is 'Literal'
        )
          invalid ###:### = yes
          obj[p.key.name] = -1 * p.value.argument.value
        else if (
          p.value.type is 'UnaryExpression' and
          p.value.operator is '+' and
          p.value.argument.type is 'Literal'
        )
          invalid ###:### = yes
          obj[p.key.name] = p.value.argument.value
    if invalid then {expression: obj, node} else undefined

  getColorLiteralsFromExpression: (node) ->
    obj = {}
    invalid = no
    if node.properties?.length
      node.properties.forEach (p) ->
        if p.key?.name and p.key.name.toLowerCase().indexOf('color') isnt -1
          if p.value.type is 'Literal'
            invalid ###:### = yes
            obj[p.key.name] = p.value.value
          else if p.value.type is 'ConditionalExpression'
            innerNode = p.value
            if (
              innerNode.consequent.type is 'Literal' or
              innerNode.alternate.type is 'Literal'
            )
              invalid ###:### = yes
              obj[p.key.name] = getSourceCode innerNode
    if invalid then {expression: obj, node} else undefined

  getObjectName: (node) ->
    return node.object.name if node?.object and node.object.name

  getPropertyName: (node) ->
    return node.property.name if node?.property and node.property.name

  getPotentialStyleReferenceFromMemberExpression: (node) ->
    return [node.object.name, node.property.name].join '.' if (
      node?.object and
      node.object.type is 'Identifier' and
      node.object.name and
      node.property and
      node.property.type is 'Identifier' and
      node.property.name and
      node.parent.type isnt 'MemberExpression'
    )

module.exports.astHelpers = astHelpers
module.exports.StyleSheets = StyleSheets
