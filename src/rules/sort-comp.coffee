###*
# @fileoverview Enforce component methods order
# @author Yannick Croissant
###
'use strict'

{has} = require 'lodash'
util = require 'util'

Components = require '../util/react/Components'
astUtil = require '../util/react/ast'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

defaultConfig =
  order: ['static-methods', 'lifecycle', 'everything-else', 'render']
  groups:
    lifecycle: [
      'displayName'
      'propTypes'
      'contextTypes'
      'childContextTypes'
      'mixins'
      'statics'
      'defaultProps'
      'constructor'
      'getDefaultProps'
      'state'
      'getInitialState'
      'getChildContext'
      'getDerivedStateFromProps'
      'componentWillMount'
      'UNSAFE_componentWillMount'
      'componentDidMount'
      'componentWillReceiveProps'
      'UNSAFE_componentWillReceiveProps'
      'shouldComponentUpdate'
      'componentWillUpdate'
      'UNSAFE_componentWillUpdate'
      'getSnapshotBeforeUpdate'
      'componentDidUpdate'
      'componentDidCatch'
      'componentWillUnmount'
    ]

###*
# Get the methods order from the default config and the user config
# @param {Object} userConfig The user configuration.
# @returns {Array} Methods order
###
getMethodsOrder = (userConfig) ->
  userConfig or= {}

  groups = util._extend defaultConfig.groups, userConfig.groups
  order = userConfig.order or defaultConfig.order

  config = []
  for entry in order
    if has groups, entry
      config = config.concat groups[entry]
    else
      config.push entry

  config

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

module.exports = {
  meta:
    docs:
      description: 'Enforce component methods order'
      category: 'Stylistic Issues'
      recommended: no
      url: docsUrl 'sort-comp'

    schema: [
      type: 'object'
      properties:
        order:
          type: 'array'
          items:
            type: 'string'
        groups:
          type: 'object'
          patternProperties:
            '^.*$':
              type: 'array'
              items:
                type: 'string'
      additionalProperties: no
    ]

  create: Components.detect (context, components) ->
    errors = {}

    MISPOSITION_MESSAGE = '{{propA}} should be placed {{position}} {{propB}}'

    methodsOrder = getMethodsOrder context.options[0]

    # --------------------------------------------------------------------------
    # Public
    # --------------------------------------------------------------------------

    regExpRegExp = /\/(.*)\/([g|y|i|m]*)/

    ###*
    # Get indexes of the matching patterns in methods order configuration
    # @param {Object} method - Method metadata.
    # @returns {Array} The matching patterns indexes. Return [Infinity] if there is no match.
    ###
    getRefPropIndexes = (method) ->
      methodGroupIndexes = []

      methodsOrder.forEach (currentGroup, groupIndex) ->
        if currentGroup is 'getters'
          if method.getter then methodGroupIndexes.push groupIndex
        else if currentGroup is 'setters'
          if method.setter then methodGroupIndexes.push groupIndex
        else if currentGroup is 'type-annotations'
          if method.typeAnnotation then methodGroupIndexes.push groupIndex
        else if currentGroup is 'static-methods'
          if method.static then methodGroupIndexes.push groupIndex
        else if currentGroup is 'instance-variables'
          if method.instanceVariable then methodGroupIndexes.push groupIndex
        else if currentGroup is 'instance-methods'
          if method.instanceMethod then methodGroupIndexes.push groupIndex
        else if (
          currentGroup in [
            'displayName'
            'propTypes'
            'contextTypes'
            'childContextTypes'
            'mixins'
            'statics'
            'defaultProps'
            'constructor'
            'getDefaultProps'
            'state'
            'getInitialState'
            'getChildContext'
            'getDerivedStateFromProps'
            'componentWillMount'
            'UNSAFE_componentWillMount'
            'componentDidMount'
            'componentWillReceiveProps'
            'UNSAFE_componentWillReceiveProps'
            'shouldComponentUpdate'
            'componentWillUpdate'
            'UNSAFE_componentWillUpdate'
            'getSnapshotBeforeUpdate'
            'componentDidUpdate'
            'componentDidCatch'
            'componentWillUnmount'
            'render'
          ]
        )
          methodGroupIndexes.push groupIndex if currentGroup is method.name
        else
          # Is the group a regex?
          isRegExp = currentGroup.match regExpRegExp
          if isRegExp
            isMatching = new RegExp(isRegExp[1], isRegExp[2]).test method.name
            methodGroupIndexes.push groupIndex if isMatching
          else if currentGroup is method.name
            methodGroupIndexes.push groupIndex

      # No matching pattern, return 'everything-else' index
      if methodGroupIndexes.length is 0
        everythingElseIndex = methodsOrder.indexOf 'everything-else'

        unless everythingElseIndex is -1
          methodGroupIndexes.push everythingElseIndex
        else
          # No matching pattern and no 'everything-else' group
          methodGroupIndexes.push Infinity

      methodGroupIndexes

    ###*
    # Get properties name
    # @param {Object} node - Property.
    # @returns {String} Property name.
    ###
    getPropertyName = (node) ->
      return 'getter functions' if node.kind is 'get'

      return 'setter functions' if node.kind is 'set'

      astUtil.getPropertyName node

    ###*
    # Store a new error in the error list
    # @param {Object} propA - Mispositioned property.
    # @param {Object} propB - Reference property.
    ###
    storeError = (propA, propB) ->
      # Initialize the error object if needed
      unless errors[propA.index]
        errors[propA.index] =
          node: propA.node
          score: 0
          closest:
            distance: Infinity
            ref:
              node: null
              index: 0
      # Increment the prop score
      errors[propA.index].score++
      # Stop here if we already have pushed another node at this position
      return unless (
        getPropertyName(errors[propA.index].node) is getPropertyName propA.node
      )
      # Stop here if we already have a closer reference
      return if (
        Math.abs(propA.index - propB.index) >
        errors[propA.index].closest.distance
      )
      # Update the closest reference
      errors[propA.index].closest.distance = Math.abs propA.index - propB.index
      errors[propA.index].closest.ref.node = propB.node
      errors[propA.index].closest.ref.index = propB.index

    ###*
    # Dedupe errors, only keep the ones with the highest score and delete the others
    ###
    dedupeErrors = ->
      for own i, error of errors
        {index} = error.closest.ref
        continue unless errors[index]
        if error.score > errors[index].score
          delete errors[index]
        else
          delete errors[i]

    ###*
    # Report errors
    ###
    reportErrors = ->
      dedupeErrors()

      for own i, error of errors
        nodeA = error.node
        nodeB = error.closest.ref.node
        indexA = i
        indexB = error.closest.ref.index

        context.report
          node: nodeA
          message: MISPOSITION_MESSAGE
          data:
            propA: getPropertyName nodeA
            propB: getPropertyName nodeB
            position: if indexA < indexB then 'before' else 'after'

    ###*
    # Compare two properties and find out if they are in the right order
    # @param {Array} propertiesInfos Array containing all the properties metadata.
    # @param {Object} propA First property name and metadata
    # @param {Object} propB Second property name.
    # @returns {Object} Object containing a correct true/false flag and the correct indexes for the two properties.
    ###
    comparePropsOrder = (propertiesInfos, propA, propB) ->
      # Get references indexes (the correct position) for given properties
      refIndexesA = getRefPropIndexes propA
      refIndexesB = getRefPropIndexes propB

      # Get current indexes for given properties
      classIndexA = propertiesInfos.indexOf propA
      classIndexB = propertiesInfos.indexOf propB

      # Loop around the references indexes for the 1st property
      for refIndexA in refIndexesA
        for refIndexB in refIndexesB
          return {
            correct: yes
            indexA: classIndexA
            indexB: classIndexB
          } if (
            refIndexA is refIndexB or
            (refIndexA < refIndexB and classIndexA < classIndexB) or
            (refIndexA > refIndexB and classIndexA > classIndexB)
          )

      # Loop around the properties for the 2nd property (for comparison)
      # Comparing the same properties
      # 1st property is placed before the 2nd one in reference and in current component
      # 1st property is placed after the 2nd one in reference and in current component
      # We did not find any correct match between reference and current component
      correct: no
      indexA: refIndexA
      indexB: refIndexB

    ###*
    # Check properties order from a properties list and store the eventual errors
    # @param {Array} properties Array containing all the properties.
    ###
    checkPropsOrder = (properties) ->
      propertiesInfos = properties.map (node) ->
        name: getPropertyName node
        getter: node.kind is 'get'
        setter: node.kind is 'set'
        static: node.static
        instanceVariable:
          not node.static and
          node.type is 'ClassProperty' and
          node.value and
          not astUtil.isFunctionLikeExpression node.value
        instanceMethod:
          not node.static and
          node.type is 'ClassProperty' and
          node.value and
          astUtil.isFunctionLikeExpression node.value
        typeAnnotation: !!node.typeAnnotation and node.value is null

      # Loop around the properties
      for propA, i in propertiesInfos
        # Loop around the properties a second time (for comparison)
        for propB, k in propertiesInfos
          continue if i is k

          # Compare the properties order
          order = comparePropsOrder propertiesInfos, propA, propB

          # Continue to next comparison is order is correct
          continue if order.correct is yes

          # Store an error if the order is incorrect
          storeError
            node: properties[i]
            index: order.indexA
          ,
            node: properties[k]
            index: order.indexB

    'Program:exit': ->
      for own _, component of components.list()
        properties = astUtil.getComponentProperties component.node
        checkPropsOrder properties

      reportErrors()

  defaultConfig
}
