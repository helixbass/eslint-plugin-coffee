###*
# @fileoverview Rule to check for "block scoped" variables by binding context
# @author Matt DuVall <http://www.mattduvall.com>
###
'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'enforce the use of variables within the scope they are defined'
      category: 'Best Practices'
      recommended: no
      url: 'https://eslint.org/docs/rules/block-scoped-var'

    schema: []

    messages:
      outOfScope: "'{{name}}' used outside of binding context."

  create: (context) ->
    stack = []

    ###*
    # Makes a block scope.
    # @param {ASTNode} node - A node of a scope.
    # @returns {void}
    ###
    enterScope = (node) -> stack.push node.range

    ###*
    # Pops the last block scope.
    # @returns {void}
    ###
    exitScope = -> stack.pop()

    ###*
    # Reports a given reference.
    # @param {eslint-scope.Reference} reference - A reference to report.
    # @returns {void}
    ###
    report = (reference) ->
      {identifier} = reference

      context.report
        node: identifier, messageId: 'outOfScope', data: name: identifier.name

    ###*
    # Finds and reports references which are outside of valid scopes.
    # @param {ASTNode} node - A node to get variables.
    # @returns {void}
    ###
    checkForVariables = (node) ->
      return unless node.declaration

      # Defines a predicate to check whether or not a given reference is outside of valid scope.
      scopeRange = stack[stack.length - 1]

      ###*
      # Check if a reference is out of scope
      # @param {ASTNode} reference node to examine
      # @returns {boolean} True is its outside the scope
      # @private
      ###
      isOutsideOfScope = (reference) ->
        idRange = reference.identifier.range

        idRange[0] < scopeRange[0] or idRange[1] > scopeRange[1]

      # Gets declared variables, and checks its references.
      variables = context.getDeclaredVariables node

      # Reports.
      for variable in variables
        variable.references.filter(isOutsideOfScope).forEach report

    Program: (node) -> stack ###:### = [node.range]

    # Manages scopes.
    BlockStatement: enterScope
    'BlockStatement:exit': exitScope
    For: enterScope
    'For:exit': exitScope
    ForStatement: enterScope
    'ForStatement:exit': exitScope
    ForInStatement: enterScope
    'ForInStatement:exit': exitScope
    ForOfStatement: enterScope
    'ForOfStatement:exit': exitScope
    SwitchStatement: enterScope
    'SwitchStatement:exit': exitScope
    CatchClause: enterScope
    'CatchClause:exit': exitScope

    # Finds and reports references which are outside of valid scope.
    Identifier: checkForVariables
