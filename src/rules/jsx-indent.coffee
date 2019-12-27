###*
# @fileoverview Validate JSX indentation
# @author Yannick Croissant
# This rule has been ported and modified from eslint and nodeca.
# @author Vitaly Puzrin
# @author Gyandeep Singh
# @copyright 2015 Vitaly Puzrin. All rights reserved.
# @copyright 2015 Gyandeep Singh. All rights reserved.
 Copyright (C) 2014 by Vitaly Puzrin

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the 'Software'), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
###
'use strict'

astUtil = require '../util/react/ast'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------
module.exports =
  meta:
    docs:
      description: 'Validate JSX indentation'
      category: 'Stylistic Issues'
      recommended: no
      url: docsUrl 'jsx-indent'
    fixable: 'whitespace'
    schema: [oneOf: [{enum: ['tab']}, {type: 'integer'}]]

  create: (context) ->
    MESSAGE =
      'Expected indentation of {{needed}} {{type}} {{characters}} but found {{gotten}}.'

    extraColumnStart = 0
    indentType = 'space'
    indentSize = 4

    sourceCode = context.getSourceCode()

    if context.options.length
      if context.options[0] is 'tab'
        indentSize = 1
        indentType = 'tab'
      else if typeof context.options[0] is 'number'
        indentSize = context.options[0]
        indentType = 'space'

    indentChar = if indentType is 'space' then ' ' else '\t'

    ###*
    # Responsible for fixing the indentation issue fix
    # @param {ASTNode} node Node violating the indent rule
    # @param {Number} needed Expected indentation character count
    # @returns {Function} function to be executed by the fixer
    # @private
    ###
    getFixerFunction = (node, needed) -> (fixer) ->
      indent = Array(needed + 1).join indentChar
      fixer.replaceTextRange(
        [node.range[0] - node.loc.start.column, node.range[0]]
        indent
      )

    ###*
    # Reports a given indent violation and properly pluralizes the message
    # @param {ASTNode} node Node violating the indent rule
    # @param {Number} needed Expected indentation character count
    # @param {Number} gotten Indentation character count in the actual node/code
    # @param {Object} loc Error line and column location
    ###
    report = (node, needed, gotten, loc) ->
      msgContext = {
        needed
        type: indentType
        characters: if needed is 1 then 'character' else 'characters'
        gotten
      }

      if loc
        context.report {
          node
          loc
          message: MESSAGE
          data: msgContext
          fix: getFixerFunction node, needed
        }
      else
        context.report {
          node
          message: MESSAGE
          data: msgContext
          fix: getFixerFunction node, needed
        }

    ###*
    # Get node indent
    # @param {ASTNode} node Node to examine
    # @param {Boolean} byLastLine get indent of node's last line
    # @param {Boolean} excludeCommas skip comma on start of line
    # @return {Number} Indent
    ###
    getNodeIndent = (node, byLastLine, excludeCommas) ->
      byLastLine or= no
      excludeCommas or= no

      src = sourceCode.getText node, node.loc.start.column + extraColumnStart
      lines = src.split '\n'
      if byLastLine then src = lines[lines.length - 1] else src = lines[0]

      skip = if excludeCommas then ',' else ''

      if indentType is 'space'
        regExp = new RegExp "^[ #{skip}]+"
      else
        regExp = new RegExp "^[\t#{skip}]+"

      indent = regExp.exec src
      if indent then indent[0].length else 0

    # ###*
    # # Check if the node is the right member of a logical expression
    # # @param {ASTNode} node The node to check
    # # @return {Boolean} true if its the case, false if not
    # ###
    # isRightInLogicalExp = (node) ->
    #   node.parent?.parent?.type is 'LogicalExpression' and
    #   node.parent.parent.right is node.parent

    # ###*
    # # Check if the node is the alternate member of a conditional expression
    # # @param {ASTNode} node The node to check
    # # @return {Boolean} true if its the case, false if not
    # ###
    # isAlternateInConditionalExp = (node) ->
    #   node.parent?.parent?.type is 'ConditionalExpression' and
    #   node.parent.parent.alternate is node.parent and
    #   sourceCode.getTokenBefore(node).value isnt '('

    ###*
    # Check indent for nodes list
    # @param {ASTNode} node The node to check
    # @param {Number} indent needed indent
    # @param {Boolean} excludeCommas skip comma on start of line
    ###
    checkNodesIndent = (node, indent, excludeCommas) ->
      nodeIndent = getNodeIndent node, no, excludeCommas
      # isCorrectRightInLogicalExp =
      #   isRightInLogicalExp(node) and nodeIndent - indent is indentSize
      # isCorrectAlternateInCondExp =
      #   isAlternateInConditionalExp(node) and nodeIndent - indent is 0
      if (
        nodeIndent isnt indent and astUtil.isNodeFirstInLine context, node # and # not isCorrectRightInLogicalExp and
      )
        # not isCorrectAlternateInCondExp

        report node, indent, nodeIndent

    handleOpeningElement = (node) ->
      prevToken = sourceCode.getTokenBefore node
      return unless prevToken
      # Use the parent in a list or an array
      if (
        prevToken.type is 'JSXText' # or # (prevToken.type is 'Punctuator' and prevToken.value is ',')
      )
        prevToken = sourceCode.getNodeByRangeIndex prevToken.range[0]
        prevToken =
          if prevToken.type in ['Literal', 'JSXText']
            prevToken.parent
          else
            prevToken
        # Use the first non-punctuator token in a conditional expression
      # else if prevToken.type is 'Punctuator' and prevToken.value is ':'
      #   prevToken = sourceCode.getTokenBefore prevToken

      #     while prevToken.type is 'Punctuator' and prevToken.value isnt '/'
      #       prevToken = sourceCode.getTokenBefore prevToken

      #   prevToken = sourceCode.getNodeByRangeIndex prevToken.range[0]

      #     while (
      #       prevToken.parent and
      #       prevToken.parent.type isnt 'ConditionalExpression'
      #     )
      #       prevToken = prevToken.parent

      prevToken = prevToken.expression if (
        prevToken.type is 'JSXExpressionContainer'
      )
      parentElementIndent = getNodeIndent prevToken
      indent =
        if (
          node.parent.parent.type is 'ExpressionStatement' and
          node.parent.parent.parent.type is 'BlockStatement' and
          node.parent.parent.parent.body.length > 1 and
          node.parent.parent isnt node.parent.parent.parent.body[0]
        )
          0
        else if (
          prevToken.loc.start.line is node.loc.start.line # or
        )
          # isRightInLogicalExp(node) or
          # isAlternateInConditionalExp node
          0
        else
          indentSize
      checkNodesIndent node, parentElementIndent + indent

    handleClosingElement = (node) ->
      return unless node.parent
      peerElementIndent = getNodeIndent(
        node.parent.openingElement or node.parent.openingFragment
      )
      checkNodesIndent node, peerElementIndent

    JSXOpeningElement: handleOpeningElement
    JSXOpeningFragment: handleOpeningElement
    JSXClosingElement: handleClosingElement
    JSXClosingFragment: handleClosingElement
    JSXExpressionContainer: (node) ->
      return unless node.parent
      parentNodeIndent = getNodeIndent node.parent
      checkNodesIndent node, parentNodeIndent + indentSize
