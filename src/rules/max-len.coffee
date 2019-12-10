###*
# @fileoverview Rule to check for max length on a line.
# @author Matt DuVall <http://www.mattduvall.com>
###

'use strict'

{isString} = require 'lodash'

#------------------------------------------------------------------------------
# Constants
#------------------------------------------------------------------------------

OPTIONS_SCHEMA =
  type: 'object'
  properties:
    code:
      type: 'integer'
      minimum: 0
    comments:
      type: 'integer'
      minimum: 0
    tabWidth:
      type: 'integer'
      minimum: 0
    ignorePattern:
      type: 'string'
    ignoreComments:
      type: 'boolean'
    ignoreStrings:
      type: 'boolean'
    ignoreUrls:
      type: 'boolean'
    ignoreTemplateLiterals:
      type: 'boolean'
    ignoreRegExpLiterals:
      type: 'boolean'
    ignoreTrailingComments:
      type: 'boolean'
  additionalProperties: no

OPTIONS_OR_INTEGER_SCHEMA =
  anyOf: [
    OPTIONS_SCHEMA
  ,
    type: 'integer'
    minimum: 0
  ]

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'enforce a maximum line length'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/max-len'

    schema: [
      OPTIONS_OR_INTEGER_SCHEMA
      OPTIONS_OR_INTEGER_SCHEMA
      OPTIONS_SCHEMA
    ]

  create: (context) ->
    ###
    # Inspired by http://tools.ietf.org/html/rfc3986#appendix-B, however:
    # - They're matching an entire string that we know is a URI
    # - We're matching part of a string where we think there *might* be a URL
    # - We're only concerned about URLs, as picking out any URI would cause
    #   too many false positives
    # - We don't care about matching the entire URL, any small segment is fine
    ###
    URL_REGEXP = /[^:/?#]:\/\/[^?#]/

    sourceCode = context.getSourceCode()

    ###*
    # Computes the length of a line that may contain tabs. The width of each
    # tab will be the number of spaces to the next tab stop.
    # @param {string} line The line.
    # @param {int} tabWidth The width of each tab stop in spaces.
    # @returns {int} The computed line length.
    # @private
    ###
    computeLineLength = (line, tabWidth) ->
      extraCharacterCount = 0

      line.replace /\t/g, (match, offset) ->
        totalOffset = offset + extraCharacterCount
        previousTabStopOffset = if tabWidth then totalOffset % tabWidth else 0
        spaceCount = tabWidth - previousTabStopOffset

        extraCharacterCount += spaceCount - 1 # -1 for the replaced tab
      Array.from(line).length + extraCharacterCount

    # The options object must be the last option specified…
    lastOption = context.options[context.options.length - 1]
    options =
      if typeof lastOption is 'object'
        Object.create lastOption
      else
        {}

    # …but max code length…
    if typeof context.options[0] is 'number'
      options.code = context.options[0]

    # …and tabWidth can be optionally specified directly as integers.
    if typeof context.options[1] is 'number'
      options.tabWidth = context.options[1]

    maxLength = options.code or 80
    tabWidth = options.tabWidth or 4
    ignoreComments = options.ignoreComments or no
    ignoreStrings = options.ignoreStrings or no
    ignoreTemplateLiterals = options.ignoreTemplateLiterals or no
    ignoreRegExpLiterals = options.ignoreRegExpLiterals or no
    ignoreTrailingComments =
      options.ignoreTrailingComments or options.ignoreComments or no
    ignoreUrls = options.ignoreUrls or no
    maxCommentLength = options.comments
    ignorePattern = options.ignorePattern or null

    if ignorePattern then ignorePattern = new RegExp ignorePattern

    #--------------------------------------------------------------------------
    # Helpers
    #--------------------------------------------------------------------------

    ###*
    # Tells if a given comment is trailing: it starts on the current line and
    # extends to or past the end of the current line.
    # @param {string} line The source line we want to check for a trailing comment on
    # @param {number} lineNumber The one-indexed line number for line
    # @param {ASTNode} comment The comment to inspect
    # @returns {boolean} If the comment is trailing on the given line
    ###
    isTrailingComment = (line, lineNumber, comment) ->
      comment and
      (comment.loc.start.line is lineNumber and
        lineNumber <= comment.loc.end.line) and
      (comment.loc.end.line > lineNumber or
        comment.loc.end.column is line.length)

    ###*
    # Tells if a comment encompasses the entire line.
    # @param {string} line The source line with a trailing comment
    # @param {number} lineNumber The one-indexed line number this is on
    # @param {ASTNode} comment The comment to remove
    # @returns {boolean} If the comment covers the entire line
    ###
    isFullLineComment = (line, lineNumber, comment) ->
      {start, end} = comment.loc
      isFirstTokenOnLine = not line.slice(0, comment.loc.start.column).trim()

      (start.line < lineNumber or
        (start.line is lineNumber and isFirstTokenOnLine)) and
        (end.line > lineNumber or
          (end.line is lineNumber and end.column is line.length))

    ###*
    # Gets the line after the comment and any remaining trailing whitespace is
    # stripped.
    # @param {string} line The source line with a trailing comment
    # @param {ASTNode} comment The comment to remove
    # @returns {string} Line without comment and trailing whitepace
    ###
    stripTrailingComment = (line, comment) ->
      # loc.column is zero-indexed
      line.slice(0, comment.loc.start.column).replace /\s+$/, ''

    ###*
    # Ensure that an array exists at [key] on `object`, and add `value` to it.
    #
    # @param {Object} object the object to mutate
    # @param {string} key the object's key
    # @param {*} value the value to add
    # @returns {void}
    # @private
    ###
    ensureArrayAndPush = (object, key, value) ->
      unless Array.isArray object[key] then object[key] = []
      object[key].push value

    allStringLiterals = []
    ###*
    # Retrieves an array containing all strings (" or ') in the source code.
    #
    # @returns {ASTNode[]} An array of string nodes.
    ###
    getAllStrings = ->
      # sourceCode.ast.tokens.filter (token) ->
      #   token.type is 'String' or
      #   (token.type is 'JSXText' and
      #     sourceCode.getNodeByRangeIndex(token.range[0] - 1).type is
      #       'JSXAttribute')
      allStringLiterals

    allTemplateLiterals = []
    ###*
    # Retrieves an array containing all template literals in the source code.
    #
    # @returns {ASTNode[]} An array of template literal nodes.
    ###
    getAllTemplateLiterals = ->
      # sourceCode.ast.tokens.filter (token) -> token.type is 'Template'
      allTemplateLiterals

    ###*
    # Retrieves an array containing all RegExp literals in the source code.
    #
    # @returns {ASTNode[]} An array of RegExp literal nodes.
    ###
    getAllRegExpLiterals = ->
      sourceCode.ast.tokens.filter (token) -> token.type is 'RegularExpression'

    ###*
    # A reducer to group an AST node by line number, both start and end.
    #
    # @param {Object} acc the accumulator
    # @param {ASTNode} node the AST node in question
    # @returns {Object} the modified accumulator
    # @private
    ###
    groupByLineNumber = (acc, node) ->
      i = node.loc.start.line
      while i <= node.loc.end.line
        ensureArrayAndPush acc, i, node
        ++i
      acc

    ###*
    # Check the program for max length
    # @param {ASTNode} node Node to examine
    # @returns {void}
    # @private
    ###
    checkProgramForMaxLength = (node) ->
      # split (honors line-ending)
      {lines} = sourceCode

      # list of comments to ignore
      comments =
        if ignoreComments or maxCommentLength or ignoreTrailingComments
          sourceCode.getAllComments()
        else
          []

      # we iterate over comments in parallel with the lines
      commentsIndex = 0

      strings = getAllStrings()
      stringsByLine = strings.reduce groupByLineNumber, {}

      templateLiterals = getAllTemplateLiterals()
      templateLiteralsByLine = templateLiterals.reduce groupByLineNumber, {}

      regExpLiterals = getAllRegExpLiterals()
      regExpLiteralsByLine = regExpLiterals.reduce groupByLineNumber, {}

      lines.forEach (line, i) ->
        # i is zero-indexed, line numbers are one-indexed
        lineNumber = i + 1

        ###
        # if we're checking comment length; we need to know whether this
        # line is a comment
        ###
        lineIsComment = no
        ###
        # We can short-circuit the comment checks if we're already out of
        # comments to check.
        ###
        if commentsIndex < comments.length
          # iterate over comments until we find one past the current line
          while (
            (comment = comments[++commentsIndex]) and
            comment.loc.start.line <= lineNumber
          )
            # eslint-disable-line no-empty
            ;

          # and step back by one
          comment = comments[--commentsIndex]

          if isFullLineComment line, lineNumber, comment
            lineIsComment = yes
            textToMeasure = line
          else if (
            ignoreTrailingComments and
            isTrailingComment line, lineNumber, comment
          )
            textToMeasure = stripTrailingComment line, comment
          else
            textToMeasure = line
        else
          textToMeasure = line
        # ignore this line
        return if (
          ignorePattern?.test(textToMeasure) or
          (ignoreUrls and URL_REGEXP.test(textToMeasure)) or
          (ignoreStrings and stringsByLine[lineNumber]) or
          (ignoreTemplateLiterals and templateLiteralsByLine[lineNumber]) or
          (ignoreRegExpLiterals and regExpLiteralsByLine[lineNumber])
        )

        lineLength = computeLineLength textToMeasure, tabWidth
        commentLengthApplies = lineIsComment and maxCommentLength

        return if lineIsComment and ignoreComments

        if commentLengthApplies
          if lineLength > maxCommentLength
            context.report {
              node
              loc: line: lineNumber, column: 0
              message:
                'Line {{lineNumber}} exceeds the maximum comment line length of {{maxCommentLength}}.'
              data: {
                lineNumber: i + 1
                maxCommentLength
              }
            }
        else if lineLength > maxLength
          context.report {
            node
            loc: line: lineNumber, column: 0
            message:
              'Line {{lineNumber}} exceeds the maximum line length of {{maxLength}}.'
            data: {
              lineNumber: i + 1
              maxLength
            }
          }

    #--------------------------------------------------------------------------
    # Public API
    #--------------------------------------------------------------------------

    TemplateLiteral: (node) ->
      allTemplateLiterals.push node
    Literal: (node) ->
      allStringLiterals.push node if (
        isString(node.value) and node.parent.type isnt 'JSXElement'
      )
    'Program:exit': checkProgramForMaxLength
