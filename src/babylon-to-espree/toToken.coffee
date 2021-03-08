'use strict'

module.exports = (token, tt, source) ->
  type = token.type
  token.range = [token.start, token.end]

  if type is tt.name
    token.type = 'Identifier'
  else if (
    type in [
      tt.semi
      tt.comma
      tt.parenL
      tt.parenR
      tt.braceL
      tt.braceR
      tt.slash
      tt.dot
      tt.bracketL
      tt.bracketR
      tt.ellipsis
      tt.arrow
      tt.star
      tt.incDec
      tt.colon
      tt.question
      tt.template
      tt.backQuote
      tt.dollarBraceL
      tt.at
      tt.logicalOR
      tt.logicalAND
      tt.bitwiseOR
      tt.bitwiseXOR
      tt.bitwiseAND
      tt.equality
      tt.relational
      tt.bitShift
      tt.plusMin
      tt.modulo
      tt.exponent
      tt.prefix
      tt.doubleColon
    ] or type.isAssign
  )
    token.type = 'Punctuator'
    unless token.value then token.value = type.label
  else if type is tt.jsxTagStart
    token.type = 'Punctuator'
    token.value = '<'
  else if type is tt.jsxTagEnd
    token.type = 'Punctuator'
    token.value = '>'
  else if type is tt.jsxName
    token.type = 'JSXIdentifier'
  else if type is tt.jsxText
    token.type = 'JSXText'
  else if type.keyword is 'null'
    token.type = 'Null'
  else if type.keyword in ['false', 'true']
    token.type = 'Boolean'
  else if type.keyword
    token.type = 'Keyword'
  else if type is tt.num
    token.type = 'Numeric'
    token.value = source.slice token.start, token.end
  else if type is tt.string
    token.type = 'String'
    token.value = source.slice token.start, token.end
  else if type is tt.regexp
    token.type = 'RegularExpression'
    value = token.value
    token.regex =
      pattern: value.pattern
      flags: value.flags
    token.value = "/#{value.pattern}/#{value.flags}"

  token
