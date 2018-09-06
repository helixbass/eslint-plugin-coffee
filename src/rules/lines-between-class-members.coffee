###*
# @fileoverview Rule to check empty newline between class members
# @author 薛定谔的猫<hh_2013@foxmail.com>
###
'use strict'

astUtils = require 'eslint/lib/ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'require or disallow an empty line between class members'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/lines-between-class-members'

    # fixable: 'whitespace'

    schema: [
      enum: ['always', 'never']
    ,
      type: 'object'
      properties:
        exceptAfterSingleLine:
          type: 'boolean'
      additionalProperties: no
    ]

  create: (context) ->
    options = []

    options[0] = context.options[0] or 'always'
    options[1] = context.options[1] or exceptAfterSingleLine: no

    ALWAYS_MESSAGE = 'Expected blank line between class members.'
    NEVER_MESSAGE = 'Unexpected blank line between class members.'

    sourceCode = context.getSourceCode()

    ###*
    # Checks if there is padding between two tokens
    # @param {Token} first The first token
    # @param {Token} second The second token
    # @returns {boolean} True if there is at least a line between the tokens
    ###
    isPaddingBetweenTokens = (first, second) ->
      comments = sourceCode.getCommentsBefore second
      len = comments.length

      # If there is no comments
      if len is 0
        linesBetweenFstAndSnd = second.loc.start.line - first.loc.end.line - 1

        return linesBetweenFstAndSnd >= 1

      # If there are comments
      sumOfCommentLines = 0 # the numbers of lines of comments
      prevCommentLineNum = -1 # line number of the end of the previous comment
      i = 0
      while i < len
        commentLinesOfThisComment =
          comments[i].loc.end.line - comments[i].loc.start.line + 1

        sumOfCommentLines += commentLinesOfThisComment

        ###
        # If this comment and the previous comment are in the same line,
        # the count of comment lines is duplicated. So decrement sumOfCommentLines.
        ###
        if prevCommentLineNum is comments[i].loc.start.line
          sumOfCommentLines -= 1

        prevCommentLineNum = comments[i].loc.end.line
        i++

      ###
      # If the first block and the first comment are in the same line,
      # the count of comment lines is duplicated. So decrement sumOfCommentLines.
      ###
      if first.loc.end.line is comments[0].loc.start.line
        sumOfCommentLines -= 1

      ###
      # If the last comment and the second block are in the same line,
      # the count of comment lines is duplicated. So decrement sumOfCommentLines.
      ###
      if comments[len - 1].loc.end.line is second.loc.start.line
        sumOfCommentLines -= 1

      linesBetweenFstAndSnd = second.loc.start.line - first.loc.end.line - 1

      linesBetweenFstAndSnd - sumOfCommentLines >= 1

    ClassBody: (node) ->
      {body} = node

      return unless body.length
      for i in [0...(body.length - 1)]
        curFirst = sourceCode.getFirstToken body[i]
        curLast = sourceCode.getLastToken body[i]
        nextFirst = sourceCode.getFirstToken body[i + 1]
        isPadded = isPaddingBetweenTokens curLast, nextFirst
        isMulti = not astUtils.isTokenOnSameLine curFirst, curLast
        skip = not isMulti and options[1].exceptAfterSingleLine

        if (
          (options[0] is 'always' and not skip and not isPadded) or
          (options[0] is 'never' and isPadded)
        )
          context.report
            node: body[i + 1]
            message: if isPadded then NEVER_MESSAGE else ALWAYS_MESSAGE
            # fix: (fixer) ->
            #   if isPadded
            #     fixer.replaceTextRange(
            #       [curLast.range[1], nextFirst.range[0]]
            #       '\n'
            #     )
            #   else
            #     fixer.insertTextAfter curLast, '\n'
