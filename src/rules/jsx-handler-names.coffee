###*
# @fileoverview Enforce event handler naming conventions in JSX
# @author Jake Marsh
###
'use strict'

docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'Enforce event handler naming conventions in JSX'
      category: 'Stylistic Issues'
      recommended: no
      url: docsUrl 'jsx-handler-names'

    schema: [
      type: 'object'
      properties:
        eventHandlerPrefix:
          type: 'string'
        eventHandlerPropPrefix:
          type: 'string'
      additionalProperties: no
    ]

  create: (context) ->
    sourceCode = context.getSourceCode()
    configuration = context.options[0] or {}
    eventHandlerPrefix = configuration.eventHandlerPrefix or 'handle'
    eventHandlerPropPrefix = configuration.eventHandlerPropPrefix or 'on'

    EVENT_HANDLER_REGEX = new RegExp(
      "^((props\\.#{eventHandlerPropPrefix})|((.*\\.)?#{eventHandlerPrefix}))[A-Z].*$"
    )
    PROP_EVENT_HANDLER_REGEX = new RegExp(
      "^(#{eventHandlerPropPrefix}[A-Z].*|ref)$"
    )

    JSXAttribute: (node) ->
      return unless node.value?.expression?.object

      propKey =
        if typeof node.name is 'object'
          node.name.name
        else
          node.name
      propValue = sourceCode
      .getText(node.value.expression)
      .replace /^this\.|.*::|@/, ''

      return if propKey is 'ref'

      propIsEventHandler = PROP_EVENT_HANDLER_REGEX.test propKey
      propFnIsNamedCorrectly = EVENT_HANDLER_REGEX.test propValue

      if propIsEventHandler and not propFnIsNamedCorrectly
        context.report {
          node
          message: "Handler function for #{propKey} prop key must begin with '#{eventHandlerPrefix}'"
        }
      else if propFnIsNamedCorrectly and not propIsEventHandler
        context.report {
          node
          message: "Prop key for #{propValue} must begin with '#{eventHandlerPropPrefix}'"
        }
