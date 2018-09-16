###*
# @fileoverview Prevent usage of the return value of React.render
# @author Dustan Kasten
###
'use strict'

versionUtil = require 'eslint-plugin-react/lib/util/version'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'Prevent usage of the return value of React.render'
      category: 'Best Practices'
      recommended: yes
      url: docsUrl 'no-render-return-value'
    schema: []

  create: (context) ->
    # --------------------------------------------------------------------------
    # Public
    # --------------------------------------------------------------------------

    CallExpression: (node) ->
      {callee, parent} = node
      return unless callee.type is 'MemberExpression'

      calleeObjectName = /^ReactDOM$/
      if versionUtil.testReactVersion context, '15.0.0'
        calleeObjectName = /^ReactDOM$/
      else if versionUtil.testReactVersion context, '0.14.0'
        calleeObjectName = /^React(DOM)?$/
      else if versionUtil.testReactVersion context, '0.13.0'
        calleeObjectName = /^React$/

      return unless (
        callee.object.type is 'Identifier' and
        calleeObjectName.test(callee.object.name) and
        callee.property.name is 'render'
      )

      if (
        parent.type in [
          'VariableDeclarator'
          'Property'
          'ReturnStatement'
          'ArrowFunctionExpression'
          'AssignmentExpression'
        ] or node.returns
      )
        context.report
          node: callee
          message: "Do not depend on the return value from #{
            callee.object.name
          }.render"
