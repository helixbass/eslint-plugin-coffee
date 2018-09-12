###*
# @fileoverview enforce or disallow capitalization of the first letter of a comment
# @author Kevin Partington
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

LETTER_PATTERN = require 'eslint/lib/util/patterns/letters'
astUtils = require 'eslint/lib/ast-utils'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

DEFAULT_IGNORE_PATTERN = astUtils.COMMENTS_IGNORE_PATTERN
WHITESPACE = /\s/g
MAYBE_URL = /^\s*[^:/?#\s]+:\/\/[^?#]/ # TODO: Combine w/ max-len pattern?
DEFAULTS =
  ignorePattern: null
  ignoreInlineComments: no
  ignoreConsecutiveComments: no

###
# Base schema body for defining the basic capitalization rule, ignorePattern,
# and ignoreInlineComments values.
# This can be used in a few different ways in the actual schema.
###
SCHEMA_BODY =
  type: 'object'
  properties:
    ignorePattern:
      type: 'string'
    ignoreInlineComments:
      type: 'boolean'
    ignoreConsecutiveComments:
      type: 'boolean'
  additionalProperties: no

###*
# Get normalized options for either block or line comments from the given
# user-provided options.
# - If the user-provided options is just a string, returns a normalized
#   set of options using default values for all other options.
# - If the user-provided options is an object, then a normalized option
#   set is returned. Options specified in overrides will take priority
#   over options specified in the main options object, which will in
#   turn take priority over the rule's defaults.
#
# @param {Object|string} rawOptions The user-provided options.
# @param {string} which Either "line" or "block".
# @returns {Object} The normalized options.
###
getNormalizedOptions = (rawOptions, which) ->
  return {...DEFAULTS} unless rawOptions

  {...DEFAULTS, ...(rawOptions[which] or rawOptions)}

###*
# Get normalized options for block and line comments.
#
# @param {Object|string} rawOptions The user-provided options.
# @returns {Object} An object with "Line" and "Block" keys and corresponding
# normalized options objects.
###
getAllNormalizedOptions = (rawOptions) ->
  Line: getNormalizedOptions rawOptions, 'line'
  Block: getNormalizedOptions rawOptions, 'block'

###*
# Creates a regular expression for each ignorePattern defined in the rule
# options.
#
# This is done in order to avoid invoking the RegExp constructor repeatedly.
#
# @param {Object} normalizedOptions The normalized rule options.
# @returns {void}
###
createRegExpForIgnorePatterns = (normalizedOptions) ->
  Object.keys(normalizedOptions).forEach (key) ->
    ignorePatternStr = normalizedOptions[key].ignorePattern

    if ignorePatternStr
      regExp = RegExp "^\\s*(?:#{ignorePatternStr})"

      normalizedOptions[key].ignorePatternRegExp = regExp

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'enforce or disallow capitalization of the first letter of a comment'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/capitalized-comments'
    fixable: 'code'
    schema: [
      enum: ['always', 'never']
    ,
      oneOf: [
        SCHEMA_BODY
      ,
        type: 'object'
        properties:
          line: SCHEMA_BODY
          block: SCHEMA_BODY
        additionalProperties: no
      ]
    ]

    messages:
      unexpectedLowercaseComment:
        'Comments should not begin with a lowercase character'
      unexpectedUppercaseComment:
        'Comments should not begin with an uppercase character'

  create: (context) ->
    capitalize = context.options[0] or 'always'
    normalizedOptions = getAllNormalizedOptions context.options[1]
    sourceCode = context.getSourceCode()

    createRegExpForIgnorePatterns normalizedOptions

    #----------------------------------------------------------------------
    # Helpers
    #----------------------------------------------------------------------

    ###*
    # Checks whether a comment is an inline comment.
    #
    # For the purpose of this rule, a comment is inline if:
    # 1. The comment is preceded by a token on the same line; and
    # 2. The command is followed by a token on the same line.
    #
    # Note that the comment itself need not be single-line!
    #
    # Also, it follows from this definition that only block comments can
    # be considered as possibly inline. This is because line comments
    # would consume any following tokens on the same line as the comment.
    #
    # @param {ASTNode} comment The comment node to check.
    # @returns {boolean} True if the comment is an inline comment, false
    # otherwise.
    ###
    isInlineComment = (comment) ->
      previousToken = sourceCode.getTokenBefore comment, includeComments: yes
      nextToken = sourceCode.getTokenAfter comment, includeComments: yes

      Boolean(
        previousToken and
          nextToken and
          comment.loc.start.line is previousToken.loc.end.line and
          comment.loc.end.line is nextToken.loc.start.line
      )

    ###*
    # Determine if a comment follows another comment.
    #
    # @param {ASTNode} comment The comment to check.
    # @returns {boolean} True if the comment follows a valid comment.
    ###
    isConsecutiveComment = (comment) ->
      previousTokenOrComment = sourceCode.getTokenBefore comment,
        includeComments: yes

      Boolean(
        previousTokenOrComment and
          ['Block', 'Line'].indexOf(previousTokenOrComment.type) isnt -1
      )

    ###*
    # Check a comment to determine if it is valid for this rule.
    #
    # @param {ASTNode} comment The comment node to process.
    # @param {Object} options The options for checking this comment.
    # @returns {boolean} True if the comment is valid, false otherwise.
    ###
    isCommentValid = (comment, options) ->
      # 1. Check for default ignore pattern.
      return yes if DEFAULT_IGNORE_PATTERN.test comment.value

      # 2. Check for custom ignore pattern.
      commentWithoutAsterisks = comment.value.replace /\*/g, ''

      return yes if options.ignorePatternRegExp?.test commentWithoutAsterisks

      # 3. Check for inline comments.
      return yes if options.ignoreInlineComments and isInlineComment comment

      # 4. Is this a consecutive comment (and are we tolerating those)?
      return yes if (
        options.ignoreConsecutiveComments and isConsecutiveComment comment
      )

      # 5. Does the comment start with a possible URL?
      return yes if MAYBE_URL.test commentWithoutAsterisks

      # 6. Is the initial word character a letter?
      commentWordCharsOnly = commentWithoutAsterisks.replace WHITESPACE, ''

      return yes if commentWordCharsOnly.length is 0

      firstWordChar = commentWordCharsOnly[0]

      return yes unless LETTER_PATTERN.test firstWordChar

      # 7. Check the case of the initial word character.
      isUppercase = firstWordChar isnt firstWordChar.toLocaleLowerCase()
      isLowercase = firstWordChar isnt firstWordChar.toLocaleUpperCase()

      return no if capitalize is 'always' and isLowercase
      return no if capitalize is 'never' and isUppercase

      yes

    ###*
    # Process a comment to determine if it needs to be reported.
    #
    # @param {ASTNode} comment The comment node to process.
    # @returns {void}
    ###
    processComment = (comment) ->
      options = normalizedOptions[comment.type]
      commentValid = isCommentValid comment, options

      unless commentValid
        messageId =
          if capitalize is 'always'
            'unexpectedLowercaseComment'
          else
            'unexpectedUppercaseComment'

        context.report {
          node: null # Intentionally using loc instead
          loc: comment.loc
          messageId
          fix: (fixer) ->
            match = comment.value.match LETTER_PATTERN

            isBlock = comment.type.toLowerCase() is 'block'
            offset = (if isBlock then '###' else '#').length
            fixer.replaceTextRange(
              # Offset match.index by 2 to account for the first 2 characters that start the comment (// or /*)
              [
                comment.range[0] + match.index + offset
                comment.range[0] + match.index + offset + 1
              ]
              if capitalize is 'always'
                match[0].toLocaleUpperCase()
              else
                match[0].toLocaleLowerCase()
            )
        }

    #----------------------------------------------------------------------
    # Public
    #----------------------------------------------------------------------

    Program: ->
      comments = sourceCode.getAllComments()

      comments
        .filter (token) -> token.type isnt 'Shebang'
        .forEach processComment
