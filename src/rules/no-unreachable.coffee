###*
# @fileoverview Checks for unreachable code due to return, throws, break, and continue.
# @author Joel Feenstra
###
'use strict'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

###*
# Checks whether or not a given variable declarator has the initializer.
# @param {ASTNode} node - A VariableDeclarator node to check.
# @returns {boolean} `true` if the node has the initializer.
###
isInitialized = (node) -> Boolean node.init

###*
# Checks whether or not a given code path segment is unreachable.
# @param {CodePathSegment} segment - A CodePathSegment to check.
# @returns {boolean} `true` if the segment is unreachable.
###
isUnreachable = (segment) -> not segment.reachable

###*
# The class to distinguish consecutive unreachable statements.
###
class ConsecutiveRange
  constructor: (sourceCode) ->
    @sourceCode = sourceCode
    @startNode = null
    @endNode = null

  ###*
  # The location object of this range.
  # @type {Object}
  ###
  location: ->
    start: @startNode.loc.start
    end: @endNode.loc.end

  ###*
  # `true` if this range is empty.
  # @type {boolean}
  ###
  isEmpty: -> not (@startNode and @endNode)

  ###*
  # Checks whether the given node is inside of this range.
  # @param {ASTNode|Token} node - The node to check.
  # @returns {boolean} `true` if the node is inside of this range.
  ###
  contains: (node) ->
    node.range[0] >= @startNode.range[0] and node.range[1] <= @endNode.range[1]

  ###*
  # Checks whether the given node is consecutive to this range.
  # @param {ASTNode} node - The node to check.
  # @returns {boolean} `true` if the node is consecutive to this range.
  ###
  isConsecutive: (node) -> @contains @sourceCode.getTokenBefore node

  ###*
  # Merges the given node to this range.
  # @param {ASTNode} node - The node to merge.
  # @returns {void}
  ###
  merge: (node) -> @endNode = node

  ###*
  # Resets this range by the given node or null.
  # @param {ASTNode|null} node - The node to reset, or null.
  # @returns {void}
  ###
  reset: (node) -> @startNode = @endNode = node

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'disallow unreachable code after `return`, `throw`, `continue`, and `break` statements'
      category: 'Possible Errors'
      recommended: yes
      url: 'https://eslint.org/docs/rules/no-unreachable'

    schema: []

  create: (context) ->
    currentCodePath = null

    range = new ConsecutiveRange context.getSourceCode()

    ###*
    # Reports a given node if it's unreachable.
    # @param {ASTNode} node - A statement node to report.
    # @returns {void}
    ###
    reportIfUnreachable = (node) ->
      nextNode = null

      if node and currentCodePath.currentSegments.every isUnreachable
        # Store this statement to distinguish consecutive statements.
        if range.isEmpty()
          range.reset node
          return

        # Skip if this statement is inside of the current range.
        return if range.contains node

        # Merge if this statement is consecutive to the current range.
        if range.isConsecutive node
          range.merge node
          return

        nextNode = node

      ###
      # Report the current range since this statement is reachable or is
      # not consecutive to the current range.
      ###
      unless range.isEmpty()
        context.report
          message: 'Unreachable code.'
          loc: range.location()
          node: range.startNode

      # Update the current range.
      range.reset nextNode

    # Manages the current code path.
    onCodePathStart: (codePath) -> currentCodePath = codePath

    onCodePathEnd: -> currentCodePath = currentCodePath.upper

    # Registers for all statement nodes (excludes FunctionDeclaration).
    BlockStatement: reportIfUnreachable
    BreakStatement: reportIfUnreachable
    ClassDeclaration: reportIfUnreachable
    ContinueStatement: reportIfUnreachable
    DebuggerStatement: reportIfUnreachable
    DoWhileStatement: reportIfUnreachable
    EmptyStatement: reportIfUnreachable
    ExpressionStatement: reportIfUnreachable
    ForInStatement: reportIfUnreachable
    ForOfStatement: reportIfUnreachable
    ForStatement: reportIfUnreachable
    For: reportIfUnreachable
    IfStatement: reportIfUnreachable
    ImportDeclaration: reportIfUnreachable
    LabeledStatement: reportIfUnreachable
    ReturnStatement: reportIfUnreachable
    SwitchStatement: reportIfUnreachable
    ThrowStatement: reportIfUnreachable
    TryStatement: reportIfUnreachable

    VariableDeclaration: (node) ->
      if node.kind isnt 'var' or node.declarations.some isInitialized
        reportIfUnreachable node

    WhileStatement: reportIfUnreachable
    WithStatement: reportIfUnreachable
    ExportNamedDeclaration: reportIfUnreachable
    ExportDefaultDeclaration: reportIfUnreachable
    ExportAllDeclaration: reportIfUnreachable

    'Program:exit': -> reportIfUnreachable()
