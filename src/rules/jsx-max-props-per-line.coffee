###*
# @fileoverview Limit maximum of props on a single line in JSX
# @author Yannick Croissant
###

'use strict'

docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'Limit maximum of props on a single line in JSX'
      category: 'Stylistic Issues'
      recommended: no
      url: docsUrl 'jsx-max-props-per-line'
    # fixable: 'code'
    schema: [
      type: 'object'
      properties:
        maximum:
          type: 'integer'
          minimum: 1
        when:
          type: 'string'
          enum: ['always', 'multiline']
    ]

  create: (context) ->
    sourceCode = context.getSourceCode()
    configuration = context.options[0] or {}
    maximum = configuration.maximum or 1
    _when = configuration.when or 'always'

    getPropName = (propNode) ->
      return sourceCode.getText propNode.argument if (
        propNode.type is 'JSXSpreadAttribute'
      )
      propNode.name.name

    # generateFixFunction = (line, max) ->
    #   output = []
    #   front = line[0].range[0]
    #   back = line[line.length - 1].range[1]
    #   i = 0
    #   while i < line.length
    #     nodes = line.slice i, i + max
    #     output.push(
    #       nodes.reduce(
    #         (prev, curr) ->
    #           return sourceCode.getText curr if prev is ''
    #           "#{prev} #{sourceCode.getText curr}"
    #         ''
    #       )
    #     )
    #     i += max
    #   code = output.join '\n'
    #   (fixer) -> fixer.replaceTextRange [front, back], code

    JSXOpeningElement: (node) ->
      return unless node.attributes.length

      return if (
        _when is 'multiline' and node.loc.start.line is node.loc.end.line
      )

      firstProp = node.attributes[0]
      linePartitionedProps = [[firstProp]]

      node.attributes.reduce (last, decl) ->
        if last.loc.end.line is decl.loc.start.line
          linePartitionedProps[linePartitionedProps.length - 1].push decl
        else
          linePartitionedProps.push [decl]
        decl

      linePartitionedProps.forEach (propsInLine) ->
        if propsInLine.length > maximum
          name = getPropName propsInLine[maximum]
          context.report
            node: propsInLine[maximum]
            message: "Prop `#{name}` must be placed on a new line"
            # fix: generateFixFunction propsInLine, maximum
