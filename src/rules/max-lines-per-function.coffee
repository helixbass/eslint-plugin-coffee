###*
# @fileoverview A rule to set the maximum number of line of code in a function.
# @author Pete Ward <peteward44@gmail.com>
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{isIife, getFunctionNameWithKind} = require '../util/ast-utils'

#------------------------------------------------------------------------------
# Constants
#------------------------------------------------------------------------------

OPTIONS_SCHEMA =
  type: 'object'
  properties:
    max:
      type: 'integer'
      minimum: 0
    skipComments:
      type: 'boolean'
    skipBlankLines:
      type: 'boolean'
    IIFEs:
      type: 'boolean'
  additionalProperties: no

OPTIONS_OR_INTEGER_SCHEMA =
  oneOf: [
    OPTIONS_SCHEMA
  ,
    type: 'integer'
    minimum: 1
  ]

###*
# Given a list of comment nodes, return a map with numeric keys (source code line numbers) and comment token values.
# @param {Array} comments An array of comment nodes.
# @returns {Map.<string,Node>} A map with numeric keys (source code line numbers) and comment token values.
###
getCommentLineNumbers = (comments) ->
  map = new Map()

  return map unless comments
  comments.forEach (comment) ->
    i = comment.loc.start.line
    while i <= comment.loc.end.line
      map.set i, comment
      i++
  map

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'enforce a maximum number of line of code in a function'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/max-lines-per-function'

    schema: [OPTIONS_OR_INTEGER_SCHEMA]

  create: (context) ->
    sourceCode = context.getSourceCode()
    {lines} = sourceCode

    option = context.options[0]
    maxLines = 50
    skipComments = no
    skipBlankLines = no
    IIFEs = no

    if typeof option is 'object'
      if typeof option.max is 'number' then maxLines = option.max
      if typeof option.skipComments is 'boolean'
        {skipComments} = option
      if typeof option.skipBlankLines is 'boolean'
        {skipBlankLines} = option
      if typeof option.IIFEs is 'boolean' then {IIFEs} = option
    else if typeof option is 'number'
      maxLines = option

    commentLineNumbers = getCommentLineNumbers sourceCode.getAllComments()

    #--------------------------------------------------------------------------
    # Helpers
    #--------------------------------------------------------------------------

    ###*
    # Tells if a comment encompasses the entire line.
    # @param {string} line The source line with a trailing comment
    # @param {number} lineNumber The one-indexed line number this is on
    # @param {ASTNode} comment The comment to remove
    # @returns {boolean} If the comment covers the entire line
    ###
    isFullLineComment = (line, lineNumber, comment) ->
      {start, end} = comment.loc
      isFirstTokenOnLine =
        start.line is lineNumber and not line.slice(0, start.column).trim()
      isLastTokenOnLine =
        end.line is lineNumber and not line.slice(end.column).trim()

      comment and
        (start.line < lineNumber or isFirstTokenOnLine) and
        (end.line > lineNumber or isLastTokenOnLine)

    ###*
    # Identifies is a node is a FunctionExpression which is embedded within a MethodDefinition or Property
    # @param {ASTNode} node Node to test
    # @returns {boolean} True if it's a FunctionExpression embedded within a MethodDefinition or Property
    ###
    isEmbedded = (node) ->
      return no unless node.parent
      return no unless node is node.parent.value
      return yes if node.parent.type is 'MethodDefinition'
      return (
        node.parent.method is yes or node.parent.kind in ['get', 'set']
      ) if node.parent.type is 'Property'
      no

    ###*
    # Count the lines in the function
    # @param {ASTNode} funcNode Function AST node
    # @returns {void}
    # @private
    ###
    processFunction = (funcNode) ->
      node = if isEmbedded funcNode then funcNode.parent else funcNode

      return if not IIFEs and isIife node
      lineCount = 0

      for i in [(node.loc.start.line - 1)...node.loc.end.line]
        line = lines[i]

        continue if (
          skipComments and
          commentLineNumbers.has(i + 1) and
          isFullLineComment line, i + 1, commentLineNumbers.get i + 1
        )

        continue if skipBlankLines and line.match /^\s*$/

        lineCount++

      if lineCount > maxLines
        name = getFunctionNameWithKind funcNode
        context.report {
          node
          message:
            '{{name}} has too many lines ({{lineCount}}). Maximum allowed is {{maxLines}}.'
          data: {name, lineCount, maxLines}
        }

    #--------------------------------------------------------------------------
    # Public API
    #--------------------------------------------------------------------------

    FunctionDeclaration: processFunction
    FunctionExpression: processFunction
    ArrowFunctionExpression: processFunction
