###*
# @fileoverview Rule to disallow assignments where both sides are exactly the same
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

SPACES = /\s+/g

###*
# Checks whether the property of 2 given member expression nodes are the same
# property or not.
#
# @param {ASTNode} left - A member expression node to check.
# @param {ASTNode} right - Another member expression node to check.
# @returns {boolean} `true` if the member expressions have the same property.
###
isSameProperty = (left, right) ->
  return yes if (
    left.property.type is 'Identifier' and
    left.property.type is right.property.type and
    left.property.name is right.property.name and
    left.computed is right.computed
  )

  lname = astUtils.getStaticPropertyName left
  rname = astUtils.getStaticPropertyName right

  lname isnt null and lname is rname

###*
# Checks whether 2 given member expression nodes are the reference to the same
# property or not.
#
# @param {ASTNode} left - A member expression node to check.
# @param {ASTNode} right - Another member expression node to check.
# @returns {boolean} `true` if the member expressions are the reference to the
#  same property or not.
###
isSameMember = (left, right) ->
  return no unless isSameProperty left, right

  lobj = left.object
  robj = right.object

  return no unless lobj.type is robj.type
  return isSameMember lobj, robj if lobj.type is 'MemberExpression'
  lobj.type is 'Identifier' and lobj.name is robj.name

###*
# Traverses 2 Pattern nodes in parallel, then reports self-assignments.
#
# @param {ASTNode|null} left - A left node to traverse. This is a Pattern or
#      a Property.
# @param {ASTNode|null} right - A right node to traverse. This is a Pattern or
#      a Property.
# @param {boolean} props - The flag to check member expressions as well.
# @param {Function} report - A callback function to report.
# @returns {void}
###
eachSelfAssignment = (left, right, props, report) ->
  if not left or not right
    # do nothing
  else if (
    left.type is 'Identifier' and
    right.type is 'Identifier' and
    left.name is right.name
  )
    report right
  else if left.type is 'ArrayPattern' and right.type is 'ArrayExpression'
    end = Math.min left.elements.length, right.elements.length

    i = 0
    while i < end
      rightElement = right.elements[i]

      eachSelfAssignment left.elements[i], rightElement, props, report

      # After a spread element, those indices are unknown.
      if rightElement and rightElement.type is 'SpreadElement' then break
      ++i
  else if left.type is 'RestElement' and right.type is 'SpreadElement'
    eachSelfAssignment left.argument, right.argument, props, report
  else if (
    left.type is 'ObjectPattern' and
    right.type is 'ObjectExpression' and
    right.properties.length >= 1
  )
    ###
    # Gets the index of the last spread property.
    # It's possible to overwrite properties followed by it.
    ###
    startJ = 0

    i = right.properties.length - 1
    while i >= 0
      propType = right.properties[i].type

      if propType in ['SpreadElement', 'ExperimentalSpreadProperty']
        startJ = i + 1
        break
      --i

    i = 0
    while i < left.properties.length
      j = startJ
      while j < right.properties.length
        eachSelfAssignment(
          left.properties[i]
          right.properties[j]
          props
          report
        )
        ++j
      ++i
  else if (
    left.type is 'Property' and
    right.type is 'Property' and
    not left.computed and
    not right.computed and
    right.kind is 'init' and
    not right.method and
    left.key.name is right.key.name
  )
    eachSelfAssignment left.value, right.value, props, report
  else if (
    props and
    left.type is 'MemberExpression' and
    right.type is 'MemberExpression' and
    isSameMember left, right
  )
    report right

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow assignments where both sides are exactly the same'
      category: 'Best Practices'
      recommended: yes
      url: 'https://eslint.org/docs/rules/no-self-assign'

    schema: [
      type: 'object'
      properties: props: type: 'boolean'
      additionalProperties: no
    ]

  create: (context) ->
    sourceCode = context.getSourceCode()
    [{props = yes} = {}] = context.options

    ###*
    # Reports a given node as self assignments.
    #
    # @param {ASTNode} node - A node to report. This is an Identifier node.
    # @returns {void}
    ###
    report = (node) ->
      context.report {
        node
        message: "'{{name}}' is assigned to itself."
        data: name: sourceCode.getText(node).replace SPACES, ''
      }

    AssignmentExpression: (node) ->
      return if node.left?.declaration
      if node.operator is '='
        eachSelfAssignment node.left, node.right, props, report
