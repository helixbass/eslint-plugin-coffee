###*
# @fileoverview Prevents usage of Function.prototype.bind and arrow functions
#               in React component props.
# @author Daniel Lo Nigro <dan.cx>
# @author Jacky Ho
###
'use strict'

propName = require 'jsx-ast-utils/propName'
Components = require '../util/react/Components'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'
jsxUtil = require '../util/react/jsx'
# {isDeclarationAssignment} = '../util/ast-utils'

# -----------------------------------------------------------------------------
# Rule Definition
# -----------------------------------------------------------------------------

violationMessageStore =
  bindCall: 'JSX props should not use .bind()'
  arrowFunc: 'JSX props should not use arrow functions'
  bindExpression: 'JSX props should not use ::'
  func: 'JSX props should not use functions'

module.exports =
  meta:
    docs:
      description:
        'Prevents usage of Function.prototype.bind and arrow functions in React component props'
      category: 'Best Practices'
      recommended: no
      url: docsUrl 'jsx-no-bind'

    schema: [
      type: 'object'
      properties:
        allowArrowFunctions:
          default: no
          type: 'boolean'
        allowBind:
          default: no
          type: 'boolean'
        allowFunctions:
          default: no
          type: 'boolean'
        ignoreRefs:
          default: no
          type: 'boolean'
        ignoreDOMComponents:
          default: no
          type: 'boolean'
      additionalProperties: no
    ]

  create: Components.detect (context) ->
    configuration = context.options[0] or {}

    # Keep track of all the variable names pointing to a bind call,
    # bind expression or an arrow function in different block statements
    blockVariableNameSets = {}

    setBlockVariableNameSet = (blockStart) ->
      blockVariableNameSets[blockStart] =
        arrowFunc: new Set()
        bindCall: new Set()
        bindExpression: new Set()
        func: new Set()

    getNodeViolationType = (node) ->
      nodeType = node.type

      return 'bindCall' if (
        not configuration.allowBind and
        nodeType is 'CallExpression' and
        node.callee.type is 'MemberExpression' and
        node.callee.property.type is 'Identifier' and
        node.callee.property.name is 'bind'
      )
      return (
        getNodeViolationType(node.test) or
        getNodeViolationType(node.consequent) or
        getNodeViolationType node.alternate
      ) if nodeType is 'ConditionalExpression'
      return 'arrowFunc' if (
        not configuration.allowArrowFunctions and
        nodeType is 'ArrowFunctionExpression'
      )
      return 'func' if (
        not configuration.allowFunctions and nodeType is 'FunctionExpression'
      )
      return 'bindExpression' if (
        not configuration.allowBind and nodeType is 'BindExpression'
      )

      null

    addVariableNameToSet = (violationType, variableName, blockStart) ->
      blockVariableNameSets[blockStart][violationType].add variableName

    getBlockStatementAncestors = (node) ->
      context
      .getAncestors node
      .reverse()
      .filter (ancestor) -> ancestor.type is 'BlockStatement'

    reportVariableViolation = (node, name, blockStart) ->
      blockSets = blockVariableNameSets[blockStart]
      violationTypes = Object.keys blockSets

      violationTypes.find (type) ->
        if blockSets[type].has name
          context.report {node, message: violationMessageStore[type]}
          return yes

        no

    findVariableViolation = (node, name) ->
      getBlockStatementAncestors(node).find (block) ->
        reportVariableViolation node, name, block.start

    BlockStatement: (node) -> setBlockVariableNameSet node.start

    AssignmentExpression: (node) ->
      return unless node.left.type is 'Identifier' and node.left.declaration
      blockAncestors = getBlockStatementAncestors node
      variableViolationType = getNodeViolationType node.right

      if (
        blockAncestors.length > 0 and variableViolationType # and # node.parent.kind is 'const' # only support const right now # TODO: should check for reassignment?
      )
        addVariableNameToSet(
          variableViolationType
          node.left.name
          blockAncestors[0].start
        )

    VariableDeclarator: (node) ->
      return unless node.init
      blockAncestors = getBlockStatementAncestors node
      variableViolationType = getNodeViolationType node.init

      if (
        blockAncestors.length > 0 and
        variableViolationType and
        node.parent.kind is 'const' # only support const right now
      )
        addVariableNameToSet(
          variableViolationType
          node.id.name
          blockAncestors[0].start
        )

    JSXAttribute: (node) ->
      isRef = configuration.ignoreRefs and propName(node) is 'ref'
      return if isRef or not node.value or not node.value.expression
      isDOMComponent = jsxUtil.isDOMComponent node.parent
      return if configuration.ignoreDOMComponents and isDOMComponent
      valueNode = node.value.expression
      valueNodeType = valueNode.type
      nodeViolationType = getNodeViolationType valueNode

      if valueNodeType is 'Identifier'
        findVariableViolation node, valueNode.name
      else if nodeViolationType
        context.report {
          node
          message: violationMessageStore[nodeViolationType]
        }
