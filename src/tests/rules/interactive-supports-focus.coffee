### eslint-env jest ###
###*
# @fileoverview Enforce that elements with onClick handlers must be focusable.
# @author Ethan Cohen
###

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

path = require 'path'
includes = require 'array-includes'
{RuleTester} = require 'eslint'
{eventHandlers, eventHandlersByType} = require 'jsx-ast-utils'
{configs} = require 'eslint-plugin-jsx-a11y'
{
  default: parserOptionsMapper
} = require '../eslint-plugin-jsx-a11y-parser-options-mapper'
rule = require 'eslint-plugin-jsx-a11y/lib/rules/interactive-supports-focus'
{
  default: ruleOptionsMapperFactory
} = require '../eslint-plugin-jsx-a11y-rule-options-mapper-factory'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

template = (strings, ...keys) -> (...values) ->
  keys.reduce(
    (acc, k, i) -> acc + (values[k] or '') + strings[i + 1]
    strings[0]
  )

ruleName = 'interactive-supports-focus'
type = 'JSXOpeningElement'
codeTemplate = template"<#{0} role=\"#{1}\" #{2}={() => undefined} />"
tabindexTemplate = template"<#{0} role=\"#{1}\" #{2}={() => undefined} tabIndex=\"0\" />"
tabbableTemplate = template"Elements with the '#{0}' interactive role must be tabbable."
focusableTemplate = template"Elements with the '#{0}' interactive role must be focusable."

recommendedOptions = configs.recommended.rules["jsx-a11y/#{ruleName}"][1] or {}

strictOptions = configs.strict.rules["jsx-a11y/#{ruleName}"][1] or {}

alwaysValid = [
  code: '<div />'
,
  code: '<div aria-hidden onClick={() => undefined} />'
,
  code: '<div aria-hidden={true == true} onClick={() => undefined} />'
,
  code: '<div aria-hidden={true is true} onClick={() => undefined} />'
,
  code: '<div aria-hidden={hidden isnt false} onClick={() => undefined} />'
,
  code: '<div aria-hidden={hidden != false} onClick={() => undefined} />'
,
  code: '<div aria-hidden={1 < 2} onClick={() => undefined} />'
,
  code: '<div aria-hidden={1 <= 2} onClick={() => undefined} />'
,
  code: '<div aria-hidden={2 > 1} onClick={() => undefined} />'
,
  code: '<div aria-hidden={2 >= 1} onClick={() => undefined} />'
,
  code: '<div onClick={() => undefined} />'
,
  code: '<div onClick={() => undefined} tabIndex={undefined} />'
,
  code: '<div onClick={() => undefined} tabIndex="bad" />'
,
  code: '<div onClick={() => undefined} role={undefined} />'
,
  code: '<div role="section" onClick={() => undefined} />'
,
  code: '<div onClick={() => undefined} aria-hidden={false} />'
,
  code: '<div onClick={() => undefined} {...props} />'
,
  code: '<input type="text" onClick={() => undefined} />'
,
  code: '<input type="hidden" onClick={() => undefined} tabIndex="-1" />'
,
  code: '<input type="hidden" onClick={() => undefined} tabIndex={-1} />'
,
  code: '<input onClick={() => undefined} />'
,
  code: '<input onClick={() => undefined} role="combobox" />'
,
  code: '<button onClick={() => undefined} className="foo" />'
,
  code: '<option onClick={() => undefined} className="foo" />'
,
  code: '<select onClick={() => undefined} className="foo" />'
,
  code: '<area href="#" onClick={() => undefined} className="foo" />'
,
  code: '<area onClick={() => undefined} className="foo" />'
,
  code: '<textarea onClick={() => undefined} className="foo" />'
,
  code: '<a onClick="showNextPage();">Next page</a>'
,
  code: '<a onClick="showNextPage();" tabIndex={undefined}>Next page</a>'
,
  code: '<a onClick="showNextPage();" tabIndex="bad">Next page</a>'
,
  code: '<a onClick={() => undefined} />'
,
  code: '<a tabIndex="0" onClick={() => undefined} />'
,
  code: '<a tabIndex={dynamicTabIndex} onClick={() => undefined} />'
,
  code: '<a tabIndex={0} onClick={() => undefined} />'
,
  code: '<a role="button" href="#" onClick={() => undefined} />'
,
  code: '<a onClick={() => undefined} href="http://x.y.z" />'
,
  code: '<a onClick={() => undefined} href="http://x.y.z" tabIndex="0" />'
,
  code: '<a onClick={() => undefined} href="http://x.y.z" tabIndex={0} />'
,
  code: '<a onClick={() => undefined} href="http://x.y.z" role="button" />'
,
  code: '<TestComponent onClick={doFoo} />'
,
  code: '<input onClick={() => undefined} type="hidden" />;'
,
  code: '<span onClick="submitForm();">Submit</span>'
,
  code: '<span onClick="submitForm();" tabIndex={undefined}>Submit</span>'
,
  code: '<span onClick="submitForm();" tabIndex="bad">Submit</span>'
,
  code: '<span onClick="doSomething();" tabIndex="0">Click me!</span>'
,
  code: '<span onClick="doSomething();" tabIndex={0}>Click me!</span>'
,
  code: '<span onClick="doSomething();" tabIndex="-1">Click me too!</span>'
,
  code:
    '<a href="javascript:void(0);" onClick="doSomething();">Click ALL the things!</a>'
,
  code: '<section onClick={() => undefined} />'
,
  code: '<main onClick={() => undefined} />'
,
  code: '<article onClick={() => undefined} />'
,
  code: '<header onClick={() => undefined} />'
,
  code: '<footer onClick={() => undefined} />'
,
  code: '<div role="button" tabIndex="0" onClick={() => undefined} />'
,
  code: '<div role="checkbox" tabIndex="0" onClick={() => undefined} />'
,
  code: '<div role="link" tabIndex="0" onClick={() => undefined} />'
,
  code: '<div role="menuitem" tabIndex="0" onClick={() => undefined} />'
,
  code: '<div role="menuitemcheckbox" tabIndex="0" onClick={() => undefined} />'
,
  code: '<div role="menuitemradio" tabIndex="0" onClick={() => undefined} />'
,
  code: '<div role="option" tabIndex="0" onClick={() => undefined} />'
,
  code: '<div role="radio" tabIndex="0" onClick={() => undefined} />'
,
  code: '<div role="spinbutton" tabIndex="0" onClick={() => undefined} />'
,
  code: '<div role="switch" tabIndex="0" onClick={() => undefined} />'
,
  code: '<div role="tab" tabIndex="0" onClick={() => undefined} />'
,
  code: '<div role="textbox" tabIndex="0" onClick={() => undefined} />'
,
  code: '<div role="textbox" aria-disabled="true" onClick={() => undefined} />'
,
  code: '<Foo.Bar onClick={() => undefined} aria-hidden={false} />'
,
  code: '<Input onClick={() => undefined} type="hidden" />'
]

interactiveRoles = [
  'button'
  'checkbox'
  'link'
  'gridcell'
  'menuitem'
  'menuitemcheckbox'
  'menuitemradio'
  'option'
  'radio'
  'searchbox'
  'slider'
  'spinbutton'
  'switch'
  'tab'
  'textbox'
  'treeitem'
]

recommendedRoles = [
  'button'
  'checkbox'
  'link'
  'searchbox'
  'spinbutton'
  'switch'
  'textbox'
]

strictRoles = [
  'button'
  'checkbox'
  'link'
  'progressbar'
  'searchbox'
  'slider'
  'spinbutton'
  'switch'
  'textbox'
]

staticElements = ['div']

triggeringHandlers = [
  ...eventHandlersByType.mouse
  ...eventHandlersByType.keyboard
]

passReducer = (roles, handlers, messageTemplate) ->
  staticElements.reduce(
    (elementAcc, element) ->
      elementAcc.concat(
        roles.reduce(
          (roleAcc, role) ->
            roleAcc.concat(
              handlers.map (handler) ->
                code: messageTemplate element, role, handler
            )
        ,
          []
        )
      )
  ,
    []
  )

failReducer = (roles, handlers, messageTemplate) ->
  staticElements.reduce(
    (elementAcc, element) ->
      elementAcc.concat(
        roles.reduce(
          (roleAcc, role) ->
            roleAcc.concat(
              handlers.map (handler) ->
                code: codeTemplate element, role, handler
                errors: [
                  {
                    type
                    message: messageTemplate role
                  }
                ]
            )
        ,
          []
        )
      )
  ,
    []
  )

ruleTester.run "#{ruleName}:recommended", rule,
  valid:
    [
      ...alwaysValid
      ...passReducer(
        interactiveRoles
        eventHandlers.filter (handler) ->
          not includes triggeringHandlers, handler
      ,
        codeTemplate
      )
      ...passReducer(
        interactiveRoles.filter (role) -> not includes recommendedRoles, role
        eventHandlers.filter (handler) -> includes triggeringHandlers, handler
        tabindexTemplate
      )
    ]
    .map ruleOptionsMapperFactory recommendedOptions
    .map parserOptionsMapper
  invalid:
    [
      ...failReducer(recommendedRoles, triggeringHandlers, tabbableTemplate)
      ...failReducer(
        interactiveRoles.filter (role) -> not includes recommendedRoles, role
        triggeringHandlers
        focusableTemplate
      )
    ]
    .map ruleOptionsMapperFactory recommendedOptions
    .map parserOptionsMapper

ruleTester.run "#{ruleName}:strict", rule,
  valid:
    [
      ...alwaysValid
      ...passReducer(
        interactiveRoles
        eventHandlers.filter (handler) ->
          not includes triggeringHandlers, handler
      ,
        codeTemplate
      )
      ...passReducer(
        interactiveRoles.filter (role) -> not includes strictRoles, role
        eventHandlers.filter (handler) -> includes triggeringHandlers, handler
        tabindexTemplate
      )
    ]
    .map ruleOptionsMapperFactory strictOptions
    .map parserOptionsMapper
  invalid:
    [
      ...failReducer(strictRoles, triggeringHandlers, tabbableTemplate)
      ...failReducer(
        interactiveRoles.filter (role) -> not includes strictRoles, role
        triggeringHandlers
        focusableTemplate
      )
    ]
    .map ruleOptionsMapperFactory strictOptions
    .map parserOptionsMapper
