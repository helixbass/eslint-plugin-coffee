###*
# @fileoverview Rule to flag the use of empty character classes in regular expressions
# @author Ian Christian Myers
###

'use strict'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

###
# plain-English description of the following regexp:
# 0. `^` fix the match at the beginning of the string
# 1. `\/`: the `/` that begins the regexp
# 2. `([^\\[]|\\.|\[([^\\\]]|\\.)+\])*`: regexp contents; 0 or more of the following
# 2.0. `[^\\[]`: any character that's not a `\` or a `[` (anything but escape sequences and character classes)
# 2.1. `\\.`: an escape sequence
# 2.2. `\[([^\\\]]|\\.)+\]`: a character class that isn't empty
# 3. `\/` the `/` that ends the regexp
# 4. `[gimuy]*`: optional regexp flags
# 5. `$`: fix the match at the end of the string
###
regex = ///
  ^
  /
  (
    [^\\[]
      |
    \\[\S\s]
      |
    \[
    (
      [^\\\]]
        |
      \\.
    )+
    \]
  )*
  /
  [gimuys]*
  $
///u
justContentRegex = ///
  ^
  (
    [^\\[]
      |
    \\[\S\s]
      |
    \[
    (
      [^\\\]]
        |
      \\.
    )+
    \]
  )*
  $
///u

withoutCommentLines = (regexChunk) ->
  regexChunk.replace /^\s*#.*$/m, ''

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow empty character classes in regular expressions'
      category: 'Possible Errors'
      recommended: yes
      url: 'https://eslint.org/docs/rules/no-empty-character-class'

    schema: []

    messages: unexpected: 'Empty class.'

  create: (context) ->
    sourceCode = context.getSourceCode()

    Literal: (node) ->
      token = sourceCode.getFirstToken node

      return unless token.type is 'RegularExpression'
      unless regex.test withoutCommentLines node.raw
        context.report {node, messageId: 'unexpected'}

    TemplateElement: (node) ->
      return unless (
        node.value?.raw? and
        node.parent?.parent?.type is 'InterpolatedRegExpLiteral'
      )
      unless justContentRegex.test withoutCommentLines node.value.raw
        context.report node: node.parent.parent, messageId: 'unexpected'
