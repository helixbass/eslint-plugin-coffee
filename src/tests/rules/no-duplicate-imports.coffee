###*
# @fileoverview Tests for no-duplicate-imports.
# @author Simen Bekkhus
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

{loadInternalEslintModule} = require '../../load-internal-eslint-module'
rule = loadInternalEslintModule 'lib/rules/no-duplicate-imports'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'no-duplicate-imports', rule,
  valid: [
    'import os from "os"\nimport fs from "fs"'
    'import { merge } from "lodash-es"'
    'import _, { merge } from "lodash-es"'
    'import * as Foobar from "async"'
    'import "foo"'
    'import os from "os"\nexport { something } from "os"'
  ,
    code: 'import os from "os"\nexport { hello } from "hello"'
    options: [includeExports: yes]
  ,
    code: 'import os from "os"\nexport * from "hello"'
    options: [includeExports: yes]
  ,
    code: 'import os from "os"\nexport { hello as hi } from "hello"'
    options: [includeExports: yes]
  ,
    code: 'import os from "os"\nexport default ->'
    options: [includeExports: yes]
  ,
    code: 'import { merge } from "lodash-es"\nexport { merge as lodashMerge }'
    options: [includeExports: yes]
  ]
  invalid: [
    code: 'import "fs"\nimport "fs"'
    errors: [message: "'fs' import is duplicated.", type: 'ImportDeclaration']
  ,
    code: 'import { merge } from "lodash-es"\nimport { find } from "lodash-es"'
    errors: [
      message: "'lodash-es' import is duplicated.", type: 'ImportDeclaration'
    ]
  ,
    code: 'import { merge } from "lodash-es"\nimport _ from "lodash-es"'
    errors: [
      message: "'lodash-es' import is duplicated.", type: 'ImportDeclaration'
    ]
  ,
    code: 'export { os } from "os"\nexport { something } from "os"'
    options: [includeExports: yes]
    errors: [
      message: "'os' export is duplicated.", type: 'ExportNamedDeclaration'
    ]
  ,
    code:
      'import os from "os"\nexport { os as foobar } from "os"\nexport { something } from "os"'
    options: [includeExports: yes]
    errors: [
      message: "'os' export is duplicated as import."
      type: 'ExportNamedDeclaration'
    ,
      message: "'os' export is duplicated.", type: 'ExportNamedDeclaration'
    ,
      message: "'os' export is duplicated as import."
      type: 'ExportNamedDeclaration'
    ]
  ,
    code: 'import os from "os"\nexport { something } from "os"'
    options: [includeExports: yes]
    errors: [
      message: "'os' export is duplicated as import."
      type: 'ExportNamedDeclaration'
    ]
  ,
    code: 'import os from "os"\nexport * from "os"'
    options: [includeExports: yes]
    errors: [
      message: "'os' export is duplicated as import."
      type: 'ExportAllDeclaration'
    ]
  ]
