###*
# @fileoverview Android and IOS components should be
# used in platform specific React Native components.
# @author Tom Hastjarjanto
###

'use strict'

module.exports = (context) ->
  reactComponents = []
  androidMessage = 'Android components should be placed in android files'
  iosMessage = 'IOS components should be placed in ios files'
  conflictMessage = "IOS and Android components can't be mixed"
  iosPathRegex =
    if context.options[0]?.iosPathRegex
      new RegExp context.options[0].iosPathRegex
    else
      /\.ios\.js$/
  androidPathRegex =
    if context.options[0]?.androidPathRegex
      new RegExp context.options[0].androidPathRegex
    else
      /\.android\.js$/

  getName = (node) ->
    if node.type is 'Property'
      key = node.key or node.argument
      return (if key.type is 'Identifier' then key.name else key.value)
    return node.name if node.type is 'Identifier'

  hasNodeWithName = (nodes, name) ->
    nodes.some (node) ->
      nodeName = getName node
      nodeName?.includes name

  reportErrors = (components, filename) ->
    containsAndroidAndIOS =
      hasNodeWithName(components, 'IOS') and
      hasNodeWithName components, 'Android'

    components.forEach (node) ->
      propName = getName node

      if propName.includes('IOS') and not filename.match iosPathRegex
        context.report node,
          if containsAndroidAndIOS then conflictMessage else iosMessage

      if propName.includes('Android') and not filename.match androidPathRegex
        context.report node,
          if containsAndroidAndIOS then conflictMessage else androidMessage

  AssignmentExpression: (node) ->
    destructuring = node.left.type is 'ObjectPattern'
    statelessDestructuring = destructuring and node.right.name is 'React'
    if destructuring and statelessDestructuring
      reactComponents ###:### = reactComponents.concat node.left.properties
  VariableDeclarator: (node) ->
    destructuring = node.init and node.id and node.id.type is 'ObjectPattern'
    statelessDestructuring = destructuring and node.init.name is 'React'
    if destructuring and statelessDestructuring
      reactComponents ###:### = reactComponents.concat node.id.properties
  ImportDeclaration: (node) ->
    if node.source.value is 'react-native'
      node.specifiers.forEach (importSpecifier) ->
        if importSpecifier.type is 'ImportSpecifier'
          reactComponents ###:### = reactComponents.concat(
            importSpecifier.imported
          )
  'Program:exit': ->
    filename = context.getFilename()
    reportErrors reactComponents, filename

module.exports.schema = [
  type: 'object'
  properties:
    androidPathRegex:
      type: 'string'
    iosPathRegex:
      type: 'string'
  additionalProperties: no
]
