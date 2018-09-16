###*
# @fileoverview Ensure proper position of the first property in JSX
# @author Joachim Seminck
###
'use strict'

docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'Ensure proper position of the first property in JSX'
      category: 'Stylistic Issues'
      recommended: no
      url: docsUrl 'jsx-first-prop-new-line'
    # fixable: 'code'

    schema: [enum: ['always', 'never', 'multiline', 'multiline-multiprop']]

  create: (context) ->
    configuration = context.options[0] or 'multiline-multiprop'

    isMultilineJSX = (jsxNode) -> jsxNode.loc.start.line < jsxNode.loc.end.line

    JSXOpeningElement: (node) ->
      if (
        (configuration is 'multiline' and isMultilineJSX(node)) or
        (configuration is 'multiline-multiprop' and
          isMultilineJSX(node) and
          node.attributes.length > 1) or
        configuration is 'always'
      )
        node.attributes.some (decl) ->
          if decl.loc.start.line is node.loc.start.line
            context.report
              node: decl
              message: 'Property should be placed on a new line'
              # fix: (fixer) ->
              #   fixer.replaceTextRange [node.name.end, decl.range[0]], '\n'
          yes
      else if configuration is 'never' and node.attributes.length > 0
        firstNode = node.attributes[0]
        if node.loc.start.line < firstNode.loc.start.line
          context.report
            node: firstNode
            message:
              'Property should be placed on the same line as the component declaration'
            # fix: (fixer) ->
            #   fixer.replaceTextRange [node.name.end, firstNode.range[0]], ' '
