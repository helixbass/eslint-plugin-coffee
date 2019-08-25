###*
# @fileoverview tests to validate spacing before and after comma.
# @author Vignesh Anand.
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/comma-spacing'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

### eslint-disable coffee/no-template-curly-in-string ###
ruleTester.run 'comma-spacing', rule,
  valid: [
    "myfunc(404, true### bla bla bla ###, 'hello')"
    "myfunc 404, true### bla bla bla ###, 'hello'"
    "myfunc(404, true ### bla bla bla ###, 'hello')"
    "myfunc(404, true### bla bla bla ###### hi ###, 'hello')"
    "myfunc(404, true### bla bla bla ### ### hi ###, 'hello')"
    "myfunc(404, true, ### bla bla bla ### 'hello')"
    "myfunc(404, # comment\n true, ### bla bla bla ### 'hello')"
  ,
    code: "myfunc(404, # comment\n true,### bla bla bla ### 'hello')"
    options: [before: no, after: no]
  ,
    'arr = [, ]'
    'arr = [1, ]'
    'arr = [, 2]'
    'arr = [1, 2]'
    'arr = [, , ]'
    'arr = [1, , ]'
    'arr = [, 2, ]'
    'arr = [, , 3]'
    'arr = [1, 2, ]'
    'arr = [, 2, 3]'
    'arr = [1, , 3]'
    'arr = [1, 2, 3]'
    "obj = {'foo':'bar', 'baz':'qur'}"
    "obj = 'foo':'bar', 'baz':'qur'"
    "obj = {'foo':'bar', 'baz':\n  'qur'}"
    '''
      obj = {
        'foo': 'bar',
        'baz': 'qur'
      }
    '''
    '(a, b) ->'
    '(a, b = 1) ->'
    '(a = 1, b, c) ->'
    'a(b, c)'
    'new A(b, c)'
    'new A b, c'
    'foo((a), b)'
    'parseInt((a + b), 10)'
    'go.boom((a + b), 10)'
    'go.boom((a + b), 10, (4))'
    'x = [ (a + c), (b + b) ]'
    "['  ,  ']"
    '["  ,  "]'
    '"#{[1, 2]}"'
    "foo(/,/, 'a')"
    "x = ',,,,,'"
    "code = 'foo = 1, bar = 3'"
    "['apples', \n 'oranges']"
    "{x: 'x,y,z'}"
  ,
    code: '''
      obj = {
        'foo':
          'bar'
        ,'baz':
          'qur'
      }
    '''
    options: [before: yes, after: no]
  ,
    code: '(a ,b) ->', options: [before: yes, after: no]
  ,
    code: 'arr = [,]', options: [before: yes, after: no]
  ,
    code: 'arr = [1 ,]', options: [before: yes, after: no]
  ,
    code: 'arr = [ ,2]', options: [before: yes, after: no]
  ,
    code: 'arr = [1 ,2]', options: [before: yes, after: no]
  ,
    code: 'arr = [,,]', options: [before: yes, after: no]
  ,
    code: 'arr = [1 , ,]', options: [before: yes, after: no]
  ,
    code: 'arr = [ ,2 ,]', options: [before: yes, after: no]
  ,
    code: 'arr = [ , ,3]', options: [before: yes, after: no]
  ,
    code: 'arr = [1 ,2 ,]', options: [before: yes, after: no]
  ,
    code: 'arr = [ ,2 ,3]', options: [before: yes, after: no]
  ,
    code: 'arr = [1 , ,3]', options: [before: yes, after: no]
  ,
    code: 'arr = [1 ,2 ,3]', options: [before: yes, after: no]
  ,
    code: "obj = {'foo':'bar' , 'baz':'qur'}"
    options: [before: yes, after: yes]
  ,
    code: 'arr = [, ]', options: [before: yes, after: yes]
  ,
    code: 'arr = [1 , ]', options: [before: yes, after: yes]
  ,
    code: 'arr = [ , 2]', options: [before: yes, after: yes]
  ,
    code: 'arr = [1 , 2]', options: [before: yes, after: yes]
  ,
    code: 'arr = [, , ]', options: [before: yes, after: yes]
  ,
    code: 'arr = [1 , , ]', options: [before: yes, after: yes]
  ,
    code: 'arr = [ , 2 , ]', options: [before: yes, after: yes]
  ,
    code: 'arr = [ , , 3]', options: [before: yes, after: yes]
  ,
    code: 'arr = [1 , 2 , ]', options: [before: yes, after: yes]
  ,
    code: 'arr = [, 2 , 3]', options: [before: yes, after: yes]
  ,
    code: 'arr = [1 , , 3]', options: [before: yes, after: yes]
  ,
    code: 'arr = [1 , 2 , 3]', options: [before: yes, after: yes]
  ,
    code: 'arr = [,]', options: [before: no, after: no]
  ,
    code: 'arr = [ ,]', options: [before: no, after: no]
  ,
    code: 'arr = [1,]', options: [before: no, after: no]
  ,
    code: 'arr = [,2]', options: [before: no, after: no]
  ,
    code: 'arr = [ ,2]', options: [before: no, after: no]
  ,
    code: 'arr = [1,2]', options: [before: no, after: no]
  ,
    code: 'arr = [,,]', options: [before: no, after: no]
  ,
    code: 'arr = [ ,,]', options: [before: no, after: no]
  ,
    code: 'arr = [1,,]', options: [before: no, after: no]
  ,
    code: 'arr = [,2,]', options: [before: no, after: no]
  ,
    code: 'arr = [ ,2,]', options: [before: no, after: no]
  ,
    code: 'arr = [,,3]', options: [before: no, after: no]
  ,
    code: 'arr = [1,2,]', options: [before: no, after: no]
  ,
    code: 'arr = [,2,3]', options: [before: no, after: no]
  ,
    code: 'arr = [1,,3]', options: [before: no, after: no]
  ,
    code: 'arr = [1,2,3]', options: [before: no, after: no]
  ,
    code: 'console.log("#{a}", "a")'
  ,
    code: '[a, b] = [1, 2]'
  ,
    code: '[a, b, ] = [1, 2]'
  ,
    code: '[a, , b] = [1, 2, 3]'
  ,
    code: '[ , b] = a'
  ,
    code: '[, b] = a'
  ,
    code: '<a>,</a>'
  ,
    code: '<a>  ,  </a>'
  ,
    code: '<a>Hello, world</a>'
    options: [before: yes, after: no]
  ]

  invalid: [
    code: 'a(b,c)'
    output: 'a(b , c)'
    options: [before: yes, after: yes]
    errors: [
      messageId: 'missing'
      data: loc: 'before'
      type: 'Punctuator'
    ,
      messageId: 'missing'
      data: loc: 'after'
      type: 'Punctuator'
    ]
  ,
    code: 'a b,c'
    output: 'a b , c'
    options: [before: yes, after: yes]
    errors: [
      messageId: 'missing'
      data: loc: 'before'
      type: 'Punctuator'
    ,
      messageId: 'missing'
      data: loc: 'after'
      type: 'Punctuator'
    ]
  ,
    code: 'new A(b,c)'
    output: 'new A(b , c)'
    options: [before: yes, after: yes]
    errors: [
      messageId: 'missing'
      data: loc: 'before'
      type: 'Punctuator'
    ,
      messageId: 'missing'
      data: loc: 'after'
      type: 'Punctuator'
    ]
  ,
    code: 'new A b,c'
    output: 'new A b , c'
    options: [before: yes, after: yes]
    errors: [
      messageId: 'missing'
      data: loc: 'before'
      type: 'Punctuator'
    ,
      messageId: 'missing'
      data: loc: 'after'
      type: 'Punctuator'
    ]
  ,
    code: 'arr = [1 , 2]'
    output: 'arr = [1, 2]'
    errors: [
      message: "There should be no space before ','."
      type: 'Punctuator'
    ]
  ,
    code: 'arr = [1 , ]'
    output: 'arr = [1, ]'
    errors: [
      message: "There should be no space before ','."
      type: 'Punctuator'
    ]
  ,
    code: 'arr = [1 , ]'
    output: 'arr = [1 ,]'
    options: [before: yes, after: no]
    errors: [
      message: "There should be no space after ','."
      type: 'Punctuator'
    ]
  ,
    code: 'arr = [1 ,2]'
    output: 'arr = [1, 2]'
    errors: [
      message: "There should be no space before ','."
      type: 'Punctuator'
    ,
      messageId: 'missing'
      data: loc: 'after'
      type: 'Punctuator'
    ]
  ,
    code: 'arr = [(1) , 2]'
    output: 'arr = [(1), 2]'
    errors: [
      message: "There should be no space before ','."
      type: 'Punctuator'
    ]
  ,
    code: 'arr = [1, 2]'
    output: 'arr = [1 ,2]'
    options: [before: yes, after: no]
    errors: [
      messageId: 'missing'
      data: loc: 'before'
      type: 'Punctuator'
    ,
      message: "There should be no space after ','."
      type: 'Punctuator'
    ]
  ,
    code: 'arr = [1\n  , 2]'
    output: 'arr = [1\n  ,2]'
    options: [before: no, after: no]
    errors: [
      message: "There should be no space after ','."
      type: 'Punctuator'
    ]
  ,
    code: 'arr = [1,\n  2]'
    output: 'arr = [1 ,\n  2]'
    options: [before: yes, after: no]
    errors: [
      messageId: 'missing'
      data: loc: 'before'
      type: 'Punctuator'
    ]
  ,
    code: """
      obj = {
        'foo': 'bar',
        'baz': 'qur'
      }
    """
    output: """
      obj = {
        'foo': 'bar' ,
        'baz': 'qur'
      }
    """
    options: [before: yes, after: no]
    errors: [
      messageId: 'missing'
      data: loc: 'before'
      type: 'Punctuator'
      # ,
      #   message: "There should be no space after ','."
      #   type: 'Punctuator'
    ]
  ,
    code: '''
      obj = {
        a: 1
        ,b: 2
      }
    '''
    output: '''
      obj = {
        a: 1
        , b: 2
      }
    '''
    options: [before: no, after: yes]
    errors: [
      messageId: 'missing'
      data: loc: 'after'
      type: 'Punctuator'
    ]
  ,
    code: '''
      obj =
        a: 1 ,
        b: 2
    '''
    output: '''
      obj =
        a: 1,
        b: 2
    '''
    options: [before: no, after: no]
    errors: [
      message: "There should be no space before ','."
      type: 'Punctuator'
    ]
  ,
    code: 'arr = [1 ,2]'
    output: 'arr = [1 , 2]'
    options: [before: yes, after: yes]
    errors: [
      messageId: 'missing'
      data: loc: 'after'
      type: 'Punctuator'
    ]
  ,
    code: 'arr = [1,2]'
    output: 'arr = [1 , 2]'
    options: [before: yes, after: yes]
    errors: [
      messageId: 'missing'
      data: loc: 'before'
      type: 'Punctuator'
    ,
      messageId: 'missing'
      data: loc: 'after'
      type: 'Punctuator'
    ]
  ,
    code: 'arr = [1 , 2]'
    output: 'arr = [1,2]'
    options: [before: no, after: no]
    errors: [
      message: "There should be no space before ','."
      type: 'Punctuator'
    ,
      message: "There should be no space after ','."
      type: 'Punctuator'
    ]
  ,
    code: '(a,b) ->'
    output: '(a , b) ->'
    options: [before: yes, after: yes]
    errors: [
      messageId: 'missing'
      data: loc: 'before'
      type: 'Punctuator'
    ,
      messageId: 'missing'
      data: loc: 'after'
      type: 'Punctuator'
    ]
  ,
    code: 'foo = (a = 1,b) => {}'
    output: 'foo = (a = 1 , b) => {}'
    options: [before: yes, after: yes]
    errors: [
      messageId: 'missing'
      data: loc: 'before'
      type: 'Punctuator'
    ,
      messageId: 'missing'
      data: loc: 'after'
      type: 'Punctuator'
    ]
  ,
    code: '(a = 1 ,b = 2) ->'
    output: '(a = 1, b = 2) ->'
    options: [before: no, after: yes]
    errors: [
      message: "There should be no space before ','."
      type: 'Punctuator'
    ,
      messageId: 'missing'
      data: loc: 'after'
      type: 'Punctuator'
    ]
  ,
    code: '<a>{foo(1 ,2)}</a>'
    output: '<a>{foo(1, 2)}</a>'
    errors: [
      message: "There should be no space before ','."
      type: 'Punctuator'
    ,
      messageId: 'missing'
      data: loc: 'after'
      type: 'Punctuator'
    ]
  ,
    code: "myfunc(404, true### bla bla bla ### , 'hello')"
    output: "myfunc(404, true### bla bla bla ###, 'hello')"
    errors: [
      message: "There should be no space before ','."
      type: 'Punctuator'
    ]
  ,
    code: "myfunc(404, true,### bla bla bla ### 'hello')"
    output: "myfunc(404, true, ### bla bla bla ### 'hello')"
    errors: [
      messageId: 'missing'
      data: loc: 'after'
      type: 'Punctuator'
    ]
  ,
    code: "myfunc(404,# comment\n true, 'hello')"
    output: "myfunc(404, # comment\n true, 'hello')"
    errors: [
      messageId: 'missing'
      data: loc: 'after'
      type: 'Punctuator'
    ]
  ]
