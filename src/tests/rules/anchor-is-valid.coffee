### eslint-env jest ###
###*
# @fileoverview Performs validity check on anchor hrefs. Warns when anchors are used as buttons.
# @author Almero Steyn
###

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

path = require 'path'
{RuleTester} = require 'eslint'
{
  default: parserOptionsMapper
} = require '../eslint-plugin-jsx-a11y-parser-options-mapper'
rule = require 'eslint-plugin-jsx-a11y/lib/rules/anchor-is-valid'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

preferButtonErrorMessage =
  'Anchor used as a button. Anchors are primarily expected to navigate. Use the button element instead. Learn more: https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/anchor-is-valid.md'

noHrefErrorMessage =
  'The href attribute is required for an anchor to be keyboard accessible. Provide a valid, navigable address as the href value. If you cannot provide an href, but still need the element to resemble a link, use a button and change it with appropriate styles. Learn more: https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/anchor-is-valid.md'

invalidHrefErrorMessage =
  'The href attribute requires a valid value to be accessible. Provide a valid, navigable address as the href value. If you cannot provide a valid href, but still need the element to resemble a link, use a button and change it with appropriate styles. Learn more: https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/anchor-is-valid.md'

preferButtonexpectedError =
  message: preferButtonErrorMessage
  type: 'JSXOpeningElement'
noHrefexpectedError =
  message: noHrefErrorMessage
  type: 'JSXOpeningElement'
invalidHrefexpectedError =
  message: invalidHrefErrorMessage
  type: 'JSXOpeningElement'

components = [components: ['Anchor', 'Link']]
specialLink = [specialLink: ['hrefLeft', 'hrefRight']]
noHrefAspect = [aspects: ['noHref']]
invalidHrefAspect = [aspects: ['invalidHref']]
preferButtonAspect = [aspects: ['preferButton']]
noHrefInvalidHrefAspect = [aspects: ['noHref', 'invalidHref']]
noHrefPreferButtonAspect = [aspects: ['noHref', 'preferButton']]
preferButtonInvalidHrefAspect = [aspects: ['preferButton', 'invalidHref']]

componentsAndSpecialLink = [
  components: ['Anchor']
  specialLink: ['hrefLeft']
]

componentsAndSpecialLinkAndInvalidHrefAspect = [
  components: ['Anchor']
  specialLink: ['hrefLeft']
  aspects: ['invalidHref']
]

componentsAndSpecialLinkAndNoHrefAspect = [
  components: ['Anchor']
  specialLink: ['hrefLeft']
  aspects: ['noHref']
]

ruleTester.run 'anchor-is-valid', rule,
  valid: [
    # DEFAULT ELEMENT 'a' TESTS
    code: '<Anchor />'
  ,
    code: '<a {...props} />'
  ,
    code: '<a href="foo" />'
  ,
    code: '<a href={foo} />'
  ,
    code: '<a href="/foo" />'
  ,
    code: '<a href="https://foo.bar.com" />'
  ,
    code: '<div href="foo" />'
  ,
    code: '<a href="javascript" />'
  ,
    code: '<a href="javascriptFoo" />'
  ,
    code: '<a href={"#foo"}/>'
  ,
    code: '<a href={"foo"}/>'
  ,
    code: '<a href={"javascript"}/>'
  ,
    code: '<a href={"#javascript"}/>'
  ,
    code: '<a href="#foo" />'
  ,
    code: '<a href="#javascript" />'
  ,
    code: '<a href="#javascriptFoo" />'
  ,
    code: '<UX.Layout>test</UX.Layout>'
  ,
    code: '<a href={this} />'
  ,
    # CUSTOM ELEMENT TEST FOR ARRAY OPTION
    code: '<Anchor {...props} />', options: components
  ,
    code: '<Anchor href="foo" />', options: components
  ,
    code: '<Anchor href={foo} />', options: components
  ,
    code: '<Anchor href="/foo" />', options: components
  ,
    code: '<Anchor href="https://foo.bar.com" />', options: components
  ,
    code: '<div href="foo" />', options: components
  ,
    code: '<Anchor href={"#foo"}/>', options: components
  ,
    code: '<Anchor href={"foo"}/>', options: components
  ,
    code: '<Anchor href="#foo" />', options: components
  ,
    code: '<Link {...props} />', options: components
  ,
    code: '<Link href="foo" />', options: components
  ,
    code: '<Link href={foo} />', options: components
  ,
    code: '<Link href="/foo" />', options: components
  ,
    code: '<Link href="https://foo.bar.com" />', options: components
  ,
    code: '<div href="foo" />', options: components
  ,
    code: '<Link href={"#foo"}/>', options: components
  ,
    code: '<Link href={"foo"}/>', options: components
  ,
    code: '<Link href="#foo" />', options: components
  ,
    # CUSTOM PROP TESTS
    code: '<a {...props} />', options: specialLink
  ,
    code: '<a hrefLeft="foo" />', options: specialLink
  ,
    code: '<a hrefLeft={foo} />', options: specialLink
  ,
    code: '<a hrefLeft="/foo" />', options: specialLink
  ,
    code: '<a hrefLeft="https://foo.bar.com" />', options: specialLink
  ,
    code: '<div hrefLeft="foo" />', options: specialLink
  ,
    code: '<a hrefLeft={"#foo"}/>', options: specialLink
  ,
    code: '<a hrefLeft={"foo"}/>', options: specialLink
  ,
    code: '<a hrefLeft="#foo" />', options: specialLink
  ,
    code: '<UX.Layout>test</UX.Layout>', options: specialLink
  ,
    code: '<a hrefRight={this} />', options: specialLink
  ,
    code: '<a {...props} />', options: specialLink
  ,
    code: '<a hrefRight="foo" />', options: specialLink
  ,
    code: '<a hrefRight={foo} />', options: specialLink
  ,
    code: '<a hrefRight="/foo" />', options: specialLink
  ,
    code: '<a hrefRight="https://foo.bar.com" />', options: specialLink
  ,
    code: '<div hrefRight="foo" />', options: specialLink
  ,
    code: '<a hrefRight={"#foo"}/>', options: specialLink
  ,
    code: '<a hrefRight={"foo"}/>', options: specialLink
  ,
    code: '<a hrefRight="#foo" />', options: specialLink
  ,
    code: '<UX.Layout>test</UX.Layout>', options: specialLink
  ,
    code: '<a hrefRight={this} />', options: specialLink
  ,
    # CUSTOM BOTH COMPONENTS AND SPECIALLINK TESTS
    code: '<Anchor {...props} />', options: componentsAndSpecialLink
  ,
    code: '<Anchor hrefLeft="foo" />', options: componentsAndSpecialLink
  ,
    code: '<Anchor hrefLeft={foo} />', options: componentsAndSpecialLink
  ,
    code: '<Anchor hrefLeft="/foo" />', options: componentsAndSpecialLink
  ,
    code: '<Anchor hrefLeft="https://foo.bar.com" />'
    options: componentsAndSpecialLink
  ,
    code: '<div hrefLeft="foo" />', options: componentsAndSpecialLink
  ,
    code: '<Anchor hrefLeft={"#foo"}/>', options: componentsAndSpecialLink
  ,
    code: '<Anchor hrefLeft={"foo"}/>', options: componentsAndSpecialLink
  ,
    code: '<Anchor hrefLeft="#foo" />', options: componentsAndSpecialLink
  ,
    code: '<UX.Layout>test</UX.Layout>', options: componentsAndSpecialLink
  ,
    # WITH ONCLICK
    # DEFAULT ELEMENT 'a' TESTS
    code: '<a {...props} onClick={() => undefined} />'
  ,
    code: '<a href="foo" onClick={() => undefined} />'
  ,
    code: '<a href={foo} onClick={() => undefined} />'
  ,
    code: '<a href="/foo" onClick={() => undefined} />'
  ,
    code: '<a href="https://foo.bar.com" onClick={() => undefined} />'
  ,
    code: '<div href="foo" onClick={() => undefined} />'
  ,
    code: '<a href={"#foo"} onClick={() => undefined} />'
  ,
    code: '<a href={"foo"} onClick={() => undefined} />'
  ,
    code: '<a href="#foo" onClick={() => undefined} />'
  ,
    code: '<a href={this} onClick={() => undefined} />'
  ,
    # CUSTOM ELEMENT TEST FOR ARRAY OPTION
    code: '<Anchor {...props} onClick={() => undefined} />', options: components
  ,
    code: '<Anchor href="foo" onClick={() => undefined} />', options: components
  ,
    code: '<Anchor href={foo} onClick={() => undefined} />', options: components
  ,
    code: '<Anchor href="/foo" onClick={() => undefined} />'
    options: components
  ,
    code: '<Anchor href="https://foo.bar.com" onClick={() => undefined} />'
    options: components
  ,
    code: '<Anchor href={"#foo"} onClick={() => undefined} />'
    options: components
  ,
    code: '<Anchor href={"foo"} onClick={() => undefined} />'
    options: components
  ,
    code: '<Anchor href="#foo" onClick={() => undefined} />'
    options: components
  ,
    code: '<Link {...props} onClick={() => undefined} />', options: components
  ,
    code: '<Link href="foo" onClick={() => undefined} />', options: components
  ,
    code: '<Link href={foo} onClick={() => undefined} />', options: components
  ,
    code: '<Link href="/foo" onClick={() => undefined} />', options: components
  ,
    code: '<Link href="https://foo.bar.com" onClick={() => undefined} />'
    options: components
  ,
    code: '<div href="foo" onClick={() => undefined} />', options: components
  ,
    code: '<Link href={"#foo"} onClick={() => undefined} />'
    options: components
  ,
    code: '<Link href={"foo"} onClick={() => undefined} />', options: components
  ,
    code: '<Link href="#foo" onClick={() => undefined} />', options: components
  ,
    # CUSTOM PROP TESTS
    code: '<a {...props} onClick={() => undefined} />', options: specialLink
  ,
    code: '<a hrefLeft="foo" onClick={() => undefined} />', options: specialLink
  ,
    code: '<a hrefLeft={foo} onClick={() => undefined} />', options: specialLink
  ,
    code: '<a hrefLeft="/foo" onClick={() => undefined} />'
    options: specialLink
  ,
    code: '<a hrefLeft href="https://foo.bar.com" onClick={() => undefined} />'
    options: specialLink
  ,
    code: '<div hrefLeft="foo" onClick={() => undefined} />'
    options: specialLink
  ,
    code: '<a hrefLeft={"#foo"} onClick={() => undefined} />'
    options: specialLink
  ,
    code: '<a hrefLeft={"foo"} onClick={() => undefined} />'
    options: specialLink
  ,
    code: '<a hrefLeft="#foo" onClick={() => undefined} />'
    options: specialLink
  ,
    code: '<a hrefRight={this} onClick={() => undefined} />'
    options: specialLink
  ,
    code: '<a {...props} onClick={() => undefined} />', options: specialLink
  ,
    code: '<a hrefRight="foo" onClick={() => undefined} />'
    options: specialLink
  ,
    code: '<a hrefRight={foo} onClick={() => undefined} />'
    options: specialLink
  ,
    code: '<a hrefRight="/foo" onClick={() => undefined} />'
    options: specialLink
  ,
    code: '<a hrefRight href="https://foo.bar.com" onClick={() => undefined} />'
    options: specialLink
  ,
    code: '<div hrefRight="foo" onClick={() => undefined} />'
    options: specialLink
  ,
    code: '<a hrefRight={"#foo"} onClick={() => undefined} />'
    options: specialLink
  ,
    code: '<a hrefRight={"foo"} onClick={() => undefined} />'
    options: specialLink
  ,
    code: '<a hrefRight="#foo" onClick={() => undefined} />'
    options: specialLink
  ,
    code: '<a hrefRight={this} onClick={() => undefined} />'
    options: specialLink
  ,
    # CUSTOM BOTH COMPONENTS AND SPECIALLINK TESTS
    code: '<Anchor {...props} onClick={() => undefined} />'
    options: componentsAndSpecialLink
  ,
    code: '<Anchor hrefLeft="foo" onClick={() => undefined} />'
    options: componentsAndSpecialLink
  ,
    code: '<Anchor hrefLeft={foo} onClick={() => undefined} />'
    options: componentsAndSpecialLink
  ,
    code: '<Anchor hrefLeft="/foo" onClick={() => undefined} />'
    options: componentsAndSpecialLink
  ,
    code:
      '<Anchor hrefLeft href="https://foo.bar.com" onClick={() => undefined} />'
    options: componentsAndSpecialLink
  ,
    code: '<Anchor hrefLeft={"#foo"} onClick={() => undefined} />'
    options: componentsAndSpecialLink
  ,
    code: '<Anchor hrefLeft={"foo"} onClick={() => undefined} />'
    options: componentsAndSpecialLink
  ,
    code: '<Anchor hrefLeft="#foo" onClick={() => undefined} />'
    options: componentsAndSpecialLink
  ,
    # WITH ASPECTS TESTS
    # NO HREF
    code: '<a />', options: invalidHrefAspect
  ,
    code: '<a href={undefined} />', options: invalidHrefAspect
  ,
    code: '<a href={null} />', options: invalidHrefAspect
  ,
    code: '<a />', options: preferButtonAspect
  ,
    code: '<a href={undefined} />', options: preferButtonAspect
  ,
    code: '<a href={null} />', options: preferButtonAspect
  ,
    code: '<a />', options: preferButtonInvalidHrefAspect
  ,
    code: '<a href={undefined} />', options: preferButtonInvalidHrefAspect
  ,
    code: '<a href={null} />', options: preferButtonInvalidHrefAspect
  ,
    # INVALID HREF
    code: '<a href="" />', options: preferButtonAspect
  ,
    code: '<a href="#" />', options: preferButtonAspect
  ,
    code: '<a href={"#"} />', options: preferButtonAspect
  ,
    code: '<a href="javascript:void(0)" />', options: preferButtonAspect
  ,
    code: '<a href={"javascript:void(0)"} />', options: preferButtonAspect
  ,
    code: '<a href="" />', options: noHrefAspect
  ,
    code: '<a href="#" />', options: noHrefAspect
  ,
    code: '<a href={"#"} />', options: noHrefAspect
  ,
    code: '<a href="javascript:void(0)" />', options: noHrefAspect
  ,
    code: '<a href={"javascript:void(0)"} />', options: noHrefAspect
  ,
    code: '<a href="" />', options: noHrefPreferButtonAspect
  ,
    code: '<a href="#" />', options: noHrefPreferButtonAspect
  ,
    code: '<a href={"#"} />', options: noHrefPreferButtonAspect
  ,
    code: '<a href="javascript:void(0)" />', options: noHrefPreferButtonAspect
  ,
    code: '<a href={"javascript:void(0)"} />', options: noHrefPreferButtonAspect
  ,
    # SHOULD BE BUTTON
    code: '<a onClick={() => undefined} />', options: invalidHrefAspect
  ,
    code: '<a href="#" onClick={() => undefined} />', options: noHrefAspect
  ,
    code: '<a href="javascript:void(0)" onClick={() => undefined} />'
    options: noHrefAspect
  ,
    code: '<a href={"javascript:void(0)"} onClick={() => undefined} />'
    options: noHrefAspect
  ,
    # CUSTOM COMPONENTS AND SPECIALLINK AND ASPECT
    code: '<Anchor hrefLeft={undefined} />'
    options: componentsAndSpecialLinkAndInvalidHrefAspect
  ,
    code: '<Anchor hrefLeft={null} />'
    options: componentsAndSpecialLinkAndInvalidHrefAspect
  ,
    code: '<Anchor hrefLeft={undefined} />'
    options: componentsAndSpecialLinkAndInvalidHrefAspect
  ,
    code: '<Anchor hrefLeft={null} />'
    options: componentsAndSpecialLinkAndInvalidHrefAspect
  ,
    code: '<Anchor hrefLeft={undefined} />'
    options: componentsAndSpecialLinkAndInvalidHrefAspect
  ,
    code: '<Anchor hrefLeft={null} />'
    options: componentsAndSpecialLinkAndInvalidHrefAspect
  ].map parserOptionsMapper
  invalid: [
    # DEFAULT ELEMENT 'a' TESTS
    # NO HREF
    code: '<a />', errors: [noHrefexpectedError]
  ,
    code: '<a href={undefined} />', errors: [noHrefexpectedError]
  ,
    code: '<a href={null} />', errors: [noHrefexpectedError]
  ,
    # INVALID HREF
    code: '<a href="" />', errors: [invalidHrefexpectedError]
  ,
    code: '<a href="#" />', errors: [invalidHrefErrorMessage]
  ,
    code: '<a href={"#"} />', errors: [invalidHrefErrorMessage]
  ,
    code: '<a href="javascript:void(0)" />', errors: [invalidHrefexpectedError]
  ,
    code: '<a href={"javascript:void(0)"} />'
    errors: [invalidHrefexpectedError]
  ,
    # SHOULD BE BUTTON
    code: '<a onClick={() => undefined} />', errors: [preferButtonexpectedError]
  ,
    code: '<a href="#" onClick={() => undefined} />'
    errors: [preferButtonexpectedError]
  ,
    code: '<a href="javascript:void(0)" onClick={() => undefined} />'
    errors: [preferButtonexpectedError]
  ,
    code: '<a href={"javascript:void(0)"} onClick={() => undefined} />'
    errors: [preferButtonexpectedError]
  ,
    # CUSTOM ELEMENT TEST FOR ARRAY OPTION
    # NO HREF
    code: '<Link />', errors: [noHrefexpectedError], options: components
  ,
    code: '<Link href={undefined} />'
    errors: [noHrefexpectedError]
    options: components
  ,
    code: '<Link href={null} />'
    errors: [noHrefexpectedError]
    options: components
  ,
    # INVALID HREF
    code: '<Link href="" />'
    errors: [invalidHrefexpectedError]
    options: components
  ,
    code: '<Link href="#" />'
    errors: [invalidHrefErrorMessage]
    options: components
  ,
    code: '<Link href={"#"} />'
    errors: [invalidHrefErrorMessage]
    options: components
  ,
    code: '<Link href="javascript:void(0)" />'
    errors: [invalidHrefexpectedError]
    options: components
  ,
    code: '<Link href={"javascript:void(0)"} />'
    errors: [invalidHrefexpectedError]
    options: components
  ,
    code: '<Anchor href="" />'
    errors: [invalidHrefexpectedError]
    options: components
  ,
    code: '<Anchor href="#" />'
    errors: [invalidHrefErrorMessage]
    options: components
  ,
    code: '<Anchor href={"#"} />'
    errors: [invalidHrefErrorMessage]
    options: components
  ,
    code: '<Anchor href="javascript:void(0)" />'
    errors: [invalidHrefexpectedError]
    options: components
  ,
    code: '<Anchor href={"javascript:void(0)"} />'
    errors: [invalidHrefexpectedError]
    options: components
  ,
    # SHOULD BE BUTTON
    code: '<Link onClick={() => undefined} />'
    errors: [preferButtonexpectedError]
    options: components
  ,
    code: '<Link href="#" onClick={() => undefined} />'
    errors: [preferButtonexpectedError]
    options: components
  ,
    code: '<Link href="javascript:void(0)" onClick={() => undefined} />'
    errors: [preferButtonexpectedError]
    options: components
  ,
    code: '<Link href={"javascript:void(0)"} onClick={() => undefined} />'
    errors: [preferButtonexpectedError]
    options: components
  ,
    code: '<Anchor onClick={() => undefined} />'
    errors: [preferButtonexpectedError]
    options: components
  ,
    code: '<Anchor href="#" onClick={() => undefined} />'
    errors: [preferButtonexpectedError]
    options: components
  ,
    code: '<Anchor href="javascript:void(0)" onClick={() => undefined} />'
    errors: [preferButtonexpectedError]
    options: components
  ,
    code: '<Anchor href={"javascript:void(0)"} onClick={() => undefined} />'
    errors: [preferButtonexpectedError]
    options: components
  ,
    # CUSTOM PROP TESTS
    # NO HREF
    code: '<a hrefLeft={undefined} />'
    errors: [noHrefexpectedError]
    options: specialLink
  ,
    code: '<a hrefLeft={null} />'
    errors: [noHrefexpectedError]
    options: specialLink
  ,
    # INVALID HREF
    code: '<a hrefLeft="" />'
    errors: [invalidHrefexpectedError]
    options: specialLink
  ,
    code: '<a hrefLeft="#" />'
    errors: [invalidHrefErrorMessage]
    options: specialLink
  ,
    code: '<a hrefLeft={"#"} />'
    errors: [invalidHrefErrorMessage]
    options: specialLink
  ,
    code: '<a hrefLeft="javascript:void(0)" />'
    errors: [invalidHrefexpectedError]
    options: specialLink
  ,
    code: '<a hrefLeft={"javascript:void(0)"} />'
    errors: [invalidHrefexpectedError]
    options: specialLink
  ,
    # SHOULD BE BUTTON
    code: '<a hrefLeft="#" onClick={() => undefined} />'
    errors: [preferButtonexpectedError]
    options: specialLink
  ,
    code: '<a hrefLeft="javascript:void(0)" onClick={() => undefined} />'
    errors: [preferButtonexpectedError]
    options: specialLink
  ,
    code: '<a hrefLeft={"javascript:void(0)"} onClick={() => undefined} />'
    errors: [preferButtonexpectedError]
    options: specialLink
  ,
    # CUSTOM BOTH COMPONENTS AND SPECIALLINK TESTS
    # NO HREF
    code: '<Anchor Anchor={undefined} />'
    errors: [noHrefexpectedError]
    options: componentsAndSpecialLink
  ,
    code: '<Anchor hrefLeft={null} />'
    errors: [noHrefexpectedError]
    options: componentsAndSpecialLink
  ,
    # INVALID HREF
    code: '<Anchor hrefLeft="" />'
    errors: [invalidHrefexpectedError]
    options: componentsAndSpecialLink
  ,
    code: '<Anchor hrefLeft="#" />'
    errors: [invalidHrefErrorMessage]
    options: componentsAndSpecialLink
  ,
    code: '<Anchor hrefLeft={"#"} />'
    errors: [invalidHrefErrorMessage]
    options: componentsAndSpecialLink
  ,
    code: '<Anchor hrefLeft="javascript:void(0)" />'
    errors: [invalidHrefexpectedError]
    options: componentsAndSpecialLink
  ,
    code: '<Anchor hrefLeft={"javascript:void(0)"} />'
    errors: [invalidHrefexpectedError]
    options: componentsAndSpecialLink
  ,
    # SHOULD BE BUTTON
    code: '<Anchor hrefLeft="#" onClick={() => undefined} />'
    errors: [preferButtonexpectedError]
    options: componentsAndSpecialLink
  ,
    code: '<Anchor hrefLeft="javascript:void(0)" onClick={() => undefined} />'
    errors: [preferButtonexpectedError]
    options: componentsAndSpecialLink
  ,
    code: '<Anchor hrefLeft={"javascript:void(0)"} onClick={() -> undefined} />'
    errors: [preferButtonexpectedError]
    options: componentsAndSpecialLink
  ,
    # WITH ASPECTS TESTS
    # NO HREF
    code: '<a />', options: noHrefAspect, errors: [noHrefErrorMessage]
  ,
    code: '<a />'
    options: noHrefPreferButtonAspect
    errors: [noHrefErrorMessage]
  ,
    code: '<a />'
    options: noHrefInvalidHrefAspect
    errors: [noHrefErrorMessage]
  ,
    code: '<a href={undefined} />'
    options: noHrefAspect
    errors: [noHrefErrorMessage]
  ,
    code: '<a href={undefined} />'
    options: noHrefPreferButtonAspect
    errors: [noHrefErrorMessage]
  ,
    code: '<a href={undefined} />'
    options: noHrefInvalidHrefAspect
    errors: [noHrefErrorMessage]
  ,
    code: '<a href={null} />'
    options: noHrefAspect
    errors: [noHrefErrorMessage]
  ,
    code: '<a href={null} />'
    options: noHrefPreferButtonAspect
    errors: [noHrefErrorMessage]
  ,
    code: '<a href={null} />'
    options: noHrefInvalidHrefAspect
    errors: [noHrefErrorMessage]
  ,
    # INVALID HREF
    code: '<a href="" />'
    options: invalidHrefAspect
    errors: [invalidHrefErrorMessage]
  ,
    code: '<a href="" />'
    options: noHrefInvalidHrefAspect
    errors: [invalidHrefErrorMessage]
  ,
    code: '<a href="" />'
    options: preferButtonInvalidHrefAspect
    errors: [invalidHrefErrorMessage]
  ,
    code: '<a href="#" />'
    options: invalidHrefAspect
    errors: [invalidHrefErrorMessage]
  ,
    code: '<a href="#" />'
    options: noHrefInvalidHrefAspect
    errors: [invalidHrefErrorMessage]
  ,
    code: '<a href="#" />'
    options: preferButtonInvalidHrefAspect
    errors: [invalidHrefErrorMessage]
  ,
    code: '<a href={"#"} />'
    options: invalidHrefAspect
    errors: [invalidHrefErrorMessage]
  ,
    code: '<a href={"#"} />'
    options: noHrefInvalidHrefAspect
    errors: [invalidHrefErrorMessage]
  ,
    code: '<a href={"#"} />'
    options: preferButtonInvalidHrefAspect
    errors: [invalidHrefErrorMessage]
  ,
    code: '<a href="javascript:void(0)" />'
    options: invalidHrefAspect
    errors: [invalidHrefErrorMessage]
  ,
    code: '<a href="javascript:void(0)" />'
    options: noHrefInvalidHrefAspect
    errors: [invalidHrefErrorMessage]
  ,
    code: '<a href="javascript:void(0)" />'
    options: preferButtonInvalidHrefAspect
    errors: [invalidHrefErrorMessage]
  ,
    code: '<a href={"javascript:void(0)"} />'
    options: invalidHrefAspect
    errors: [invalidHrefErrorMessage]
  ,
    code: '<a href={"javascript:void(0)"} />'
    options: noHrefInvalidHrefAspect
    errors: [invalidHrefErrorMessage]
  ,
    code: '<a href={"javascript:void(0)"} />'
    options: preferButtonInvalidHrefAspect
    errors: [invalidHrefErrorMessage]
  ,
    # SHOULD BE BUTTON
    code: '<a onClick={() => undefined} />'
    options: preferButtonAspect
    errors: [preferButtonErrorMessage]
  ,
    code: '<a onClick={() => undefined} />'
    options: preferButtonInvalidHrefAspect
    errors: [preferButtonErrorMessage]
  ,
    code: '<a onClick={() => undefined} />'
    options: noHrefPreferButtonAspect
    errors: [preferButtonErrorMessage]
  ,
    code: '<a onClick={() => undefined} />'
    options: noHrefAspect
    errors: [noHrefErrorMessage]
  ,
    code: '<a onClick={() => undefined} />'
    options: noHrefInvalidHrefAspect
    errors: [noHrefErrorMessage]
  ,
    code: '<a href="#" onClick={() => undefined} />'
    options: preferButtonAspect
    errors: [preferButtonErrorMessage]
  ,
    code: '<a href="#" onClick={() => undefined} />'
    options: noHrefPreferButtonAspect
    errors: [preferButtonErrorMessage]
  ,
    code: '<a href="#" onClick={() => undefined} />'
    options: preferButtonInvalidHrefAspect
    errors: [preferButtonErrorMessage]
  ,
    code: '<a href="#" onClick={() => undefined} />'
    options: invalidHrefAspect
    errors: [invalidHrefErrorMessage]
  ,
    code: '<a href="#" onClick={() => undefined} />'
    options: noHrefInvalidHrefAspect
    errors: [invalidHrefErrorMessage]
  ,
    code: '<a href="javascript:void(0)" onClick={() => undefined} />'
    options: preferButtonAspect
    errors: [preferButtonErrorMessage]
  ,
    code: '<a href="javascript:void(0)" onClick={() => undefined} />'
    options: noHrefPreferButtonAspect
    errors: [preferButtonErrorMessage]
  ,
    code: '<a href="javascript:void(0)" onClick={() => undefined} />'
    options: preferButtonInvalidHrefAspect
    errors: [preferButtonErrorMessage]
  ,
    code: '<a href="javascript:void(0)" onClick={() => undefined} />'
    options: invalidHrefAspect
    errors: [invalidHrefErrorMessage]
  ,
    code: '<a href="javascript:void(0)" onClick={() => undefined} />'
    options: noHrefInvalidHrefAspect
    errors: [invalidHrefErrorMessage]
  ,
    code: '<a href={"javascript:void(0)"} onClick={() => undefined} />'
    options: preferButtonAspect
    errors: [preferButtonErrorMessage]
  ,
    code: '<a href={"javascript:void(0)"} onClick={() => undefined} />'
    options: noHrefPreferButtonAspect
    errors: [preferButtonErrorMessage]
  ,
    code: '<a href={"javascript:void(0)"} onClick={() => undefined} />'
    options: preferButtonInvalidHrefAspect
    errors: [preferButtonErrorMessage]
  ,
    code: '<a href={"javascript:void(0)"} onClick={() => undefined} />'
    options: invalidHrefAspect
    errors: [invalidHrefErrorMessage]
  ,
    code: '<a href={"javascript:void(0)"} onClick={() => undefined} />'
    options: noHrefInvalidHrefAspect
    errors: [invalidHrefErrorMessage]
  ,
    # CUSTOM COMPONENTS AND SPECIALLINK AND ASPECT
    code: '<Anchor hrefLeft={undefined} />'
    options: componentsAndSpecialLinkAndNoHrefAspect
    errors: [noHrefErrorMessage]
  ,
    code: '<Anchor hrefLeft={null} />'
    options: componentsAndSpecialLinkAndNoHrefAspect
    errors: [noHrefErrorMessage]
  ,
    code: '<Anchor hrefLeft={undefined} />'
    options: componentsAndSpecialLinkAndNoHrefAspect
    errors: [noHrefErrorMessage]
  ,
    code: '<Anchor hrefLeft={null} />'
    options: componentsAndSpecialLinkAndNoHrefAspect
    errors: [noHrefErrorMessage]
  ,
    code: '<Anchor hrefLeft={undefined} />'
    options: componentsAndSpecialLinkAndNoHrefAspect
    errors: [noHrefErrorMessage]
  ,
    code: '<Anchor hrefLeft={null} />'
    options: componentsAndSpecialLinkAndNoHrefAspect
    errors: [noHrefErrorMessage]
  ].map parserOptionsMapper
