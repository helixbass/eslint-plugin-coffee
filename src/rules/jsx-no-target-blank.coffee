###*
# @fileoverview Forbid target='_blank' attribute
# @author Kevin Miller
###

'use strict'

docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'
linkComponentsUtil = require 'eslint-plugin-react/lib/util/linkComponents'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

findLastIndex = (arr, condition) ->
  i = arr.length - 1
  while i >= 0
    return i if condition arr[i]
    i -= 1

  -1

attributeValuePossiblyBlank = (attribute) ->
  return no unless attribute?.value
  {value} = attribute
  return (
    typeof value.value is 'string' and value.value.toLowerCase() is '_blank'
  ) if value.type is 'Literal'
  if value.type is 'JSXExpressionContainer'
    expr = value.expression
    return (
      typeof expr.value is 'string' and expr.value.toLowerCase() is '_blank'
    ) if expr.type is 'Literal'
    if expr.type is 'ConditionalExpression'
      return yes if (
        expr.alternate?.type is 'Literal' and
        expr.alternate.value and
        expr.alternate.value.toLowerCase() is '_blank'
      )
      return yes if (
        expr.consequent.type is 'Literal' and
        expr.consequent.value and
        expr.consequent.value.toLowerCase() is '_blank'
      )
  no

hasExternalLink = (
  node
  linkAttribute
  warnOnSpreadAttributes
  spreadAttributeIndex
) ->
  linkIndex = findLastIndex node.attributes, (attr) ->
    attr.name?.name is linkAttribute
  foundExternalLink =
    linkIndex isnt -1 and
    ((attr) ->
      attr.value.type is 'Literal' and /^(?:\w+:|\/\/)/.test attr.value.value
    ) node.attributes[linkIndex]
  foundExternalLink or
    (warnOnSpreadAttributes and linkIndex < spreadAttributeIndex)

hasDynamicLink = (node, linkAttribute) ->
  dynamicLinkIndex = findLastIndex node.attributes, (attr) ->
    attr.name?.name is linkAttribute and
    attr.value and
    attr.value.type is 'JSXExpressionContainer'
  return yes unless dynamicLinkIndex is -1
  undefined

getStringFromValue = (value) ->
  if value
    return value.value if value.type is 'Literal'
    if value.type is 'JSXExpressionContainer'
      return value.expression.quasis[0].value.cooked if (
        value.expression.type is 'TemplateLiteral'
      )
      return value.expression?.value
  null

hasSecureRel = (
  node
  allowReferrer
  warnOnSpreadAttributes
  spreadAttributeIndex
) ->
  relIndex = findLastIndex node.attributes, (attr) ->
    attr.type is 'JSXAttribute' and attr.name.name is 'rel'
  return no if (
    relIndex is -1 or
    (warnOnSpreadAttributes and relIndex < spreadAttributeIndex)
  )

  relAttribute = node.attributes[relIndex]
  value = getStringFromValue relAttribute.value
  tags = value and typeof value is 'string' and value.toLowerCase().split ' '
  noreferrer = tags and tags.indexOf('noreferrer') >= 0
  return yes if noreferrer
  allowReferrer and tags and tags.indexOf('noopener') >= 0

module.exports =
  meta:
    fixable: 'code'
    docs:
      description:
        'Forbid `target="_blank"` attribute without `rel="noreferrer"`'
      category: 'Best Practices'
      recommended: yes
      url: docsUrl 'jsx-no-target-blank'

    messages:
      noTargetBlank:
        'Using target="_blank" without rel="noreferrer" ' +
        'is a security risk: see https://html.spec.whatwg.org/multipage/links.html#link-type-noopener'

    schema: [
      type: 'object'
      properties:
        allowReferrer:
          type: 'boolean'
        enforceDynamicLinks:
          enum: ['always', 'never']
        warnOnSpreadAttributes:
          type: 'boolean'
      additionalProperties: no
    ]

  create: (context) ->
    configuration = context.options[0] or {}
    allowReferrer = configuration.allowReferrer or no
    warnOnSpreadAttributes = configuration.warnOnSpreadAttributes or no
    enforceDynamicLinks = configuration.enforceDynamicLinks or 'always'
    components = linkComponentsUtil.getLinkComponents context

    JSXOpeningElement: (node) ->
      return unless components.has node.name.name

      targetIndex = findLastIndex node.attributes, (attr) ->
        attr.name?.name is 'target'
      spreadAttributeIndex = findLastIndex node.attributes, (attr) ->
        attr.type is 'JSXSpreadAttribute'

      unless attributeValuePossiblyBlank node.attributes[targetIndex]
        hasSpread = spreadAttributeIndex >= 0

        if warnOnSpreadAttributes and hasSpread
          # continue to check below
        else
          return if (
            (hasSpread and targetIndex < spreadAttributeIndex) or
            not hasSpread or
            not warnOnSpreadAttributes
          )

      linkAttribute = components.get node.name.name
      hasDangerousLink =
        hasExternalLink(
          node
          linkAttribute
          warnOnSpreadAttributes
          spreadAttributeIndex
        ) or
        (enforceDynamicLinks is 'always' and hasDynamicLink node, linkAttribute)
      if (
        hasDangerousLink and
        not hasSecureRel(
          node
          allowReferrer
          warnOnSpreadAttributes
          spreadAttributeIndex
        )
      )
        context.report {
          node
          messageId: 'noTargetBlank'
          fix: (fixer) ->
            # eslint 5 uses `node.attributes`; eslint 6+ uses `node.parent.attributes`
            nodeWithAttrs = if node.parent.attributes then node.parent else node
            # eslint 5 does not provide a `name` property on JSXSpreadElements
            relAttribute = nodeWithAttrs.attributes.find (attr) ->
              attr.name?.name is 'rel'

            return null if (
              targetIndex < spreadAttributeIndex or
              (spreadAttributeIndex >= 0 and not relAttribute)
            )

            return fixer.insertTextAfter(
              nodeWithAttrs.attributes.slice(-1)[0]
              ' rel="noreferrer"'
            ) unless relAttribute

            return fixer.insertTextAfter relAttribute, '="noreferrer"' unless (
              relAttribute.value
            )

            if relAttribute.value.type is 'Literal'
              parts =
                relAttribute.value.value.split('noreferrer').filter Boolean
              return fixer.replaceText(
                relAttribute.value
                "\"#{parts.concat('noreferrer').join ' '}\""
              )

            if relAttribute.value.type is 'JSXExpressionContainer'
              if relAttribute.value.expression.type is 'Literal'
                if typeof relAttribute.value.expression.value is 'string'
                  parts =
                    relAttribute.value.expression.value
                    .split('noreferrer')
                    .filter Boolean
                  return fixer.replaceText(
                    relAttribute.value.expression
                    "\"#{parts.concat('noreferrer').join ' '}\""
                  )

                # for undefined, boolean, number, symbol, bigint, and null
                return fixer.replaceText relAttribute.value, '"noreferrer"'

            null
        }
      undefined
