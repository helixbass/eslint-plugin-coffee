###*
# @fileoverview Disallows multiple blank lines.
# implementation adapted from the no-trailing-spaces rule.
# @author Greg Cochard
###
'use strict'

{countBy} = require 'lodash'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow multiple empty lines'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-multiple-empty-lines'

    fixable: 'whitespace'

    schema: [
      type: 'object'
      properties:
        max:
          type: 'integer'
          minimum: 0
        maxEOF:
          type: 'integer'
          minimum: 0
        maxBOF:
          type: 'integer'
          minimum: 0
      required: ['max']
      additionalProperties: no
    ]

  create: (context) ->
    # Use options.max or 2 as default
    max = 2
    maxEOF = max
    maxBOF = max

    if context.options.length
      {max} = context.options[0]
      maxEOF =
        unless typeof context.options[0].maxEOF is 'undefined'
          context.options[0].maxEOF
        else
          max
      maxBOF =
        unless typeof context.options[0].maxBOF is 'undefined'
          context.options[0].maxBOF
        else
          max

    sourceCode = context.getSourceCode()

    # Swallow the final newline, as some editors add it automatically and we don't want it to cause an issue
    allLines =
      if sourceCode.lines[sourceCode.lines.length - 1] is ''
        sourceCode.lines.slice 0, -1
      else
        sourceCode.lines
    templateLiteralLines = new Set()

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    TemplateLiteral: (node) ->
      node.quasis.forEach (literalPart) ->
        ignoredLine = literalPart.loc.start.line
        # Empty lines have a semantic meaning if they're inside template literals. Don't count these as empty lines.
        # Don't trust loc.end.line (since we're currently just +1'ing the last column of the inclusive location data)
        # while ignoredLine < literalPart.loc.end.line
        #   templateLiteralLines.add ignoredLine
        #   ignoredLine++
        numNewlines = countBy(literalPart.value.raw)['\n'] ? 0
        for [0...numNewlines]
          templateLiteralLines.add ignoredLine
          ignoredLine++
    'Program:exit': (node) ->
      allLines
      # Given a list of lines, first get a list of line numbers that are non-empty.
      .reduce(
        (nonEmptyLineNumbers, line, index) ->
          if line.trim() or templateLiteralLines.has index + 1
            nonEmptyLineNumbers.push index + 1
          nonEmptyLineNumbers
      ,
        []
      )
      # Add a value at the end to allow trailing empty lines to be checked.
      .concat allLines.length + 1
      # Given two line numbers of non-empty lines, report the lines between if the difference is too large.
      .reduce(
        (lastLineNumber, lineNumber) ->
          if lastLineNumber is 0
            message =
              'Too many blank lines at the beginning of file. Max of {{max}} allowed.'
            maxAllowed = maxBOF
          else if lineNumber is allLines.length + 1
            message =
              'Too many blank lines at the end of file. Max of {{max}} allowed.'
            maxAllowed = maxEOF
          else
            message = 'More than {{max}} blank {{pluralizedLines}} not allowed.'
            maxAllowed = max

          if lineNumber - lastLineNumber - 1 > maxAllowed
            context.report {
              node
              loc:
                start: line: lastLineNumber + 1, column: 0
                end: line: lineNumber, column: 0
              message
              data:
                max: maxAllowed
                pluralizedLines: if maxAllowed is 1 then 'line' else 'lines'
              fix: (fixer) ->
                rangeStart = sourceCode.getIndexFromLoc(
                  line: lastLineNumber + 1, column: 0
                )

                ###
                # The end of the removal range is usually the start index of the next line.
                # However, at the end of the file there is no next line, so the end of the
                # range is just the length of the text.
                ###
                lineNumberAfterRemovedLines = lineNumber - maxAllowed
                rangeEnd =
                  if lineNumberAfterRemovedLines <= allLines.length
                    sourceCode.getIndexFromLoc(
                      line: lineNumberAfterRemovedLines, column: 0
                    )
                  else
                    sourceCode.text.length

                fixer.removeRange [rangeStart, rangeEnd]
            }

          lineNumber
      ,
        0
      )
