###*
# @fileoverview Prevent multiple component definition per file
# @author Yannick Croissant
###
'use strict'

Components = require '../util/react/Components'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'Prevent multiple component definition per file'
      category: 'Stylistic Issues'
      recommended: no
      url: docsUrl 'no-multi-comp'

    schema: [
      type: 'object'
      properties:
        ignoreStateless:
          default: no
          type: 'boolean'
      additionalProperties: no
    ]

  create: Components.detect (context, components) ->
    configuration = context.options[0] or {}
    ignoreStateless = configuration.ignoreStateless or no

    MULTI_COMP_MESSAGE = 'Declare only one React component per file'

    ###*
    # Checks if the component is ignored
    # @param {Object} component The component being checked.
    # @returns {Boolean} True if the component is ignored, false if not.
    ###
    isIgnored = (component) ->
      ignoreStateless and /Function/.test component.node.type

    # --------------------------------------------------------------------------
    # Public
    # --------------------------------------------------------------------------

    'Program:exit': ->
      return if components.length() <= 1

      list = components.list()
      i = 0

      for own _, component of list
        continue if isIgnored(component) or ++i is 1
        context.report
          node: component.node
          message: MULTI_COMP_MESSAGE
