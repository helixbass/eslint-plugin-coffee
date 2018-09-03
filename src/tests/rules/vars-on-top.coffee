###*
# @fileoverview Tests for vars-on-top rule.
# @author Danny Fritz
# @author Gyandeep Singh
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/vars-on-top'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'vars-on-top', rule,
  valid: [
    '''
      first = 0
      foo = ->
        first = 2
    '''
    'foo = ->'
    '''
      foo = ->
        first = null
        if yes
          first = yes
        else
          first = 1
    '''
    '''
      foo = ->
        first = null
        second = 1
        {third} = null
        [fourth] = 1
        fifth = null
        {...sixth} = third
        [seventh...] = null
        if yes
          third = yes
        first = second
    '''
    '''
      foo = ->
        for i in [0...10]
          alert i
    '''
    '''
      foo = ->
        outer = null
        inner = ->
          inner = 1
          outer = inner
        outer = 1
    '''
    '''
      foo = ->
        first = null
        #Hello
        second = 1
        first = second
    '''
    '''
      foo = ->
        first = null
        ###
            Hello Clarice
        ###
        second = 1
        first = second
    '''
    '''
      foo = ->
        first = null
        second = 1
        bar = ->
          first = null
          first = 5
        first = second
    '''
    '''
      foo = ->
        first = null
        second = 1
        bar = ->
          third = null
          third = 5
        first = second
    '''
    '''
      foo = ->
        first = null
        bar = ->
          third = null
          third = 5
        first = 5
      '}'
    '''
    '''
      foo = ->
        first = null
        first.onclick ->
          third = null
          third = 5
        first = 5
    '''
    '''
      foo = ->
        i = 0
        alert j for j in [0...10]
        i = i + 1
    '''
    """
      'use strict'
      x = null
      f()
    """
    """
      'use strict'
      'directive'
      x = y = null
      f()
    """
    """
      f = ->
        'use strict'
        x = null
        f()
    """
    """
      f = ->
        'use strict'
        'directive'
        x = null
        y = null
        f()
    """
    """
      import React from 'react'
      y = null
      f = ->
        'use strict'
        x = null
        y = null
        f()
    """
    """
      'use strict'
      import React from 'react'
      y = null
      f = ->
        'use strict'
        x = null
        y = null
        f()
    """
    """
      import React from 'react'
      'use strict'
      y = null
      f = ->
        'use strict'
        x = null
        y = null
        f()
    """
    """
      import * as foo from 'mod.js'
      'use strict'
      y = null
      f = ->
        'use strict'
        x = null
        y = null
        f()
    """
    """
      import { square, diag } from 'lib'
      'use strict'
      y = null
      f = ->
        'use strict'
        x = null
        y = null
        f()
    """
    """
      import { default as foo } from 'lib'
      'use strict'
      y = null
      f = ->
        'use strict'
        x = null
        y = null
        f()
    """
    """
      import 'src/mylib'
      'use strict'
      y = null
      f = ->
        'use strict'
        x = null
        y = null
        f()
    """
    """
      import theDefault, { named1, named2 } from 'src/mylib'
      'use strict'
      y = null
      f = ->
        'use strict'
        x = null
        y = null
        f()
    """
    '''
      export x = null
      y = null
      z = null
    '''
    '''
      x = null
      export y = null
      z = null
    '''
    '''
      x = null
      y = null
      export z = null
    '''
  ]

  invalid: [
    code: '''
      first = 0
      foo = ->
        first = 2
        second = 2
      second = 0
    '''
    errors: [
      message:
        'All declarations must be at the top of the function scope.'
      type: 'Identifier'
    ]
  ,
    code: '''
      foo = ->
        first = null
        first = 1
        first = 2
        first = 3
        first = 4
        second = 1
        second = 2
        first = second
    '''
    errors: [
      message:
        'All declarations must be at the top of the function scope.'
      type: 'Identifier'
    ]
  ,
    code: '''
      foo = ->
        first = null
        second = yes if yes
        first = second
    '''
    errors: [
      message:
        'All declarations must be at the top of the function scope.'
      type: 'Identifier'
    ]
  ,
    code: '''
      foo = ->
        first = 10
        i = null
        for i in [0...first]
          second = i
    '''
    errors: [
      message:
        'All declarations must be at the top of the function scope.'
      type: 'Identifier'
    ]
  ,
    code: '''
      foo = ->
        first = 10
        i = null
        switch first
          when 10
            hello = 1
    '''
    errors: [
      message:
        'All declarations must be at the top of the function scope.'
      type: 'Identifier'
    ]
  ,
    code: '''
      foo = ->
        first = 10
        i = null
        try
          hello = 1
        catch e
          alert 'error'
    '''
    errors: [
      message:
        'All declarations must be at the top of the function scope.'
      type: 'Identifier'
    ]
  ,
    code: '''
      foo = ->
        first = 10
        i = null
        try
          asdf
        catch e
          hello = 1
    '''
    errors: [
      message:
        'All declarations must be at the top of the function scope.'
      type: 'Identifier'
    ]
  ,
    code: '''
      foo = ->
        first = 10
        while first
          hello = 1
    '''
    errors: [
      message:
        'All declarations must be at the top of the function scope.'
      type: 'Identifier'
    ]
  ,
    code: '''
      foo = ->
        first = [1, 2, 3]
        item = null
        for item in first
          hello = item
    '''
    errors: [
      message:
        'All declarations must be at the top of the function scope.'
      type: 'Identifier'
    ]
  ,
    code: """
      'use strict'
      0
      x = null
      f()
    """
    errors: [
      message:
        'All declarations must be at the top of the function scope.'
      type: 'Identifier'
    ]
  ,
    code: """
      f = ->
        'use strict'
        0
        x = null
        f()
    """
    errors: [
      message:
        'All declarations must be at the top of the function scope.'
      type: 'Identifier'
    ]
  ,
    code: """
      import {foo} from 'foo'
      export {foo}
      test = 1
    """
    errors: [
      message:
        'All declarations must be at the top of the function scope.'
      type: 'Identifier'
    ]
  ,
    code: """
      export {foo} from 'foo'
      test = 1
    """
    errors: [
      message:
        'All declarations must be at the top of the function scope.'
      type: 'Identifier'
    ]
  ,
    code: """
      export * from 'foo'
      test = 1
    """
    errors: [
      message:
        'All declarations must be at the top of the function scope.'
      type: 'Identifier'
    ]
  ]
