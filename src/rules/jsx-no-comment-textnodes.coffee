###*
# @fileoverview Comments inside children section of tag should be placed inside braces.
# @author Ben Vinegar
###
'use strict'

docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'Comments inside children section of tag should be placed inside braces'
      category: 'Possible Errors'
      recommended: yes
      url: docsUrl 'jsx-no-comment-textnodes'

    schema: [
      type: 'object'
      properties: {}
      additionalProperties: no
    ]

  create: (context) ->
    reportLiteralNode = (node) ->
      context.report(
        node
        'Comments inside children section of tag should be placed inside braces'
      )

    check = (node) ->
      sourceCode = context.getSourceCode()
      # since babel-eslint has the wrong node.raw, we'll get the source text
      rawValue = sourceCode.getText node
      if /^\s*(#|###)/m.test rawValue
        # inside component, e.g. <div>literal</div>
        if (
          node.parent.type isnt 'JSXAttribute' and
          node.parent.type isnt 'JSXExpressionContainer' and
          node.parent.type.indexOf('JSX') isnt -1
        )
          reportLiteralNode node

    # --------------------------------------------------------------------------
    # Public
    # --------------------------------------------------------------------------

    Literal: check
    JSXText: check
