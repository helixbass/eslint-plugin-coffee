'use strict'

# comment fixes
module.exports = (ast, comments, tokens) ->
  if comments.length
    firstComment = comments[0]
    lastComment = comments[comments.length - 1]
    # fixup program start
    unless tokens.length
      # if no tokens, the program starts at the end of the last comment
      ast.start = lastComment.end
      ast.loc.start.line = lastComment.loc.end.line
      ast.loc.start.column = lastComment.loc.end.column

      if ast.leadingComments is null and ast.innerComments.length
        ast.leadingComments = ast.innerComments
    else if firstComment.start < tokens[0].start
      # if there are comments before the first token, the program starts at the first token
      token = tokens[0]
      # ast.start = token.start;
      # ast.loc.start.line = token.loc.start.line;
      # ast.loc.start.column = token.loc.start.column;

      # estraverse do not put leading comments on first node when the comment
      # appear before the first token
      if ast.body.length
        node = ast.body[0]
        node.leadingComments = []
        firstTokenStart = token.start
        len = comments.length
        i = 0
        while i < len and comments[i].start < firstTokenStart
          node.leadingComments.push comments[i]
          i++
    # fixup program end
    if tokens.length
      lastToken = tokens[tokens.length - 1]
      if lastComment.end > lastToken.end
        # If there is a comment after the last token, the program ends at the
        # last token and not the comment
        # ast.end = lastToken.end;
        ast.range[1] = lastToken.end
        ast.loc.end.line = lastToken.loc.end.line
        ast.loc.end.column = lastToken.loc.end.column
  else
    unless tokens.length
      ast.loc.start.line = 1
      ast.loc.end.line = 1
  if ast.body and ast.body.length > 0
    ast.loc.start.line = ast.body[0].loc.start.line
    ast.range[0] = ast.body[0].start
  undefined
