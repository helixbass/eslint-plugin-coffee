###*
# @fileoverview Enforce stateless components to be written as a pure function
# @author Yannick Croissant
# @author Alberto Rodríguez
# @copyright 2015 Alberto Rodríguez. All rights reserved.
###
'use strict'

Components = require '../util/react/Components'
versionUtil = require 'eslint-plugin-react/lib/util/version'
astUtil = require '../util/react/ast'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'
{isDeclarationAssignment} = require '../util/ast-utils'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'Enforce stateless components to be written as a pure function'
      category: 'Stylistic Issues'
      recommended: no
      url: docsUrl 'prefer-stateless-function'
    schema: [
      type: 'object'
      properties:
        ignorePureComponents:
          default: no
          type: 'boolean'
      additionalProperties: no
    ]

  create: Components.detect (context, components, utils) ->
    configuration = context.options[0] or {}
    ignorePureComponents = configuration.ignorePureComponents or no

    sourceCode = context.getSourceCode()

    # --------------------------------------------------------------------------
    # Public
    # --------------------------------------------------------------------------

    ###*
    # Checks whether a given array of statements is a single call of `super`.
    # @see ESLint no-useless-constructor rule
    # @param {ASTNode[]} body - An array of statements to check.
    # @returns {boolean} `true` if the body is a single call of `super`.
    ###
    isSingleSuperCall = (body) ->
      body.length is 1 and
      body[0].type is 'ExpressionStatement' and
      body[0].expression.type is 'CallExpression' and
      body[0].expression.callee.type is 'Super'

    ###*
    # Checks whether a given node is a pattern which doesn't have any side effects.
    # Default parameters and Destructuring parameters can have side effects.
    # @see ESLint no-useless-constructor rule
    # @param {ASTNode} node - A pattern node.
    # @returns {boolean} `true` if the node doesn't have any side effects.
    ###
    isSimple = (node) -> node.type in ['Identifier', 'RestElement']

    ###*
    # Checks whether a given array of expressions is `...arguments` or not.
    # `super(...arguments)` passes all arguments through.
    # @see ESLint no-useless-constructor rule
    # @param {ASTNode[]} superArgs - An array of expressions to check.
    # @returns {boolean} `true` if the superArgs is `...arguments`.
    ###
    isSpreadArguments = (superArgs) ->
      superArgs.length is 1 and
      superArgs[0].type is 'SpreadElement' and
      superArgs[0].argument.type is 'Identifier' and
      superArgs[0].argument.name is 'arguments'

    ###*
    # Checks whether given 2 nodes are identifiers which have the same name or not.
    # @see ESLint no-useless-constructor rule
    # @param {ASTNode} ctorParam - A node to check.
    # @param {ASTNode} superArg - A node to check.
    # @returns {boolean} `true` if the nodes are identifiers which have the same
    #      name.
    ###
    isValidIdentifierPair = (ctorParam, superArg) ->
      ctorParam.type is 'Identifier' and
      superArg.type is 'Identifier' and
      ctorParam.name is superArg.name

    ###*
    # Checks whether given 2 nodes are a rest/spread pair which has the same values.
    # @see ESLint no-useless-constructor rule
    # @param {ASTNode} ctorParam - A node to check.
    # @param {ASTNode} superArg - A node to check.
    # @returns {boolean} `true` if the nodes are a rest/spread pair which has the
    #      same values.
    ###
    isValidRestSpreadPair = (ctorParam, superArg) ->
      ctorParam.type is 'RestElement' and
      superArg.type is 'SpreadElement' and
      isValidIdentifierPair ctorParam.argument, superArg.argument

    ###*
    # Checks whether given 2 nodes have the same value or not.
    # @see ESLint no-useless-constructor rule
    # @param {ASTNode} ctorParam - A node to check.
    # @param {ASTNode} superArg - A node to check.
    # @returns {boolean} `true` if the nodes have the same value or not.
    ###
    isValidPair = (ctorParam, superArg) ->
      isValidIdentifierPair(ctorParam, superArg) or
      isValidRestSpreadPair ctorParam, superArg

    ###*
    # Checks whether the parameters of a constructor and the arguments of `super()`
    # have the same values or not.
    # @see ESLint no-useless-constructor rule
    # @param {ASTNode} ctorParams - The parameters of a constructor to check.
    # @param {ASTNode} superArgs - The arguments of `super()` to check.
    # @returns {boolean} `true` if those have the same values.
    ###
    isPassingThrough = (ctorParams, superArgs) ->
      return no unless ctorParams.length is superArgs.length

      i = 0
      while i < ctorParams.length
        return no unless isValidPair ctorParams[i], superArgs[i]
        ++i

      yes

    ###*
    # Checks whether the constructor body is a redundant super call.
    # @see ESLint no-useless-constructor rule
    # @param {Array} body - constructor body content.
    # @param {Array} ctorParams - The params to check against super call.
    # @returns {boolean} true if the construtor body is redundant
    ###
    isRedundantSuperCall = (body, ctorParams) ->
      isSingleSuperCall(body) and
      ctorParams.every(isSimple) and
      (isSpreadArguments(body[0].expression.arguments) or
        isPassingThrough ctorParams, body[0].expression.arguments)

    ###*
    # Check if a given AST node have any other properties the ones available in stateless components
    # @param {ASTNode} node The AST node being checked.
    # @returns {Boolean} True if the node has at least one other property, false if not.
    ###
    hasOtherProperties = (node) ->
      properties = astUtil.getComponentProperties node
      properties.some (property) ->
        name = astUtil.getPropertyName property
        isDisplayName = name is 'displayName'
        isPropTypes =
          name is 'propTypes' or (name is 'props' and property.typeAnnotation)
        contextTypes = name is 'contextTypes'
        defaultProps = name is 'defaultProps'
        isUselessConstructor =
          property.kind is 'constructor' and
          isRedundantSuperCall property.value.body.body, property.value.params
        isRender = name is 'render'
        not isDisplayName and
          not isPropTypes and
          not contextTypes and
          not defaultProps and
          not isUselessConstructor and
          not isRender

    ###*
    # Mark component as pure as declared
    # @param {ASTNode} node The AST node being checked.
    ###
    markSCUAsDeclared = (node) ->
      components.set node, hasSCU: yes

    ###*
    # Mark childContextTypes as declared
    # @param {ASTNode} node The AST node being checked.
    ###
    markChildContextTypesAsDeclared = (node) ->
      components.set node, hasChildContextTypes: yes

    ###*
    # Mark a setState as used
    # @param {ASTNode} node The AST node being checked.
    ###
    markThisAsUsed = (node) ->
      components.set node, useThis: yes

    ###*
    # Mark a props or context as used
    # @param {ASTNode} node The AST node being checked.
    ###
    markPropsOrContextAsUsed = (node) ->
      components.set node, usePropsOrContext: yes

    ###*
    # Mark a ref as used
    # @param {ASTNode} node The AST node being checked.
    ###
    markRefAsUsed = (node) ->
      components.set node, useRef: yes

    ###*
    # Mark return as invalid
    # @param {ASTNode} node The AST node being checked.
    ###
    markReturnAsInvalid = (node) ->
      components.set node, invalidReturn: yes

    ###*
    # Mark a ClassDeclaration as having used decorators
    # @param {ASTNode} node The AST node being checked.
    ###
    markDecoratorsAsUsed = (node) ->
      components.set node, useDecorators: yes

    visitClass = (node) ->
      if ignorePureComponents and utils.isPureComponent node
        markSCUAsDeclared node

      if node.decorators?.length then markDecoratorsAsUsed node

    ClassDeclaration: visitClass
    ClassExpression: visitClass

    # Mark `this` destructuring as a usage of `this`
    VariableDeclarator: (node) ->
      # Ignore destructuring on other than `this`
      return unless (
        node.id?.type is 'ObjectPattern' and node.init?.type is 'ThisExpression'
      )
      # Ignore `props` and `context`
      useThis = node.id.properties.some (property) ->
        name = astUtil.getPropertyName property
        name isnt 'props' and name isnt 'context'
      unless useThis
        markPropsOrContextAsUsed node
        return
      markThisAsUsed node

    AssignmentExpression: (node) ->
      return unless isDeclarationAssignment node
      {left, right} = node
      # Ignore destructuring on other than `this`
      return unless (
        left.type is 'ObjectPattern' and right.type is 'ThisExpression'
      )
      # Ignore `props` and `context`
      useThis = left.properties.some (property) ->
        name = astUtil.getPropertyName property
        name isnt 'props' and name isnt 'context'
      unless useThis
        markPropsOrContextAsUsed node
        return
      markThisAsUsed node

    # Mark `this` usage
    MemberExpression: (node) ->
      unless node.object.type is 'ThisExpression'
        if node.property and node.property.name is 'childContextTypes'
          component = utils.getRelatedComponent node
          return unless component
          markChildContextTypesAsDeclared component.node
          return
        return
        # Ignore calls to `this.props` and `this.context`
      else if (
        (node.property.name or node.property.value) is 'props' or
        (node.property.name or node.property.value) is 'context'
      )
        markPropsOrContextAsUsed node
        return
      markThisAsUsed node

    # Mark `ref` usage
    JSXAttribute: (node) ->
      name = sourceCode.getText node.name
      return unless name is 'ref'
      markRefAsUsed node

    # Mark `render` that do not return some JSX
    ReturnStatement: (node) ->
      scope = context.getScope()
      while scope
        blockNode = scope.block?.parent
        if blockNode and blockNode.type in ['MethodDefinition', 'Property']
          break
        scope = scope.upper
      isRender = blockNode?.key and blockNode.key.name is 'render'
      allowNull = versionUtil.testReactVersion context, '15.0.0' # Stateless components can return null since React 15
      isReturningJSX = utils.isReturningJSX node, not allowNull
      isReturningNull = node.argument and node.argument.value in [null, no]
      return if (
        not isRender or
        (allowNull and (isReturningJSX or isReturningNull)) or
        (not allowNull and isReturningJSX)
      )
      markReturnAsInvalid node

    'Program:exit': ->
      list = components.list()
      for own _, component of list
        continue if (
          hasOtherProperties(component.node) or
          component.useThis or
          component.useRef or
          component.invalidReturn or
          component.hasChildContextTypes or
          component.useDecorators or
          (not utils.isES5Component(component.node) and
            not utils.isES6Component component.node)
        )

        continue if component.hasSCU and component.usePropsOrContext
        context.report
          node: component.node
          message: 'Component should be written as a pure function'
