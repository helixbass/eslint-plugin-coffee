###*
# @fileoverview Enforce consistent usage of destructuring assignment of props, state, and context.
### #
'use strict'

Components = require '../util/react/Components'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'
{isDeclarationAssignment} = require '../util/ast-utils'

DEFAULT_OPTION = 'always'

module.exports =
  meta:
    docs:
      description:
        'Enforce consistent usage of destructuring assignment of props, state, and context'
      category: 'Stylistic Issues'
      recommended: no
      url: docsUrl 'destructuring-assignment'
    schema: [
      type: 'string'
      enum: ['always', 'never']
    ,
      type: 'object'
      properties:
        ignoreClassFields:
          type: 'boolean'
      additionalProperties: no
    ]

  create: Components.detect (context, components, utils) ->
    configuration = context.options[0] or DEFAULT_OPTION
    ignoreClassFields =
      (context.options[1] and context.options[1].ignoreClassFields is yes) or no

    ###*
    # Checks if a prop is being assigned a value props.bar = 'bar'
    # @param {ASTNode} node The AST node being checked.
    # @returns {Boolean}
    ###
    isAssignmentToProp = (node) ->
      node.parent?.type is 'AssignmentExpression' and node.parent.left is node

    ###*
    # @param {ASTNode} node We expect either an ArrowFunctionExpression,
    #   FunctionDeclaration, or FunctionExpression
    ###
    handleStatelessComponent = (node) ->
      destructuringProps =
        node.params?[0] and node.params[0].type is 'ObjectPattern'
      destructuringContext =
        node.params?[1] and node.params[1].type is 'ObjectPattern'

      if (
        destructuringProps and
        components.get(node) and
        configuration is 'never'
      )
        context.report {
          node
          message:
            'Must never use destructuring props assignment in SFC argument'
        }
      else if (
        destructuringContext and
        components.get(node) and
        configuration is 'never'
      )
        context.report {
          node
          message:
            'Must never use destructuring context assignment in SFC argument'
        }

    handleSFCUsage = (node) ->
      # props.aProp || context.aProp
      isPropUsed =
        node.object.name in ['props', 'context'] and not isAssignmentToProp node
      if isPropUsed and configuration is 'always'
        context.report {
          node
          message: "Must use destructuring #{node.object.name} assignment"
        }

    isInClassProperty = (node) ->
      curNode = node.parent
      while curNode
        return yes if curNode.type is 'ClassProperty'
        curNode = curNode.parent
      no

    handleClassUsage = (node) ->
      # this.props.Aprop || this.context.aProp || this.state.aState
      isPropUsed =
        node.object.type is 'MemberExpression' and
        node.object.object.type is 'ThisExpression' and
        node.object.property.name in ['props', 'context', 'state'] and
        not isAssignmentToProp node

      if (
        isPropUsed and
        configuration is 'always' and
        not (ignoreClassFields and isInClassProperty node)
      )
        context.report {
          node
          message: "Must use destructuring #{
            node.object.property.name
          } assignment"
        }

    FunctionDeclaration: handleStatelessComponent

    ArrowFunctionExpression: handleStatelessComponent

    FunctionExpression: handleStatelessComponent

    MemberExpression: (node) ->
      SFCComponent = components.get context.getScope(node).block
      classComponent = utils.getParentComponent node
      if SFCComponent then handleSFCUsage node
      if classComponent then handleClassUsage node, classComponent

    VariableDeclarator: (node) ->
      classComponent = utils.getParentComponent node
      SFCComponent = components.get context.getScope(node).block

      destructuring = node.init and node.id and node.id.type is 'ObjectPattern'
      # let {foo} = props;
      destructuringSFC =
        destructuring and node.init.name in ['props', 'context']
      # let {foo} = this.props;
      destructuringClass =
        destructuring and
        node.init.object and
        node.init.object.type is 'ThisExpression' and
        node.init.property.name in ['props', 'context', 'state']

      if SFCComponent and destructuringSFC and configuration is 'never'
        context.report {
          node
          message: "Must never use destructuring #{node.init.name} assignment"
        }

      if (
        classComponent and
        destructuringClass and
        configuration is 'never' and
        not (ignoreClassFields and node.parent.type is 'ClassProperty')
      )
        context.report {
          node
          message: "Must never use destructuring #{
            node.init.property.name
          } assignment"
        }

    AssignmentExpression: (node) ->
      return unless isDeclarationAssignment node
      {left, right} = node
      classComponent = utils.getParentComponent node
      SFCComponent = components.get context.getScope(node).block

      destructuring = left.type is 'ObjectPattern'
      # let {foo} = props;
      destructuringSFC = destructuring and right.name in ['props', 'context']
      # let {foo} = this.props;
      destructuringClass =
        destructuring and
        right.object?.type is 'ThisExpression' and
        right.property.name in ['props', 'context', 'state']

      if SFCComponent and destructuringSFC and configuration is 'never'
        context.report {
          node
          message: "Must never use destructuring #{right.name} assignment"
        }

      if (
        classComponent and
        destructuringClass and
        configuration is 'never' and
        not (ignoreClassFields and node.parent.type is 'ClassProperty')
      )
        context.report {
          node
          message: "Must never use destructuring #{
            right.property.name
          } assignment"
        }
