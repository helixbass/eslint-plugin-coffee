###*
# @fileoverview Enforce boolean attributes notation in JSX
# @author Yannick Croissant
###
'use strict'

docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

exceptionsSchema =
  type: 'array'
  items: type: 'string', minLength: 1
  uniqueItems: yes

ALWAYS = 'always'
NEVER = 'never'

errorData = new WeakMap()
getErrorData = (exceptions) ->
  unless errorData.has exceptions
    exceptionProps = Array.from(exceptions, (name) -> "`#{name}`").join ', '
    exceptionsMessage =
      if exceptions.size > 0
        " for the following props: #{exceptionProps}"
      else
        ''
    errorData.set exceptions, {exceptionsMessage}
  errorData.get exceptions

isAlways = (configuration, exceptions, propName) ->
  isException = exceptions.has propName
  return not isException if configuration is ALWAYS
  isException

isNever = (configuration, exceptions, propName) ->
  isException = exceptions.has propName
  return not isException if configuration is NEVER
  isException

module.exports =
  meta:
    docs:
      description: 'Enforce boolean attributes notation in JSX'
      category: 'Stylistic Issues'
      recommended: no
      url: docsUrl 'jsx-boolean-value'
    fixable: 'code'

    schema:
      anyOf: [
        type: 'array'
        items: [enum: [ALWAYS, NEVER]]
        additionalItems: no
      ,
        type: 'array'
        items: [
          enum: [ALWAYS]
        ,
          type: 'object'
          additionalProperties: no
          properties:
            [NEVER]: exceptionsSchema
        ]
        additionalItems: no
      ,
        type: 'array'
        items: [
          enum: [NEVER]
        ,
          type: 'object'
          additionalProperties: no
          properties:
            [ALWAYS]: exceptionsSchema
        ]
        additionalItems: no
      ]

  create: (context) ->
    configuration = context.options[0] or NEVER
    configObject = context.options[1] or {}
    exceptions = new Set(
      (
        if configuration is ALWAYS
          configObject[NEVER]
        else
          configObject[ALWAYS]
      ) or []
    )

    NEVER_MESSAGE =
      'Value must be omitted for boolean attributes{{exceptionsMessage}}'
    ALWAYS_MESSAGE =
      'Value must be set for boolean attributes{{exceptionsMessage}}'

    JSXAttribute: (node) ->
      propName = node.name?.name
      {value} = node

      if isAlways(configuration, exceptions, propName) and value is null
        data = getErrorData exceptions
        context.report {
          node
          message: ALWAYS_MESSAGE
          data
          fix: (fixer) -> fixer.insertTextAfter node, '={true}'
        }
      if (
        isNever(configuration, exceptions, propName) and
        value and
        value.type is 'JSXExpressionContainer' and
        value.expression.value is yes
      )
        data = getErrorData exceptions
        context.report {
          node
          message: NEVER_MESSAGE
          data
          fix: (fixer) -> fixer.removeRange [node.name.range[1], value.range[1]]
        }
