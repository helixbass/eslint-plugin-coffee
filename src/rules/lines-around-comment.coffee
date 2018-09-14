###*
# @fileoverview Enforces empty lines around comments.
# @author Jamund Ferguson
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

lodash = require 'lodash'
astUtils = require 'eslint/lib/ast-utils'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

###*
# Return an array with with any line numbers that are empty.
# @param {Array} lines An array of each line of the file.
# @returns {Array} An array of line numbers.
###
getEmptyLineNums = (lines) ->
  emptyLines = lines
  .map (line, i) ->
    code: line.trim()
    num: i + 1
  .filter (line) -> not line.code
  .map (line) -> line.num

  emptyLines

###*
# Return an array with with any line numbers that contain comments.
# @param {Array} comments An array of comment tokens.
# @returns {Array} An array of line numbers.
###
getCommentLineNums = (comments) ->
  lines = []

  comments.forEach (token) ->
    start = token.loc.start.line
    end = token.loc.end.line

    lines.push start, end
  lines

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'require empty lines around comments'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/lines-around-comment'

    fixable: 'whitespace'

    schema: [
      type: 'object'
      properties:
        beforeBlockComment:
          type: 'boolean'
        afterBlockComment:
          type: 'boolean'
        beforeLineComment:
          type: 'boolean'
        afterLineComment:
          type: 'boolean'
        allowBlockStart:
          type: 'boolean'
        allowBlockEnd:
          type: 'boolean'
        allowClassStart:
          type: 'boolean'
        allowClassEnd:
          type: 'boolean'
        allowObjectStart:
          type: 'boolean'
        allowObjectEnd:
          type: 'boolean'
        allowArrayStart:
          type: 'boolean'
        allowArrayEnd:
          type: 'boolean'
        ignorePattern:
          type: 'string'
        applyDefaultIgnorePatterns:
          type: 'boolean'
      additionalProperties: no
    ]

  create: (context) ->
    options = if context.options[0] then {...context.options[0]} else {}
    {ignorePattern} = options
    defaultIgnoreRegExp = astUtils.COMMENTS_IGNORE_PATTERN
    customIgnoreRegExp = new RegExp ignorePattern
    applyDefaultIgnorePatterns = options.applyDefaultIgnorePatterns isnt no

    options.beforeLineComment or= no
    options.afterLineComment or= no
    options.beforeBlockComment =
      unless typeof options.beforeBlockComment is 'undefined'
        options.beforeBlockComment
      else
        yes
    options.afterBlockComment or= no
    options.allowBlockStart or= no
    options.allowBlockEnd or= no

    sourceCode = context.getSourceCode()

    {lines} = sourceCode
    numLines = lines.length + 1
    comments = sourceCode.getAllComments()
    commentLines = getCommentLineNums comments
    emptyLines = getEmptyLineNums lines
    commentAndEmptyLines = commentLines.concat emptyLines

    ###*
    # Returns whether or not comments are on lines starting with or ending with code
    # @param {token} token The comment token to check.
    # @returns {boolean} True if the comment is not alone.
    ###
    codeAroundComment = (token) ->
      currentToken = token

      currentToken = sourceCode.getTokenBefore currentToken,
        includeComments: yes
      while currentToken and astUtils.isCommentToken currentToken
        currentToken = sourceCode.getTokenBefore currentToken,
          includeComments: yes

      return yes if (
        currentToken and astUtils.isTokenOnSameLine currentToken, token
      )

      currentToken = token
      currentToken = sourceCode.getTokenAfter currentToken, includeComments: yes

      while currentToken and astUtils.isCommentToken currentToken
        currentToken = sourceCode.getTokenAfter currentToken,
          includeComments: yes

      return yes if (
        currentToken and astUtils.isTokenOnSameLine token, currentToken
      )

      no

    ###*
    # Returns whether or not comments are inside a node type or not.
    # @param {ASTNode} parent The Comment parent node.
    # @param {string} nodeType The parent type to check against.
    # @returns {boolean} True if the comment is inside nodeType.
    ###
    isParentNodeType = (parent, nodeType) ->
      parent.type is nodeType or
      (parent.body and parent.body.type is nodeType) or
      (parent.consequent and parent.consequent.type is nodeType)

    ###*
    # Returns the parent node that contains the given token.
    # @param {token} token The token to check.
    # @returns {ASTNode} The parent node that contains the given token.
    ###
    getParentNodeOfToken = (token) ->
      sourceCode.getNodeByRangeIndex token.range[0]

    hasExplicitDelimiter = (node) ->
      return yes if /^Array/.test node.type
      return not node.implicit if /^Object/.test node.type
      no

    ###*
    # Returns whether or not comments are at the parent start or not.
    # @param {token} token The Comment token.
    # @param {string} nodeType The parent type to check against.
    # @returns {boolean} True if the comment is at parent start.
    ###
    isCommentAtParentStart = (token, nodeType) ->
      parent = getParentNodeOfToken token

      parent and
        isParentNodeType(parent, nodeType) and
        token.loc.start.line - parent.loc.start.line is (
          if nodeType is 'SwitchCase' or hasExplicitDelimiter parent
            1
          else
            0
        )

    ###*
    # Returns whether or not comments are at the parent end or not.
    # @param {token} token The Comment token.
    # @param {string} nodeType The parent type to check against.
    # @returns {boolean} True if the comment is at parent end.
    ###
    isCommentAtParentEnd = (token, nodeType) ->
      parent = getParentNodeOfToken token

      parent and
        isParentNodeType(parent, nodeType) and
        parent.loc.end.line - token.loc.end.line is (
          if nodeType is 'SwitchCase' or hasExplicitDelimiter parent
            1
          else
            0
        )

    ###*
    # Returns whether or not comments are at the block start or not.
    # @param {token} token The Comment token.
    # @returns {boolean} True if the comment is at block start.
    ###
    isCommentAtBlockStart = (token) ->
      isCommentAtParentStart(token, 'ClassBody') or
      isCommentAtParentStart(token, 'BlockStatement') or
      isCommentAtParentStart token, 'SwitchCase'

    ###*
    # Returns whether or not comments are at the block end or not.
    # @param {token} token The Comment token.
    # @returns {boolean} True if the comment is at block end.
    ###
    isCommentAtBlockEnd = (token) ->
      isCommentAtParentEnd(token, 'ClassBody') or
      isCommentAtParentEnd(token, 'BlockStatement') or
      isCommentAtParentEnd(token, 'SwitchCase') or
      isCommentAtParentEnd token, 'SwitchStatement'

    ###*
    # Returns whether or not comments are at the class start or not.
    # @param {token} token The Comment token.
    # @returns {boolean} True if the comment is at class start.
    ###
    isCommentAtClassStart = (token) -> isCommentAtParentStart token, 'ClassBody'

    ###*
    # Returns whether or not comments are at the class end or not.
    # @param {token} token The Comment token.
    # @returns {boolean} True if the comment is at class end.
    ###
    isCommentAtClassEnd = (token) -> isCommentAtParentEnd token, 'ClassBody'

    ###*
    # Returns whether or not comments are at the object start or not.
    # @param {token} token The Comment token.
    # @returns {boolean} True if the comment is at object start.
    ###
    isCommentAtObjectStart = (token) ->
      isCommentAtParentStart(token, 'ObjectExpression') or
      isCommentAtParentStart token, 'ObjectPattern'

    ###*
    # Returns whether or not comments are at the object end or not.
    # @param {token} token The Comment token.
    # @returns {boolean} True if the comment is at object end.
    ###
    isCommentAtObjectEnd = (token) ->
      isCommentAtParentEnd(token, 'ObjectExpression') or
      isCommentAtParentEnd token, 'ObjectPattern'

    ###*
    # Returns whether or not comments are at the array start or not.
    # @param {token} token The Comment token.
    # @returns {boolean} True if the comment is at array start.
    ###
    isCommentAtArrayStart = (token) ->
      isCommentAtParentStart(token, 'ArrayExpression') or
      isCommentAtParentStart token, 'ArrayPattern'

    ###*
    # Returns whether or not comments are at the array end or not.
    # @param {token} token The Comment token.
    # @returns {boolean} True if the comment is at array end.
    ###
    isCommentAtArrayEnd = (token) ->
      isCommentAtParentEnd(token, 'ArrayExpression') or
      isCommentAtParentEnd token, 'ArrayPattern'

    ###*
    # Checks if a comment token has lines around it (ignores inline comments)
    # @param {token} token The Comment token.
    # @param {Object} opts Options to determine the newline.
    # @param {boolean} opts.after Should have a newline after this line.
    # @param {boolean} opts.before Should have a newline before this line.
    # @returns {void}
    ###
    checkForEmptyLine = (token, opts) ->
      return if (
        applyDefaultIgnorePatterns and defaultIgnoreRegExp.test token.value
      )

      return if ignorePattern and customIgnoreRegExp.test token.value

      {after, before} = opts

      prevLineNum = token.loc.start.line - 1
      nextLineNum = token.loc.end.line + 1
      commentIsNotAlone = codeAroundComment token

      blockStartAllowed =
        options.allowBlockStart and
        isCommentAtBlockStart(token) and
        not (options.allowClassStart is no and isCommentAtClassStart token)
      blockEndAllowed =
        options.allowBlockEnd and
        isCommentAtBlockEnd(token) and
        not (options.allowClassEnd is no and isCommentAtClassEnd token)
      classStartAllowed =
        options.allowClassStart and isCommentAtClassStart token
      classEndAllowed = options.allowClassEnd and isCommentAtClassEnd token
      objectStartAllowed =
        options.allowObjectStart and isCommentAtObjectStart token
      objectEndAllowed = options.allowObjectEnd and isCommentAtObjectEnd token
      arrayStartAllowed =
        options.allowArrayStart and isCommentAtArrayStart token
      arrayEndAllowed = options.allowArrayEnd and isCommentAtArrayEnd token

      exceptionStartAllowed =
        blockStartAllowed or
        classStartAllowed or
        objectStartAllowed or
        arrayStartAllowed
      exceptionEndAllowed =
        blockEndAllowed or
        classEndAllowed or
        objectEndAllowed or
        arrayEndAllowed

      # ignore top of the file and bottom of the file
      if prevLineNum < 1 then before = no
      if nextLineNum >= numLines then after = no

      # we ignore all inline comments
      return if commentIsNotAlone

      previousTokenOrComment = sourceCode.getTokenBefore token,
        includeComments: yes
      nextTokenOrComment = sourceCode.getTokenAfter token, includeComments: yes

      # check for newline before
      if (
        not exceptionStartAllowed and
        before and
        not lodash.includes(commentAndEmptyLines, prevLineNum) and
        not (
          astUtils.isCommentToken(previousTokenOrComment) and
          astUtils.isTokenOnSameLine previousTokenOrComment, token
        )
      )
        lineStart = token.range[0] - token.loc.start.column
        range = [lineStart, lineStart]

        context.report
          node: token
          message: 'Expected line before comment.'
          fix: (fixer) -> fixer.insertTextBeforeRange range, '\n'

      # check for newline after
      if (
        not exceptionEndAllowed and
        after and
        not lodash.includes(commentAndEmptyLines, nextLineNum) and
        not (
          astUtils.isCommentToken(nextTokenOrComment) and
          astUtils.isTokenOnSameLine token, nextTokenOrComment
        )
      )
        context.report
          node: token
          message: 'Expected line after comment.'
          fix: (fixer) -> fixer.insertTextAfter token, '\n'

    #--------------------------------------------------------------------------
    # Public
    #--------------------------------------------------------------------------

    Program: ->
      comments.forEach (token) ->
        if token.type is 'Line'
          if options.beforeLineComment or options.afterLineComment
            checkForEmptyLine token,
              after: options.afterLineComment
              before: options.beforeLineComment
        else if token.type is 'Block'
          if options.beforeBlockComment or options.afterBlockComment
            checkForEmptyLine token,
              after: options.afterBlockComment
              before: options.beforeBlockComment
