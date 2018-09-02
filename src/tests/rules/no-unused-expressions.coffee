###*
# @fileoverview Tests for no-unused-expressions rule.
# @author Michael Ficarra
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-unused-expressions'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-unused-expressions', rule,
  valid: [
    'f = ->'
    'a = b'
    'new a'
    '''
      f()
      g()
    '''
    'i++'
    'a()'
    'a?()'
    'do a'
    'do -> a'
  ,
    code: 'a && a()', options: [allowShortCircuit: yes]
  ,
    code: 'a and a()', options: [allowShortCircuit: yes]
  ,
    code: 'a() || (b = c)', options: [allowShortCircuit: yes]
  ,
    code: 'a() or (b = c)', options: [allowShortCircuit: yes]
  ,
    code: 'a() ? (b = c)', options: [allowShortCircuit: yes]
  ,
    code: '(if a then b() else c())'
  ,
    code: '(if a then b() || (c = d) else e())'
    options: [allowShortCircuit: yes]
  ,
    'delete foo.bar'
    '"use strict"'
    '''
      "directive one"
      "directive two"
      f()
    '''
    '''
      foo = ->
        "use strict"
        true
    '''
    '''
      foo = ->
        "directive one"
        "directive two"
        f()
    '''
    '''
      foo = ->
        foo = "use strict"
        return true
    '''
    'foo = -> yield 0'
    'foo = -> await 5'
    'foo = -> await foo.bar'
  ,
    code: 'foo = -> bar && await baz'
    options: [allowShortCircuit: yes]
  ,
    'foo = -> (if foo then await bar else await baz)'
  ,
    code: 'tag"tagged template literal"'
    options: [allowTaggedTemplates: yes]
  ,
    code: 'shouldNotBeAffectedByAllowTemplateTagsOption()'
    options: [allowTaggedTemplates: yes]
  ,
    '''
      foo = ->
        return b if c
        d
    '''
    '''
      foo = ->
        x for x in y
    '''
    '''
      foo =
        x for x in y
    '''
    '''
      foo = ->
        switch a
          when b
            c
          when d
            e
          else
            f
    '''
    '''
      foo =
        switch a
          when b
            c
          when d
            e
          else
            f
    '''
    '''
      foo = ->
        while a
          b
    '''
    '''
      foo =
        while a
          b
    '''
    '''
      foo = ->
        if a
          b()
          c
        else
          d
    '''
    '''
      foo =
        if a
          b()
          c
        else
          d
    '''
  ]
  invalid: [
    code: '0'
    errors: [
      message:
        'Expected an assignment or function call and instead saw an expression.'
      type: 'ExpressionStatement'
    ]
  ,
    code: 'a'
    errors: [
      message:
        'Expected an assignment or function call and instead saw an expression.'
      type: 'ExpressionStatement'
    ]
  ,
    code: 'f(); 0'
    errors: [
      message:
        'Expected an assignment or function call and instead saw an expression.'
      type: 'ExpressionStatement'
    ]
  ,
    code: '{0}'
    errors: [
      message:
        'Expected an assignment or function call and instead saw an expression.'
      type: 'ExpressionStatement'
    ]
  ,
    code: '[]'
    errors: [
      message:
        'Expected an assignment or function call and instead saw an expression.'
      type: 'ExpressionStatement'
    ]
  ,
    code: 'a && b()'
    errors: [
      message:
        'Expected an assignment or function call and instead saw an expression.'
      type: 'ExpressionStatement'
    ]
  ,
    code: 'a() || false'
    errors: [
      message:
        'Expected an assignment or function call and instead saw an expression.'
      type: 'ExpressionStatement'
    ]
  ,
    code: 'a || (b = c)'
    errors: [
      message:
        'Expected an assignment or function call and instead saw an expression.'
      type: 'ExpressionStatement'
    ]
  ,
    code: '(if a then b() || (c = d) else e)'
    errors: [
      message:
        'Expected an assignment or function call and instead saw an expression.'
      type: 'ExpressionStatement'
    ]
  ,
    code: '"untagged #{template} literal"'
    errors: [
      'Expected an assignment or function call and instead saw an expression.'
    ]
  ,
    code: 'tag"tagged template literal"'
    errors: [
      'Expected an assignment or function call and instead saw an expression.'
    ]
  ,
    code: 'a && b()'
    errors: [
      message:
        'Expected an assignment or function call and instead saw an expression.'
      type: 'ExpressionStatement'
    ]
  ,
    code: 'a || b'
    options: [allowShortCircuit: yes]
    errors: [
      message:
        'Expected an assignment or function call and instead saw an expression.'
      type: 'ExpressionStatement'
    ]
  ,
    code: 'a() && b'
    options: [allowShortCircuit: yes]
    errors: [
      message:
        'Expected an assignment or function call and instead saw an expression.'
      type: 'ExpressionStatement'
    ]
  ,
    code: '(if a then b else 0)'
    errors: [
      message:
        'Expected an assignment or function call and instead saw an expression.'
      type: 'ExpressionStatement'
    ]
  ,
    code: 'foo.bar'
    errors: [
      message:
        'Expected an assignment or function call and instead saw an expression.'
      type: 'ExpressionStatement'
    ]
  ,
    code: '!a'
    errors: [
      message:
        'Expected an assignment or function call and instead saw an expression.'
      type: 'ExpressionStatement'
    ]
  ,
    code: '+a'
    errors: [
      message:
        'Expected an assignment or function call and instead saw an expression.'
      type: 'ExpressionStatement'
    ]
  ,
    code: '''
      "directive one"
      f()
      "directive two"
    '''
    errors: [
      message:
        'Expected an assignment or function call and instead saw an expression.'
      type: 'ExpressionStatement'
    ]
  ,
    code: '''
      foo = ->
        "directive one"
        f()
        "directive two"
        ret
    '''
    errors: [
      message:
        'Expected an assignment or function call and instead saw an expression.'
      type: 'ExpressionStatement'
    ]
  ,
    code: '''
      if 0
        "not a directive"
        f()
    '''
    errors: [
      message:
        'Expected an assignment or function call and instead saw an expression.'
      type: 'ExpressionStatement'
    ]
  ,
    code: '''
      foo = ->
        foo = yes
        "use strict"
        ret
    '''
    errors: [
      message:
        'Expected an assignment or function call and instead saw an expression.'
      type: 'ExpressionStatement'
    ]
  ,
    code: '"untagged #{template} literal"'
    options: [allowTaggedTemplates: yes]
    errors: [
      'Expected an assignment or function call and instead saw an expression.'
    ]
  ,
    code: '"untagged #{template} literal"'
    options: [allowTaggedTemplates: no]
    errors: [
      'Expected an assignment or function call and instead saw an expression.'
    ]
  ,
    code: 'tag"tagged #{template} literal"'
    options: [allowTaggedTemplates: no]
    errors: [
      'Expected an assignment or function call and instead saw an expression.'
    ]
  ,
    code: '''
      for x in y
        z
    '''
    errors: [
      message:
        'Expected an assignment or function call and instead saw an expression.'
      type: 'ExpressionStatement'
    ]
  ,
    code: '''
      while x
        y
    '''
    errors: [
      message:
        'Expected an assignment or function call and instead saw an expression.'
      type: 'ExpressionStatement'
    ]
  ,
    code: '''
      switch x
        when y
          z
    '''
    errors: [
      message:
        'Expected an assignment or function call and instead saw an expression.'
      type: 'ExpressionStatement'
    ]
  ]
