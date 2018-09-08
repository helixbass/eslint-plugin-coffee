###*
# @fileoverview A rule to suggest using template literals instead of string concatenation.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

astUtils = require 'eslint/lib/ast-utils'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

###*
# Checks whether or not a given node is a concatenation.
# @param {ASTNode} node - A node to check.
# @returns {boolean} `true` if the node is a concatenation.
###
isConcatenation = (node) ->
  node.type is 'BinaryExpression' and node.operator is '+'

###*
# Gets the top binary expression node for concatenation in parents of a given node.
# @param {ASTNode} node - A node to get.
# @returns {ASTNode} the top binary expression node in parents of a given node.
###
getTopConcatBinaryExpression = (node) ->
  currentNode = node

  while isConcatenation currentNode.parent then currentNode = currentNode.parent
  currentNode

###*
# Determines whether a given node is a octal escape sequence
# @param {ASTNode} node A node to check
# @returns {boolean} `true` if the node is an octal escape sequence
###
isOctalEscapeSequence = (node) ->
  # No need to check TemplateLiterals – would throw error with octal escape
  isStringLiteral = node.type is 'Literal' and typeof node.value is 'string'

  return no unless isStringLiteral

  match = node.raw.match /^([^\\]|\\[^0-7])*\\([0-7]{1,3})/

  if match
    # \0 is actually not considered an octal
    return yes if match[2] isnt '0' or typeof match[3] isnt 'undefined'
  no

###*
# Checks whether or not a node contains a octal escape sequence
# @param {ASTNode} node A node to check
# @returns {boolean} `true` if the node contains an octal escape sequence
###
hasOctalEscapeSequence = (node) ->
  return (
    hasOctalEscapeSequence(node.left) or hasOctalEscapeSequence node.right
  ) if isConcatenation node

  isOctalEscapeSequence node

###*
# Checks whether or not a given binary expression has string literals.
# @param {ASTNode} node - A node to check.
# @returns {boolean} `true` if the node has string literals.
###
hasStringLiteral = (node) ->
  # `left` is deeper than `right` normally.
  return (
    hasStringLiteral(node.right) or hasStringLiteral node.left
  ) if isConcatenation node
  astUtils.isStringLiteral node

###*
# Checks whether or not a given binary expression has non string literals.
# @param {ASTNode} node - A node to check.
# @returns {boolean} `true` if the node has non string literals.
###
hasNonStringLiteral = (node) ->
  # `left` is deeper than `right` normally.
  return (
    hasNonStringLiteral(node.right) or hasNonStringLiteral node.left
  ) if isConcatenation node
  not astUtils.isStringLiteral node

###*
# Determines whether a given node will start with a template curly expression (`${}`) when being converted to a template literal.
# @param {ASTNode} node The node that will be fixed to a template literal
# @returns {boolean} `true` if the node will start with a template curly.
###
startsWithTemplateCurly = (node) ->
  return startsWithTemplateCurly node.left if node.type is 'BinaryExpression'
  return (
    node.expressions.length and
    node.quasis.length and
    node.quasis[0].range[0] is node.quasis[0].range[1]
  ) if node.type is 'TemplateLiteral'
  node.type isnt 'Literal' or typeof node.value isnt 'string'

###*
# Determines whether a given node end with a template curly expression (`${}`) when being converted to a template literal.
# @param {ASTNode} node The node that will be fixed to a template literal
# @returns {boolean} `true` if the node will end with a template curly.
###
endsWithTemplateCurly = (node) ->
  return startsWithTemplateCurly node.right if node.type is 'BinaryExpression'
  return (
    node.expressions.length and
    node.quasis.length and
    node.quasis[node.quasis.length - 1].range[0] is
      node.quasis[node.quasis.length - 1].range[1]
  ) if node.type is 'TemplateLiteral'
  node.type isnt 'Literal' or typeof node.value isnt 'string'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'require template literals instead of string concatenation'
      category: 'ECMAScript 6'
      recommended: no
      url: 'https://eslint.org/docs/rules/prefer-template'

    schema: []

    fixable: 'code'

  create: (context) ->
    sourceCode = context.getSourceCode()
    done = Object.create null

    ###*
    # Gets the non-token text between two nodes, ignoring any other tokens that appear between the two tokens.
    # @param {ASTNode} node1 The first node
    # @param {ASTNode} node2 The second node
    # @returns {string} The text between the nodes, excluding other tokens
    ###
    getTextBetween = (node1, node2) ->
      allTokens = [node1]
        .concat(sourceCode.getTokensBetween node1, node2)
        .concat node2
      sourceText = sourceCode.getText()

      allTokens
        .slice 0, -1
        .reduce(
          (accumulator, token, index) ->
            accumulator +
            sourceText.slice token.range[1], allTokens[index + 1].range[0]
          ''
        )

    ###*
    # Returns a template literal form of the given node.
    # @param {ASTNode} currentNode A node that should be converted to a template literal
    # @param {string} textBeforeNode Text that should appear before the node
    # @param {string} textAfterNode Text that should appear after the node
    # @returns {string} A string form of this node, represented as a template literal
    ###
    getTemplateLiteral = (currentNode, textBeforeNode, textAfterNode) ->
      ###
      # If the current node is a string literal, escape any instances of ${ or ` to prevent them from being interpreted
      # as a template placeholder. However, if the code already contains a backslash before the ${ or `
      # for some reason, don't add another backslash, because that would change the meaning of the code (it would cause
      # an actual backslash character to appear before the dollar sign).
      ###
      return "\"#{
        str = currentNode.raw
          .slice 1, -1
          .replace /\\*(#{|")/g, (matched) ->
            return "\\#{matched}" if matched.lastIndexOf('\\') % 2
            matched

        unless currentNode.raw[0] is '"'
          # Unescape any quotes that appear in the original Literal that no longer need to be escaped.
          str = str.replace(
            new RegExp "\\\\#{currentNode.raw[0]}", 'g'
            currentNode.raw[0]
          )
        str
      }\"" if (
        currentNode.type is 'Literal' and typeof currentNode.value is 'string'
      )

      return sourceCode.getText currentNode if (
        currentNode.type is 'TemplateLiteral'
      )

      if (
        isConcatenation(currentNode) and
        hasStringLiteral(currentNode) and
        hasNonStringLiteral currentNode
      )
        plusSign = sourceCode.getFirstTokenBetween(
          currentNode.left
          currentNode.right
          (token) -> token.value is '+'
        )
        textBeforePlus = getTextBetween currentNode.left, plusSign
        textAfterPlus = getTextBetween plusSign, currentNode.right
        leftEndsWithCurly = endsWithTemplateCurly currentNode.left
        rightStartsWithCurly = startsWithTemplateCurly currentNode.right

        # If the left side of the expression ends with a template curly, add the extra text to the end of the curly bracket.
        # `foo${bar}` /* comment */ + 'baz' --> `foo${bar /* comment */  }${baz}`
        return (
          getTemplateLiteral(
            currentNode.left
            textBeforeNode
            textBeforePlus + textAfterPlus
          ).slice(0, -1) +
          getTemplateLiteral(currentNode.right, null, textAfterNode).slice 1
        ) if leftEndsWithCurly
        # Otherwise, if the right side of the expression starts with a template curly, add the text there.
        # 'foo' /* comment */ + `${bar}baz` --> `foo${ /* comment */  bar}baz`
        return (
          getTemplateLiteral(currentNode.left, textBeforeNode, null).slice(
            0
            -1
          ) +
          getTemplateLiteral(
            currentNode.right
            textBeforePlus + textAfterPlus
            textAfterNode
          ).slice 1
        ) if rightStartsWithCurly

        ###
        # Otherwise, these nodes should not be combined into a template curly, since there is nowhere to put
        # the text between them.
        ###
        return "#{getTemplateLiteral(
          currentNode.left
          textBeforeNode
          null
        )}#{textBeforePlus}+#{textAfterPlus}#{getTemplateLiteral(
          currentNode.right
          textAfterNode
          null
        )}"

      "\"\#{#{textBeforeNode or ''}#{sourceCode.getText(
        currentNode
      )}#{textAfterNode or ''}}\""

    ###*
    # Returns a fixer object that converts a non-string binary expression to a template literal
    # @param {SourceCodeFixer} fixer The fixer object
    # @param {ASTNode} node A node that should be converted to a template literal
    # @returns {Object} A fix for this binary expression
    ###
    fixNonStringBinaryExpression = (fixer, node) ->
      topBinaryExpr = getTopConcatBinaryExpression node.parent

      return null if hasOctalEscapeSequence topBinaryExpr

      fixer.replaceText(
        topBinaryExpr
        getTemplateLiteral topBinaryExpr, null, null
      )

    ###*
    # Reports if a given node is string concatenation with non string literals.
    #
    # @param {ASTNode} node - A node to check.
    # @returns {void}
    ###
    checkForStringConcat = (node) ->
      return if (
        not astUtils.isStringLiteral(node) or not isConcatenation node.parent
      )

      topBinaryExpr = getTopConcatBinaryExpression node.parent

      # Checks whether or not this node had been checked already.
      return if done[topBinaryExpr.range[0]]
      done[topBinaryExpr.range[0]] = yes

      if hasNonStringLiteral topBinaryExpr
        context.report
          node: topBinaryExpr
          message: 'Unexpected string concatenation.'
          fix: (fixer) -> fixNonStringBinaryExpression fixer, node

    Program: -> done = Object.create null

    Literal: checkForStringConcat
    TemplateLiteral: checkForStringConcat
