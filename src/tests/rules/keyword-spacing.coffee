###*
# @fileoverview Tests for keyword-spacing rule.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

# parser = require '../../fixtures/fixture-parser'
rule = require '../../rules/keyword-spacing'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

BOTH = before: yes, after: yes
NEITHER = before: no, after: no

###*
# Creates an option object to test an "overrides" option.
#
# e.g.
#
#     override("as", BOTH)
#
# returns
#
#     {
#         before: false,
#         after: false,
#         overrides: {as: {before: true, after: true}}
#     }
#
# @param {string} keyword - A keyword to be overriden.
# @param {Object} value - A value to override.
# @returns {Object} An option object to test an "overrides" option.
###
override = (keyword, value) ->
  retv =
    before: value.before is no
    after: value.after is no
    overrides: {}

  retv.overrides[keyword] = value

  retv

###*
# Gets an error message that expected space(s) before a specified keyword.
#
# @param {string} keyword - A keyword.
# @returns {string[]} An error message.
###
expectedBefore = (keyword) -> ["Expected space(s) before \"#{keyword}\"."]

###*
# Gets an error message that expected space(s) after a specified keyword.
#
# @param {string} keyword - A keyword.
# @returns {string[]} An error message.
###
expectedAfter = (keyword) -> ["Expected space(s) after \"#{keyword}\"."]

###*
# Gets error messages that expected space(s) before and after a specified
# keyword.
#
# @param {string} keyword - A keyword.
# @returns {string[]} Error messages.
###
expectedBeforeAndAfter = (keyword) -> [
  "Expected space(s) before \"#{keyword}\"."
  "Expected space(s) after \"#{keyword}\"."
]

###*
# Gets an error message that unexpected space(s) before a specified keyword.
#
# @param {string} keyword - A keyword.
# @returns {string[]} An error message.
###
unexpectedBefore = (keyword) -> ["Unexpected space(s) before \"#{keyword}\"."]

###*
# Gets an error message that unexpected space(s) after a specified keyword.
#
# @param {string} keyword - A keyword.
# @returns {string[]} An error message.
###
unexpectedAfter = (keyword) -> ["Unexpected space(s) after \"#{keyword}\"."]

###*
# Gets error messages that unexpected space(s) before and after a specified
# keyword.
#
# @param {string} keyword - A keyword.
# @returns {string[]} Error messages.
###
unexpectedBeforeAndAfter = (keyword) -> [
  "Unexpected space(s) before \"#{keyword}\"."
  "Unexpected space(s) after \"#{keyword}\"."
]

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

### eslint-disable coffee/no-template-curly-in-string ###
ruleTester.run 'keyword-spacing', rule,
  valid: [
    #----------------------------------------------------------------------
    # as
    #----------------------------------------------------------------------

    code: 'import * as a from "foo"'
  ,
    code: 'import*as a from"foo"'
    options: [NEITHER]
  ,
    code: 'import* as a from"foo"'
    options: [override 'as', BOTH]
  ,
    code: 'import *as a from "foo"'
    options: [override 'as', NEITHER]
  ,
    #----------------------------------------------------------------------
    # await
    #----------------------------------------------------------------------

    code: '-> await +1'
  ,
    code: '-> await +1'
    options: [NEITHER]
  ,
    code: '-> await +1'
    options: [override 'await', BOTH]
  ,
    code: '-> await +1'
    options: [override 'await', NEITHER]
  ,
    # not conflict with `array-bracket-spacing`
    code: '-> [await a]'
  ,
    code: '-> [ await a]'
    options: [NEITHER]
  ,
    # not conflict with `arrow-spacing`
    code: '() =>await a'
  ,
    code: '() => await a'
    options: [NEITHER]
  ,
    # not conflict with `comma-spacing`
    code: '-> f(0,await a)'
  ,
    code: '-> f(0, await a)'
    options: [NEITHER]
  ,
    # not conflict with `computed-property-spacing`
    code: '-> a[await a]'
  ,
    code: '-> {[await a]: 0}'
  ,
    code: '-> a[ await a]'
    options: [NEITHER]
  ,
    code: '-> [ await a]: 0'
    options: [NEITHER]
  ,
    # not conflict with `key-spacing`
    code: '-> {a:await a }'
  ,
    code: '-> {a: await a }'
    options: [NEITHER]
  ,
    # not conflict with `space-in-parens`
    code: '-> (await a)'
  ,
    code: '-> ( await a)'
    options: [NEITHER]
  ,
    # not conflict with `space-infix-ops`
    code: '-> a =await a'
  ,
    code: '-> a = await a'
    options: [NEITHER]
  ,
    # not conflict with `space-unary-ops`
    code: "-> !await'a'"
  ,
    code: "-> ! await 'a'"
    options: [NEITHER]
  ,
    # not conflict with `template-curly-spacing`
    code: '-> "#{await a}"'
  ,
    code: '-> "#{ await a}"'
    options: [NEITHER]
  ,
    # not conflict with `jsx-curly-spacing`
    code: '-> <Foo onClick={await a} />'
  ,
    code: '-> <Foo onClick={ await a} />'
    options: [NEITHER]
  ,
    #----------------------------------------------------------------------
    # do
    #----------------------------------------------------------------------

    'do ->'
  ,
    code: 'do->', options: [NEITHER]
  ,
    code: 'do ->', options: [override 'do', BOTH]
  ,
    code: 'do->', options: [override 'do', NEITHER]
  ,
    #----------------------------------------------------------------------
    # else
    #----------------------------------------------------------------------

    'if (a) then {} else {}'
    'unless (a) then {} else {}'
    'if (a) then {} else if (b) then {}'
    'if (a) then {} else (0)'
    'if (a) then {} else []'
    'if (a) then {} else +1'
    'if (a) then {} else "a"'
  ,
    code: 'if(a)then{}else{}', options: [NEITHER]
  ,
    code: 'if(a)then{}else if(b)then{}', options: [NEITHER]
  ,
    code: 'if(a)then{}else(0)', options: [NEITHER]
  ,
    code: 'if(a)then{}else[]', options: [NEITHER]
  ,
    code: 'if(a)then{}else+1', options: [NEITHER]
  ,
    code: 'if(a)then{}else"a"', options: [NEITHER]
  ,
    code: 'if(a)then{} else {}', options: [override 'else', BOTH]
  ,
    code: 'if (a) then {}else{}'
    options: [override 'else', NEITHER]
  ,
    #----------------------------------------------------------------------
    # export
    #----------------------------------------------------------------------
    code: 'export {a}'
  ,
    code: 'export default a'
  ,
    code: 'export * from "a"'
  ,
    code: 'export{a}'
    options: [NEITHER]
  ,
    code: 'export {a}'
    options: [override 'export', BOTH]
  ,
    code: 'export{a}'
    options: [override 'export', NEITHER]
  ,
    #----------------------------------------------------------------------
    # extends
    #----------------------------------------------------------------------

    code: 'class Bar extends []'
  ,
    code: 'class Bar extends[]'
    options: [NEITHER]
  ,
    code: 'class Bar extends []'
    options: [override 'extends', BOTH]
  ,
    code: 'class Bar extends[]'
    options: [override 'extends', NEITHER]
  ,
    #----------------------------------------------------------------------
    # from
    #----------------------------------------------------------------------

    code: 'import {foo} from "foo"'
  ,
    code: 'export {foo} from "foo"'
  ,
    code: 'export * from "foo"'
  ,
    code: 'import{foo}from"foo"'
    options: [NEITHER]
  ,
    code: 'export{foo}from"foo"'
    options: [NEITHER]
  ,
    code: 'export*from"foo"'
    options: [NEITHER]
  ,
    code: 'import{foo} from "foo"'
    options: [override 'from', BOTH]
  ,
    code: 'export{foo} from "foo"'
    options: [override 'from', BOTH]
  ,
    code: 'export* from "foo"'
    options: [override 'from', BOTH]
  ,
    code: 'import {foo}from"foo"'
    options: [override 'from', NEITHER]
  ,
    code: 'export {foo}from"foo"'
    options: [override 'from', NEITHER]
  ,
    code: 'export *from"foo"'
    options: [override 'from', NEITHER]
  ,
    #----------------------------------------------------------------------
    # get
    #----------------------------------------------------------------------

    # code: '({ get [b]() {} })'
    # ,
    # code: 'class A { a() {} get [b]() {} }'
    # ,
    # code: 'class A { a() {} static get [b]() {} }'
    # ,
    # code: '({ get[b]() {} })'
    # options: [NEITHER]
    # ,
    # code: 'class A { a() {}get[b]() {} }'
    # options: [NEITHER]
    # ,
    # code: 'class A { a() {}static get[b]() {} }'
    # options: [NEITHER]
    # ,
    # code: '({ get [b]() {} })'
    # options: [override 'get', BOTH]
    # ,
    # code: 'class A { a() {} get [b]() {} }'
    # options: [override 'get', BOTH]
    # ,
    # code: '({ get[b]() {} })'
    # options: [override 'get', NEITHER]
    # ,
    # code: 'class A { a() {}get[b]() {} }'
    # options: [override 'get', NEITHER]
    # ,
    # # not conflict with `comma-spacing`
    # code: '({ a,get [b]() {} })'
    # ,
    # code: '({ a, get[b]() {} })'
    # options: [NEITHER]
    # ,
    #----------------------------------------------------------------------
    # if
    #----------------------------------------------------------------------

    'if (a) then {}'
    'if (a) then {} else if (a) then {}'
  ,
    code: 'if(a)then{}', options: [NEITHER]
  ,
    code: 'if(a)then{}else if(a)then{}', options: [NEITHER]
  ,
    code: 'if (a)then{}', options: [override 'if', BOTH]
  ,
    code: 'if (a)then{}else if (a)then{}', options: [override 'if', BOTH]
  ,
    code: 'if(a) then {}', options: [override 'if', NEITHER]
  ,
    code: 'if(a) then {} else if(a) then {}'
    options: [override 'if', NEITHER]
  ,
    #----------------------------------------------------------------------
    # import
    #----------------------------------------------------------------------
    code: 'import {a} from "foo"'
  ,
    code: 'import a from "foo"'
  ,
    code: 'import * as a from "a"'
  ,
    code: 'import{a}from"foo"'
    options: [NEITHER]
  ,
    code: 'import*as a from"foo"'
    options: [NEITHER]
  ,
    code: 'import {a}from"foo"'
    options: [override 'import', BOTH]
  ,
    code: 'import *as a from"foo"'
    options: [override 'import', BOTH]
  ,
    code: 'import{a} from "foo"'
    options: [override 'import', NEITHER]
  ,
    code: 'import* as a from "foo"'
    options: [override 'import', NEITHER]
  ,
    #----------------------------------------------------------------------
    # in
    #----------------------------------------------------------------------

    code: 'for [foo] in {foo: 0} then {}'
  ,
    code: 'for[foo]in{foo: 0}then{}'
    options: [NEITHER]
  ,
    code: 'for[foo] in {foo: 0}then{}'
    options: [override 'in', BOTH]
  ,
    code: '''
      for[foo] in {foo: 0}
        {}
    '''
    options: [override 'in', BOTH]
  ,
    code: 'for [foo]in{foo: 0} then {}'
    options: [override 'in', NEITHER]
  ,
    code: 'for [foo] in ({foo: 0}) then {}'
  ,
    #----------------------------------------------------------------------
    # instanceof
    #----------------------------------------------------------------------

    # not conflict with `space-infix-ops`
    'if ("foo"instanceof{foo: 0}) then {}'
  ,
    code: 'if("foo" instanceof {foo: 0})then{}', options: [NEITHER]
  ,
    #----------------------------------------------------------------------
    # of
    #----------------------------------------------------------------------

    code: 'for  a, [foo] of {foo: 0} then {}'
  ,
    code: 'for a, [foo]of{foo: 0}then{}'
    options: [NEITHER]
  ,
    code: 'for a, [foo] of {foo: 0}then{}'
    options: [override 'of', BOTH]
  ,
    code: 'for a, [foo]of{foo: 0} then {}'
    options: [override 'of', NEITHER]
  ,
    code: 'for a, [foo] of ({foo: 0}) then {}'
  ,
    #----------------------------------------------------------------------
    # return
    #----------------------------------------------------------------------

    '-> return +a'
  ,
    code: '-> return+a', options: [NEITHER]
  ,
    code: '-> return +a'
    options: [override 'return', BOTH]
  ,
    code: '-> return+a'
    options: [override 'return', NEITHER]
  ,
    '''
      ->
        return
    '''
  ,
    code: '''
      ->
        return
    '''
    options: [NEITHER]
  ,
    #----------------------------------------------------------------------
    # set
    #----------------------------------------------------------------------

    # code: '({ set [b](value) {} })'
    # ,
    # code: 'class A { a() {} set [b](value) {} }'
    # ,
    # code: 'class A { a() {} static set [b](value) {} }'
    # ,
    # code: '({ set[b](value) {} })'
    # options: [NEITHER]
    # ,
    # code: 'class A { a() {}set[b](value) {} }'
    # options: [NEITHER]
    # ,
    # code: '({ set [b](value) {} })'
    # options: [override 'set', BOTH]
    # ,
    # code: 'class A { a() {} set [b](value) {} }'
    # options: [override 'set', BOTH]
    # ,
    # code: '({ set[b](value) {} })'
    # options: [override 'set', NEITHER]
    # ,
    # code: 'class A { a() {}set[b](value) {} }'
    # options: [override 'set', NEITHER]
    # ,
    # # not conflict with `comma-spacing`
    # code: '({ a,set [b](value) {} })'
    # ,
    # code: '({ a, set[b](value) {} })'
    # options: [NEITHER]
    # ,
    #----------------------------------------------------------------------
    # switch
    #----------------------------------------------------------------------

    '''
      switch (a)
        when b
          c
    '''
  ,
    code: '''
      switch(a)
        when b
          c
    '''
    options: [NEITHER]
  ,
    code: '''
      switch (a)
        when b
          c
    '''
    options: [override 'switch', BOTH]
  ,
    code: '''
      switch(a)
        when b
          c
    '''
    options: [override 'switch', NEITHER]
  ,
    #----------------------------------------------------------------------
    # throw
    #----------------------------------------------------------------------

    '-> throw +a'
  ,
    code: '-> throw+a', options: [NEITHER]
  ,
    code: '-> throw +a', options: [override 'throw', BOTH]
  ,
    code: '-> throw+a', options: [override 'throw', NEITHER]
  ,
    '''
      ->
        throw a
    '''
  ,
    code: '''
      ->
        throw a
    '''
    options: [NEITHER]
  ,
    #----------------------------------------------------------------------
    # while
    #----------------------------------------------------------------------

    'while (a) then {}'
    'until (a) then {}'
    '(a) while b'
    '(a) until b'
  ,
    code: 'while(a)then{}', options: [NEITHER]
  ,
    code: 'while (a)then{}', options: [override 'while', BOTH]
  ,
    code: 'while(a) then {}', options: [override 'while', NEITHER]

    #----------------------------------------------------------------------
    # typescript parser
    #----------------------------------------------------------------------

    # # class declaration don't error with decorator
    # code: '@dec class Foo {}'
    # parser: parser 'typescript-parsers/decorator-with-class'
    # ,

    # # get, set, async methods don't error with decorator
    # code:
    #   'class Foo { @dec get bar() {} @dec set baz() {} @dec async baw() {} }'
    # parser: parser 'typescript-parsers/decorator-with-class-methods'
    # ,
    # code:
    #   'class Foo { @dec static qux() {} @dec static get bar() {} @dec static set baz() {} @dec static async baw() {} }'
    # parser: parser 'typescript-parsers/decorator-with-static-class-methods'
    # ,

    # # type keywords can be used as parameters in arrow functions
    # code: 'symbol => 4;'
    # parser: parser 'typescript-parsers/keyword-with-arrow-function'
  ]

  invalid: [
    #----------------------------------------------------------------------
    # as
    #----------------------------------------------------------------------

    code: 'import *as a from "foo"'
    output: 'import * as a from "foo"'
    errors: expectedBefore 'as'
  ,
    code: 'import* as a from"foo"'
    output: 'import*as a from"foo"'
    options: [NEITHER]
    errors: unexpectedBefore 'as'
  ,
    code: 'import*as a from"foo"'
    output: 'import* as a from"foo"'
    options: [override 'as', BOTH]
    errors: expectedBefore 'as'
  ,
    code: 'import * as a from "foo"'
    output: 'import *as a from "foo"'
    options: [override 'as', NEITHER]
    errors: unexpectedBefore 'as'
  ,
    #----------------------------------------------------------------------
    # else
    #----------------------------------------------------------------------

    code: 'if a then {}else b'
    output: 'if a then {} else b'
    errors: expectedBefore 'else'
  ,
    code: 'if a then {}else(0)'
    output: 'if a then {} else (0)'
    errors: expectedBeforeAndAfter 'else'
  ,
    code: 'if a then {}else[]'
    output: 'if a then {} else []'
    errors: expectedBeforeAndAfter 'else'
  ,
    code: 'if a then {}else+1'
    output: 'if a then {} else +1'
    errors: expectedBeforeAndAfter 'else'
  ,
    code: 'if a then {}else"a"'
    output: 'if a then {} else "a"'
    errors: expectedBeforeAndAfter 'else'
  ,
    code: 'if a then{} else {}'
    output: 'if a then{}else{}'
    options: [NEITHER]
    errors: unexpectedBeforeAndAfter 'else'
  ,
    code: 'if a then{} else if b then{}'
    output: 'if a then{}else if b then{}'
    options: [NEITHER]
    errors: unexpectedBefore 'else'
  ,
    code: 'if a then{} else (0)'
    output: 'if a then{}else(0)'
    options: [NEITHER]
    errors: unexpectedBeforeAndAfter 'else'
  ,
    code: 'if a then{} else []'
    output: 'if a then{}else[]'
    options: [NEITHER]
    errors: unexpectedBeforeAndAfter 'else'
  ,
    code: 'if a then{} else +1'
    output: 'if a then{}else+1'
    options: [NEITHER]
    errors: unexpectedBeforeAndAfter 'else'
  ,
    code: 'if a then{} else "a"'
    output: 'if a then{}else"a"'
    options: [NEITHER]
    errors: unexpectedBeforeAndAfter 'else'
  ,
    code: 'if a then{}else{}'
    output: 'if a then{} else {}'
    options: [override 'else', BOTH]
    errors: expectedBeforeAndAfter 'else'
  ,
    code: 'if a then {} else {}'
    output: 'if a then {}else{}'
    options: [override 'else', NEITHER]
    errors: unexpectedBeforeAndAfter 'else'
  ,
    code: 'if a then {}else {}'
    output: 'if a then {} else {}'
    errors: expectedBefore 'else'
  ,
    code: 'if  a then {} else{}'
    output: 'if  a then {} else {}'
    errors: expectedAfter 'else'
  ,
    code: 'if a then{} else{}'
    output: 'if a then{}else{}'
    options: [NEITHER]
    errors: unexpectedBefore 'else'
  ,
    code: 'if a then{}else {}'
    output: 'if a then{}else{}'
    options: [NEITHER]
    errors: unexpectedAfter 'else'
  ,
    #----------------------------------------------------------------------
    # export
    #----------------------------------------------------------------------

    code: 'export{a}'
    output: 'export {a}'
    errors: expectedAfter 'export'
  ,
    code: 'export* from "a"'
    output: 'export * from "a"'
    errors: expectedAfter 'export'
  ,
    code: 'export {a}'
    output: 'export{a}'
    options: [NEITHER]
    errors: unexpectedAfter 'export'
  ,
    code: 'export{a}'
    output: 'export {a}'
    options: [override 'export', BOTH]
    errors: expectedAfter 'export'
  ,
    code: 'export {a}'
    output: 'export{a}'
    options: [override 'export', NEITHER]
    errors: unexpectedAfter 'export'
  ,
    #----------------------------------------------------------------------
    # extends
    #----------------------------------------------------------------------

    code: 'class Bar extends[]'
    output: 'class Bar extends []'
    errors: expectedAfter 'extends'
  ,
    code: '(class extends[])'
    output: '(class extends [])'
    errors: expectedAfter 'extends'
  ,
    code: 'class Bar extends []'
    output: 'class Bar extends[]'
    options: [NEITHER]
    errors: unexpectedAfter 'extends'
  ,
    code: '(class extends [])'
    output: '(class extends[])'
    options: [NEITHER]
    errors: unexpectedAfter 'extends'
  ,
    code: 'class Bar extends[]'
    output: 'class Bar extends []'
    options: [override 'extends', BOTH]
    errors: expectedAfter 'extends'
  ,
    code: 'class Bar extends []'
    output: 'class Bar extends[]'
    options: [override 'extends', NEITHER]
    errors: unexpectedAfter 'extends'
  ,
    code: 'class Bar extends"}"'
    output: 'class Bar extends "}"'
    errors: expectedAfter 'extends'
  ,
    #----------------------------------------------------------------------
    # from
    #----------------------------------------------------------------------

    code: 'import {foo}from"foo"'
    output: 'import {foo} from "foo"'
    errors: expectedBeforeAndAfter 'from'
  ,
    code: 'export {foo}from"foo"'
    output: 'export {foo} from "foo"'
    errors: expectedBeforeAndAfter 'from'
  ,
    code: 'export *from"foo"'
    output: 'export * from "foo"'
    errors: expectedBeforeAndAfter 'from'
  ,
    code: 'import{foo} from "foo"'
    output: 'import{foo}from"foo"'
    options: [NEITHER]
    errors: unexpectedBeforeAndAfter 'from'
  ,
    code: 'export{foo} from "foo"'
    output: 'export{foo}from"foo"'
    options: [NEITHER]
    errors: unexpectedBeforeAndAfter 'from'
  ,
    code: 'export* from "foo"'
    output: 'export*from"foo"'
    options: [NEITHER]
    errors: unexpectedBeforeAndAfter 'from'
  ,
    code: 'import{foo}from"foo"'
    output: 'import{foo} from "foo"'
    options: [override 'from', BOTH]
    errors: expectedBeforeAndAfter 'from'
  ,
    code: 'export{foo}from"foo"'
    output: 'export{foo} from "foo"'
    options: [override 'from', BOTH]
    errors: expectedBeforeAndAfter 'from'
  ,
    code: 'export*from"foo"'
    output: 'export* from "foo"'
    options: [override 'from', BOTH]
    errors: expectedBeforeAndAfter 'from'
  ,
    code: 'import {foo} from "foo"'
    output: 'import {foo}from"foo"'
    options: [override 'from', NEITHER]
    errors: unexpectedBeforeAndAfter 'from'
  ,
    code: 'export {foo} from "foo"'
    output: 'export {foo}from"foo"'
    options: [override 'from', NEITHER]
    errors: unexpectedBeforeAndAfter 'from'
  ,
    code: 'export * from "foo"'
    output: 'export *from"foo"'
    options: [override 'from', NEITHER]
    errors: unexpectedBeforeAndAfter 'from'
  ,
    # #----------------------------------------------------------------------
    # # get
    # #----------------------------------------------------------------------

    # code: '({ get[b]() {} })'
    # output: '({ get [b]() {} })'
    # errors: expectedAfter 'get'
    # ,
    # code: 'class A { a() {}get[b]() {} }'
    # output: 'class A { a() {} get [b]() {} }'
    # errors: expectedBeforeAndAfter 'get'
    # ,
    # code: 'class A { a() {} static get[b]() {} }'
    # output: 'class A { a() {} static get [b]() {} }'
    # errors: expectedAfter 'get'
    # ,
    # code: '({ get [b]() {} })'
    # output: '({ get[b]() {} })'
    # options: [NEITHER]
    # errors: unexpectedAfter 'get'
    # ,
    # code: 'class A { a() {} get [b]() {} }'
    # output: 'class A { a() {}get[b]() {} }'
    # options: [NEITHER]
    # errors: unexpectedBeforeAndAfter 'get'
    # ,
    # code: 'class A { a() {}static get [b]() {} }'
    # output: 'class A { a() {}static get[b]() {} }'
    # options: [NEITHER]
    # errors: unexpectedAfter 'get'
    # ,
    # code: '({ get[b]() {} })'
    # output: '({ get [b]() {} })'
    # options: [override 'get', BOTH]
    # errors: expectedAfter 'get'
    # ,
    # code: 'class A { a() {}get[b]() {} }'
    # output: 'class A { a() {} get [b]() {} }'
    # options: [override 'get', BOTH]
    # errors: expectedBeforeAndAfter 'get'
    # ,
    # code: '({ get [b]() {} })'
    # output: '({ get[b]() {} })'
    # options: [override 'get', NEITHER]
    # errors: unexpectedAfter 'get'
    # ,
    # code: 'class A { a() {} get [b]() {} }'
    # output: 'class A { a() {}get[b]() {} }'
    # options: [override 'get', NEITHER]
    # errors: unexpectedBeforeAndAfter 'get'
    # ,
    #----------------------------------------------------------------------
    # if
    #----------------------------------------------------------------------

    code: 'if(a) then b'
    output: 'if (a) then b'
    errors: expectedAfter 'if'
  ,
    code: 'unless(a) then b'
    output: 'unless (a) then b'
    errors: expectedAfter 'unless'
  ,
    code: 'f(1)if(a)'
    output: 'f(1) if (a)'
    errors: expectedBeforeAndAfter 'if'
  ,
    code: 'f(1)unless(a)'
    output: 'f(1) unless (a)'
    errors: expectedBeforeAndAfter 'unless'
  ,
    code: 'f(1)if a'
    output: 'f(1) if a'
    errors: expectedBefore 'if'
  ,
    code: 'if (a) then ; else if(b) then ;'
    output: 'if (a) then ; else if (b) then ;'
    errors: expectedAfter 'if'
  ,
    code: '''
      if (a)
        {}
    '''
    output: '''
      if(a)
        {}
    '''
    options: [NEITHER]
    errors: unexpectedAfter 'if'
  ,
    code: 'if(a)then ; else if (b)then ;'
    output: 'if(a)then ; else if(b)then ;'
    options: [NEITHER]
    errors: unexpectedAfter 'if'
  ,
    code: 'if(a)then ;'
    output: 'if (a)then ;'
    options: [override 'if', BOTH]
    errors: expectedAfter 'if'
  ,
    code: 'if (a)then ; else if(b)then ;'
    output: 'if (a)then ; else if (b)then ;'
    options: [override 'if', BOTH]
    errors: expectedAfter 'if'
  ,
    code: 'if (a) then ;'
    output: 'if(a) then ;'
    options: [override 'if', NEITHER]
    errors: unexpectedAfter 'if'
  ,
    code: 'if(a) then ; else if (b) then ;'
    output: 'if(a) then ; else if(b) then ;'
    options: [override 'if', NEITHER]
    errors: unexpectedAfter 'if'
  ,
    code: 'if (a)then{}'
    output: 'if (a) then {}'
    errors: expectedBeforeAndAfter 'then'
  ,
    code: 'if (a) then {}'
    output: 'if (a)then{}'
    options: [override 'then', NEITHER]
    errors: unexpectedBeforeAndAfter 'then'
  ,
    #----------------------------------------------------------------------
    # import
    #----------------------------------------------------------------------

    code: 'import{a} from "foo"'
    output: 'import {a} from "foo"'
    errors: expectedAfter 'import'
  ,
    code: 'import* as a from "a"'
    output: 'import * as a from "a"'
    errors: expectedAfter 'import'
  ,
    code: 'import {a}from"foo"'
    output: 'import{a}from"foo"'
    options: [NEITHER]
    errors: unexpectedAfter 'import'
  ,
    code: 'import *as a from"foo"'
    output: 'import*as a from"foo"'
    options: [NEITHER]
    errors: unexpectedAfter 'import'
  ,
    code: 'import{a}from"foo"'
    output: 'import {a}from"foo"'
    options: [override 'import', BOTH]
    errors: expectedAfter 'import'
  ,
    code: 'import*as a from"foo"'
    output: 'import *as a from"foo"'
    options: [override 'import', BOTH]
    errors: expectedAfter 'import'
  ,
    code: 'import {a} from "foo"'
    output: 'import{a} from "foo"'
    options: [override 'import', NEITHER]
    errors: unexpectedAfter 'import'
  ,
    code: 'import * as a from "foo"'
    output: 'import* as a from "foo"'
    options: [override 'import', NEITHER]
    errors: unexpectedAfter 'import'
  ,
    #----------------------------------------------------------------------
    # in
    #----------------------------------------------------------------------

    code: 'for [foo]in{foo: 0} then ;'
    output: 'for [foo] in {foo: 0} then ;'
    errors: expectedBeforeAndAfter 'in'
  ,
    code: 'for[foo] in {foo: 0}then ;'
    output: 'for[foo]in{foo: 0}then ;'
    options: [NEITHER]
    errors: unexpectedBeforeAndAfter 'in'
  ,
    code: 'for[foo]in{foo: 0}then ;'
    output: 'for[foo] in {foo: 0}then ;'
    options: [override 'in', BOTH]
    errors: expectedBeforeAndAfter 'in'
  ,
    code: 'for [foo] in {foo: 0} then ;'
    output: 'for [foo]in{foo: 0} then ;'
    options: [override 'in', NEITHER]
    errors: unexpectedBeforeAndAfter 'in'
  ,
    code: 'for [foo]from{foo: 0} then ;'
    output: 'for [foo] from {foo: 0} then ;'
    errors: expectedBeforeAndAfter 'from'
  ,
    code: 'for[foo] from {foo: 0}then ;'
    output: 'for[foo]from{foo: 0}then ;'
    options: [NEITHER]
    errors: unexpectedBeforeAndAfter 'from'
  ,
    code: 'for[foo]from{foo: 0}then ;'
    output: 'for[foo] from {foo: 0}then ;'
    options: [override 'from', BOTH]
    errors: expectedBeforeAndAfter 'from'
  ,
    code: 'for [foo] from {foo: 0} then ;'
    output: 'for [foo]from{foo: 0} then ;'
    options: [override 'from', NEITHER]
    errors: unexpectedBeforeAndAfter 'from'
  ,
    #----------------------------------------------------------------------
    # instanceof
    #----------------------------------------------------------------------

    # ignores

    #----------------------------------------------------------------------
    # of
    #----------------------------------------------------------------------

    code: 'for a, [foo]of{foo: 0} then ;'
    output: 'for a, [foo] of {foo: 0} then ;'
    errors: expectedBeforeAndAfter 'of'
  ,
    code: 'for a, [foo] of {foo: 0}then{}'
    output: 'for a, [foo] of {foo: 0} then {}'
    errors: expectedBeforeAndAfter 'then'
  ,
    code: 'for a, [foo]of{foo: 0} then {}'
    output: 'for a, [foo]of{foo: 0}then{}'
    options: [NEITHER]
    errors: unexpectedBeforeAndAfter 'then'
  ,
    code: 'for a, [foo] of {foo: 0}then ;'
    output: 'for a, [foo]of{foo: 0}then ;'
    options: [NEITHER]
    errors: unexpectedBeforeAndAfter 'of'
  ,
    code: 'for a, [foo]of{foo: 0}then ;'
    output: 'for a, [foo] of {foo: 0}then ;'
    options: [override 'of', BOTH]
    errors: expectedBeforeAndAfter 'of'
  ,
    code: 'for a, [foo] of {foo: 0} then ;'
    output: 'for a, [foo]of{foo: 0} then ;'
    options: [override 'of', NEITHER]
    errors: unexpectedBeforeAndAfter 'of'
  ,
    #----------------------------------------------------------------------
    # return
    #----------------------------------------------------------------------

    code: '-> return+a'
    output: '-> return +a'
    errors: expectedAfter 'return'
  ,
    code: '-> return +a'
    output: '-> return+a'
    options: [NEITHER]
    errors: unexpectedAfter 'return'
  ,
    code: '-> return+a'
    output: '-> return +a'
    options: [override 'return', BOTH]
    errors: expectedAfter 'return'
  ,
    code: '-> return +a'
    output: '-> return+a'
    options: [override 'return', NEITHER]
    errors: unexpectedAfter 'return'
  ,
    # #----------------------------------------------------------------------
    # # set
    # #----------------------------------------------------------------------

    # code: '({ set[b](value) {} })'
    # output: '({ set [b](value) {} })'
    # errors: expectedAfter 'set'
    # ,
    # code: 'class A { a() {}set[b](value) {} }'
    # output: 'class A { a() {} set [b](value) {} }'
    # errors: expectedBeforeAndAfter 'set'
    # ,
    # code: 'class A { a() {} static set[b](value) {} }'
    # output: 'class A { a() {} static set [b](value) {} }'
    # errors: expectedAfter 'set'
    # ,
    # code: '({ set [b](value) {} })'
    # output: '({ set[b](value) {} })'
    # options: [NEITHER]
    # errors: unexpectedAfter 'set'
    # ,
    # code: 'class A { a() {} set [b](value) {} }'
    # output: 'class A { a() {}set[b](value) {} }'
    # options: [NEITHER]
    # errors: unexpectedBeforeAndAfter 'set'
    # ,
    # code: '({ set[b](value) {} })'
    # output: '({ set [b](value) {} })'
    # options: [override 'set', BOTH]
    # errors: expectedAfter 'set'
    # ,
    # code: 'class A { a() {}set[b](value) {} }'
    # output: 'class A { a() {} set [b](value) {} }'
    # options: [override 'set', BOTH]
    # errors: expectedBeforeAndAfter 'set'
    # ,
    # code: '({ set [b](value) {} })'
    # output: '({ set[b](value) {} })'
    # options: [override 'set', NEITHER]
    # errors: unexpectedAfter 'set'
    # ,
    # code: 'class A { a() {} set [b](value) {} }'
    # output: 'class A { a() {}set[b](value) {} }'
    # options: [override 'set', NEITHER]
    # errors: unexpectedBeforeAndAfter 'set'
    # ,
    #----------------------------------------------------------------------
    # switch
    #----------------------------------------------------------------------

    code: '''
      switch(a)
        when b then c
    '''
    output: '''
      switch (a)
        when b then c
    '''
    errors: expectedAfter 'switch'
  ,
    code: '''
      switch (a)
        when b then c
    '''
    output: '''
      switch(a)
        when b then c
    '''
    options: [NEITHER]
    errors: unexpectedAfter 'switch'
  ,
    code: '''
      switch(a)
        when b then c
    '''
    output: '''
      switch (a)
        when b then c
    '''
    options: [override 'switch', BOTH]
    errors: expectedAfter 'switch'
  ,
    code: '''
      switch (a)
        when b then c
    '''
    output: '''
      switch(a)
        when b then c
    '''
    options: [override 'switch', NEITHER]
    errors: unexpectedAfter 'switch'
  ,
    #----------------------------------------------------------------------
    # throw
    #----------------------------------------------------------------------

    code: '-> throw+a'
    output: '-> throw +a'
    errors: expectedAfter 'throw'
  ,
    code: '-> throw +a'
    output: '-> throw+a'
    options: [NEITHER]
    errors: unexpectedAfter 'throw'
  ,
    code: '-> throw+a'
    output: '-> throw +a'
    options: [override 'throw', BOTH]
    errors: expectedAfter 'throw'
  ,
    code: '-> throw +a'
    output: '-> throw+a'
    options: [override 'throw', NEITHER]
    errors: unexpectedAfter 'throw'
  ,
    #----------------------------------------------------------------------
    # while
    #----------------------------------------------------------------------

    code: 'while(a) then ;'
    output: 'while (a) then ;'
    errors: expectedAfter 'while'
  ,
    code: 'until(a) then ;'
    output: 'until (a) then ;'
    errors: expectedAfter 'until'
  ,
    code: '(a)while b'
    output: '(a) while b'
    errors: expectedBefore 'while'
  ,
    code: '(a)until b'
    output: '(a) until b'
    errors: expectedBefore 'until'
  ,
    code: 'while (a) then ;'
    output: 'while(a)then ;'
    options: [NEITHER]
    errors: [unexpectedAfter('while'), unexpectedBefore('then')]
  ,
    code: 'while(a)then ;'
    output: 'while (a)then ;'
    options: [override 'while', BOTH]
    errors: expectedAfter 'while'
  ,
    code: 'while (a) then ;'
    output: 'while(a) then ;'
    options: [override 'while', NEITHER]
    errors: unexpectedAfter 'while'
  ,
    code: 'do->'
    output: 'do ->'
    errors: expectedAfter 'do'
  ,
    code: 'do ->'
    output: 'do->'
    options: [NEITHER]
    errors: unexpectedAfter 'do'
  ,
    code: 'do->'
    output: 'do ->'
    options: [override 'do', BOTH]
    errors: expectedAfter 'do'
  ,
    code: 'do ->'
    output: 'do->'
    options: [override 'do', NEITHER]
    errors: unexpectedAfter 'do'

    # #----------------------------------------------------------------------
    # # typescript parser
    # #----------------------------------------------------------------------

    # # get, set, async decorator keywords shouldn't be detected
    # code:
    #   'class Foo { @desc({set a(value) {}, get a() {}, async c() {}}) async[foo]() {} }'
    # output:
    #   'class Foo { @desc({set a(value) {}, get a() {}, async c() {}}) async [foo]() {} }'
    # errors: expectedAfter 'async'
    # parser: parser 'typescript-parsers/decorator-with-keywords-class-method'
  ]
