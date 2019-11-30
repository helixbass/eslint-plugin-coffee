###*
# @fileoverview Rule to disallow use of unmodified expressions in loop conditions
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

Traverser =
  try
    require 'eslint/lib/util/traverser'
  catch
    require 'eslint/lib/shared/traverser'
astUtils = require '../eslint-ast-utils'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

SENTINEL_PATTERN =
  /(?:(?:Call|Class|Function|Member|New|Yield)Expression|Statement|Declaration)$/
LOOP_PATTERN = /^(?:DoWhile|For|While)Statement$/ # for-in/of statements don't have `test` property.
GROUP_PATTERN = /^(?:BinaryExpression|ConditionalExpression)$/
SKIP_PATTERN = /^(?:ArrowFunction|Class|Function)Expression$/
DYNAMIC_PATTERN = /^(?:Call|Member|New|TaggedTemplate|Yield)Expression$/

###*
# @typedef {Object} LoopConditionInfo
# @property {eslint-scope.Reference} reference - The reference.
# @property {ASTNode} group - BinaryExpression or ConditionalExpression nodes
#      that the reference is belonging to.
# @property {Function} isInLoop - The predicate which checks a given reference
#      is in this loop.
# @property {boolean} modified - The flag that the reference is modified in
#      this loop.
###

###*
# Checks whether or not a given reference is a write reference.
#
# @param {eslint-scope.Reference} reference - A reference to check.
# @returns {boolean} `true` if the reference is a write reference.
###
isWriteReference = (reference) ->
  if reference.init
    def = reference.resolved?.defs[0]

    return no if (
      not def or
      def.type isnt 'Variable' or
      def.parent.kind isnt 'var'
    )
  reference.isWrite()

###*
# Checks whether or not a given loop condition info does not have the modified
# flag.
#
# @param {LoopConditionInfo} condition - A loop condition info to check.
# @returns {boolean} `true` if the loop condition info is "unmodified".
###
isUnmodified = (condition) -> not condition.modified

###*
# Checks whether or not a given loop condition info does not have the modified
# flag and does not have the group this condition belongs to.
#
# @param {LoopConditionInfo} condition - A loop condition info to check.
# @returns {boolean} `true` if the loop condition info is "unmodified".
###
isUnmodifiedAndNotBelongToGroup = (condition) ->
  not (condition.modified or condition.group)

###*
# Checks whether or not a given reference is inside of a given node.
#
# @param {ASTNode} node - A node to check.
# @param {eslint-scope.Reference} reference - A reference to check.
# @returns {boolean} `true` if the reference is inside of the node.
###
isInRange = (node, reference) ->
  nr = node.range
  ir = reference.identifier.range

  nr[0] <= ir[0] and ir[1] <= nr[1]

###*
# Checks whether or not a given reference is inside of a loop node's condition.
#
# @param {ASTNode} node - A node to check.
# @param {eslint-scope.Reference} reference - A reference to check.
# @returns {boolean} `true` if the reference is inside of the loop node's
#      condition.
###
isInLoop =
  WhileStatement: isInRange
  DoWhileStatement: isInRange
  ForStatement: (node, reference) ->
    isInRange(node, reference) and
    not (node.init and isInRange node.init, reference)

###*
# Gets the function which encloses a given reference.
# This supports only FunctionDeclaration.
#
# @param {eslint-scope.Reference} reference - A reference to get.
# @returns {ASTNode|null} The function node or null.
###
getEncloseFunctionName = (reference) ->
  node = reference.identifier

  while node
    if node.type is 'FunctionExpression'
      if (
        node.parent.type is 'AssignmentExpression' and
        node.parent.left.type is 'Identifier'
      )
        return node.parent.left.name
      return null

    node = node.parent

  null

###*
# Updates the "modified" flags of given loop conditions with given modifiers.
#
# @param {LoopConditionInfo[]} conditions - The loop conditions to be updated.
# @param {eslint-scope.Reference[]} modifiers - The references to update.
# @returns {void}
###
updateModifiedFlag = (conditions, modifiers) ->
  ###
  # Besides checking for the condition being in the loop, we want to
  # check the function that this modifier is belonging to is called
  # in the loop.
  # FIXME: This should probably be extracted to a function.
  ###
  for condition in conditions
    for modifier in modifiers when not condition.modified
      inLoop =
        condition.isInLoop(modifier) or
        !!(
          (funcName = getEncloseFunctionName(modifier)) and
          (funcVar = astUtils.getVariableByName(
            modifier.from.upper
            funcName
          )) and
          funcVar.references.some condition.isInLoop
        )

      condition.modified = inLoop

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow unmodified loop conditions'
      category: 'Best Practices'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-unmodified-loop-condition'

    schema: []

  create: (context) ->
    sourceCode = context.getSourceCode()
    groupMap = null

    ###*
    # Reports a given condition info.
    #
    # @param {LoopConditionInfo} condition - A loop condition info to report.
    # @returns {void}
    ###
    report = (condition) ->
      node = condition.reference.identifier

      context.report {
        node
        message: "'{{name}}' is not modified in this loop."
        data: node
      }

    ###*
    # Registers given conditions to the group the condition belongs to.
    #
    # @param {LoopConditionInfo[]} conditions - A loop condition info to
    #      register.
    # @returns {void}
    ###
    registerConditionsToGroup = (conditions) ->
      i = 0
      while i < conditions.length
        condition = conditions[i]

        if condition.group
          group = groupMap.get condition.group

          unless group
            group = []
            groupMap.set condition.group, group
          group.push condition
        ++i

    ###*
    # Reports references which are inside of unmodified groups.
    #
    # @param {LoopConditionInfo[]} conditions - A loop condition info to report.
    # @returns {void}
    ###
    checkConditionsInGroup = (conditions) ->
      if conditions.every isUnmodified then conditions.forEach report

    ###*
    # Checks whether or not a given group node has any dynamic elements.
    #
    # @param {ASTNode} root - A node to check.
    #      This node is one of BinaryExpression or ConditionalExpression.
    # @returns {boolean} `true` if the node is dynamic.
    ###
    hasDynamicExpressions = (root) ->
      retv = no

      Traverser.traverse root,
        visitorKeys: sourceCode.visitorKeys
        enter: (node) ->
          if DYNAMIC_PATTERN.test node.type
            retv ###:### = yes
            @break()
          else if SKIP_PATTERN.test node.type
            @skip()

      retv

    ###*
    # Creates the loop condition information from a given reference.
    #
    # @param {eslint-scope.Reference} reference - A reference to create.
    # @returns {LoopConditionInfo|null} Created loop condition info, or null.
    ###
    toLoopCondition = (reference) ->
      return null if reference.init

      group = null
      child = reference.identifier
      node = child.parent

      while node
        if SENTINEL_PATTERN.test node.type
          # This reference is inside of a loop condition.
          return {
            reference
            group
            isInLoop: isInLoop[node.type].bind null, node
            modified: no
          } if LOOP_PATTERN.test(node.type) and node.test is child

          # This reference is outside of a loop condition.
          break

        ###
        # If it's inside of a group, OK if either operand is modified.
        # So stores the group this reference belongs to.
        ###
        if GROUP_PATTERN.test node.type
          # If this expression is dynamic, no need to check.
          if hasDynamicExpressions node then break else group = node

        child = node
        node = node.parent

      null

    ###*
    # Finds unmodified references which are inside of a loop condition.
    # Then reports the references which are outside of groups.
    #
    # @param {eslint-scope.Variable} variable - A variable to report.
    # @returns {void}
    ###
    checkReferences = (variable) ->
      # Gets references that exist in loop conditions.
      conditions = variable.references.map(toLoopCondition).filter Boolean

      return if conditions.length is 0

      # Registers the conditions to belonging groups.
      registerConditionsToGroup conditions

      # Check the conditions are modified.
      modifiers = variable.references.filter isWriteReference

      if modifiers.length > 0 then updateModifiedFlag conditions, modifiers

      ###
      # Reports the conditions which are not belonging to groups.
      # Others will be reported after all variables are done.
      ###
      conditions.filter(isUnmodifiedAndNotBelongToGroup).forEach report

    'Program:exit': ->
      queue = [context.getScope()]

      groupMap = new Map()

      while scope = queue.pop()
        queue.push ...scope.childScopes
        scope.variables.forEach checkReferences

      groupMap.forEach checkConditionsInGroup
      groupMap ###:### = null
