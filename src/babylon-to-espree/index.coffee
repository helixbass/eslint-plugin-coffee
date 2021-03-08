'use strict'

attachComments = require './attachComments'
convertComments = require './convertComments'
toTokens = require './toTokens'
toAST = require './toAST'

module.exports = (ast, traverse, tt, code) ->
  ast.tokens.pop()

  # convert tokens
  ast.tokens = toTokens ast.tokens, tt, code

  # add comments
  convertComments ast.comments

  # transform esprima and acorn divergent nodes
  toAST ast, traverse, code

  # ast.program.tokens = ast.tokens;
  # ast.program.comments = ast.comments;
  # ast = ast.program;

  # remove File
  ast.type = 'Program'
  ast.sourceType = ast.program.sourceType
  ast.directives = ast.program.directives
  ast.body = ast.program.body
  delete ast.program
  delete ast._paths

  attachComments ast, ast.comments, ast.tokens
  undefined
