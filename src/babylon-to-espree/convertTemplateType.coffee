'use strict'

module.exports = (tokens, tt) ->
  startingToken = 0
  currentToken = 0
  numBraces = 0 # track use of {}
  numBackQuotes = 0 # track number of nested templates
  isBackQuote = (token) ->
    tokens[token].type is tt.backQuote

  isTemplateStarter = (token) ->
    isBackQuote(token) or
    # only can be a template starter when in a template already
    (tokens[token].type is tt.braceR and numBackQuotes > 0)

  isTemplateEnder = (token) ->
    isBackQuote(token) or tokens[token].type is tt.dollarBraceL

  # append the values between start and end
  createTemplateValue = (start, end) ->
    value = ''
    while start <= end
      if tokens[start].value
        value += tokens[start].value
      else unless tokens[start].type is tt.template
        value += tokens[start].type.label
      start++
    value

  # create Template token
  replaceWithTemplateType = (start, end) ->
    templateToken =
      type: 'Template'
      value: createTemplateValue start, end
      start: tokens[start].start
      end: tokens[end].end
      loc:
        start: tokens[start].loc.start
        end: tokens[end].loc.end

    # put new token in place of old tokens
    tokens.splice start, end - start + 1, templateToken

  trackNumBraces = (token) ->
    if tokens[token].type is tt.braceL
      numBraces++
    else if tokens[token].type is tt.braceR
      numBraces--

  while startingToken < tokens.length
    # template start: check if ` or }
    if isTemplateStarter(startingToken) and numBraces is 0
      if isBackQuote startingToken
        numBackQuotes++

      currentToken = startingToken + 1

      # check if token after template start is "template"
      break if (
        currentToken >= tokens.length - 1 or
        tokens[currentToken].type isnt tt.template
      )

      # template end: find ` or ${
      while not isTemplateEnder currentToken
        break if currentToken >= tokens.length - 1
        currentToken++

      if isBackQuote currentToken
        numBackQuotes--
      # template start and end found: create new token
      replaceWithTemplateType startingToken, currentToken
    else if numBackQuotes > 0
      trackNumBraces startingToken
    startingToken++
  undefined
