path = require 'path'
{
  test
  # getTSParsers
} = require '../eslint-plugin-import-utils'

{RuleTester} = require 'eslint'

ruleTester = new RuleTester parser: path.join __dirname, '../../..'
rule = require '../../rules/order'

withoutAutofixOutput = (_test) -> Object.assign {}, _test, output: _test.code

ruleTester.run 'order', rule,
  valid: [
    # Default order using require
    test
      code: '''
        fs = require('fs')
        async = require('async')
        relParent1 = require('../foo')
        relParent2 = require('../foo/bar')
        relParent3 = require('../')
        sibling = require('./foo')
        index = require('./')
      '''
    # Default order using import
    test
      code: '''
        import fs from 'fs'
        import async, {foo1} from 'async'
        import relParent1 from '../foo'
        import relParent2, {foo2} from '../foo/bar'
        import relParent3 from '../'
        import sibling, {foo3} from './foo'
        import index from './'
      '''
    # Multiple module of the same rank next to each other
    test
      code: '''
        fs = require('fs')
        fs = require('fs')
        path = require('path')
        _ = require('lodash')
        async = require('async')
      '''
    # Overriding order to be the reverse of the default order
    test
      code: '''
        index = require('./')
        sibling = require('./foo')
        relParent3 = require('../')
        relParent2 = require('../foo/bar')
        relParent1 = require('../foo')
        async = require('async')
        fs = require('fs')
      '''
      options: [groups: ['index', 'sibling', 'parent', 'external', 'builtin']]
    # Ignore dynamic requires
    test
      code: '''
        path = require('path')
        _ = require('lodash')
        async = require('async')
        fs = require('f' + 's')
      '''
    # Ignore non-require call expressions
    test
      code: '''
        path = require('path')
        result = add(1, 2)
        _ = require('lodash')
      '''
    # Ignore requires that are not at the top-level
    test
      code: '''
        index = require('./')
        foo = ->
          fs = require('fs')
        () => require('fs')
        if (a)
          require('fs')
      '''
    # Ignore unknown/invalid cases
    test
      code: '''
        unknown1 = require('/unknown1')
        fs = require('fs')
        unknown2 = require('/unknown2')
        async = require('async')
        unknown3 = require('/unknown3')
        foo = require('../foo')
        unknown4 = require('/unknown4')
        bar = require('../foo/bar')
        unknown5 = require('/unknown5')
        parent = require('../')
        unknown6 = require('/unknown6')
        foo = require('./foo')
        unknown7 = require('/unknown7')
        index = require('./')
        unknown8 = require('/unknown8')
    '''
    # Ignoring unassigned values by default (require)
    test
      code: '''
          require('./foo')
          require('fs')
          path = require('path')
      '''
    # Ignoring unassigned values by default (import)
    test
      code: '''
        import './foo'
        import 'fs'
        import path from 'path'
      '''
    # No imports
    test
      code: '''
        add = (a, b) ->
          return a + b
        foo = null
      '''
    # Grouping import types
    test
      code: '''
        fs = require('fs')
        index = require('./')
        path = require('path')

        sibling = require('./foo')
        relParent3 = require('../')
        async = require('async')
        relParent1 = require('../foo')
      '''
      options: [
        groups: [['builtin', 'index'], ['sibling', 'parent', 'external']]
      ]
    # Omitted types should implicitly be considered as the last type
    test
      code: '''
        index = require('./')
        path = require('path')
      '''
      options: [
        groups: [
          'index'
          ['sibling', 'parent', 'external']
          # missing 'builtin'
        ]
      ]
    # Mixing require and import should have import up top
    test
      code: '''
        import async, {foo1} from 'async'
        import relParent2, {foo2} from '../foo/bar'
        import sibling, {foo3} from './foo'
        fs = require('fs')
        relParent1 = require('../foo')
        relParent3 = require('../')
        index = require('./')
      '''
    # Adding unknown import types (e.g. using a resolver alias via babel) to the groups.
    test
      code: '''
        import fs from 'fs'
        import { Input } from '-/components/Input'
        import { Button } from '-/components/Button'
        import { add } from './helper'
      '''
      options: [
        groups: ['builtin', 'external', 'unknown', 'parent', 'sibling', 'index']
      ]
    # Using unknown import types (e.g. using a resolver alias via babel) with
    # an alternative custom group list.
    test
      code: '''
        import { Input } from '-/components/Input'
        import { Button } from '-/components/Button'
        import fs from 'fs'
        import { add } from './helper'
      '''
      options: [
        groups: ['unknown', 'builtin', 'external', 'parent', 'sibling', 'index']
      ]
    # Using unknown import types (e.g. using a resolver alias via babel)
    # Option: newlines-between: 'always'
    test
      code: '''
        import fs from 'fs'

        import { Input } from '-/components/Input'
        import { Button } from '-/components/Button'

        import { add } from './helper'
      '''
      options: [
        'newlines-between': 'always'
        groups: ['builtin', 'external', 'unknown', 'parent', 'sibling', 'index']
      ]

    # Using pathGroups to customize ordering, position 'after'
    test
      code: '''
        import fs from 'fs'
        import _ from 'lodash'
        import { Input } from '~/components/Input'
        import { Button } from '#/components/Button'
        import { add } from './helper'
      '''
      options: [
        pathGroups: [
          pattern: '~/**', group: 'external', position: 'after'
        ,
          pattern: '#/**', group: 'external', position: 'after'
        ]
      ]
    # pathGroup without position means "equal" with group
    test
      code: '''
        import fs from 'fs'
        import { Input } from '~/components/Input'
        import async from 'async'
        import { Button } from '#/components/Button'
        import _ from 'lodash'
        import { add } from './helper'
      '''
      options: [
        pathGroups: [
          pattern: '~/**', group: 'external'
        ,
          pattern: '#/**', group: 'external'
        ]
      ]
    # Using pathGroups to customize ordering, position 'before'
    test
      code: '''
        import fs from 'fs'

        import { Input } from '~/components/Input'

        import { Button } from '#/components/Button'

        import _ from 'lodash'

        import { add } from './helper'
      '''
      options: [
        'newlines-between': 'always'
        pathGroups: [
          pattern: '~/**', group: 'external', position: 'before'
        ,
          pattern: '#/**', group: 'external', position: 'before'
        ]
      ]
    # Using pathGroups to customize ordering, with patternOptions
    test
      code: '''
        import fs from 'fs'

        import _ from 'lodash'

        import { Input } from '~/components/Input'

        import { Button } from '!/components/Button'

        import { add } from './helper'
      '''
      options: [
        'newlines-between': 'always'
        pathGroups: [
          pattern: '~/**', group: 'external', position: 'after'
        ,
          pattern: '!/**'
          patternOptions: nonegate: yes
          group: 'external'
          position: 'after'
        ]
      ]

    # Option: newlines-between: 'always'
    test
      code: '''
        fs = require('fs')
        index = require('./')
        path = require('path')

        sibling = require('./foo')

        relParent1 = require('../foo')
        relParent3 = require('../')
        async = require('async')
      '''
      options: [
        groups: [['builtin', 'index'], ['sibling'], ['parent', 'external']]
        'newlines-between': 'always'
      ]
    # Option: newlines-between: 'never'
    test
      code: '''
        fs = require('fs')
        index = require('./')
        path = require('path')
        sibling = require('./foo')
        relParent1 = require('../foo')
        relParent3 = require('../')
        async = require('async')
      '''
      options: [
        groups: [['builtin', 'index'], ['sibling'], ['parent', 'external']]
        'newlines-between': 'never'
      ]
    # Option: newlines-between: 'ignore'
    test
      code: '''
        fs = require('fs')

        index = require('./')
        path = require('path')
        sibling = require('./foo')

        relParent1 = require('../foo')

        relParent3 = require('../')
        async = require('async')
      '''
      options: [
        groups: [['builtin', 'index'], ['sibling'], ['parent', 'external']]
        'newlines-between': 'ignore'
      ]
    # 'ignore' should be the default value for `newlines-between`
    test
      code: '''
        fs = require('fs')

        index = require('./')
        path = require('path')
        sibling = require('./foo')

        relParent1 = require('../foo')

        relParent3 = require('../')

        async = require('async')
      '''
      options: [
        groups: [['builtin', 'index'], ['sibling'], ['parent', 'external']]
      ]
    # Option newlines-between: 'always' with multiline imports #1
    test
      code: '''
        import path from 'path'

        import {
            I,
            Want,
            Couple,
            Imports,
            Here
        } from 'bar'
        import external from 'external'
      '''
      options: ['newlines-between': 'always']
    # Option newlines-between: 'always' with multiline imports #2
    test
      code: '''
        import path from 'path'
        import net \
          from 'net'

        import external from 'external'
      '''
      options: ['newlines-between': 'always']
    # Option newlines-between: 'always' with multiline imports #3
    test
      code: '''
        import foo \
          from '../../../../this/will/be/very/long/path/and/therefore/this/import/has/to/be/in/two/lines'

        import bar \
          from './sibling'
      '''
      options: ['newlines-between': 'always']
    # Option newlines-between: 'always' with not assigned import #1
    test
      code: '''
        import path from 'path'

        import 'loud-rejection'
        import 'something-else'

        import _ from 'lodash'
      '''
      options: ['newlines-between': 'always']
    # Option newlines-between: 'never' with not assigned import #2
    test
      code: '''
        import path from 'path'
        import 'loud-rejection'
        import 'something-else'
        import _ from 'lodash'
      '''
      options: ['newlines-between': 'never']
    # Option newlines-between: 'always' with not assigned require #1
    test
      code: '''
        path = require('path')

        require('loud-rejection')
        require('something-else')

        _ = require('lodash')
      '''
      options: ['newlines-between': 'always']
    # Option newlines-between: 'never' with not assigned require #2
    test
      code: '''
        path = require('path')
        require('loud-rejection')
        require('something-else')
        _ = require('lodash')
      '''
      options: ['newlines-between': 'never']
    # Option newlines-between: 'never' should ignore nested require statement's #1
    test
      code: '''
        some = require('asdas')
        config = {
          port: 4444,
          runner: {
            server_path: require('runner-binary').path,

            cli_args: {
                'webdriver.chrome.driver': require('browser-binary').path
            }
          }
        }
      '''
      options: ['newlines-between': 'never']
    # Option newlines-between: 'always' should ignore nested require statement's #2
    test
      code: '''
        some = require('asdas')
        config = {
          port: 4444,
          runner: {
            server_path: require('runner-binary').path,
            cli_args: {
                'webdriver.chrome.driver': require('browser-binary').path
            }
          }
        }
      '''
      options: ['newlines-between': 'always']
    # Option: newlines-between: 'always-and-inside-groups'
    test
      code: '''
        fs = require('fs')
        path = require('path')

        util = require('util')

        async = require('async')

        relParent1 = require('../foo')
        relParent2 = require('../')

        relParent3 = require('../bar')

        sibling = require('./foo')
        sibling2 = require('./bar')

        sibling3 = require('./foobar')
      '''
      options: ['newlines-between': 'always-and-inside-groups']
    # Option alphabetize: {order: 'ignore'}
    test
      code: '''
        import a from 'foo'
        import b from 'bar'

        import index from './'
      '''
      options: [
        groups: ['external', 'index']
        alphabetize: order: 'ignore'
      ]
    # Option alphabetize: {order: 'asc'}
    test
      code: '''
        import c from 'Bar'
        import b from 'bar'
        import a from 'foo'

        import index from './'
      '''
      options: [
        groups: ['external', 'index']
        alphabetize: order: 'asc'
      ]
    # Option alphabetize: {order: 'desc'}
    test
      code: '''
        import a from 'foo'
        import b from 'bar'
        import c from 'Bar'

        import index from './'
      '''
      options: [
        groups: ['external', 'index']
        alphabetize: order: 'desc'
      ]
    # Option alphabetize with newlines-between: {order: 'asc', newlines-between: 'always'}
    test
      code: '''
        import b from 'Bar'
        import c from 'bar'
        import a from 'foo'

        import index from './'
      '''
      options: [
        groups: ['external', 'index']
        alphabetize: order: 'asc'
        'newlines-between': 'always'
      ]
  ]
  invalid: [
    # builtin before external module (require)
    test
      code: '''
        async = require('async')
        fs = require('fs')
      '''
      output: '''
        fs = require('fs')
        async = require('async')\n
      '''
      errors: [
        ruleId: 'order'
        message: '`fs` import should occur before import of `async`'
      ]
    # fix order with spaces on the end of line
    test
      code: """
        async = require('async')
        fs = require('fs')#{' '}
      """
      output: """
        fs = require('fs')#{' '}
        async = require('async')\n
      """
      errors: [
        ruleId: 'order'
        message: '`fs` import should occur before import of `async`'
      ]
    # fix order with comment on the end of line
    test
      code: '''
        async = require('async')
        fs = require('fs') ### comment ###
      '''
      output: '''
        fs = require('fs') ### comment ###
        async = require('async')\n
      '''
      errors: [
        ruleId: 'order'
        message: '`fs` import should occur before import of `async`'
      ]
    # fix order with comments at the end and start of line
    test
      code: '''
        async = require('async') ### comment2 ###
        fs = require('fs') ### comment4 ###
      '''
      output: '''
        fs = require('fs') ### comment4 ###
        async = require('async') ### comment2 ###\n
      '''
      errors: [
        ruleId: 'order'
        message: '`fs` import should occur before import of `async`'
      ]
      # # fix order with few comments at the end and start of line
      # test
      #   code: '''
      #     /* comment0 */  /* comment1 */  var async = require('async'); /* comment2 */
      #     /* comment3 */  var fs = require('fs'); /* comment4 */
      #   '''
      #   output: '''
      #     /* comment3 */  var fs = require('fs'); /* comment4 */
      #     /* comment0 */  /* comment1 */  var async = require('async'); /* comment2 */
      #   '''
      #   errors: [
      #     ruleId: 'order'
      #     message: '`fs` import should occur before import of `async`'
      #   ]
      # # fix order with windows end of lines
      # test
      #   code:
      #     "/* comment0 */  /* comment1 */  var async = require('async'); /* comment2 */" +
      #     '\r\n' +
      #     "/* comment3 */  var fs = require('fs'); /* comment4 */" +
      #     '\r\n'
      #   output:
      #     "/* comment3 */  var fs = require('fs'); /* comment4 */" +
      #     '\r\n' +
      #     "/* comment0 */  /* comment1 */  var async = require('async'); /* comment2 */" +
      #     '\r\n'
      #   errors: [
      #     ruleId: 'order'
      #     message: '`fs` import should occur before import of `async`'
      #   ]
      # # fix order with multilines comments at the end and start of line
      # test
      #   code: '''
      #     /* multiline1
      #       comment1 */  var async = require('async'); /* multiline2
      #       comment2 */  var fs = require('fs'); /* multiline3
      #       comment3 */
      #   '''
      #   output:
      #     '''
      #     /* multiline1
      #       comment1 */  var fs = require('fs');''' +
      #     ' ' + '''
      # var async = require('async'); /* multiline2
      #       comment2 *//* multiline3
      #       comment3 */
      #   '''
      #   errors: [
      #     ruleId: 'order'
      #     message: '`fs` import should occur before import of `async`'
      #   ]
    # fix destructured commonjs import
    test
      code: '''
        {b} = require('async')
        {a} = require('fs')
      '''
      output: '''
        {a} = require('fs')
        {b} = require('async')\n
      '''
      errors: [
        ruleId: 'order'
        message: '`fs` import should occur before import of `async`'
      ]
    # fix order of multiline import
    test
      code: '''
        async = require('async')
        fs =
          require('fs')
      '''
      output: '''
        fs =
          require('fs')
        async = require('async')\n
      '''
      errors: [
        ruleId: 'order'
        message: '`fs` import should occur before import of `async`'
      ]
    # fix order at the end of file
    test
      code: '''
        async = require('async')
        fs = require('fs')
      '''
      output: '''
        fs = require('fs')
        async = require('async')\n
      '''
      errors: [
        ruleId: 'order'
        message: '`fs` import should occur before import of `async`'
      ]
    # builtin before external module (import)
    test
      code: '''
        import async from 'async'
        import fs from 'fs'
      '''
      output: '''
        import fs from 'fs'
        import async from 'async'\n
      '''
      errors: [
        ruleId: 'order'
        message: '`fs` import should occur before import of `async`'
      ]
    # builtin before external module (mixed import and require)
    test
      code: '''
        async = require('async')
        import fs from 'fs'
      '''
      output: '''
        import fs from 'fs'
        async = require('async')\n
      '''
      errors: [
        ruleId: 'order'
        message: '`fs` import should occur before import of `async`'
      ]
    # external before parent
    test
      code: '''
        parent = require('../parent')
        async = require('async')
      '''
      output: '''
        async = require('async')
        parent = require('../parent')\n
      '''
      errors: [
        ruleId: 'order'
        message: '`async` import should occur before import of `../parent`'
      ]
    # parent before sibling
    test
      code: '''
        sibling = require('./sibling')
        parent = require('../parent')
      '''
      output: '''
        parent = require('../parent')
        sibling = require('./sibling')\n
      '''
      errors: [
        ruleId: 'order'
        message: '`../parent` import should occur before import of `./sibling`'
      ]
    # sibling before index
    test
      code: '''
        index = require('./')
        sibling = require('./sibling')
      '''
      output: '''
        sibling = require('./sibling')
        index = require('./')\n
      '''
      errors: [
        ruleId: 'order'
        message: '`./sibling` import should occur before import of `./`'
      ]
    # Multiple errors
    test
      code: '''
        sibling = require('./sibling')
        async = require('async')
        fs = require('fs')
      '''
      errors: [
        ruleId: 'order'
        message: '`async` import should occur before import of `./sibling`'
      ,
        ruleId: 'order'
        message: '`fs` import should occur before import of `./sibling`'
      ]
    # Uses 'after' wording if it creates less errors
    test
      code: '''
        index = require('./')
        fs = require('fs')
        path = require('path')
        _ = require('lodash')
        foo = require('foo')
        bar = require('bar')
        x = y
      '''
      output: '''
        fs = require('fs')
        path = require('path')
        _ = require('lodash')
        foo = require('foo')
        bar = require('bar')
        index = require('./')
        x = y
      '''
      errors: [
        ruleId: 'order'
        message: '`./` import should occur after import of `bar`'
      ]
    test
      code: '''
        index = require('./')
        fs = require('fs')
        path = require('path')
        _ = require('lodash')
        foo = require('foo')
        bar = require('bar')
      '''
      output: '''
        fs = require('fs')
        path = require('path')
        _ = require('lodash')
        foo = require('foo')
        bar = require('bar')
        index = require('./')\n
      '''
      errors: [
        ruleId: 'order'
        message: '`./` import should occur after import of `bar`'
      ]
    # Overriding order to be the reverse of the default order
    test
      code: '''
        fs = require('fs')
        index = require('./')
      '''
      output: '''
        index = require('./')
        fs = require('fs')\n
      '''
      options: [groups: ['index', 'sibling', 'parent', 'external', 'builtin']]
      errors: [
        ruleId: 'order'
        message: '`./` import should occur before import of `fs`'
      ]
    # member expression of require
    test(
      withoutAutofixOutput
        code: '''
          foo = require('./foo').bar
          fs = require('fs')
        '''
        errors: [
          ruleId: 'order'
          message: '`fs` import should occur before import of `./foo`'
        ]
    )
    # nested member expression of require
    test(
      withoutAutofixOutput
        code: '''
          foo = require('./foo').bar.bar.bar
          fs = require('fs')
        '''
        errors: [
          ruleId: 'order'
          message: '`fs` import should occur before import of `./foo`'
        ]
    )
    # fix near nested member expression of require with newlines
    test(
      withoutAutofixOutput
        code: '''
          foo = require('./foo').bar
            .bar
            .bar
          fs = require('fs')
        '''
        errors: [
          ruleId: 'order'
          message: '`fs` import should occur before import of `./foo`'
        ]
    )
    # fix nested member expression of require with newlines
    test(
      withoutAutofixOutput
        code: '''
          foo = require('./foo')
          fs = require('fs').bar
            .bar
            .bar
        '''
        errors: [
          ruleId: 'order'
          message: '`fs` import should occur before import of `./foo`'
        ]
    )
    # Grouping import types
    test
      code: '''
        fs = require('fs')
        index = require('./')
        sibling = require('./foo')
        path = require('path')
      '''
      output: '''
        fs = require('fs')
        index = require('./')
        path = require('path')
        sibling = require('./foo')\n
      '''
      options: [
        groups: [['builtin', 'index'], ['sibling', 'parent', 'external']]
      ]
      errors: [
        ruleId: 'order'
        message: '`path` import should occur before import of `./foo`'
      ]
    # Omitted types should implicitly be considered as the last type
    test
      code: '''
        path = require('path')
        async = require('async')
      '''
      output: '''
        async = require('async')
        path = require('path')\n
      '''
      options: [
        groups: [
          'index'
          ['sibling', 'parent', 'external', 'internal']
          # missing 'builtin'
        ]
      ]
      errors: [
        ruleId: 'order'
        message: '`async` import should occur before import of `path`'
      ]
    # Setting the order for an unknown type
    # should make the rule trigger an error and do nothing else
    test
      code: '''
        async = require('async')
        index = require('./')
      '''
      options: [groups: ['index', ['sibling', 'parent', 'UNKNOWN', 'internal']]]
      errors: [
        ruleId: 'order'
        message: 'Incorrect configuration of the rule: Unknown type `"UNKNOWN"`'
      ]
    # Type in an array can't be another array, too much nesting
    test
      code: '''
        async = require('async')
        index = require('./')
      '''
      options: [
        groups: ['index', ['sibling', 'parent', ['builtin'], 'internal']]
      ]
      errors: [
        ruleId: 'order'
        message:
          'Incorrect configuration of the rule: Unknown type `["builtin"]`'
      ]
    # No numbers
    test
      code: '''
        async = require('async')
        index = require('./')
      '''
      options: [groups: ['index', ['sibling', 'parent', 2, 'internal']]]
      errors: [
        ruleId: 'order'
        message: 'Incorrect configuration of the rule: Unknown type `2`'
      ]
    # Duplicate
    test
      code: '''
        async = require('async')
        index = require('./')
      '''
      options: [groups: ['index', ['sibling', 'parent', 'parent', 'internal']]]
      errors: [
        ruleId: 'order'
        message: 'Incorrect configuration of the rule: `parent` is duplicated'
      ]
    # Mixing require and import should have import up top
    test
      code: '''
        import async, {foo1} from 'async'
        import relParent2, {foo2} from '../foo/bar'
        fs = require('fs')
        relParent1 = require('../foo')
        relParent3 = require('../')
        import sibling, {foo3} from './foo'
        index = require('./')
      '''
      output: '''
        import async, {foo1} from 'async'
        import relParent2, {foo2} from '../foo/bar'
        import sibling, {foo3} from './foo'
        fs = require('fs')
        relParent1 = require('../foo')
        relParent3 = require('../')
        index = require('./')
      '''
      errors: [
        ruleId: 'order'
        message: '`./foo` import should occur before import of `fs`'
      ]
    test
      code: '''
        fs = require('fs')
        import async, {foo1} from 'async'
        import relParent2, {foo2} from '../foo/bar'
      '''
      output: '''
        import async, {foo1} from 'async'
        import relParent2, {foo2} from '../foo/bar'
        fs = require('fs')\n
      '''
      errors: [
        ruleId: 'order'
        message: '`fs` import should occur after import of `../foo/bar`'
      ]
    # Default order using import with custom import alias
    test
      code: '''
        import { Button } from '-/components/Button'
        import { add } from './helper'
        import fs from 'fs'
      '''
      output: '''
        import fs from 'fs'
        import { Button } from '-/components/Button'
        import { add } from './helper'\n
      '''
      options: [
        groups: ['builtin', 'external', 'unknown', 'parent', 'sibling', 'index']
      ]
      errors: [
        line: 3
        message:
          '`fs` import should occur before import of `-/components/Button`'
      ]
    # Default order using import with custom import alias
    test
      code: '''
        import fs from 'fs'
        import { Button } from '-/components/Button'
        import { LinkButton } from '-/components/Link'
        import { add } from './helper'
      '''
      output: '''
        import fs from 'fs'

        import { Button } from '-/components/Button'
        import { LinkButton } from '-/components/Link'

        import { add } from './helper'
      '''
      options: [
        groups: ['builtin', 'external', 'unknown', 'parent', 'sibling', 'index']
        'newlines-between': 'always'
      ]
      errors: [
        line: 1
        message: 'There should be at least one empty line between import groups'
      ,
        line: 3
        message: 'There should be at least one empty line between import groups'
      ]
    # Option newlines-between: 'never' - should report unnecessary line between groups
    test
      code: '''
        fs = require('fs')
        index = require('./')
        path = require('path')

        sibling = require('./foo')

        relParent1 = require('../foo')
        relParent3 = require('../')
        async = require('async')
      '''
      output: '''
        fs = require('fs')
        index = require('./')
        path = require('path')
        sibling = require('./foo')
        relParent1 = require('../foo')
        relParent3 = require('../')
        async = require('async')
      '''
      options: [
        groups: [['builtin', 'index'], ['sibling'], ['parent', 'external']]
        'newlines-between': 'never'
      ]
      errors: [
        line: 3
        message: 'There should be no empty line between import groups'
      ,
        line: 5
        message: 'There should be no empty line between import groups'
      ]
    # Fix newlines-between with comments after
    test
      code: '''
        fs = require('fs') ### comment ###

        index = require('./')
      '''
      output: '''
        fs = require('fs') ### comment ###
        index = require('./')
      '''
      options: [
        groups: [['builtin'], ['index']]
        'newlines-between': 'never'
      ]
      errors: [
        line: 1
        message: 'There should be no empty line between import groups'
      ]
    # Cannot fix newlines-between with multiline comment after
    test
      code: '''
        fs = require('fs') ### multiline
        comment ###

        index = require('./')
      '''
      output: '''
        fs = require('fs') ### multiline
        comment ###

        index = require('./')
      '''
      options: [
        groups: [['builtin'], ['index']]
        'newlines-between': 'never'
      ]
      errors: [
        line: 1
        message: 'There should be no empty line between import groups'
      ]
    # Option newlines-between: 'always' - should report lack of newline between groups
    test
      code: '''
        fs = require('fs')
        index = require('./')
        path = require('path')
        sibling = require('./foo')
        relParent1 = require('../foo')
        relParent3 = require('../')
        async = require('async')
      '''
      output: '''
        fs = require('fs')
        index = require('./')
        path = require('path')

        sibling = require('./foo')

        relParent1 = require('../foo')
        relParent3 = require('../')
        async = require('async')
      '''
      options: [
        groups: [['builtin', 'index'], ['sibling'], ['parent', 'external']]
        'newlines-between': 'always'
      ]
      errors: [
        line: 3
        message: 'There should be at least one empty line between import groups'
      ,
        line: 4
        message: 'There should be at least one empty line between import groups'
      ]
    # Option newlines-between: 'always' should report unnecessary empty lines space between import groups
    test
      code: '''
        fs = require('fs')

        path = require('path')
        index = require('./')

        sibling = require('./foo')

        async = require('async')
      '''
      output: '''
        fs = require('fs')
        path = require('path')
        index = require('./')

        sibling = require('./foo')
        async = require('async')
      '''
      options: [
        groups: [['builtin', 'index'], ['sibling', 'parent', 'external']]
        'newlines-between': 'always'
      ]
      errors: [
        line: 1
        message: 'There should be no empty line within import group'
      ,
        line: 6
        message: 'There should be no empty line within import group'
      ]
    # Option newlines-between: 'never' cannot fix if there are other statements between imports
    test
      code: '''
        import path from 'path'
        import 'loud-rejection'

        import 'something-else'
        import _ from 'lodash'
      '''
      output: '''
        import path from 'path'
        import 'loud-rejection'

        import 'something-else'
        import _ from 'lodash'
      '''
      options: ['newlines-between': 'never']
      errors: [
        line: 1
        message: 'There should be no empty line between import groups'
      ]
    # Option newlines-between: 'always' should report missing empty lines when using not assigned imports
    test
      code: '''
        import path from 'path'
        import 'loud-rejection'
        import 'something-else'
        import _ from 'lodash'
      '''
      output: '''
        import path from 'path'

        import 'loud-rejection'
        import 'something-else'
        import _ from 'lodash'
      '''
      options: ['newlines-between': 'always']
      errors: [
        line: 1
        message: 'There should be at least one empty line between import groups'
      ]
    # fix missing empty lines with single line comment after
    test
      code: '''
        import path from 'path' # comment
        import _ from 'lodash'
      '''
      output: '''
        import path from 'path' # comment

        import _ from 'lodash'
      '''
      options: ['newlines-between': 'always']
      errors: [
        line: 1
        message: 'There should be at least one empty line between import groups'
      ]
    # fix missing empty lines with few line block comment after
    test
      code: '''
        import path from 'path' ### comment ### ### comment ###
        import _ from 'lodash'
      '''
      output: '''
        import path from 'path' ### comment ### ### comment ###

        import _ from 'lodash'
      '''
      options: ['newlines-between': 'always']
      errors: [
        line: 1
        message: 'There should be at least one empty line between import groups'
      ]
    # fix missing empty lines with single line block comment after
    test
      code: '''
        import path from 'path' ### 1
        2 ###
        import _ from 'lodash'
      '''
      output: '''
        import path from 'path'
         ### 1
        2 ###
        import _ from 'lodash'
      '''
      options: ['newlines-between': 'always']
      errors: [
        line: 1
        message: 'There should be at least one empty line between import groups'
      ]
    # reorder fix cannot cross function call on moving below #1
    test
      code: '''
        local = require('./local')

        fn_call()

        global1 = require('global1')
        global2 = require('global2')

        fn_call()
      '''
      output: '''
        local = require('./local')

        fn_call()

        global1 = require('global1')
        global2 = require('global2')

        fn_call()
      '''
      errors: [
        ruleId: 'order'
        message: '`./local` import should occur after import of `global2`'
      ]
    # reorder fix cannot cross function call on moving below #2
    test
      code: '''
        local = require('./local')
        fn_call()
        global1 = require('global1')
        global2 = require('global2')

        fn_call()
      '''
      output: '''
        local = require('./local')
        fn_call()
        global1 = require('global1')
        global2 = require('global2')

        fn_call()
      '''
      errors: [
        ruleId: 'order'
        message: '`./local` import should occur after import of `global2`'
      ]
    # reorder fix cannot cross function call on moving below #3
    test
      code: '''
        local1 = require('./local1')
        local2 = require('./local2')
        local3 = require('./local3')
        local4 = require('./local4')
        fn_call()
        global1 = require('global1')
        global2 = require('global2')
        global3 = require('global3')
        global4 = require('global4')
        global5 = require('global5')
        fn_call()
      '''
      output: '''
        local1 = require('./local1')
        local2 = require('./local2')
        local3 = require('./local3')
        local4 = require('./local4')
        fn_call()
        global1 = require('global1')
        global2 = require('global2')
        global3 = require('global3')
        global4 = require('global4')
        global5 = require('global5')
        fn_call()
      '''
      errors: [
        '`./local1` import should occur after import of `global5`'
        '`./local2` import should occur after import of `global5`'
        '`./local3` import should occur after import of `global5`'
        '`./local4` import should occur after import of `global5`'
      ]
    # reorder fix cannot cross function call on moving below
    test(
      withoutAutofixOutput
        code: '''
          local = require('./local')
          global1 = require('global1')
          global2 = require('global2')
          fn_call()
          global3 = require('global3')

          fn_call()
        '''
        errors: [
          ruleId: 'order'
          message: '`./local` import should occur after import of `global3`'
        ]
    )
    # reorder fix cannot cross function call on moving below
    # fix imports that not crosses function call only
    test
      code: '''
        local1 = require('./local1')
        global1 = require('global1')
        global2 = require('global2')
        fn_call()
        local2 = require('./local2')
        global3 = require('global3')
        global4 = require('global4')

        fn_call()
      '''
      output: '''
        local1 = require('./local1')
        global1 = require('global1')
        global2 = require('global2')
        fn_call()
        global3 = require('global3')
        global4 = require('global4')
        local2 = require('./local2')

        fn_call()
      '''
      errors: [
        '`./local1` import should occur after import of `global4`'
        '`./local2` import should occur after import of `global4`'
      ]

    # pathGroup with position 'after'
    test
      code: '''
        import fs from 'fs'
        import _ from 'lodash'
        import { add } from './helper'
        import { Input } from '~/components/Input'
        '''
      output: '''
        import fs from 'fs'
        import _ from 'lodash'
        import { Input } from '~/components/Input'
        import { add } from './helper'\n
        '''
      options: [
        pathGroups: [pattern: '~/**', group: 'external', position: 'after']
      ]
      errors: [
        ruleId: 'order'
        message:
          '`~/components/Input` import should occur before import of `./helper`'
      ]
    # pathGroup without position
    test
      code: '''
        import fs from 'fs'
        import _ from 'lodash'
        import { add } from './helper'
        import { Input } from '~/components/Input'
        import async from 'async'
        '''
      output: '''
        import fs from 'fs'
        import _ from 'lodash'
        import { Input } from '~/components/Input'
        import async from 'async'
        import { add } from './helper'\n
        '''
      options: [pathGroups: [pattern: '~/**', group: 'external']]
      errors: [
        ruleId: 'order'
        message: '`./helper` import should occur after import of `async`'
      ]
    # pathGroup with position 'before'
    test
      code: '''
        import fs from 'fs'
        import _ from 'lodash'
        import { add } from './helper'
        import { Input } from '~/components/Input'
        '''
      output: '''
        import fs from 'fs'
        import { Input } from '~/components/Input'
        import _ from 'lodash'
        import { add } from './helper'\n
        '''
      options: [
        pathGroups: [pattern: '~/**', group: 'external', position: 'before']
      ]
      errors: [
        ruleId: 'order'
        message:
          '`~/components/Input` import should occur before import of `lodash`'
      ]
    # multiple pathGroup with different positions for same group, fix for 'after'
    test
      code: '''
        import fs from 'fs'
        import { Import } from '$/components/Import'
        import _ from 'lodash'
        import { Output } from '~/components/Output'
        import { Input } from '#/components/Input'
        import { add } from './helper'
        import { Export } from '-/components/Export'
        '''
      output: '''
        import fs from 'fs'
        import { Export } from '-/components/Export'
        import { Import } from '$/components/Import'
        import _ from 'lodash'
        import { Output } from '~/components/Output'
        import { Input } from '#/components/Input'
        import { add } from './helper'\n
        '''
      options: [
        pathGroups: [
          pattern: '~/**', group: 'external', position: 'after'
        ,
          pattern: '#/**', group: 'external', position: 'after'
        ,
          pattern: '-/**', group: 'external', position: 'before'
        ,
          pattern: '$/**', group: 'external', position: 'before'
        ]
      ]
      errors: [
        ruleId: 'order'
        message:
          '`-/components/Export` import should occur before import of `$/components/Import`'
      ]
    # multiple pathGroup with different positions for same group, fix for 'before'
    test
      code: '''
        import fs from 'fs'
        import { Export } from '-/components/Export'
        import { Import } from '$/components/Import'
        import _ from 'lodash'
        import { Input } from '#/components/Input'
        import { add } from './helper'
        import { Output } from '~/components/Output'
        '''
      output: '''
        import fs from 'fs'
        import { Export } from '-/components/Export'
        import { Import } from '$/components/Import'
        import _ from 'lodash'
        import { Output } from '~/components/Output'
        import { Input } from '#/components/Input'
        import { add } from './helper'\n
        '''
      options: [
        pathGroups: [
          pattern: '~/**', group: 'external', position: 'after'
        ,
          pattern: '#/**', group: 'external', position: 'after'
        ,
          pattern: '-/**', group: 'external', position: 'before'
        ,
          pattern: '$/**', group: 'external', position: 'before'
        ]
      ]
      errors: [
        ruleId: 'order'
        message:
          '`~/components/Output` import should occur before import of `#/components/Input`'
      ]
    # reorder fix cannot cross non import or require
    test(
      withoutAutofixOutput
        code: '''
          async = require('async')
          fn_call()
          fs = require('fs')
        '''
        errors: [
          ruleId: 'order'
          message: '`fs` import should occur before import of `async`'
        ]
    )
    # reorder fix cannot cross function call on moving below (from #1252)
    test
      code: '''
        env = require('./config')

        Object.keys(env)

        http = require('http')
        express = require('express')

        http.createServer(express())
      '''
      output: '''
        env = require('./config')

        Object.keys(env)

        http = require('http')
        express = require('express')

        http.createServer(express())
      '''
      errors: [
        ruleId: 'order'
        message: '`./config` import should occur after import of `express`'
      ]
    # reorder cannot cross non plain requires
    test(
      withoutAutofixOutput
        code: '''
          async = require('async')
          a = require('./value.js')(a)
          fs = require('fs')
        '''
        errors: [
          ruleId: 'order'
          message: '`fs` import should occur before import of `async`'
        ]
    )
    # reorder fixes cannot be applied to non plain requires #1
    test(
      withoutAutofixOutput
        code: '''
          async = require('async')
          fs = require('fs')(a)
        '''
        errors: [
          ruleId: 'order'
          message: '`fs` import should occur before import of `async`'
        ]
    )
    # reorder fixes cannot be applied to non plain requires #2
    test(
      withoutAutofixOutput
        code: '''
          async = require('async')(a)
          fs = require('fs')
        '''
        errors: [
          ruleId: 'order'
          message: '`fs` import should occur before import of `async`'
        ]
    )
    # cannot require in case of not assignment require
    test(
      withoutAutofixOutput
        code: '''
          async = require('async')
          require('./aa')
          fs = require('fs')
        '''
        errors: [
          ruleId: 'order'
          message: '`fs` import should occur before import of `async`'
        ]
    )
    # reorder cannot cross function call (import statement)
    test(
      withoutAutofixOutput
        code: '''
          import async from 'async'
          fn_call()
          import fs from 'fs'
        '''
        errors: [
          ruleId: 'order'
          message: '`fs` import should occur before import of `async`'
        ]
    )
    # reorder cannot cross variable assignment (import statement)
    test(
      withoutAutofixOutput
        code: '''
          import async from 'async'
          a = 1
          import fs from 'fs'
        '''
        errors: [
          ruleId: 'order'
          message: '`fs` import should occur before import of `async`'
        ]
    )
    # reorder cannot cross non plain requires (import statement)
    test(
      withoutAutofixOutput
        code: '''
          import async from 'async'
          a = require('./value.js')(a)
          import fs from 'fs'
        '''
        errors: [
          ruleId: 'order'
          message: '`fs` import should occur before import of `async`'
        ]
    )
    # cannot reorder in case of not assignment import
    test(
      withoutAutofixOutput
        code: '''
          import async from 'async'
          import './aa'
          import fs from 'fs'
        '''
        errors: [
          ruleId: 'order'
          message: '`fs` import should occur before import of `async`'
        ]
    )
    # ...getTSParsers().map((parser) -> {
    #   code: '''
    #     var async = require('async');
    #     var fs = require('fs');
    #   '''
    #   output: '''
    #     var fs = require('fs');
    #     var async = require('async');
    #   '''
    #   parser
    #   errors: [
    #     ruleId: 'order'
    #     message: '`fs` import should occur before import of `async`'
    #   ]
    # }
    # )
    # Option alphabetize: {order: 'asc'}
    test
      code: '''
        import b from 'bar'
        import c from 'Bar'
        import a from 'foo'

        import index from './'
      '''
      output: '''
        import c from 'Bar'
        import b from 'bar'
        import a from 'foo'

        import index from './'
      '''
      options: [
        groups: ['external', 'index']
        alphabetize: order: 'asc'
      ]
      errors: [
        ruleID: 'order'
        message: '`Bar` import should occur before import of `bar`'
      ]
    # Option alphabetize: {order: 'desc'}
    test
      code: '''
        import a from 'foo'
        import c from 'Bar'
        import b from 'bar'

        import index from './'
      '''
      output: '''
        import a from 'foo'
        import b from 'bar'
        import c from 'Bar'

        import index from './'
      '''
      options: [
        groups: ['external', 'index']
        alphabetize: order: 'desc'
      ]
      errors: [
        ruleID: 'order'
        message: '`bar` import should occur before import of `Bar`'
      ]
  ].filter (t) -> !!t
