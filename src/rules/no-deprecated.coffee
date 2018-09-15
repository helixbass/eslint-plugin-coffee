###*
# @fileoverview Prevent usage of deprecated methods
# @author Yannick Croissant
# @author Scott Feeney
# @author Sergei Startsev
###
'use strict'

Components = require '../util/react/Components'
astUtil = require '../util/react/ast'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'
pragmaUtil = require 'eslint-plugin-react/lib/util/pragma'
versionUtil = require 'eslint-plugin-react/lib/util/version'
{isDeclarationAssignment} = require '../util/ast-utils'

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------

MODULES =
  react: ['React']
  'react-addons-perf': ['ReactPerf', 'Perf']

DEPRECATED_MESSAGE =
  '{{oldMethod}} is deprecated since React {{version}}{{newMethod}}{{refs}}'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'Prevent usage of deprecated methods'
      category: 'Best Practices'
      recommended: yes
      url: docsUrl 'no-deprecated'
    schema: []

  create: Components.detect (context, components, utils) ->
    sourceCode = context.getSourceCode()
    pragma = pragmaUtil.getFromContext context

    getDeprecated = ->
      deprecated = {}
      # 0.12.0
      deprecated["#{pragma}.renderComponent"] = ['0.12.0', "#{pragma}.render"]
      deprecated["#{pragma}.renderComponentToString"] = [
        '0.12.0'
        "#{pragma}.renderToString"
      ]
      deprecated["#{pragma}.renderComponentToStaticMarkup"] = [
        '0.12.0'
        "#{pragma}.renderToStaticMarkup"
      ]
      deprecated["#{pragma}.isValidComponent"] = [
        '0.12.0'
        "#{pragma}.isValidElement"
      ]
      deprecated["#{pragma}.PropTypes.component"] = [
        '0.12.0'
        "#{pragma}.PropTypes.element"
      ]
      deprecated["#{pragma}.PropTypes.renderable"] = [
        '0.12.0'
        "#{pragma}.PropTypes.node"
      ]
      deprecated["#{pragma}.isValidClass"] = ['0.12.0']
      deprecated['this.transferPropsTo'] = ['0.12.0', 'spread operator ({...})']
      # 0.13.0
      deprecated["#{pragma}.addons.classSet"] = [
        '0.13.0'
        'the npm module classnames'
      ]
      deprecated["#{pragma}.addons.cloneWithProps"] = [
        '0.13.0'
        "#{pragma}.cloneElement"
      ]
      # 0.14.0
      deprecated["#{pragma}.render"] = ['0.14.0', 'ReactDOM.render']
      deprecated["#{pragma}.unmountComponentAtNode"] = [
        '0.14.0'
        'ReactDOM.unmountComponentAtNode'
      ]
      deprecated["#{pragma}.findDOMNode"] = ['0.14.0', 'ReactDOM.findDOMNode']
      deprecated["#{pragma}.renderToString"] = [
        '0.14.0'
        'ReactDOMServer.renderToString'
      ]
      deprecated["#{pragma}.renderToStaticMarkup"] = [
        '0.14.0'
        'ReactDOMServer.renderToStaticMarkup'
      ]
      # 15.0.0
      deprecated["#{pragma}.addons.LinkedStateMixin"] = ['15.0.0']
      deprecated['ReactPerf.printDOM'] = ['15.0.0', 'ReactPerf.printOperations']
      deprecated['Perf.printDOM'] = ['15.0.0', 'Perf.printOperations']
      deprecated['ReactPerf.getMeasurementsSummaryMap'] = [
        '15.0.0'
        'ReactPerf.getWasted'
      ]
      deprecated['Perf.getMeasurementsSummaryMap'] = [
        '15.0.0'
        'Perf.getWasted'
      ]
      # 15.5.0
      deprecated["#{pragma}.createClass"] = [
        '15.5.0'
        'the npm module create-react-class'
      ]
      deprecated["#{pragma}.addons.TestUtils"] = [
        '15.5.0'
        'ReactDOM.TestUtils'
      ]
      deprecated["#{pragma}.PropTypes"] = [
        '15.5.0'
        'the npm module prop-types'
      ]
      # 15.6.0
      deprecated["#{pragma}.DOM"] = [
        '15.6.0'
        'the npm module react-dom-factories'
      ]
      # 16.3.0
      deprecated.componentWillMount = [
        '16.3.0'
        'UNSAFE_componentWillMount'
        'https://reactjs.org/docs/react-component.html#unsafe_componentwillmount'
      ]
      deprecated.componentWillReceiveProps = [
        '16.3.0'
        'UNSAFE_componentWillReceiveProps'
        'https://reactjs.org/docs/react-component.html#unsafe_componentwillreceiveprops'
      ]
      deprecated.componentWillUpdate = [
        '16.3.0'
        'UNSAFE_componentWillUpdate'
        'https://reactjs.org/docs/react-component.html#unsafe_componentwillupdate'
      ]
      deprecated

    isDeprecated = (method) ->
      deprecated = getDeprecated()

      deprecated?[method] and
        deprecated[method][0] and
        versionUtil.testReactVersion context, deprecated[method][0]

    checkDeprecation = (node, methodName, methodNode) ->
      return unless isDeprecated methodName
      deprecated = getDeprecated()
      version = deprecated[methodName][0]
      newMethod = deprecated[methodName][1]
      refs = deprecated[methodName][2]
      context.report
        node: methodNode or node
        message: DEPRECATED_MESSAGE
        data: {
          oldMethod: methodName
          version
          newMethod: if newMethod then ", use #{newMethod} instead" else ''
          refs: if refs then ", see #{refs}" else ''
        }

    getReactModuleName = (node) ->
      moduleName = no
      return moduleName unless node
      for own _, module of MODULES
        moduleName = module.find (name) -> name is node.name
        break if moduleName
      moduleName

    ###*
    # Returns life cycle methods if available
    # @param {ASTNode} node The AST node being checked.
    # @returns {Array} The array of methods.
    ###
    getLifeCycleMethods = (node) ->
      properties = astUtil.getComponentProperties node
      properties.map (property) ->
        name: astUtil.getPropertyName property
        node: astUtil.getPropertyNameNode property

    ###*
    # Checks life cycle methods
    # @param {ASTNode} node The AST node being checked.
    ###
    checkLifeCycleMethods = (node) ->
      if utils.isES5Component(node) or utils.isES6Component node
        methods = getLifeCycleMethods node
        methods.forEach (method) ->
          checkDeprecation node, method.name, method.node

    # --------------------------------------------------------------------------
    # Public
    # --------------------------------------------------------------------------

    MemberExpression: (node) -> checkDeprecation node, sourceCode.getText node

    ImportDeclaration: (node) ->
      isReactImport = typeof MODULES[node.source.value] isnt 'undefined'
      return unless isReactImport
      node.specifiers.forEach (specifier) ->
        return unless specifier.imported
        checkDeprecation(
          node
          "#{MODULES[node.source.value][0]}.#{specifier.imported.name}"
        )

    VariableDeclarator: (node) ->
      reactModuleName = getReactModuleName node.init
      isRequire = node.init?.callee and node.init.callee.name is 'require'
      isReactRequire =
        node.init?.arguments and
        node.init.arguments.length and
        typeof MODULES[node.init.arguments[0].value] isnt 'undefined'
      isDestructuring = node.id and node.id.type is 'ObjectPattern'

      return if (
        not (isDestructuring and reactModuleName) and
        not (isDestructuring and isRequire and isReactRequire)
      )
      node.id.properties.forEach (property) ->
        checkDeprecation(
          node
          "#{reactModuleName or pragma}.#{property.key.name}"
        )

    AssignmentExpression: (node) ->
      return unless isDeclarationAssignment node
      {left, right} = node
      reactModuleName = getReactModuleName right
      isRequire = right?.callee?.name is 'require'
      isReactRequire =
        right?.arguments?.length and MODULES[right.arguments[0].value]?
      isDestructuring = left.type is 'ObjectPattern'
      return unless isDestructuring
      return unless reactModuleName or (isRequire and isReactRequire)
      left.properties.forEach (property) ->
        checkDeprecation(
          node
          "#{reactModuleName or pragma}.#{property.key.name}"
        )

    ClassDeclaration: checkLifeCycleMethods
    ClassExpression: checkLifeCycleMethods
    ObjectExpression: checkLifeCycleMethods
