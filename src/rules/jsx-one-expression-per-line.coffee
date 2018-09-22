###*
# @fileoverview Limit to one expression per line in JSX
# @author Mark Ivan Allen <Vydia.com>
###

'use strict'

docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

optionDefaults = allow: 'none'

module.exports =
  meta:
    docs:
      description: 'Limit to one expression per line in JSX'
      category: 'Stylistic Issues'
      recommended: no
      url: docsUrl 'jsx-one-expression-per-line'
    fixable: 'whitespace'
    schema: [
      type: 'object'
      properties:
        allow:
          enum: ['none', 'literal', 'single-child']
      default: optionDefaults
      additionalProperties: no
    ]

  create: (context) ->
    options = {...optionDefaults, ...context.options[0]}
    sourceCode = context.getSourceCode()

    nodeKey = (node) -> "#{node.loc.start.line},#{node.loc.start.column}"

    nodeDescriptor = (n) ->
      if n.openingElement
        n.openingElement.name.name
      else
        sourceCode.getText(n).replace /\n/g, ''

    handleJSX = (node) ->
      {children} = node

      return unless children?.length

      openingElement = node.openingElement or node.openingFragment
      closingElement = node.closingElement or node.closingFragment
      openingElementStartLine = openingElement.loc.start.line
      openingElementEndLine = openingElement.loc.end.line
      closingElementStartLine = closingElement.loc.start.line
      closingElementEndLine = closingElement.loc.end.line

      if children.length is 1
        onlyChild = children[0]
        if (
          openingElementStartLine is openingElementEndLine and
          openingElementEndLine is closingElementStartLine and
          closingElementStartLine is closingElementEndLine and
          closingElementEndLine is onlyChild.loc.start.line and
          onlyChild.loc.start.line is onlyChild.loc.end.line
        )
          return if (
            options.allow is 'single-child' or
            (options.allow is 'literal' and
              onlyChild.type in ['Literal', 'JSXText'])
          )

      childrenGroupedByLine = {}
      fixDetailsByNode = {}

      children.forEach (child) ->
        countNewLinesBeforeContent = 0
        countNewLinesAfterContent = 0

        if child.type in ['Literal', 'JSXText']
          # TODO: this is only necessary b/c JSXFragments aren't currently getting transformed Babel -> espree
          raw = child.extra?.raw ? child.raw
          return if /^\s*$/.test raw

          countNewLinesBeforeContent = (raw.match(/^ *\n/g) or []).length
          countNewLinesAfterContent = (raw.match(/\n *$/g) or []).length

        startLine = child.loc.start.line + countNewLinesBeforeContent
        endLine = child.loc.end.line - countNewLinesAfterContent

        # if startLine is endLine TODO: >= is only necessary because of column + 1 in AST I think?
        if startLine >= endLine
          (childrenGroupedByLine[startLine] ?= []).push child
        else
          (childrenGroupedByLine[startLine] ?= []).push child
          (childrenGroupedByLine[endLine] ?= []).push child

      Object.keys(childrenGroupedByLine).forEach (_line) ->
        line = parseInt _line, 10
        firstIndex = 0
        lastIndex = childrenGroupedByLine[line].length - 1

        childrenGroupedByLine[line].forEach (child, i) ->
          if i is firstIndex
            if line is openingElementEndLine then prevChild = openingElement
          else
            prevChild = childrenGroupedByLine[line][i - 1]

          if i is lastIndex
            if line is closingElementStartLine then nextChild = closingElement
          else
            # We don't need to append a trailing because the next child will prepend a leading.
            # nextChild = childrenGroupedByLine[line][i + 1];

          spaceBetweenPrev = ->
            (prevChild.type in ['Literal', 'JSXText'] and
              (/ $/).test(prevChild.raw)) or
            (child.type in ['Literal', 'JSXText'] and /^ /.test(child.raw)) or
            sourceCode.isSpaceBetweenTokens prevChild, child

          spaceBetweenNext = ->
            (nextChild.type in ['Literal', 'JSXText'] and
              /^ /.test(nextChild.raw)) or
            (child.type in ['Literal', 'JSXText'] and (/ $/).test(child.raw)) or
            sourceCode.isSpaceBetweenTokens child, nextChild

          return if not prevChild and not nextChild

          source = sourceCode.getText child
          leadingSpace = !!(prevChild and spaceBetweenPrev())
          trailingSpace = !!(nextChild and spaceBetweenNext())
          leadingNewLine = !!prevChild
          trailingNewLine = !!nextChild

          key = nodeKey child

          unless fixDetailsByNode[key]
            fixDetailsByNode[key] = {
              node: child
              source
              descriptor: nodeDescriptor child
            }

          if leadingSpace then fixDetailsByNode[key].leadingSpace = yes
          if leadingNewLine then fixDetailsByNode[key].leadingNewLine = yes
          if trailingNewLine then fixDetailsByNode[key].trailingNewLine = yes
          if trailingSpace then fixDetailsByNode[key].trailingSpace = yes

      Object.keys(fixDetailsByNode).forEach (key) ->
        details = fixDetailsByNode[key]

        {node: nodeToReport, descriptor} = details
        source = details.source.replace /(^ +| +(?=\n)*$)/g, ''

        leadingSpaceString = if details.leadingSpace then "\n{' '}" else ''
        trailingSpaceString = if details.trailingSpace then "{' '}\n" else ''
        leadingNewLineString = if details.leadingNewLine then '\n' else ''
        trailingNewLineString = if details.trailingNewLine then '\n' else ''

        replaceText = "#{leadingSpaceString}#{leadingNewLineString}#{source}#{trailingNewLineString}#{trailingSpaceString}"

        context.report
          node: nodeToReport
          message: "`#{descriptor}` must be placed on a new line"
          fix: (fixer) -> fixer.replaceText nodeToReport, replaceText

    JSXElement: handleJSX
    JSXFragment: handleJSX
