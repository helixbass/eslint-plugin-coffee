###*
# @fileoverview Look for useless escapes in strings and regexes
# @author Onur Temizkan
###

'use strict'

astUtils = require '../eslint-ast-utils'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

###*
# Returns the union of two sets.
# @param {Set} setA The first set
# @param {Set} setB The second set
# @returns {Set} The union of the two sets
###
union = (setA, setB) ->
  new Set do ->
    yield from setA
    yield from setB

VALID_STRING_ESCAPES = union new Set('\\nrvtbfux'), astUtils.LINEBREAKS
REGEX_GENERAL_ESCAPES = new Set '\\bcdDfnpPrsStvwWxu0123456789]/'
REGEX_NON_CHARCLASS_ESCAPES = union(
  REGEX_GENERAL_ESCAPES
  new Set '^/.$*+?[{}|()Bk'
)

###*
# Parses a regular expression into a list of characters with character class info.
# @param {string} regExpText The raw text used to create the regular expression
# @returns {Object[]} A list of characters, each with info on escaping and whether they're in a character class.
# @example
#
# parseRegExp('a\\b[cd-]')
#
# returns:
# [
#   {text: 'a', index: 0, escaped: false, inCharClass: false, startsCharClass: false, endsCharClass: false},
#   {text: 'b', index: 2, escaped: true, inCharClass: false, startsCharClass: false, endsCharClass: false},
#   {text: 'c', index: 4, escaped: false, inCharClass: true, startsCharClass: true, endsCharClass: false},
#   {text: 'd', index: 5, escaped: false, inCharClass: true, startsCharClass: false, endsCharClass: false},
#   {text: '-', index: 6, escaped: false, inCharClass: true, startsCharClass: false, endsCharClass: false}
# ]
###
parseRegExp = (regExpText) ->
  charList = []

  regExpText
  .split ''
  .reduce(
    (state, char, index) ->
      unless state.escapeNextChar
        return Object.assign state, escapeNextChar: yes if char is '\\'
        if char is '[' and not state.inCharClass
          return Object.assign state, inCharClass: yes, startingCharClass: yes
        if char is ']' and state.inCharClass
          if charList.length and charList[charList.length - 1].inCharClass
            charList[charList.length - 1].endsCharClass = yes
          return Object.assign state, inCharClass: no, startingCharClass: no
      charList.push {
        text: char
        index
        escaped: state.escapeNextChar
        inCharClass: state.inCharClass
        startsCharClass: state.startingCharClass
        endsCharClass: no
      }
      Object.assign state, escapeNextChar: no, startingCharClass: no
  ,
    escapeNextChar: no, inCharClass: no, startingCharClass: no
  )

  charList

module.exports =
  meta:
    docs:
      description: 'disallow unnecessary escape characters'
      category: 'Best Practices'
      recommended: yes
      url: 'https://eslint.org/docs/rules/no-useless-escape'

    schema: []

  create: (context) ->
    sourceCode = context.getSourceCode()

    ###*
    # Reports a node
    # @param {ASTNode} node The node to report
    # @param {number} startOffset The backslash's offset from the start of the node
    # @param {string} character The uselessly escaped character (not including the backslash)
    # @returns {void}
    ###
    report = (node, startOffset, character) ->
      context.report {
        node
        loc: sourceCode.getLocFromIndex(
          sourceCode.getIndexFromLoc(node.loc.start) + startOffset
        )
        message: 'Unnecessary escape character: \\{{character}}.'
        data: {character}
      }

    ###*
    # Checks if the escape character in given string slice is unnecessary.
    #
    # @private
    # @param {ASTNode} node - node to validate.
    # @param {string} match - string slice to validate.
    # @returns {void}
    ###
    validateString = (node, match, value) ->
      isTemplateElement = node.type is 'TemplateElement'
      escapedChar = match[0][1]
      isUnnecessaryEscape = not VALID_STRING_ESCAPES.has escapedChar
      if isTemplateElement
        {quote} = node.parent
        isQuoteEscape = quote? and escapedChar is quote[0]
        if isQuoteEscape and quote.length is 3
          isQuoteEscape = no
          followingQuotes = /// ^ (?: \\?#{quote[0]} )+ ///.exec(
            value[(match.index + match[0].length)..]
          )
          precedingQuotes = /// (?: \\?#{quote[0]} )+ $ ///.exec(
            value[...match.index]
          )
          isClosingQuote = match.index + match[0].length is value.length
          # eslint-disable-next-line coffee/no-inner-declarations
          getNumFoundQuotes = (quotesMatch) ->
            return 0 unless quotesMatch
            quotesMatch[0].match(///#{quote[0]}///g).length
          isQuoteEscape = yes if (
            isClosingQuote or
            getNumFoundQuotes(followingQuotes) +
              getNumFoundQuotes(precedingQuotes) >=
              2
          )
      else
        isQuoteEscape = escapedChar is node.raw[0]

      if isTemplateElement or node.extra?.raw?[0] is '"'
        if escapedChar is '#'
          # Warn if `\#` is not followed by `{`
          isUnnecessaryEscape = match.input[match.index + 2] isnt '{'
        else if escapedChar is '{'
          ###
          # Warn if `\{` is not preceded by `#`. If preceded by `#`, escaping
          # is necessary and the rule should not warn. If preceded by `/#`, the rule
          # will warn for the `/#` instead, as it is the first unnecessarily escaped character.
          ###
          isUnnecessaryEscape = match.input[match.index - 1] isnt '#'

      if isUnnecessaryEscape and not isQuoteEscape
        report node, match.index + 1, match[0].slice 1

    ###*
    # Checks if a node has an escape.
    #
    # @param {ASTNode} node - node to check.
    # @returns {void}
    ###
    check = (node) ->
      isTemplateElement = node.type is 'TemplateElement'

      # Don't report tagged template literals, because the backslash character is accessible to the tag function.
      return if (
        isTemplateElement and
        node.parent?.parent?.type is 'TaggedTemplateExpression' and
        node.parent is node.parent.parent.quasi
      )

      isInterpolatedRegex =
        isTemplateElement and
        node.parent?.parent?.type is 'InterpolatedRegExpLiteral'

      if (
        typeof node.value is 'string' or
        (isTemplateElement and not isInterpolatedRegex)
      )
        ###
        # JSXAttribute doesn't have any escape sequence: https://facebook.github.io/jsx/.
        # In addition, backticks are not supported by JSX yet: https://github.com/facebook/jsx/issues/25.
        ###
        return if node.parent.type in [
          'JSXAttribute'
          'JSXElement'
          'JSXFragment'
        ]

        value =
          if isTemplateElement
            node.value.raw
          else
            node.raw.slice 1, -1
        pattern = /\\[^\d]/g

        while match = pattern.exec value
          validateString node, match, value
      else if node.regex or isInterpolatedRegex
        parseRegExp node.regex?.pattern ? node.value.raw
        ###
        # The '-' character is a special case, because it's only valid to escape it if it's in a character
        # class, and is not at either edge of the character class. To account for this, don't consider '-'
        # characters to be valid in general, and filter out '-' characters that appear in the middle of a
        # character class.
        ###
        .filter (charInfo) ->
          not (
            charInfo.text is '-' and
            charInfo.inCharClass and
            not charInfo.startsCharClass and
            not charInfo.endsCharClass
          )
          ###
          # The '^' character is also a special case; it must always be escaped outside of character classes, but
          # it only needs to be escaped in character classes if it's at the beginning of the character class. To
          # account for this, consider it to be a valid escape character outside of character classes, and filter
          # out '^' characters that appear at the start of a character class.
          ###
        .filter (charInfo) ->
          not (charInfo.text is '^' and charInfo.startsCharClass)
          # Filter out characters that aren't escaped.
        .filter (charInfo) -> charInfo.escaped
        # Filter out characters that are valid to escape, based on their position in the regular expression.
        .filter (charInfo) ->
          not (
            if charInfo.inCharClass
              REGEX_GENERAL_ESCAPES
            else
              REGEX_NON_CHARCLASS_ESCAPES
          ).has charInfo.text
          # Report all the remaining characters.
        .forEach (charInfo) -> report node, charInfo.index, charInfo.text

    Literal: check
    TemplateElement: check
