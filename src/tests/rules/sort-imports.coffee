###*
# @fileoverview Tests for sort-imports rule.
# @author Christian Schuller
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require 'eslint/lib/rules/sort-imports'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
expectedError =
  message: 'Imports should be sorted alphabetically.'
  type: 'ImportDeclaration'
ignoreCaseArgs = [ignoreCase: yes]

ruleTester.run 'sort-imports', rule,
  valid: [
    """
      import a from 'foo.js'
      import b from 'bar.js'
      import c from 'baz.js'
    """
    """
      import * as B from 'foo.js'
      import A from 'bar.js'
    """
    """
      import * as B from 'foo.js'
      import {a, b} from 'bar.js'
    """
    """
      import {b, c} from 'bar.js'
      import A from 'foo.js'
    """
  ,
    code: """
      import A from 'bar.js'
      import {b, c} from 'foo.js'
    """
    options: [memberSyntaxSortOrder: ['single', 'multiple', 'none', 'all']]
  ,
    """
      import {a, b} from 'bar.js'
      import {c, d} from 'foo.js'
    """
    """
      import A from 'foo.js'
      import B from 'bar.js'
    """
    """
      import A from 'foo.js'
      import a from 'bar.js'
    """
    """
      import a, * as b from 'foo.js'
      import c from 'bar.js'
    """
    """
      import 'foo.js'
      import a from 'bar.js'
    """
    """
      import B from 'foo.js'
      import a from 'bar.js'
    """
  ,
    code: """
      import a from 'foo.js'
      import B from 'bar.js'
    """
    options: ignoreCaseArgs
  ,
    "import {a, b, c, d} from 'foo.js'"
  ,
    code: "import {b, A, C, d} from 'foo.js'"
    options: [ignoreMemberSort: yes]
  ,
    code: "import {B, a, C, d} from 'foo.js'"
    options: [ignoreMemberSort: yes]
  ,
    code: "import {a, B, c, D} from 'foo.js'"
    options: ignoreCaseArgs
  ,
    "import a, * as b from 'foo.js'"
    """
      import * as a from 'foo.js'
      
      import b from 'bar.js'
    """
    """
      import * as bar from 'bar.js'
      import * as foo from 'foo.js'
    """
  ,
    # https://github.com/eslint/eslint/issues/5130
    code: """
      import 'foo'
      import bar from 'bar'
    """
    options: ignoreCaseArgs
  ,
    # https://github.com/eslint/eslint/issues/5305
    "import React, {Component} from 'react'"
  ]
  invalid: [
    code: """
      import a from 'foo.js'
      import A from 'bar.js'
    """
    output: null
    errors: [expectedError]
  ,
    code: """
      import b from 'foo.js'
      import a from 'bar.js'
    """
    output: null
    errors: [expectedError]
  ,
    code: """
      import {b, c} from 'foo.js'
      import {a, d} from 'bar.js'
    """
    output: null
    errors: [expectedError]
  ,
    code: """
      import * as foo from 'foo.js'
      import * as bar from 'bar.js'
    """
    output: null
    errors: [expectedError]
  ,
    code: """
      import a from 'foo.js'
      import {b, c} from 'bar.js'
    """
    output: null
    errors: [
      message: "Expected 'multiple' syntax before 'single' syntax."
      type: 'ImportDeclaration'
    ]
  ,
    code: """
      import a from 'foo.js'
      import * as b from 'bar.js'
    """
    output: null
    errors: [
      message: "Expected 'all' syntax before 'single' syntax."
      type: 'ImportDeclaration'
    ]
  ,
    code: """
      import a from 'foo.js'
      import 'bar.js'
    """
    output: null
    errors: [
      message: "Expected 'none' syntax before 'single' syntax."
      type: 'ImportDeclaration'
    ]
  ,
    code: """
      import b from 'bar.js'
      import * as a from 'foo.js'
    """
    output: null
    options: [memberSyntaxSortOrder: ['all', 'single', 'multiple', 'none']]
    errors: [
      message: "Expected 'all' syntax before 'single' syntax."
      type: 'ImportDeclaration'
    ]
  ,
    code: "import {b, a, d, c} from 'foo.js'"
    output: "import {a, b, c, d} from 'foo.js'"
    errors: [
      message:
        "Member 'a' of the import declaration should be sorted alphabetically."
      type: 'ImportSpecifier'
    ]
  ,
    code: "import {a, B, c, D} from 'foo.js'"
    output: "import {B, D, a, c} from 'foo.js'"
    errors: [
      message:
        "Member 'B' of the import declaration should be sorted alphabetically."
      type: 'ImportSpecifier'
    ]
  ,
    code: "import {zzzzz, ### comment ### aaaaa} from 'foo.js'"
    output: null # not fixed due to comment
    errors: [
      message:
        "Member 'aaaaa' of the import declaration should be sorted alphabetically."
      type: 'ImportSpecifier'
    ]
  ,
    code: "import {zzzzz ### comment ###, aaaaa} from 'foo.js'"
    output: null # not fixed due to comment
    errors: [
      message:
        "Member 'aaaaa' of the import declaration should be sorted alphabetically."
      type: 'ImportSpecifier'
    ]
  ,
    code: "import {### comment ### zzzzz, aaaaa} from 'foo.js'"
    output: null # not fixed due to comment
    errors: [
      message:
        "Member 'aaaaa' of the import declaration should be sorted alphabetically."
      type: 'ImportSpecifier'
    ]
  ,
    code: "import {zzzzz, aaaaa ### comment ###} from 'foo.js'"
    output: null # not fixed due to comment
    errors: [
      message:
        "Member 'aaaaa' of the import declaration should be sorted alphabetically."
      type: 'ImportSpecifier'
    ]
  ,
    code: """
              import {
                boop,
                foo,
                zoo,
                baz as qux,
                bar,
                beep
              } from 'foo.js'
            """
    output: """
              import {
                bar,
                beep,
                boop,
                foo,
                baz as qux,
                zoo
              } from 'foo.js'
            """
    errors: [
      message:
        "Member 'qux' of the import declaration should be sorted alphabetically."
      type: 'ImportSpecifier'
    ]
  ]
