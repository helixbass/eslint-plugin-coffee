### eslint-env jest ###
###*
# @fileoverview Enforce that elements that do not support ARIA roles,
#  states and properties do not have those attributes.
# @author Ethan Cohen
###

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

path = require 'path'
{dom} = require 'aria-query'
{RuleTester} = require 'eslint'
{
  default: parserOptionsMapper
} = require '../eslint-plugin-jsx-a11y-parser-options-mapper'
rule = require 'eslint-plugin-jsx-a11y/lib/rules/aria-unsupported-elements'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

errorMessage = (invalidProp) ->
  message: """
    This element does not support ARIA roles, states and properties. \
    Try removing the prop '#{invalidProp}'.
  """
  type: 'JSXOpeningElement'

domElements = [...dom.keys()]
# Generate valid test cases
roleValidityTests = domElements.map (element) ->
  isReserved = dom.get(element).reserved or no
  role = if isReserved then '' else 'role'

  code: "<#{element} #{role} />"

ariaValidityTests =
  domElements
  .map (element) ->
    isReserved = dom.get(element).reserved or no
    aria = if isReserved then '' else 'aria-hidden'

    code: "<#{element} #{aria} />"
  .concat(
    code: '<fake aria-hidden />'
    errors: [errorMessage 'aria-hidden']
  )

# Generate invalid test cases.
invalidRoleValidityTests =
  domElements
  .filter (element) -> Boolean dom.get(element).reserved
  .map (reservedElem) ->
    code: "<#{reservedElem} role {...props} />"
    errors: [errorMessage 'role']

invalidAriaValidityTests =
  domElements
  .filter (element) -> Boolean dom.get(element).reserved
  .map (reservedElem) ->
    code: "<#{reservedElem} aria-hidden aria-role=\"none\" {...props} />"
    errors: [errorMessage 'aria-hidden']

ruleTester.run 'aria-unsupported-elements', rule,
  valid: roleValidityTests.concat(ariaValidityTests).map(parserOptionsMapper)
  invalid:
    invalidRoleValidityTests
    .concat(invalidAriaValidityTests)
    .map parserOptionsMapper
