###*
# @fileoverview A rule to disallow using `this`/`super` before `super()`.
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
# Checks whether or not a given node is a constructor.
# @param {ASTNode} node - A node to check. This node type is one of
#   `Program`, `FunctionDeclaration`, `FunctionExpression`, and
#   `ArrowFunctionExpression`.
# @returns {boolean} `true` if the node is a constructor.
###
isConstructorFunction = (node) ->
  node.type is 'FunctionExpression' and
  node.parent.type is 'MethodDefinition' and
  node.parent.kind is 'constructor'

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description:
        'disallow `this`/`super` before calling `super()` in constructors'
      category: 'ECMAScript 6'
      recommended: yes
      url: 'https://eslint.org/docs/rules/no-this-before-super'

    schema: []

  create: (context) ->
    ###
    # Information for each constructor.
    # - upper:      Information of the upper constructor.
    # - hasExtends: A flag which shows whether the owner class has a valid
    #   `extends` part.
    # - scope:      The scope of the owner class.
    # - codePath:   The code path of this constructor.
    ###
    funcInfo = null

    ###
    # Information for each code path segment.
    # Each key is the id of a code path segment.
    # Each value is an object:
    # - superCalled:  The flag which shows `super()` called in all code paths.
    # - invalidNodes: The array of invalid ThisExpression and Super nodes.
    ###
    segInfoMap = Object.create null

    ###*
    # Gets whether or not `super()` is called in a given code path segment.
    # @param {CodePathSegment} segment - A code path segment to get.
    # @returns {boolean} `true` if `super()` is called.
    ###
    isCalled = (segment) ->
      not segment.reachable or segInfoMap[segment.id].superCalled

    ###*
    # Checks whether or not this is in a constructor.
    # @returns {boolean} `true` if this is in a constructor.
    ###
    isInConstructorOfDerivedClass = ->
      Boolean funcInfo?.isConstructor and funcInfo.hasExtends

    ###*
    # Checks whether or not this is before `super()` is called.
    # @returns {boolean} `true` if this is before `super()` is called.
    ###
    isBeforeCallOfSuper = ->
      isInConstructorOfDerivedClass() and
      not funcInfo.codePath.currentSegments.every isCalled

    ###*
    # Sets a given node as invalid.
    # @param {ASTNode} node - A node to set as invalid. This is one of
    #      a ThisExpression and a Super.
    # @returns {void}
    ###
    setInvalid = (node) ->
      segments = funcInfo.codePath.currentSegments

      for segment in segments when segment.reachable
        segInfoMap[segment.id].invalidNodes.push node

    ###*
    # Sets the current segment as `super` was called.
    # @returns {void}
    ###
    setSuperCalled = ->
      segments = funcInfo.codePath.currentSegments

      for segment in segments when segment.reachable
        segInfoMap[segment.id].superCalled = yes

    isThisParam = (node) ->
      func = funcInfo.node
      {params} = func
      return no unless params.length
      prevNode = node
      currentNode = node.parent
      while currentNode and currentNode isnt func
        prevNode = currentNode
        currentNode = currentNode.parent
      prevNode in params

    ###*
    # Adds information of a constructor into the stack.
    # @param {CodePath} codePath - A code path which was started.
    # @param {ASTNode} node - The current node.
    # @returns {void}
    ###
    onCodePathStart: (codePath, node) ->
      if isConstructorFunction node
        # Class > ClassBody > MethodDefinition > FunctionExpression
        classNode = node.parent.parent.parent

        funcInfo = {
          upper: funcInfo
          isConstructor: yes
          hasExtends: Boolean(
            classNode.superClass and
              not astUtils.isNullOrUndefined classNode.superClass
          )
          codePath
          node
          thisParams: []
        }
      else
        funcInfo ###:### = {
          upper: funcInfo
          isConstructor: no
          hasExtends: no
          codePath
          node
          thisParams: []
        }

    ###*
    # Removes the top of stack item.
    #
    # And this treverses all segments of this code path then reports every
    # invalid node.
    #
    # @param {CodePath} codePath - A code path which was ended.
    # @param {ASTNode} node - The current node.
    # @returns {void}
    ###
    onCodePathEnd: (codePath) ->
      isDerivedClass = funcInfo.hasExtends
      {thisParams} = funcInfo

      funcInfo ###:### = funcInfo.upper
      return unless isDerivedClass

      codePath.traverseSegments (segment, controller) ->
        info = segInfoMap[segment.id]

        for invalidNode in info.invalidNodes
          context.report
            message: "'{{kind}}' is not allowed before 'super()'."
            node: invalidNode
            data:
              kind: if invalidNode.type is 'Super' then 'super' else 'this'

        unless info.superCalled
          for thisParam in thisParams
            context.report
              message: "'{{kind}}' is not allowed before 'super()'."
              node: thisParam
              data: kind: 'this'

        if info.superCalled then controller.skip()

    ###*
    # Initialize information of a given code path segment.
    # @param {CodePathSegment} segment - A code path segment to initialize.
    # @returns {void}
    ###
    onCodePathSegmentStart: (segment) ->
      return unless isInConstructorOfDerivedClass()

      # Initialize info.
      segInfoMap[segment.id] =
        superCalled:
          segment.prevSegments.length > 0 and
          segment.prevSegments.every isCalled
        invalidNodes: []

    ###*
    # Update information of the code path segment when a code path was
    # looped.
    # @param {CodePathSegment} fromSegment - The code path segment of the
    #      end of a loop.
    # @param {CodePathSegment} toSegment - A code path segment of the head
    #      of a loop.
    # @returns {void}
    ###
    onCodePathSegmentLoop: (fromSegment, toSegment) ->
      return unless isInConstructorOfDerivedClass()

      # Update information inside of the loop.
      funcInfo.codePath.traverseSegments first: toSegment, last: fromSegment, (
        segment
        controller
      ) ->
        info = segInfoMap[segment.id]

        if info.superCalled
          info.invalidNodes = []
          controller.skip()
        else if (
          segment.prevSegments.length > 0 and
          segment.prevSegments.every isCalled
        )
          info.superCalled = yes
          info.invalidNodes = []

    ###*
    # Reports if this is before `super()`.
    # @param {ASTNode} node - A target node.
    # @returns {void}
    ###
    ThisExpression: (node) ->
      if isBeforeCallOfSuper()
        if isThisParam node
          funcInfo.thisParams.push node
        else
          setInvalid node

    ###*
    # Reports if this is before `super()`.
    # @param {ASTNode} node - A target node.
    # @returns {void}
    ###
    Super: (node) ->
      if not astUtils.isCallee(node) and isBeforeCallOfSuper()
        setInvalid node

    ###*
    # Marks `super()` called.
    # @param {ASTNode} node - A target node.
    # @returns {void}
    ###
    'CallExpression:exit': (node) ->
      if node.callee.type is 'Super' and isBeforeCallOfSuper()
        setSuperCalled()

    ###*
    # Resets state.
    # @returns {void}
    ###
    'Program:exit': -> segInfoMap ###:### = Object.create null
