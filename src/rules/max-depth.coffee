###*
# @fileoverview A rule to set the maximum depth block can be nested in a function.
# @author Ian Christian Myers
###

'use strict'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'enforce a maximum depth that blocks can be nested'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/max-depth'

    schema: [
      oneOf: [
        type: 'integer'
        minimum: 0
      ,
        type: 'object'
        properties:
          maximum:
            type: 'integer'
            minimum: 0
          max:
            type: 'integer'
            minimum: 0
        additionalProperties: no
      ]
    ]

  create: (context) ->
    #--------------------------------------------------------------------------
    # Helpers
    #--------------------------------------------------------------------------

    functionStack = []
    option = context.options[0]
    maxDepth = 4

    if (
      typeof option is 'object' and
      Object.prototype.hasOwnProperty.call(option, 'maximum') and
      typeof option.maximum is 'number'
    )
      maxDepth = option.maximum
    if (
      typeof option is 'object' and
      Object.prototype.hasOwnProperty.call(option, 'max') and
      typeof option.max is 'number'
    )
      maxDepth = option.max
    if typeof option is 'number' then maxDepth = option

    ###*
    # When parsing a new function, store it in our function stack
    # @returns {void}
    # @private
    ###
    startFunction = -> functionStack.push 0

    ###*
    # When parsing is done then pop out the reference
    # @returns {void}
    # @private
    ###
    endFunction = -> functionStack.pop()

    ###*
    # Save the block and Evaluate the node
    # @param {ASTNode} node node to evaluate
    # @returns {void}
    # @private
    ###
    pushBlock = (node) ->
      len = ++functionStack[functionStack.length - 1]

      if len > maxDepth
        context.report {
          node
          message: 'Blocks are nested too deeply ({{depth}}).'
          data: depth: len
        }

    ###*
    # Pop the saved block
    # @returns {void}
    # @private
    ###
    popBlock = -> functionStack[functionStack.length - 1]--

    #--------------------------------------------------------------------------
    # Public API
    #--------------------------------------------------------------------------

    Program: startFunction
    FunctionDeclaration: startFunction
    FunctionExpression: startFunction
    ArrowFunctionExpression: startFunction

    IfStatement: (node) ->
      unless node.parent.type is 'IfStatement' then pushBlock node
    SwitchStatement: pushBlock
    TryStatement: pushBlock
    DoWhileStatement: pushBlock
    WhileStatement: pushBlock
    WithStatement: pushBlock
    ForStatement: pushBlock
    ForInStatement: pushBlock
    ForOfStatement: pushBlock
    For: pushBlock

    'IfStatement:exit': popBlock
    'SwitchStatement:exit': popBlock
    'TryStatement:exit': popBlock
    'DoWhileStatement:exit': popBlock
    'WhileStatement:exit': popBlock
    'WithStatement:exit': popBlock
    'ForStatement:exit': popBlock
    'ForInStatement:exit': popBlock
    'ForOfStatement:exit': popBlock
    'For:exit': popBlock

    'FunctionDeclaration:exit': endFunction
    'FunctionExpression:exit': endFunction
    'ArrowFunctionExpression:exit': endFunction
    'Program:exit': endFunction
