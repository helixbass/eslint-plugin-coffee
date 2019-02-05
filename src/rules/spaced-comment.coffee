###*
# @fileoverview Source code for spaced-comments rule
# @author Gyandeep Singh
###
'use strict'

lodash = require 'lodash'
astUtils = require '../eslint-ast-utils'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

###*
# Escapes the control characters of a given string.
# @param {string} s - A string to escape.
# @returns {string} An escaped string.
###
escape = (s) -> "(?:#{lodash.escapeRegExp s})"

###*
# Escapes the control characters of a given string.
# And adds a repeat flag.
# @param {string} s - A string to escape.
# @returns {string} An escaped string.
###
escapeAndRepeat = (s) -> "#{escape s}+"

###*
# Parses `markers` option.
# If markers don't include `"*"`, this adds `"*"` to allow JSDoc comments.
# @param {string[]} [markers] - A marker list.
# @returns {string[]} A marker list.
###
parseMarkersOption = (markers) ->
  # `*` is a marker for JSDoc comments.
  return markers.concat '*' if markers.indexOf('*') is -1

  markers

###*
# Creates string pattern for exceptions.
# Generated pattern:
#
# 1. A space or an exception pattern sequence.
#
# @param {string[]} exceptions - An exception pattern list.
# @returns {string} A regular expression string for exceptions.
###
createExceptionsPattern = (exceptions) ->
  pattern = ''

  ###
  # A space or an exception pattern sequence.
  # []                 ==> "\s"
  # ["-"]              ==> "(?:\s|\-+$)"
  # ["-", "="]         ==> "(?:\s|(?:\-+|=+)$)"
  # ["-", "=", "--=="] ==> "(?:\s|(?:\-+|=+|(?:\-\-==)+)$)" ==> https://jex.im/regulex/#!embed=false&flags=&re=(%3F%3A%5Cs%7C(%3F%3A%5C-%2B%7C%3D%2B%7C(%3F%3A%5C-%5C-%3D%3D)%2B)%24)
  ###
  if exceptions.length is 0
    # a space.
    pattern += '\\s'
  else
    # a space or...
    pattern += '(?:\\s|'

    if exceptions.length is 1
      # a sequence of the exception pattern.
      pattern += escapeAndRepeat exceptions[0]
    else
      # a sequence of one of the exception patterns.
      pattern += '(?:'
      pattern += exceptions.map(escapeAndRepeat).join '|'
      pattern += ')'
    pattern += "(?:$|[#{Array.from(astUtils.LINEBREAKS).join ''}]))"

  pattern

###*
# Creates RegExp object for `always` mode.
# Generated pattern for beginning of comment:
#
# 1. First, a marker or nothing.
# 2. Next, a space or an exception pattern sequence.
#
# @param {string[]} markers - A marker list.
# @param {string[]} exceptions - An exception pattern list.
# @returns {RegExp} A RegExp object for the beginning of a comment in `always` mode.
###
createAlwaysStylePattern = (markers, exceptions) ->
  pattern = '^'

  ###
  # A marker or nothing.
  # ["*"]            ==> "\*?"
  # ["*", "!"]       ==> "(?:\*|!)?"
  # ["*", "/", "!<"] ==> "(?:\*|\/|(?:!<))?" ==> https://jex.im/regulex/#!embed=false&flags=&re=(%3F%3A%5C*%7C%5C%2F%7C(%3F%3A!%3C))%3F
  ###
  if markers.length is 1
    # the marker.
    pattern += escape markers[0]
  else
    # one of markers.
    pattern += '(?:'
    pattern += markers.map(escape).join '|'
    pattern += ')'

  pattern += '?' # or nothing.
  pattern += createExceptionsPattern exceptions

  new RegExp pattern

###*
# Creates RegExp object for `never` mode.
# Generated pattern for beginning of comment:
#
# 1. First, a marker or nothing (captured).
# 2. Next, a space or a tab.
#
# @param {string[]} markers - A marker list.
# @returns {RegExp} A RegExp object for `never` mode.
###
createNeverStylePattern = (markers) ->
  pattern = "^(#{markers.map(escape).join '|'})?[ \t]+"

  new RegExp pattern

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'enforce consistent spacing after the `//` or `/*` in a comment'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/spaced-comment'

    fixable: 'whitespace'

    schema: [
      enum: ['always', 'never']
    ,
      type: 'object'
      properties:
        exceptions:
          type: 'array'
          items:
            type: 'string'
        markers:
          type: 'array'
          items:
            type: 'string'
        line:
          type: 'object'
          properties:
            exceptions:
              type: 'array'
              items:
                type: 'string'
            markers:
              type: 'array'
              items:
                type: 'string'
          additionalProperties: no
        block:
          type: 'object'
          properties:
            exceptions:
              type: 'array'
              items:
                type: 'string'
            markers:
              type: 'array'
              items:
                type: 'string'
            balanced:
              type: 'boolean'
          additionalProperties: no
      additionalProperties: no
    ]

  create: (context) ->
    sourceCode = context.getSourceCode()

    # Unless the first option is never, require a space
    requireSpace = context.options[0] isnt 'never'

    ###
    # Parse the second options.
    # If markers don't include `"*"`, it's added automatically for JSDoc
    # comments.
    ###
    config = context.options[1] or {}
    balanced = config.block?.balanced

    styleRules = ['block', 'line'].reduce(
      (rule, type) ->
        markers = parseMarkersOption(
          config[type]?.markers or config.markers or []
        )
        exceptions = config[type]?.exceptions or config.exceptions or []
        endNeverPattern = '[ \t]+$'

        # Create RegExp object for valid patterns.
        rule[type] =
          beginRegex:
            if requireSpace
              createAlwaysStylePattern markers, exceptions
            else
              createNeverStylePattern markers
          endRegex:
            if balanced and requireSpace
              new RegExp "#{createExceptionsPattern exceptions}$"
            else
              new RegExp endNeverPattern
          hasExceptions: exceptions.length > 0
          markers: new RegExp "^(#{markers.map(escape).join '|'})"

        rule
      {}
    )

    ###*
    # Reports a beginning spacing error with an appropriate message.
    # @param {ASTNode} node - A comment node to check.
    # @param {string} message - An error message to report.
    # @param {Array} match - An array of match results for markers.
    # @param {string} refChar - Character used for reference in the error message.
    # @returns {void}
    ###
    reportBegin = (node, message, match, refChar) ->
      type = node.type.toLowerCase()
      commentIdentifier = if type is 'block' then '###' else '#'

      context.report {
        node
        fix: (fixer) ->
          start = node.range[0]
          end = start + commentIdentifier.length

          if requireSpace
            if match then end += match[0].length
            return fixer.insertTextAfterRange [start, end], ' '
          end += match[0].length
          fixer.replaceTextRange(
            [start, end]
            commentIdentifier + (if match[1] then match[1] else '')
          )
        message
        data: {refChar}
      }

    ###*
    # Reports an ending spacing error with an appropriate message.
    # @param {ASTNode} node - A comment node to check.
    # @param {string} message - An error message to report.
    # @param {string} match - An array of the matched whitespace characters.
    # @returns {void}
    ###
    reportEnd = (node, message, match) ->
      context.report {
        node
        fix: (fixer) ->
          return fixer.insertTextAfterRange(
            [node.range[0], node.range[1] - 3]
            ' '
          ) if requireSpace
          end = node.range[1] - 3
          start = end - match[0].length

          fixer.replaceTextRange [start, end], ''
        message
      }

    ###*
    # Reports a given comment if it's invalid.
    # @param {ASTNode} node - a comment node to check.
    # @returns {void}
    ###
    checkCommentForSpace = (node) ->
      type = node.type.toLowerCase()
      rule = styleRules[type]
      commentIdentifier = if type is 'block' then '###' else '#'

      # Ignores empty comments.
      return if node.value.length is 0

      beginMatch = rule.beginRegex.exec node.value
      endMatch = rule.endRegex.exec node.value

      # Checks.
      if requireSpace
        unless beginMatch
          hasMarker = rule.markers.exec node.value
          marker =
            if hasMarker
              commentIdentifier + hasMarker[0]
            else
              commentIdentifier

          if rule.hasExceptions
            reportBegin(
              node
              "Expected exception block, space or tab after '{{refChar}}' in comment."
              hasMarker
              marker
            )
          else
            reportBegin(
              node
              "Expected space or tab after '{{refChar}}' in comment."
              hasMarker
              marker
            )

        if balanced and type is 'block' and not endMatch
          reportEnd node, "Expected space or tab before '###' in comment."
      else
        if beginMatch
          unless beginMatch[1]
            reportBegin(
              node
              "Unexpected space or tab after '{{refChar}}' in comment."
              beginMatch
              commentIdentifier
            )
          else
            reportBegin(
              node
              'Unexpected space or tab after marker ({{refChar}}) in comment.'
              beginMatch
              beginMatch[1]
            )

        if balanced and type is 'block' and endMatch
          reportEnd(
            node
            "Unexpected space or tab before '###' in comment."
            endMatch
          )

    Program: ->
      comments = sourceCode.getAllComments()

      comments
      .filter (token) -> token.type isnt 'Shebang'
      .forEach checkCommentForSpace
