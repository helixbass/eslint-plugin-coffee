###*
 * # @fileoverview enforce a particular style for multiline comments
 * # @author Teddy Katz
###
'use strict'

astUtils = require '../eslint-ast-utils'

###
 * ------------------------------------------------------------------------------
 * Rule Definition
 * ------------------------------------------------------------------------------
###

module.exports =
  meta:
    docs:
      description: 'enforce a particular style for multiline comments'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/multiline-comment-style'
    fixable: 'whitespace'
    schema: [
      enum: ['hashed-block', 'starred-block', 'separate-lines', 'bare-block']
    ]

  create: (context) ->
    sourceCode = context.getSourceCode()
    option = context.options[0] or 'hashed-block'

    EXPECTED_BLOCK_ERROR =
      'Expected a block comment instead of consecutive line comments.'
    START_NEWLINE_ERROR = "Expected a linebreak after '###'."
    END_NEWLINE_ERROR = "Expected a linebreak before '###'."
    MISSING_HASH_ERROR = "Expected a '#' at the start of this line."
    MISSING_STAR_ERROR = "Expected a '*' at the start of this line."
    ALIGNMENT_ERROR =
      'Expected this line to be aligned with the start of the comment.'
    EXPECTED_LINES_ERROR =
      'Expected multiple line comments instead of a block comment.'

    ###
     * ----------------------------------------------------------------------
     * Helpers
     * ----------------------------------------------------------------------
    ###

    ###*
     * # Gets a list of comment lines in a group
     * # @param {Token[]} commentGroup A group of comments, containing either multiple line comments or a single block comment
     * # @returns {string[]} A list of comment lines
    ###
    getCommentLines = (commentGroup) ->
      if commentGroup[0].type is 'Line'
        return commentGroup.map (comment) ->
          comment.value
      commentGroup[0].value
      .split astUtils.LINEBREAK_MATCHER
      .map (line) -> line.replace /^\s*[*#]?/, ''

    ###*
     * # Converts a comment into starred-block form
     * # @param {Token} firstComment The first comment of the group being converted
     * # @param {string[]} commentLinesList A list of lines to appear in the new starred-block comment
     * # @returns {string} A representation of the comment value in starred-block form, excluding start and end markers
    ###
    convertToStarredBlock = (firstComment, commentLinesList) ->
      initialOffset = sourceCode.text.slice(
        firstComment.range[0] - firstComment.loc.start.column
        firstComment.range[0]
      )
      starredLines = commentLinesList.map (line) -> "#{initialOffset} *#{line}"

      "\n#{starredLines.join '\n'}\n#{initialOffset}"

    convertToHashedBlock = (firstComment, commentLinesList) ->
      initialOffset = sourceCode.text.slice(
        firstComment.range[0] - firstComment.loc.start.column
        firstComment.range[0]
      )
      hashedLines = commentLinesList.map (line) -> "#{initialOffset}##{line}"

      "\n#{hashedLines.join '\n'}\n#{initialOffset}"

    ###*
     * # Converts a comment into separate-line form
     * # @param {Token} firstComment The first comment of the group being converted
     * # @param {string[]} commentLinesList A list of lines to appear in the new starred-block comment
     * # @returns {string} A representation of the comment value in separate-line form
    ###
    convertToSeparateLines = (firstComment, commentLinesList) ->
      initialOffset = sourceCode.text.slice(
        firstComment.range[0] - firstComment.loc.start.column
        firstComment.range[0]
      )
      separateLines = commentLinesList.map (line) -> "# #{line.trim()}"

      separateLines.join "\n#{initialOffset}"

    ###*
     * # Converts a comment into bare-block form
     * # @param {Token} firstComment The first comment of the group being converted
     * # @param {string[]} commentLinesList A list of lines to appear in the new starred-block comment
     * # @returns {string} A representation of the comment value in bare-block form
    ###
    convertToBlock = (firstComment, commentLinesList) ->
      initialOffset = sourceCode.text.slice(
        firstComment.range[0] - firstComment.loc.start.column
        firstComment.range[0]
      )
      blockLines = commentLinesList.map (line) -> line.trim()

      "### #{blockLines.join "\n#{initialOffset}    "} ###"

    ###*
     * # Check a comment is JSDoc form
     * # @param {Token[]} commentGroup A group of comments, containing either multiple line comments or a single block comment
     * # @returns {boolean} if commentGroup is JSDoc form, return true
    ###
    isJSDoc = (commentGroup) ->
      lines = commentGroup[0].value.split astUtils.LINEBREAK_MATCHER

      commentGroup[0].type is 'Block' and
        /^\*\s*$/.test(lines[0]) and
        lines
        .slice 1, -1
        .every((line) -> /^\s*[ #]/.test line) and
        /^\s*$/.test lines[lines.length - 1]

    ###*
     * # Each method checks a group of comments to see if it's valid according to the given option.
     * # @param {Token[]} commentGroup A list of comments that appear together. This will either contain a single
     * # block comment or multiple line comments.
     * # @returns {void}
    ###
    commentGroupCheckers =
      'hashed-block': (commentGroup) ->
        commentLines = getCommentLines commentGroup

        return if commentLines.some (value) -> value.includes '###'

        if commentGroup.length > 1
          context.report
            loc:
              start: commentGroup[0].loc.start
              end: commentGroup[commentGroup.length - 1].loc.end
            message: EXPECTED_BLOCK_ERROR
            fix: (fixer) ->
              range = [
                commentGroup[0].range[0]
                commentGroup[commentGroup.length - 1].range[1]
              ]
              hashedBlock = "####{convertToHashedBlock(
                commentGroup[0]
                commentLines
              )}###"

              if commentLines.some((value) -> value.startsWith '#')
                null
              else
                fixer.replaceTextRange range, hashedBlock
        else
          block = commentGroup[0]
          lines = block.value.split astUtils.LINEBREAK_MATCHER
          lineIndent = sourceCode.text.slice(
            block.range[0] - block.loc.start.column
            block.range[0]
          )
          expectedLinePrefix = "#{lineIndent}#"

          unless /^\*?\s*$/.test lines[0]
            start =
              if block.value.startsWith '*'
                block.range[0] + 1
              else
                block.range[0]

            context.report
              loc:
                start: block.loc.start
                end:
                  line: block.loc.start.line
                  column: block.loc.start.column + 2
              message: START_NEWLINE_ERROR
              fix: (fixer) ->
                fixer.insertTextAfterRange(
                  [start, start + '###'.length]
                  "\n#{expectedLinePrefix}"
                )

          unless /^\s*$/.test lines[lines.length - 1]
            context.report
              loc:
                start:
                  line: block.loc.end.line, column: block.loc.end.column - 2
                end: block.loc.end
              message: END_NEWLINE_ERROR
              fix: (fixer) ->
                fixer.replaceTextRange(
                  [block.range[1] - '###'.length, block.range[1]]
                  "\n#{lineIndent}###"
                )

          lineNumber = block.loc.start.line + 1
          while lineNumber <= block.loc.end.line
            lineText = sourceCode.lines[lineNumber - 1]

            unless (
              if lineNumber is block.loc.end.line
                lineText.startsWith "#{lineIndent}#"
              else
                lineText.startsWith expectedLinePrefix
            )
              context.report
                loc:
                  start: line: lineNumber, column: 0
                  end:
                    line: lineNumber
                    column: sourceCode.lines[lineNumber - 1].length
                message:
                  if lineNumber is block.loc.end.line or /^\s*#/.test lineText
                    ALIGNMENT_ERROR
                  else
                    MISSING_HASH_ERROR
                # eslint-disable-next-line coffee/no-loop-func
                fix: (fixer) ->
                  lineStartIndex = sourceCode.getIndexFromLoc(
                    line: lineNumber, column: 0
                  )
                  linePrefixLength =
                    lineText.match(/^\s*(?:#(?!##))? ?/)[0].length
                  commentStartIndex = lineStartIndex + linePrefixLength

                  replacementText =
                    if lineNumber is block.loc.end.line
                      lineIndent
                    else if lineText.length is linePrefixLength
                      expectedLinePrefix
                    else
                      "#{expectedLinePrefix} "

                  fixer.replaceTextRange(
                    [lineStartIndex, commentStartIndex]
                    replacementText
                  )
            lineNumber++
      'starred-block': (commentGroup) ->
        commentLines = getCommentLines commentGroup

        return if commentLines.some (value) -> value.includes '###'

        if commentGroup.length > 1
          context.report
            loc:
              start: commentGroup[0].loc.start
              end: commentGroup[commentGroup.length - 1].loc.end
            message: EXPECTED_BLOCK_ERROR
            fix: (fixer) ->
              range = [
                commentGroup[0].range[0]
                commentGroup[commentGroup.length - 1].range[1]
              ]
              starredBlock = "####{convertToStarredBlock(
                commentGroup[0]
                commentLines
              )}###"

              if commentLines.some((value) -> value.startsWith '#')
                null
              else
                fixer.replaceTextRange range, starredBlock
        else
          block = commentGroup[0]
          lines = block.value.split astUtils.LINEBREAK_MATCHER
          lineIndent = sourceCode.text.slice(
            block.range[0] - block.loc.start.column
            block.range[0]
          )
          expectedLinePrefix = "#{lineIndent} *"

          unless /^\*?\s*$/.test lines[0]
            start =
              if block.value.startsWith '*'
                block.range[0] + 1
              else
                block.range[0]

            context.report
              loc:
                start: block.loc.start
                end:
                  line: block.loc.start.line
                  column: block.loc.start.column + 2
              message: START_NEWLINE_ERROR
              fix: (fixer) ->
                fixer.insertTextAfterRange(
                  [start, start + '###'.length]
                  "\n#{expectedLinePrefix}"
                )

          unless /^\s*$/.test lines[lines.length - 1]
            context.report
              loc:
                start:
                  line: block.loc.end.line, column: block.loc.end.column - 2
                end: block.loc.end
              message: END_NEWLINE_ERROR
              fix: (fixer) ->
                fixer.replaceTextRange(
                  [block.range[1] - '###'.length, block.range[1]]
                  "\n#{lineIndent}###"
                )

          lineNumber = block.loc.start.line + 1
          while lineNumber <= block.loc.end.line
            lineText = sourceCode.lines[lineNumber - 1]

            unless (
              if lineNumber is block.loc.end.line
                lineText.startsWith("#{lineIndent}#") or
                  lineText.startsWith "#{lineIndent} *"
              else
                lineText.startsWith expectedLinePrefix
            )
              context.report
                loc:
                  start: line: lineNumber, column: 0
                  end:
                    line: lineNumber
                    column: sourceCode.lines[lineNumber - 1].length
                message:
                  if lineNumber is block.loc.end.line or /^\s*\*/.test lineText
                    ALIGNMENT_ERROR
                  else
                    MISSING_STAR_ERROR
                # eslint-disable-next-line coffee/no-loop-func
                fix: (fixer) ->
                  lineStartIndex = sourceCode.getIndexFromLoc(
                    line: lineNumber, column: 0
                  )
                  linePrefixLength = lineText.match(/^\s*\*? ?/)[0].length
                  commentStartIndex = lineStartIndex + linePrefixLength

                  replacementText =
                    if lineNumber is block.loc.end.line
                      lineIndent
                    else if lineText.length is linePrefixLength
                      expectedLinePrefix
                    else
                      "#{expectedLinePrefix} "

                  fixer.replaceTextRange(
                    [lineStartIndex, commentStartIndex]
                    replacementText
                  )
            lineNumber++
      'separate-lines': (commentGroup) ->
        if not isJSDoc(commentGroup) and commentGroup[0].type is 'Block'
          commentLines = getCommentLines commentGroup
          block = commentGroup[0]
          tokenAfter = sourceCode.getTokenAfter block, includeComments: yes

          return if (
            tokenAfter and block.loc.end.line is tokenAfter.loc.start.line
          )

          context.report
            loc:
              start: block.loc.start
              end:
                line: block.loc.start.line, column: block.loc.start.column + 2
            message: EXPECTED_LINES_ERROR
            fix: (fixer) ->
              fixer.replaceText(
                block
                convertToSeparateLines block, commentLines.filter (line) -> line
              )
      'bare-block': (commentGroup) ->
        unless isJSDoc commentGroup
          commentLines = getCommentLines commentGroup

          # disallows consecutive line comments in favor of using a block comment.
          if (
            commentGroup[0].type is 'Line' and
            commentLines.length > 1 and
            not commentLines.some((value) -> value.includes '###')
          )
            context.report
              loc:
                start: commentGroup[0].loc.start
                end: commentGroup[commentGroup.length - 1].loc.end
              message: EXPECTED_BLOCK_ERROR
              fix: (fixer) ->
                range = [
                  commentGroup[0].range[0]
                  commentGroup[commentGroup.length - 1].range[1]
                ]
                block = convertToBlock(
                  commentGroup[0]
                  commentLines.filter (line) -> line
                )

                fixer.replaceTextRange range, block

          # prohibits block comments from having a * at the beginning of each line.
          if commentGroup[0].type is 'Block'
            block = commentGroup[0]
            lines =
              block.value
              .split astUtils.LINEBREAK_MATCHER
              .filter (line) -> line.trim()

            if lines.length > 0 and lines.every((line) -> /^\s*[*#]/.test line)
              context.report
                loc:
                  start: block.loc.start
                  end:
                    line: block.loc.start.line
                    column: block.loc.start.column + 2
                message: EXPECTED_BLOCK_ERROR
                fix: (fixer) ->
                  fixer.replaceText(
                    block
                    convertToBlock block, commentLines.filter (line) -> line
                  )

    ###
     * ----------------------------------------------------------------------
     * Public
     * ----------------------------------------------------------------------
    ###

    Program: ->
      sourceCode
      .getAllComments()
      .filter (comment) -> comment.type isnt 'Shebang'
      .filter (comment) ->
        not astUtils.COMMENTS_IGNORE_PATTERN.test comment.value
      .filter (comment) ->
        tokenBefore = sourceCode.getTokenBefore comment, includeComments: yes

        not tokenBefore or tokenBefore.loc.end.line < comment.loc.start.line
      .reduce(
        (commentGroups, comment, index, commentList) ->
          tokenBefore = sourceCode.getTokenBefore comment, includeComments: yes

          if (
            comment.type is 'Line' and
            index and
            commentList[index - 1].type is 'Line' and
            tokenBefore and
            tokenBefore.loc.end.line is comment.loc.start.line - 1 and
            tokenBefore is commentList[index - 1]
          )
            commentGroups[commentGroups.length - 1].push comment
          else
            commentGroups.push [comment]

          commentGroups
      ,
        []
      )
      .filter (commentGroup) ->
        not (
          commentGroup.length is 1 and
          commentGroup[0].loc.start.line is commentGroup[0].loc.end.line
        )
      .forEach commentGroupCheckers[option]
