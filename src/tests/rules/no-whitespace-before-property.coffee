###*
# @fileoverview Rule to disallow whitespace before properties
# @author Kai Cataldo
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-whitespace-before-property'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-whitespace-before-property', rule,
  valid: [
    'foo.bar'
    'foo.bar()'
    'foo[bar]'
    "foo['bar']"
    'foo[0]'
    'foo[ bar ]'
    "foo[ 'bar' ]"
    'foo[ 0 ]'
    'foo::bar'
    '''
      foo
      .bar
    '''
    '''
      foo
      ::bar
    '''
    '''
      foo.
      bar
    '''
    '''
      foo
      .bar()
    '''
    '''
      foo.
      bar()
    '''
    '''
      foo.
       bar
    '''
    '''
      foo
      . bar
    '''
    '''
      foo.
       bar()
    '''
    '''
      foo
      . bar()
    '''
    '''
      foo.
      \tbar
    '''
    '''
      foo
      .\tbar
    '''
    '''
      foo.
      \tbar()
    '''
    '''
      foo
      .\tbar()
    '''
    'foo.bar.baz'
    'foo::bar.baz'
    'foo::bar::baz'
    '''
      foo
      .bar
      .baz
    '''
    '''
      foo.
      bar.
      baz
    '''
    'foo.bar().baz()'
    'foo::bar().baz()'
    '''
      foo
      .bar()
      .baz()
    '''
    '''
      foo.
      bar().
      baz()
    '''
    '''
      foo
        .bar
        .baz
    '''
    '''
      foo.
       bar.
       baz
    '''
    '''
      foo
       .bar()
       .baz()
    '''
    '''
      foo.
      bar().
      baz()
    '''
    '''
      foo
      \t.bar
      \t.baz
    '''
    '''
      foo.
      \tbar.
      \tbaz
    '''
    '''
      foo
      \t.bar()
      \t.baz()
    '''
    '''
      foo.
      \tbar().
      \tbaz()
    '''
    '''
      foo
      \t.bar
      \t[baz]
    '''
    "foo['bar' + baz]"
    "foo[ 'bar' + baz ]"
    '(foo + bar).baz'
    '( foo + bar ).baz'
    '(if foo then bar else baz).qux'
    '( if foo then bar else baz ).qux'
    '(if foo then bar else baz)[qux]'
    '( if foo then bar else baz )[qux]'
    '( if foo then bar else baz )[0].qux'
    "foo.bar[('baz')]"
    "foo.bar[ ('baz') ]"
    'foo[[bar]]'
    'foo[ [ bar ] ]'
    "foo[['bar']]"
    "foo[ [ 'bar' ] ]"
    "foo[(('baz'))]"
    "foo[ (('baz'))]"
    "foo[0][[('baz')]]"
    "foo[bar.baz('qux')]"
    'foo[(bar.baz() + 0) + qux]'
    "foo['bar ' + 1 + ' baz']"
    "5['toExponential']()"
    '@b'
    '@::c'
    '@[d]'
  ]

  invalid: [
    code: 'foo. bar'
    output: 'foo.bar'
    errors: ['Unexpected whitespace before property bar.']
  ,
    code: 'foo:: bar'
    output: 'foo::bar'
    errors: ['Unexpected whitespace before property bar.']
  ,
    code: '@:: bar'
    output: '@::bar'
    errors: ['Unexpected whitespace before property bar.']
  ,
    code: 'foo .bar'
    output: 'foo.bar'
    errors: ['Unexpected whitespace before property bar.']
  ,
    code: 'foo ::bar'
    output: 'foo::bar'
    errors: ['Unexpected whitespace before property bar.']
  ,
    code: 'foo. bar. baz'
    output: 'foo.bar.baz'
    errors: [
      'Unexpected whitespace before property baz.'
      'Unexpected whitespace before property bar.'
    ]
  ,
    code: 'foo .bar. baz'
    output: 'foo.bar.baz'
    errors: [
      'Unexpected whitespace before property baz.'
      'Unexpected whitespace before property bar.'
    ]
  ,
    # tabs
    code: 'foo\t.bar'
    output: 'foo.bar'
    errors: ['Unexpected whitespace before property bar.']
  ,
    code: 'foo.\tbar'
    output: 'foo.bar'
    errors: ['Unexpected whitespace before property bar.']
  ,
    code: 'foo\t.bar()'
    output: 'foo.bar()'
    errors: ['Unexpected whitespace before property bar.']
  ,
    code: 'foo.\tbar()'
    output: 'foo.bar()'
    errors: ['Unexpected whitespace before property bar.']
  ,
    code: 'foo.\tbar.\tbaz'
    output: 'foo.bar.baz'
    errors: [
      'Unexpected whitespace before property baz.'
      'Unexpected whitespace before property bar.'
    ]
  ,
    code: 'foo\t.bar.\tbaz'
    output: 'foo.bar.baz'
    errors: [
      'Unexpected whitespace before property baz.'
      'Unexpected whitespace before property bar.'
    ]
  ,
    code: 'foo.\tbar().\tbaz()'
    output: 'foo.bar().baz()'
    errors: [
      'Unexpected whitespace before property baz.'
      'Unexpected whitespace before property bar.'
    ]
  ,
    code: 'foo\t.bar().\tbaz()'
    output: 'foo.bar().baz()'
    errors: [
      'Unexpected whitespace before property baz.'
      'Unexpected whitespace before property bar.'
    ]
  ,
    code: 'foo. bar\n .baz'
    output: 'foo.bar\n .baz'
    errors: ['Unexpected whitespace before property bar.']
  ,
    code: 'foo .bar\n.baz'
    output: 'foo.bar\n.baz'
    errors: ['Unexpected whitespace before property bar.']
  ,
    code: 'foo.\n bar. baz'
    output: 'foo.\n bar.baz'
    errors: ['Unexpected whitespace before property baz.']
  ,
    code: 'foo.\nbar . baz'
    output: 'foo.\nbar.baz'
    errors: ['Unexpected whitespace before property baz.']
  ,
    code: 'foo. bar()\n .baz()'
    output: 'foo.bar()\n .baz()'
    errors: ['Unexpected whitespace before property bar.']
  ,
    code: 'foo .bar()\n.baz()'
    output: 'foo.bar()\n.baz()'
    errors: ['Unexpected whitespace before property bar.']
  ,
    code: 'foo.\n bar(). baz()'
    output: 'foo.\n bar().baz()'
    errors: ['Unexpected whitespace before property baz.']
  ,
    code: 'foo.\nbar() . baz()'
    output: 'foo.\nbar().baz()'
    errors: ['Unexpected whitespace before property baz.']
  ,
    code: 'foo.\tbar\n\t.baz'
    output: 'foo.bar\n\t.baz'
    errors: ['Unexpected whitespace before property bar.']
  ,
    code: 'foo\t.bar\n.baz'
    output: 'foo.bar\n.baz'
    errors: ['Unexpected whitespace before property bar.']
  ,
    code: 'foo.\n\tbar.\tbaz'
    output: 'foo.\n\tbar.baz'
    errors: ['Unexpected whitespace before property baz.']
  ,
    code: 'foo.\nbar\t.\tbaz'
    output: 'foo.\nbar.baz'
    errors: ['Unexpected whitespace before property baz.']
  ,
    code: 'foo.\tbar()\n\t.baz()'
    output: 'foo.bar()\n\t.baz()'
    errors: ['Unexpected whitespace before property bar.']
  ,
    code: 'foo\t.bar()\n.baz()'
    output: 'foo.bar()\n.baz()'
    errors: ['Unexpected whitespace before property bar.']
  ,
    code: 'foo.\n\tbar().\tbaz()'
    output: 'foo.\n\tbar().baz()'
    errors: ['Unexpected whitespace before property baz.']
  ,
    code: 'foo.\nbar()\t.\tbaz()'
    output: 'foo.\nbar().baz()'
    errors: ['Unexpected whitespace before property baz.']
  ,
    code: '(foo + bar) .baz'
    output: '(foo + bar).baz'
    errors: ['Unexpected whitespace before property baz.']
  ,
    code: '(foo + bar) ::baz'
    output: '(foo + bar)::baz'
    errors: ['Unexpected whitespace before property baz.']
  ,
    code: '(foo + bar). baz'
    output: '(foo + bar).baz'
    errors: ['Unexpected whitespace before property baz.']
  ,
    code: '(if foo then bar else baz) .qux'
    output: '(if foo then bar else baz).qux'
    errors: ['Unexpected whitespace before property qux.']
  ,
    code: '(if foo then bar else baz). qux'
    output: '(if foo then bar else baz).qux'
    errors: ['Unexpected whitespace before property qux.']
  ,
    code: '( if foo then bar else baz )[0] .qux'
    output: '( if foo then bar else baz )[0].qux'
    errors: ['Unexpected whitespace before property qux.']
  ,
    code: '( if foo then bar else baz )[0]. qux'
    output: '( if foo then bar else baz )[0].qux'
    errors: ['Unexpected whitespace before property qux.']
  ,
    code: "foo .bar[('baz')]"
    output: "foo.bar[('baz')]"
    errors: ['Unexpected whitespace before property bar.']
  ,
    code: "foo[bar .baz('qux')]"
    output: "foo[bar.baz('qux')]"
    errors: ['Unexpected whitespace before property baz.']
  ,
    code: 'foo[(bar. baz() + 0) + qux]'
    output: 'foo[(bar.baz() + 0) + qux]'
    errors: ['Unexpected whitespace before property baz.']
  ,
    code: '5 .toExponential()'
    output: null # This case is not fixed; can't be sure whether 5..toExponential or (5).toExponential is preferred
    errors: ['Unexpected whitespace before property toExponential.']
  ,
    code: '5       .toExponential()'
    output: null # Not fixed
    errors: ['Unexpected whitespace before property toExponential.']
  ,
    code: '5.0 .toExponential()'
    output: '5.0.toExponential()'
    errors: ['Unexpected whitespace before property toExponential.']
  ,
    code: '0x5 .toExponential()'
    output: '0x5.toExponential()'
    errors: ['Unexpected whitespace before property toExponential.']
  ,
    code: '5e0 .toExponential()'
    output: '5e0.toExponential()'
    errors: ['Unexpected whitespace before property toExponential.']
  ,
    code: '5e-0 .toExponential()'
    output: '5e-0.toExponential()'
    errors: ['Unexpected whitespace before property toExponential.']
  ]
