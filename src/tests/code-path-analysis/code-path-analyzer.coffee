###*
# @fileoverview Tests for CodePathAnalyzer.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

assert = require 'assert'
fs = require 'fs'
path = require 'path'
Linter = do ->
  linterModule = require 'eslint/lib/linter'
  linterModule.Linter ? linterModule

EventGeneratorTester = require(
  '../../tools/internal-testers/event-generator-tester'
)
createEmitter =
  try
    require 'eslint/lib/util/safe-emitter'
  catch
    require 'eslint/lib/linter/safe-emitter'
debug = require '../../eslint-code-path-analysis-debug-helpers'
CodePath = require '../../eslint-code-path-analysis-code-path'
CodePathAnalyzer = require '../../eslint-code-path-analysis-code-path-analyzer'
CodePathSegment = require '../../eslint-code-path-analysis-code-path-segment'
NodeEventGenerator =
  try
    require 'eslint/lib/util/node-event-generator'
  catch
    require 'eslint/lib/linter/node-event-generator'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

expectedPatternJS = /\/\*expected\s+((?:.|[\r\n])+?)\s*\*\//g
expectedPattern = /###expected\s+((?:.|[\r\n])+?)\s*###/g
lineEndingPattern = /\r?\n/g
linter = new Linter()

###*
# Extracts the content of `/*expected` comments from a given source code.
# It's expected DOT arrows.
#
# @param {string} source - A source code text.
# @returns {string[]} DOT arrows.
###
getExpectedDotArrows = (source, {isJS}) ->
  regex = if isJS then expectedPatternJS else expectedPattern
  regex.lastIndex = 0

  retv = []

  while (m = regex.exec source) isnt null
    retv.push m[1].replace lineEndingPattern, '\n'

  retv

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

describe 'CodePathAnalyzer', ->
  EventGeneratorTester.testEventGeneratorInterface(
    new CodePathAnalyzer new NodeEventGenerator createEmitter()
  )

  describe 'interface of code paths', ->
    actual = []

    beforeEach ->
      actual ###:### = []
      linter.defineRule 'test', ->
        onCodePathStart: (codePath) -> actual.push codePath
      linter.verify(
        'function foo(a) { if (a) return 0; else throw new Error(); }'
        rules: test: 2
      )

    it 'should have `id` as unique string', ->
      assert typeof actual[0].id is 'string'
      assert typeof actual[1].id is 'string'
      assert actual[0].id isnt actual[1].id

    it 'should have `upper` as CodePath', ->
      assert actual[0].upper is null
      assert actual[1].upper is actual[0]

    it 'should have `childCodePaths` as CodePath[]', ->
      assert Array.isArray actual[0].childCodePaths
      assert Array.isArray actual[1].childCodePaths
      assert actual[0].childCodePaths.length is 1
      assert actual[1].childCodePaths.length is 0
      assert actual[0].childCodePaths[0] is actual[1]

    it 'should have `initialSegment` as CodePathSegment', ->
      assert actual[0].initialSegment instanceof CodePathSegment
      assert actual[1].initialSegment instanceof CodePathSegment
      assert actual[0].initialSegment.prevSegments.length is 0
      assert actual[1].initialSegment.prevSegments.length is 0

    it 'should have `finalSegments` as CodePathSegment[]', ->
      assert Array.isArray actual[0].finalSegments
      assert Array.isArray actual[1].finalSegments
      assert actual[0].finalSegments.length is 1
      assert actual[1].finalSegments.length is 2
      assert actual[0].finalSegments[0].nextSegments.length is 0
      assert actual[1].finalSegments[0].nextSegments.length is 0
      assert actual[1].finalSegments[1].nextSegments.length is 0

      # finalSegments should include returnedSegments and thrownSegments.
      assert actual[0].finalSegments[0] is actual[0].returnedSegments[0]
      assert actual[1].finalSegments[0] is actual[1].returnedSegments[0]
      assert actual[1].finalSegments[1] is actual[1].thrownSegments[0]

    it 'should have `returnedSegments` as CodePathSegment[]', ->
      assert Array.isArray actual[0].returnedSegments
      assert Array.isArray actual[1].returnedSegments
      assert actual[0].returnedSegments.length is 1
      assert actual[1].returnedSegments.length is 1
      assert actual[0].returnedSegments[0] instanceof CodePathSegment
      assert actual[1].returnedSegments[0] instanceof CodePathSegment

    it 'should have `thrownSegments` as CodePathSegment[]', ->
      assert Array.isArray actual[0].thrownSegments
      assert Array.isArray actual[1].thrownSegments
      assert actual[0].thrownSegments.length is 0
      assert actual[1].thrownSegments.length is 1
      assert actual[1].thrownSegments[0] instanceof CodePathSegment

    it 'should have `currentSegments` as CodePathSegment[]', ->
      assert Array.isArray actual[0].currentSegments
      assert Array.isArray actual[1].currentSegments
      assert actual[0].currentSegments.length is 0
      assert actual[1].currentSegments.length is 0

      # there is the current segment in progress.
      linter.defineRule 'test', ->
        codePath = null

        onCodePathStart: (cp) -> codePath = cp
        ReturnStatement: ->
          assert codePath.currentSegments.length is 1
          assert codePath.currentSegments[0] instanceof CodePathSegment
        ThrowStatement: ->
          assert codePath.currentSegments.length is 1
          assert codePath.currentSegments[0] instanceof CodePathSegment
      linter.verify(
        'function foo(a) { if (a) return 0; else throw new Error(); }'
        rules: test: 2
      )

  describe 'interface of code path segments', ->
    actual = []

    beforeEach ->
      actual ###:### = []
      linter.defineRule 'test', ->
        onCodePathSegmentStart: (segment) -> actual.push segment
      linter.verify(
        'function foo(a) { if (a) return 0; else throw new Error(); }'
        rules: test: 2
      )

    it 'should have `id` as unique string', ->
      assert typeof actual[0].id is 'string'
      assert typeof actual[1].id is 'string'
      assert typeof actual[2].id is 'string'
      assert typeof actual[3].id is 'string'
      assert actual[0].id isnt actual[1].id
      assert actual[0].id isnt actual[2].id
      assert actual[0].id isnt actual[3].id
      assert actual[1].id isnt actual[2].id
      assert actual[1].id isnt actual[3].id
      assert actual[2].id isnt actual[3].id

    it 'should have `nextSegments` as CodePathSegment[]', ->
      assert Array.isArray actual[0].nextSegments
      assert Array.isArray actual[1].nextSegments
      assert Array.isArray actual[2].nextSegments
      assert Array.isArray actual[3].nextSegments
      assert actual[0].nextSegments.length is 0
      assert actual[1].nextSegments.length is 2
      assert actual[2].nextSegments.length is 0
      assert actual[3].nextSegments.length is 0
      assert actual[1].nextSegments[0] is actual[2]
      assert actual[1].nextSegments[1] is actual[3]

    it 'should have `allNextSegments` as CodePathSegment[]', ->
      assert Array.isArray actual[0].allNextSegments
      assert Array.isArray actual[1].allNextSegments
      assert Array.isArray actual[2].allNextSegments
      assert Array.isArray actual[3].allNextSegments
      assert actual[0].allNextSegments.length is 0
      assert actual[1].allNextSegments.length is 2
      assert actual[2].allNextSegments.length is 1
      assert actual[3].allNextSegments.length is 1
      assert actual[2].allNextSegments[0].reachable is no
      assert actual[3].allNextSegments[0].reachable is no

    it 'should have `prevSegments` as CodePathSegment[]', ->
      assert Array.isArray actual[0].prevSegments
      assert Array.isArray actual[1].prevSegments
      assert Array.isArray actual[2].prevSegments
      assert Array.isArray actual[3].prevSegments
      assert actual[0].prevSegments.length is 0
      assert actual[1].prevSegments.length is 0
      assert actual[2].prevSegments.length is 1
      assert actual[3].prevSegments.length is 1
      assert actual[2].prevSegments[0] is actual[1]
      assert actual[3].prevSegments[0] is actual[1]

    it 'should have `allPrevSegments` as CodePathSegment[]', ->
      assert Array.isArray actual[0].allPrevSegments
      assert Array.isArray actual[1].allPrevSegments
      assert Array.isArray actual[2].allPrevSegments
      assert Array.isArray actual[3].allPrevSegments
      assert actual[0].allPrevSegments.length is 0
      assert actual[1].allPrevSegments.length is 0
      assert actual[2].allPrevSegments.length is 1
      assert actual[3].allPrevSegments.length is 1

    it 'should have `reachable` as boolean', ->
      assert actual[0].reachable is yes
      assert actual[1].reachable is yes
      assert actual[2].reachable is yes
      assert actual[3].reachable is yes

  describe 'onCodePathStart', ->
    it 'should be fired at the head of programs/functions', ->
      count = 0
      lastCodePathNodeType = null

      linter.defineRule 'test', ->
        onCodePathStart: (cp, node) ->
          count += 1
          lastCodePathNodeType = node.type

          assert cp instanceof CodePath
          if count is 1
            assert node.type is 'Program'
          else if count is 2
            assert node.type is 'FunctionDeclaration'
          else if count is 3
            assert node.type is 'FunctionExpression'
          else if count is 4
            assert node.type is 'ArrowFunctionExpression'
        Program: -> assert lastCodePathNodeType is 'Program'
        FunctionDeclaration: ->
          assert lastCodePathNodeType is 'FunctionDeclaration'
        FunctionExpression: ->
          assert lastCodePathNodeType is 'FunctionExpression'
        ArrowFunctionExpression: ->
          assert lastCodePathNodeType is 'ArrowFunctionExpression'
      linter.verify(
        'foo(); function foo() {} var foo = function() {}; var foo = () => {};'
        rules: {test: 2}, env: es6: yes
      )

      assert count is 4

  describe 'onCodePathEnd', ->
    it 'should be fired at the end of programs/functions', ->
      count = 0
      lastNodeType = null

      linter.defineRule 'test', ->
        onCodePathEnd: (cp, node) ->
          count += 1

          assert cp instanceof CodePath
          if count is 4
            assert node.type is 'Program'
          else if count is 1
            assert node.type is 'FunctionDeclaration'
          else if count is 2
            assert node.type is 'FunctionExpression'
          else if count is 3
            assert node.type is 'ArrowFunctionExpression'
          assert node.type is lastNodeType
        'Program:exit': -> lastNodeType = 'Program'
        'FunctionDeclaration:exit': ->
          lastNodeType ###:### = 'FunctionDeclaration'
        'FunctionExpression:exit': ->
          lastNodeType ###:### = 'FunctionExpression'
        'ArrowFunctionExpression:exit': ->
          lastNodeType ###:### = 'ArrowFunctionExpression'
      linter.verify(
        'foo(); function foo() {} var foo = function() {}; var foo = () => {};'
        rules: {test: 2}, env: es6: yes
      )

      assert count is 4

  describe 'onCodePathSegmentStart', ->
    it 'should be fired at the head of programs/functions for the initial segment', ->
      count = 0
      lastCodePathNodeType = null

      linter.defineRule 'test', ->
        onCodePathSegmentStart: (segment, node) ->
          count += 1
          lastCodePathNodeType = node.type

          assert segment instanceof CodePathSegment
          if count is 1
            assert node.type is 'Program'
          else if count is 2
            assert node.type is 'FunctionDeclaration'
          else if count is 3
            assert node.type is 'FunctionExpression'
          else if count is 4
            assert node.type is 'ArrowFunctionExpression'
        Program: -> assert lastCodePathNodeType is 'Program'
        FunctionDeclaration: ->
          assert lastCodePathNodeType is 'FunctionDeclaration'
        FunctionExpression: ->
          assert lastCodePathNodeType is 'FunctionExpression'
        ArrowFunctionExpression: ->
          assert lastCodePathNodeType is 'ArrowFunctionExpression'
      linter.verify(
        'foo(); function foo() {} var foo = function() {}; var foo = () => {};'
        rules: {test: 2}, env: es6: yes
      )

      assert count is 4

  describe 'onCodePathSegmentEnd', ->
    it 'should be fired at the end of programs/functions for the final segment', ->
      count = 0
      lastNodeType = null

      linter.defineRule 'test', ->
        onCodePathSegmentEnd: (cp, node) ->
          count += 1

          assert cp instanceof CodePathSegment
          if count is 4
            assert node.type is 'Program'
          else if count is 1
            assert node.type is 'FunctionDeclaration'
          else if count is 2
            assert node.type is 'FunctionExpression'
          else if count is 3
            assert node.type is 'ArrowFunctionExpression'
          assert node.type is lastNodeType
        'Program:exit': -> lastNodeType = 'Program'
        'FunctionDeclaration:exit': ->
          lastNodeType ###:### = 'FunctionDeclaration'
        'FunctionExpression:exit': ->
          lastNodeType ###:### = 'FunctionExpression'
        'ArrowFunctionExpression:exit': ->
          lastNodeType ###:### = 'ArrowFunctionExpression'
      linter.verify(
        'foo(); function foo() {} var foo = function() {}; var foo = () => {};'
        rules: {test: 2}, env: es6: yes
      )

      assert count is 4

  describe 'onCodePathSegmentLoop', ->
    it 'should be fired in `while` loops', ->
      count = 0

      linter.defineRule 'test', ->
        onCodePathSegmentLoop: (fromSegment, toSegment, node) ->
          count += 1
          assert fromSegment instanceof CodePathSegment
          assert toSegment instanceof CodePathSegment
          assert node.type is 'WhileStatement'
      linter.verify 'while (a) { foo(); }', rules: test: 2

      assert count is 1

    it 'should be fired in `do-while` loops', ->
      count = 0

      linter.defineRule 'test', ->
        onCodePathSegmentLoop: (fromSegment, toSegment, node) ->
          count += 1
          assert fromSegment instanceof CodePathSegment
          assert toSegment instanceof CodePathSegment
          assert node.type is 'DoWhileStatement'
      linter.verify 'do { foo(); } while (a);', rules: test: 2

      assert count is 1

    it 'should be fired in `for` loops', ->
      count = 0

      linter.defineRule 'test', ->
        onCodePathSegmentLoop: (fromSegment, toSegment, node) ->
          count += 1
          assert fromSegment instanceof CodePathSegment
          assert toSegment instanceof CodePathSegment

          if count is 1
            # connect path: "update" -> "test"
            assert node.parent.type is 'ForStatement'
          else if count is 2
            assert node.type is 'ForStatement'
      linter.verify 'for (var i = 0; i < 10; ++i) { foo(); }', rules: test: 2

      assert count is 2

    it 'should be fired in `for-in` loops', ->
      count = 0

      linter.defineRule 'test', ->
        onCodePathSegmentLoop: (fromSegment, toSegment, node) ->
          count += 1
          assert fromSegment instanceof CodePathSegment
          assert toSegment instanceof CodePathSegment

          if count is 1
            # connect path: "right" -> "left"
            assert node.parent.type is 'ForInStatement'
          else if count is 2
            assert node.type is 'ForInStatement'
      linter.verify 'for (var k in obj) { foo(); }', rules: test: 2

      assert count is 2

    it 'should be fired in `for-of` loops', ->
      count = 0

      linter.defineRule 'test', ->
        onCodePathSegmentLoop: (fromSegment, toSegment, node) ->
          count += 1
          assert fromSegment instanceof CodePathSegment
          assert toSegment instanceof CodePathSegment

          if count is 1
            # connect path: "right" -> "left"
            assert node.parent.type is 'ForOfStatement'
          else if count is 2
            assert node.type is 'ForOfStatement'
      linter.verify 'for (var x of xs) { foo(); }',
        rules: {test: 2}, env: es6: yes

      assert count is 2

  describe 'completed code paths are correct', ->
    testDataDir = path.join(
      __dirname
      '../../../src/tests/fixtures/code-path-analysis/'
    )
    testDataFiles = fs.readdirSync testDataDir

    testDataFiles
    .filter (file) -> /\.(coffee|js)$/.test file
    .forEach (file) ->
      isJS = /\.js$/.test file
      it file, ->
        source = fs.readFileSync path.join(testDataDir, file), encoding: 'utf8'
        expected = getExpectedDotArrows source, {isJS}
        actual = []

        assert expected.length > 0, '/*expected */ comments not found.'

        linter.defineRule 'test', ->
          onCodePathEnd: (codePath) ->
            actual.push debug.makeDotArrows codePath
        messages = linter.verify source, {
          rules: test: 2
          ...(
            if isJS
              env: es6: yes
            # parser: path.join __dirname, '../../..'
            else
              parser:
                filePath: path.join __dirname, '../../..'
                definition: require path.join __dirname, '../../..'
          )
        }

        assert.strictEqual messages.length, 0
        assert.strictEqual(
          actual.length
          expected.length
          'a count of code paths is wrong.'
        )

        i = 0
        while i < actual.length
          assert.strictEqual actual[i], expected[i]
          ++i
