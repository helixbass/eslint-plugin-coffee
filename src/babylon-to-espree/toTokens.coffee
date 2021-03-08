'use strict'

convertTemplateType = require './convertTemplateType'
toToken = require './toToken'

module.exports = (tokens, tt, code) ->
  # transform tokens to type "Template"
  convertTemplateType tokens, tt

  transformedTokens = []
  for token in tokens when (
    token.type isnt 'CommentLine' and token.type isnt 'CommentBlock'
  )
    transformedTokens.push toToken token, tt, code

  transformedTokens
