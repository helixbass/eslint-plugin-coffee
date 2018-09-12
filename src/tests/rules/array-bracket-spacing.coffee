###*
# @fileoverview Disallows or enforces spaces inside of brackets.
# @author Ian Christian Myers
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

# path = require 'path'
rule = require '../../rules/array-bracket-spacing'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

###*
# Gets the path to the specified parser.
#
# @param {string} name - The parser name to get.
# @returns {string} The path to the specified parser.
###
# parser = (name) ->
#   path.resolve(
#     __dirname
#     "../../fixtures/parsers/array-bracket-spacing/#{name}.js"
#   )

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'array-bracket-spacing', rule,
  valid: [
    code: 'foo = obj[ 1 ]', options: ['always']
  ,
    code: "foo = obj[ 'foo' ]", options: ['always']
  ,
    code: 'foo = obj[ [ 1, 1 ] ]', options: ['always']
  ,
    # always - singleValue
    code: "foo = ['foo']", options: ['always', {singleValue: no}]
  ,
    code: 'foo = [2]', options: ['always', {singleValue: no}]
  ,
    code: 'foo = [[ 1, 1 ]]', options: ['always', {singleValue: no}]
  ,
    code: "foo = [{ 'foo': 'bar' }]"
    options: ['always', {singleValue: no}]
  ,
    code: "foo = [foo: 'bar']"
    options: ['always', {singleValue: no}]
  ,
    code: 'foo = [bar]', options: ['always', {singleValue: no}]
  ,
    # always - objectsInArrays
    code: "foo = [{ 'bar': 'baz' }, 1,  5 ]"
    options: ['always', {objectsInArrays: no}]
  ,
    # always - objectsInArrays
    code: "foo = [ 'bar': 'baz', 1,  5 ]"
    options: ['always', {objectsInArrays: no}]
  ,
    code: "foo = [ 1, 5, { 'bar': 'baz' }]"
    options: ['always', {objectsInArrays: no}]
  ,
    code: """
      foo = [{
        'bar': 'baz', 
        'qux': [{ 'bar': 'baz' }], 
        'quxx': 1 
      }]
    """
    options: ['always', {objectsInArrays: no}]
  ,
    code: "foo = [{ 'bar': 'baz' }]"
    options: ['always', {objectsInArrays: no}]
  ,
    code: "foo = [{ 'bar': 'baz' }, 1, { 'bar': 'baz' }]"
    options: ['always', {objectsInArrays: no}]
  ,
    code: "foo = [ 1, { 'bar': 'baz' }, 5 ]"
    options: ['always', {objectsInArrays: no}]
  ,
    code: "foo = [ 1, { 'bar': 'baz' }, [{ 'bar': 'baz' }] ]"
    options: ['always', {objectsInArrays: no}]
  ,
    code: 'foo = [ (->) ]'
    options: ['always', {objectsInArrays: no}]
  ,
    # always - arraysInArrays
    code: 'arr = [[ 1, 2 ], 2, 3, 4 ]'
    options: ['always', {arraysInArrays: no}]
  ,
    code: 'arr = [[ 1, 2 ], [[[ 1 ]]], 3, 4 ]'
    options: ['always', {arraysInArrays: no}]
  ,
    code: 'foo = [ arr[i], arr[j] ]'
    options: ['always', {arraysInArrays: no}]
  ,
    # always - arraysInArrays, objectsInArrays
    code: "arr = [[ 1, 2 ], 2, 3, { 'foo': 'bar' }]"
    options: ['always', {arraysInArrays: no, objectsInArrays: no}]
  ,
    # always - arraysInArrays, objectsInArrays, singleValue
    code: "arr = [[ 1, 2 ], [2], 3, { 'foo': 'bar' }]"
    options: [
      'always'
    ,
      arraysInArrays: no, objectsInArrays: no, singleValue: no
    ]
  ,
    # always
    code: 'obj[ foo ]', options: ['always']
  ,
    code: "obj[ 'foo' ]", options: ['always']
  ,
    code: "obj[ 'foo' + 'bar' ]", options: ['always']
  ,
    code: 'obj[ obj2[ foo ] ]', options: ['always']
  ,
    code: '''
      obj.map (item) -> return [
        1,
        2,
        3,
        4
      ]
    '''
    options: ['always']
  ,
    code: """
      obj[ 'map' ] (item) -> return [
        1
        2
        3
        4
      ]
    """
    options: ['always']
  ,
    code: """
      obj[ 'for' + 'Each' ] (item) -> return [
        1,
        2,
        3,
        4
      ]
    """
    options: ['always']
  ,
    code: 'arr = [ 1, 2, 3, 4 ]', options: ['always']
  ,
    code: 'arr = [ [ 1, 2 ], 2, 3, 4 ]', options: ['always']
  ,
    code: '''
      arr = [
        1, 2, 3, 4
      ]
    '''
    options: ['always']
  ,
    code: 'foo = []', options: ['always']
  ,
    # singleValue: false, objectsInArrays: true, arraysInArrays
    code: """
      this.db.mappings.insert([
        { alias: 'a', url: 'http://www.amazon.de' },
        { alias: 'g', url: 'http://www.google.de' }
      ], ->)
    """
    options: [
      'always'
    ,
      singleValue: no, objectsInArrays: yes, arraysInArrays: yes
    ]
  ,
    # always - destructuring assignment
    code: '[ x, y ] = z'
    options: ['always']
  ,
    code: '[ x,y ] = z'
    options: ['always']
  ,
    code: '''
      [ x, y
      ] = z
    '''
    options: ['always']
  ,
    code: '''
      [
        x, y ] = z
    '''
    options: ['always']
  ,
    code: '''
      [
        x, y
      ] = z
    '''
    options: ['always']
  ,
    code: '''
      [
        x,,,
      ] = z
    '''
    options: ['always']
  ,
    code: '[ ,x, ] = z'
    options: ['always']
  ,
    code: '''
      [
        x, ...y
      ] = z
    '''
    options: ['always']
  ,
    code: '''
      [
        x, ...y ] = z
    '''
    options: ['always']
  ,
    code: '[[ x, y ], z ] = arr'
    options: ['always', {arraysInArrays: no}]
  ,
    code: '[ x, [ y, z ]] = arr'
    options: ['always', {arraysInArrays: no}]
  ,
    code: '[{ x, y }, z ] = arr'
    options: ['always', {objectsInArrays: no}]
  ,
    code: '[ x, { y, z }] = arr'
    options: ['always', {objectsInArrays: no}]
  ,
    # never
    code: 'obj[foo]', options: ['never']
  ,
    code: "obj['foo']", options: ['never']
  ,
    code: "obj['foo' + 'bar']", options: ['never']
  ,
    code: "obj['foo'+'bar']", options: ['never']
  ,
    code: 'obj[obj2[foo]]', options: ['never']
  ,
    code: '''
      obj.map (item) -> return [
        1,
        2,
        3,
        4
      ]
    '''
    options: ['never']
  ,
    code: """
      obj['map'] (item) -> return [
        1,
        2,
        3,
        4
      ]
    """
    options: ['never']
  ,
    code: """
      obj['for' + 'Each'] (item) -> return [
        1,
        2,
        3,
        4
      ]
    """
    options: ['never']
  ,
    code: 'arr = [1, 2, 3, 4]', options: ['never']
  ,
    code: 'arr = [[1, 2], 2, 3, 4]', options: ['never']
  ,
    code: '''
      arr = [
        1, 2, 3, 4
      ]
    '''
    options: ['never']
  ,
    code: '''
      obj[foo
      ]
    '''
    options: ['never']
  ,
    code: '''
      arr = [1,
        2,
        3,
        4
      ]
    '''
    options: ['never']
  ,
    code: '''
      arr = [
        1
        2
        3
        4
      ]
    '''
    options: ['never']
  ,
    # never - destructuring assignment
    code: '[x, y] = z', options: ['never']
  ,
    code: '[x,y] = z', options: ['never']
  ,
    code: '''
      [x, y
      ] = z
    '''
    options: ['never']
  ,
    code: '''
      [
        x, y] = z
    '''
    options: ['never']
  ,
    code: '''
      [
        x, y
      ] = z
    '''
    options: ['never']
  ,
    code: '''
      [
        x,,,
      ] = z
    '''
    options: ['never']
  ,
    code: '[,x,] = z', options: ['never']
  ,
    code: '''
      [
        x, ...y
      ] = z
    '''
    options: ['never']
  ,
    code: '''
      [
        x, ...y] = z
    '''
    options: ['never']
  ,
    code: '[ [x, y], z] = arr'
    options: ['never', {arraysInArrays: yes}]
  ,
    code: '[x, [y, z] ] = arr'
    options: ['never', {arraysInArrays: yes}]
  ,
    code: '[ { x, y }, z] = arr'
    options: ['never', {objectsInArrays: yes}]
  ,
    code: '[x, { y, z } ] = arr'
    options: ['never', {objectsInArrays: yes}]
  ,
    # never - singleValue
    code: "foo = [ 'foo' ]", options: ['never', {singleValue: yes}]
  ,
    code: 'foo = [ 2 ]', options: ['never', {singleValue: yes}]
  ,
    code: 'foo = [ [1, 1] ]', options: ['never', {singleValue: yes}]
  ,
    code: "foo = [ {'foo': 'bar'} ]"
    options: ['never', {singleValue: yes}]
  ,
    code: 'foo = [ bar ]', options: ['never', {singleValue: yes}]
  ,
    # never - objectsInArrays
    code: "foo = [ {'bar': 'baz'}, 1, 5]"
    options: ['never', {objectsInArrays: yes}]
  ,
    code: "foo = [1, 5, {'bar': 'baz'} ]"
    options: ['never', {objectsInArrays: yes}]
  ,
    code: """
      foo = [ {
        'bar': 'baz', 
        'qux': [ {'bar': 'baz'} ], 
        'quxx': 1 
      } ]
    """
    options: ['never', {objectsInArrays: yes}]
  ,
    code: "foo = [ {'bar': 'baz'} ]"
    options: ['never', {objectsInArrays: yes}]
  ,
    code: "foo = ['bar': 'baz']"
    options: ['never', {objectsInArrays: yes}]
  ,
    code: "foo = [ {'bar': 'baz'}, 1, {'bar': 'baz'} ]"
    options: ['never', {objectsInArrays: yes}]
  ,
    code: "foo = [1, {'bar': 'baz'} , 5]"
    options: ['never', {objectsInArrays: yes}]
  ,
    code: "foo = [1, {'bar': 'baz'}, [ {'bar': 'baz'} ]]"
    options: ['never', {objectsInArrays: yes}]
  ,
    code: 'foo = [(->)]'
    options: ['never', {objectsInArrays: yes}]
  ,
    code: 'foo = []', options: ['never', {objectsInArrays: yes}]
  ,
    # never - arraysInArrays
    code: 'arr = [ [1, 2], 2, 3, 4]'
    options: ['never', {arraysInArrays: yes}]
  ,
    code: 'foo = [arr[i], arr[j]]'
    options: ['never', {arraysInArrays: yes}]
  ,
    code: 'foo = []', options: ['never', {arraysInArrays: yes}]
  ,
    # never - arraysInArrays, singleValue
    code: 'arr = [ [1, 2], [ [ [ 1 ] ] ], 3, 4]'
    options: ['never', {arraysInArrays: yes, singleValue: yes}]
  ,
    # never - arraysInArrays, objectsInArrays
    code: "arr = [ [1, 2], 2, 3, {'foo': 'bar'} ]"
    options: ['never', {arraysInArrays: yes, objectsInArrays: yes}]
  ,
    # should not warn
    code: 'foo = {}', options: ['never']
  ,
    code: 'foo = []', options: ['never']
  ,
    code: "foo = [{'bar':'baz'}, 1, {'bar': 'baz'}]", options: ['never']
  ,
    code: "foo = [{'bar': 'baz'}]", options: ['never']
  ,
    code: """
      foo = [{
        'bar': 'baz', 
        'qux': [{'bar': 'baz'}], 
        'quxx': 1 
      }]
    """
    options: ['never']
  ,
    code: "foo = [1, {'bar': 'baz'}, 5]", options: ['never']
  ,
    code: "foo = [{'bar': 'baz'}, 1,  5]", options: ['never']
  ,
    code: "foo = [1, 5, {'bar': 'baz'}]", options: ['never']
  ,
    code: "obj = {'foo': [1, 2]}", options: ['never']
    # ,
    #   # destructuring with type annotation
    #   code: '([ a, b ]: Array<any>) => {}'
    #   options: ['always']
    #   parserOptions: ecmaVersion: 6
    #   parser: parser 'flow-destructuring-1'
    # ,
    #   code: '([a, b]: Array< any >) => {}'
    #   options: ['never']
    #   parserOptions: ecmaVersion: 6
    #   parser: parser 'flow-destructuring-2'
  ]

  invalid: [
    code: 'foo = [ ]'
    output: 'foo = []'
    options: ['never']
    errors: [
      messageId: 'unexpectedSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayExpression'
      line: 1
      column: 7
    ]
  ,
    # objectsInArrays
    code: "foo = [ { 'bar': 'baz' }, 1,  5]"
    output: "foo = [{ 'bar': 'baz' }, 1,  5 ]"
    options: ['always', {objectsInArrays: no}]
    errors: [
      messageId: 'unexpectedSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayExpression'
      line: 1
      column: 7
    ,
      messageId: 'missingSpaceBefore'
      data:
        tokenValue: ']'
      type: 'ArrayExpression'
      line: 1
      column: 32
    ]
  ,
    code: "foo = [1, 5, { 'bar': 'baz' } ]"
    output: "foo = [ 1, 5, { 'bar': 'baz' }]"
    options: ['always', {objectsInArrays: no}]
    errors: [
      messageId: 'missingSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayExpression'
      line: 1
      column: 7
    ,
      messageId: 'unexpectedSpaceBefore'
      data:
        tokenValue: ']'
      type: 'ArrayExpression'
      line: 1
      column: 31
    ]
  ,
    code: "foo = [ { 'bar':'baz' }, 1, { 'bar': 'baz' } ]"
    output: "foo = [{ 'bar':'baz' }, 1, { 'bar': 'baz' }]"
    options: ['always', {objectsInArrays: no}]
    errors: [
      messageId: 'unexpectedSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayExpression'
      line: 1
      column: 7
    ,
      messageId: 'unexpectedSpaceBefore'
      data:
        tokenValue: ']'
      type: 'ArrayExpression'
      line: 1
      column: 46
    ]
  ,
    # singleValue
    code: "obj = [ 'foo' ]"
    output: "obj = ['foo']"
    options: ['always', {singleValue: no}]
    errors: [
      messageId: 'unexpectedSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayExpression'
      line: 1
      column: 7
    ,
      messageId: 'unexpectedSpaceBefore'
      data:
        tokenValue: ']'
      type: 'ArrayExpression'
      line: 1
      column: 15
    ]
  ,
    code: "obj = ['foo' ]"
    output: "obj = ['foo']"
    options: ['always', {singleValue: no}]
    errors: [
      messageId: 'unexpectedSpaceBefore'
      data:
        tokenValue: ']'
      type: 'ArrayExpression'
      line: 1
      column: 14
    ]
  ,
    code: "obj = ['foo']"
    output: "obj = [ 'foo' ]"
    options: ['never', {singleValue: yes}]
    errors: [
      messageId: 'missingSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayExpression'
      line: 1
      column: 7
    ,
      messageId: 'missingSpaceBefore'
      data:
        tokenValue: ']'
      type: 'ArrayExpression'
      line: 1
      column: 13
    ]
  ,
    # always - arraysInArrays
    code: 'arr = [ [ 1, 2 ], 2, 3, 4 ]'
    output: 'arr = [[ 1, 2 ], 2, 3, 4 ]'
    options: ['always', {arraysInArrays: no}]
    errors: [
      messageId: 'unexpectedSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayExpression'
      line: 1
      column: 7
    ]
  ,
    code: 'arr = [ 1, 2, 2, [ 3, 4 ] ]'
    output: 'arr = [ 1, 2, 2, [ 3, 4 ]]'
    options: ['always', {arraysInArrays: no}]
    errors: [
      messageId: 'unexpectedSpaceBefore'
      data:
        tokenValue: ']'
      type: 'ArrayExpression'
      line: 1
      column: 27
    ]
  ,
    code: 'arr = [[ 1, 2 ], 2, [ 3, 4 ] ]'
    output: 'arr = [[ 1, 2 ], 2, [ 3, 4 ]]'
    options: ['always', {arraysInArrays: no}]
    errors: [
      messageId: 'unexpectedSpaceBefore'
      data:
        tokenValue: ']'
      type: 'ArrayExpression'
      line: 1
      column: 30
    ]
  ,
    code: 'arr = [ [ 1, 2 ], 2, [ 3, 4 ]]'
    output: 'arr = [[ 1, 2 ], 2, [ 3, 4 ]]'
    options: ['always', {arraysInArrays: no}]
    errors: [
      messageId: 'unexpectedSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayExpression'
      line: 1
      column: 7
    ]
  ,
    code: 'arr = [ [ 1, 2 ], 2, [ 3, 4 ] ]'
    output: 'arr = [[ 1, 2 ], 2, [ 3, 4 ]]'
    options: ['always', {arraysInArrays: no}]
    errors: [
      messageId: 'unexpectedSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayExpression'
      line: 1
      column: 7
    ,
      messageId: 'unexpectedSpaceBefore'
      data:
        tokenValue: ']'
      type: 'ArrayExpression'
      line: 1
      column: 31
    ]
  ,
    # always - destructuring
    code: '[x,y] = y'
    output: '[ x,y ] = y'
    options: ['always']
    errors: [
      messageId: 'missingSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayPattern'
      line: 1
      column: 1
    ,
      messageId: 'missingSpaceBefore'
      data:
        tokenValue: ']'
      type: 'ArrayPattern'
      line: 1
      column: 5
    ]
  ,
    code: '[x,y ] = y'
    output: '[ x,y ] = y'
    options: ['always']
    errors: [
      messageId: 'missingSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayPattern'
      line: 1
      column: 1
    ]
  ,
    code: '[,,,x,,] = y'
    output: '[ ,,,x,, ] = y'
    options: ['always']
    errors: [
      messageId: 'missingSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayPattern'
      line: 1
      column: 1
    ,
      messageId: 'missingSpaceBefore'
      data:
        tokenValue: ']'
      type: 'ArrayPattern'
      line: 1
      column: 8
    ]
  ,
    code: '[ ,,,x,,] = y'
    output: '[ ,,,x,, ] = y'
    options: ['always']
    errors: [
      messageId: 'missingSpaceBefore'
      data:
        tokenValue: ']'
      type: 'ArrayPattern'
      line: 1
      column: 9
    ]
  ,
    code: '[...horse] = y'
    output: '[ ...horse ] = y'
    options: ['always']
    errors: [
      messageId: 'missingSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayPattern'
      line: 1
      column: 1
    ,
      messageId: 'missingSpaceBefore'
      data:
        tokenValue: ']'
      type: 'ArrayPattern'
      line: 1
      column: 10
    ]
  ,
    code: '[...horse ] = y'
    output: '[ ...horse ] = y'
    options: ['always']
    errors: [
      messageId: 'missingSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayPattern'
      line: 1
      column: 1
    ]
  ,
    code: '[ [ x, y ], z ] = arr'
    output: '[[ x, y ], z ] = arr'
    options: ['always', {arraysInArrays: no}]
    errors: [
      messageId: 'unexpectedSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayPattern'
      line: 1
      column: 1
    ]
  ,
    code: '[ { x, y }, z ] = arr'
    output: '[{ x, y }, z ] = arr'
    options: ['always', {objectsInArrays: no}]
    errors: [
      messageId: 'unexpectedSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayPattern'
      line: 1
      column: 1
    ]
  ,
    code: '[ x, { y, z } ] = arr'
    output: '[ x, { y, z }] = arr'
    options: ['always', {objectsInArrays: no}]
    errors: [
      messageId: 'unexpectedSpaceBefore'
      data:
        tokenValue: ']'
      type: 'ArrayPattern'
      line: 1
      column: 15
    ]
  ,
    # never -  arraysInArrays
    code: 'arr = [[1, 2], 2, [3, 4]]'
    output: 'arr = [ [1, 2], 2, [3, 4] ]'
    options: ['never', {arraysInArrays: yes}]
    errors: [
      messageId: 'missingSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayExpression'
      line: 1
      column: 7
    ,
      messageId: 'missingSpaceBefore'
      data:
        tokenValue: ']'
      type: 'ArrayExpression'
      line: 1
      column: 25
    ]
  ,
    code: 'arr = [ ]'
    output: 'arr = []'
    options: ['never', {arraysInArrays: yes}]
    errors: [
      messageId: 'unexpectedSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayExpression'
      line: 1
      column: 7
    ]
  ,
    # never -  objectsInArrays
    code: 'arr = [ ]'
    output: 'arr = []'
    options: ['never', {objectsInArrays: yes}]
    errors: [
      messageId: 'unexpectedSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayExpression'
      line: 1
      column: 7
    ]
  ,
    code: 'arr = [ a: b]'
    output: 'arr = [a: b]'
    options: ['never', {objectsInArrays: yes}]
    errors: [
      messageId: 'unexpectedSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayExpression'
      line: 1
      column: 7
    ]
  ,
    # always
    code: 'arr = [1, 2, 3, 4]'
    output: 'arr = [ 1, 2, 3, 4 ]'
    options: ['always']
    errors: [
      messageId: 'missingSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayExpression'
      line: 1
      column: 7
    ,
      messageId: 'missingSpaceBefore'
      data:
        tokenValue: ']'
      type: 'ArrayExpression'
      line: 1
      column: 18
    ]
  ,
    code: 'arr = [1, 2, 3, 4 ]'
    output: 'arr = [ 1, 2, 3, 4 ]'
    options: ['always']
    errors: [
      messageId: 'missingSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayExpression'
      line: 1
      column: 7
    ]
  ,
    code: 'arr = [ 1, 2, 3, 4]'
    output: 'arr = [ 1, 2, 3, 4 ]'
    options: ['always']
    errors: [
      messageId: 'missingSpaceBefore'
      data:
        tokenValue: ']'
      type: 'ArrayExpression'
      line: 1
      column: 19
    ]
  ,
    # never
    code: 'arr = [ 1, 2, 3, 4 ]'
    output: 'arr = [1, 2, 3, 4]'
    options: ['never']
    errors: [
      messageId: 'unexpectedSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayExpression'
      line: 1
      column: 7
    ,
      messageId: 'unexpectedSpaceBefore'
      data:
        tokenValue: ']'
      type: 'ArrayExpression'
      line: 1
      column: 20
    ]
  ,
    code: 'arr = [1, 2, 3, 4 ]'
    output: 'arr = [1, 2, 3, 4]'
    options: ['never']
    errors: [
      messageId: 'unexpectedSpaceBefore'
      data:
        tokenValue: ']'
      type: 'ArrayExpression'
      line: 1
      column: 19
    ]
  ,
    code: 'arr = [ 1, 2, 3, 4]'
    output: 'arr = [1, 2, 3, 4]'
    options: ['never']
    errors: [
      messageId: 'unexpectedSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayExpression'
      line: 1
      column: 7
    ]
  ,
    code: 'arr = [ [ 1], 2, 3, 4]'
    output: 'arr = [[1], 2, 3, 4]'
    options: ['never']
    errors: [
      messageId: 'unexpectedSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayExpression'
      line: 1
      column: 7
    ,
      messageId: 'unexpectedSpaceAfter'
      data:
        tokenValue: '['
      type: 'ArrayExpression'
      line: 1
      column: 9
    ]
  ,
    code: 'arr = [[1 ], 2, 3, 4 ]'
    output: 'arr = [[1], 2, 3, 4]'
    options: ['never']
    errors: [
      messageId: 'unexpectedSpaceBefore'
      data:
        tokenValue: ']'
      type: 'ArrayExpression'
      line: 1
      column: 11
    ,
      messageId: 'unexpectedSpaceBefore'
      data:
        tokenValue: ']'
      type: 'ArrayExpression'
      line: 1
      column: 22
    ]
    # ,
    #   # destructuring with type annotation
    #   code: '([ a, b ]: Array<any>) => {}'
    #   output: '([a, b]: Array<any>) => {}'
    #   options: ['never']
    #   parserOptions:
    #     ecmaVersion: 6
    #   errors: [
    #     messageId: 'unexpectedSpaceAfter'
    #     data:
    #       tokenValue: '['
    #     type: 'ArrayPattern'
    #     line: 1
    #     column: 2
    #   ,
    #     messageId: 'unexpectedSpaceBefore'
    #     data:
    #       tokenValue: ']'
    #     type: 'ArrayPattern'
    #     line: 1
    #     column: 9
    #   ]
    #   parser: parser 'flow-destructuring-1'
    # ,
    #   code: '([a, b]: Array< any >) => {}'
    #   output: '([ a, b ]: Array< any >) => {}'
    #   options: ['always']
    #   parserOptions:
    #     ecmaVersion: 6
    #   errors: [
    #     messageId: 'missingSpaceAfter'
    #     data:
    #       tokenValue: '['
    #     type: 'ArrayPattern'
    #     line: 1
    #     column: 2
    #   ,
    #     messageId: 'missingSpaceBefore'
    #     data:
    #       tokenValue: ']'
    #     type: 'ArrayPattern'
    #     line: 1
    #     column: 7
    #   ]
    #   parser: parser 'flow-destructuring-2'
  ]
