###*
# @fileoverview Report "this" being used in stateless functional components.
###
'use strict'

Components = require '../util/react/Components'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------

ERROR_MESSAGE = 'Stateless functional components should not use this'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'Report "this" being used in stateless components'
      category: 'Possible Errors'
      recommended: no
      url: docsUrl 'no-this-in-sfc'
    schema: []

  create: Components.detect (context, components, utils) ->
    MemberExpression: (node) ->
      return unless node.object.type is 'ThisExpression'
      component = components.get utils.getParentStatelessComponent()
      return unless component
      context.report {
        node
        message: ERROR_MESSAGE
      }
