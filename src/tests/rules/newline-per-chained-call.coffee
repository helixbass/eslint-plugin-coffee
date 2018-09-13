###*
# @fileoverview Tests for newline-per-chained-call rule.
# @author Rajendra Patil
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/newline-per-chained-call'
{RuleTester} = require 'eslint'

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'newline-per-chained-call', rule,
  valid: [
    '''
      _
      .chain {}
      .map foo
      .filter bar
      .value()
    '''
    'a.b.c.d.e.f'
    '''
      a()
      .b()
      .c
      .e
    '''
    '''
      a = m1.m2()
      b = m1.m2()
      c = m1.m2()
    '''
    '''
      a = m1()
      .m2()
    '''
    'a = m1()'
    '''
      a()
      .b().c.e.d()
    '''
    'a().b().c.e.d()'
    'a.b.c.e.d()'
    '''
      a = window
        .location
        .href
        .match(/(^[^#]*)/)[0]
    '''
    """
      a = window['location']
      .href
      .match(/(^[^#]*)/)[0]
    """
    "a = window['location'].href.match(/(^[^#]*)/)[0]"
  ,
    code: 'a = m1().m2.m3()'
    options: [ignoreChainWithDepth: 3]
  ,
    code: 'a = m1().m2.m3().m4.m5().m6.m7().m8'
    options: [ignoreChainWithDepth: 8]
  ,
    code: '''
      http.request
        a: 1 # Param
      .on 'response', (response) ->
          # Do something with response.
          # Do something with response.
          # Do something with response.
          # Do something with response.
          # Do something with response.
          # Do something with response.
          # Do something with response.
          # Do something with response.
          # Do something with response.
          # Do something with response.
      .on 'error', (error) ->
          # Do something with error.
          # Do something with error.
          # Do something with error.
          # Do something with error.
          # Do something with error.
          # Do something with error.
          # Do something with error.
          # Do something with error.
          # Do something with error.
          # Do something with error.
      .end()
    '''
  ,
    code: '''
      anObject.method1().method2()['method' + n]()[if aCondition
        method3
      else
        method4]()
    '''
  ,
    code: 'foo.bar()[(biz)]()'
  ,
    code: "foo.bar()['foo' + \u2029 + 'bar']()"
  ]
  invalid: [
    code: '''
      _
      .chain({}).map(foo).filter(bar).value()
    '''
    # output: '_\n.chain({}).map(foo)\n.filter(bar)\n.value()'
    errors: [
      message: 'Expected line break before `.filter`.'
    ,
      message: 'Expected line break before `.value`.'
    ]
  ,
    code: '''
      _
      .chain {}
      .map foo
      .filter(bar).value()
    '''
    # output: '_\n.chain({})\n.map(foo)\n.filter(bar)\n.value()'
    errors: [message: 'Expected line break before `.value`.']
  ,
    code: 'a().b().c().e.d()'
    # output: 'a().b()\n.c().e.d()'
    errors: [message: 'Expected line break before `.c`.']
  ,
    code: 'a.b.c().e().d()'
    # output: 'a.b.c().e()\n.d()'
    errors: [message: 'Expected line break before `.d`.']
  ,
    code: '_.chain({}).map(a).value() '
    # output: '_.chain({}).map(a)\n.value() '
    errors: [message: 'Expected line break before `.value`.']
  ,
    code: '''
      a = m1.m2()
      b = m1.m2().m3().m4().m5()
    '''
    # output: 'a = m1.m2()\n b = m1.m2().m3()\n.m4()\n.m5()'
    errors: [
      message: 'Expected line break before `.m4`.'
    ,
      message: 'Expected line break before `.m5`.'
    ]
  ,
    code: '''
      a = m1.m2()
      b = m1.m2().m3()
      .m4().m5()
    '''
    # output: 'a = m1.m2()\n b = m1.m2().m3()\n.m4()\n.m5()'
    errors: [message: 'Expected line break before `.m5`.']
  ,
    code: '''
      a = m1().m2
      .m3().m4().m5().m6().m7()
    '''
    # output: 'a = m1().m2\n.m3().m4().m5()\n.m6()\n.m7()'
    options: [ignoreChainWithDepth: 3]
    errors: [
      message: 'Expected line break before `.m6`.'
    ,
      message: 'Expected line break before `.m7`.'
    ]
  ,
    code: '''
      http.request({
        a: 1 # Param
          # Param
          # Param
      }).on('response', (response) ->
          # Do something with response.
          # Do something with response.
          # Do something with response.
          # Do something with response.
          # Do something with response.
          # Do something with response.
          # Do something with response.
          # Do something with response.
          # Do something with response.
          # Do something with response.
      ).on('error', (error) ->
          # Do something with error.
          # Do something with error.
          # Do something with error.
          # Do something with error.
          # Do something with error.
          # Do something with error.
          # Do something with error.
          # Do something with error.
          # Do something with error.
          # Do something with error.
      ).end()
    '''
    # output: [
    #   'http.request({'
    #   '    # Param'
    #   '    # Param'
    #   '    # Param'
    #   "}).on('response', function(response) {"
    #   '    # Do something with response.'
    #   '    # Do something with response.'
    #   '    # Do something with response.'
    #   '    # Do something with response.'
    #   '    # Do something with response.'
    #   '    # Do something with response.'
    #   '    # Do something with response.'
    #   '    # Do something with response.'
    #   '    # Do something with response.'
    #   '    # Do something with response.'
    #   '})'
    #   ".on('error', function(error) {"
    #   '    # Do something with error.'
    #   '    # Do something with error.'
    #   '    # Do something with error.'
    #   '    # Do something with error.'
    #   '    # Do something with error.'
    #   '    # Do something with error.'
    #   '    # Do something with error.'
    #   '    # Do something with error.'
    #   '    # Do something with error.'
    #   '    # Do something with error.'
    #   '})'
    #   '.end()'
    # ].join '\n'
    errors: [
      message: 'Expected line break before `.on`.'
    ,
      message: 'Expected line break before `.end`.'
    ]
  ,
    code: '(foo).bar().biz()'
    # output: '(foo).bar()\n.biz()'
    options: [ignoreChainWithDepth: 1]
    errors: [message: 'Expected line break before `.biz`.']
  ,
    code: 'foo.bar(). ### comment ### biz()'
    # output: 'foo.bar()\n. ### comment ### biz()'
    options: [ignoreChainWithDepth: 1]
    errors: [message: 'Expected line break before `.biz`.']
  ,
    code: 'foo.bar() ### comment ### .biz()'
    # output: 'foo.bar() ### comment ### \n.biz()'
    options: [ignoreChainWithDepth: 1]
    errors: [message: 'Expected line break before `.biz`.']
  ]
