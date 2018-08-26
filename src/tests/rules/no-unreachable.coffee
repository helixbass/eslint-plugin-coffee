###*
# @fileoverview Tests for no-unreachable rule.
# @author Joel Feenstra
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/no-unreachable'
{RuleTester} = require 'eslint'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'

ruleTester.run 'no-unreachable', rule,
  valid: [
    '''
      foo = ->
        bar = -> return 1
        return bar()
    '''
    '''
      foo = ->
        x = 1
        y = 2
    '''
    '''
      foo = ->
        x = 1
        y = 2
        return
    '''
    '''
      while (true)
        switch (foo)
          when 1
            x = 1
            x = 2
    '''
    '''
      while (true)
        continue
    '''
    '''
      ->
        x = 1
        if (x)
          return
        x = 2
    '''
    '''
      ->
        x = 1
        if (x)
        else
          return
        x = 2
    '''
    '''
      ->
        x = 1
        switch (x)
          when 0
            break
          else
            return
        x = 2
    '''
    # '''
    #   ->
    #     x = 1
    #     switch (x)
    #       when 0
    #       else
    #         return
    #     x = 2
    # '''
    '''
      ->
        x = 1
        while (x)
          return
        x = 2
    '''
    # '''
    #   ->
    #     x = 1
    #     for x of {}
    #       return
    #     x = 2
    # '''
    '''
      ->
        x = 1
        try
          return
        finally
          x = 2
    '''
    '''
      ->
        x = 1
        loop
          if (x)
            break
        x = 2
    '''
  ]
  invalid: [
    code: '''
      ->
        return x
        x = 1
    '''
    errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
    # ,
    #   code: 'function foo() { return x; var x, y = 1; }'
    #   errors: [message: 'Unreachable code.', type: 'VariableDeclaration']
    # ,
    #   code: 'while (true) { continue; var x = 1; }'
    #   errors: [message: 'Unreachable code.', type: 'VariableDeclaration']
    # ,
    #   code: 'function foo() { return; x = 1; }'
    #   errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
    # ,
    #   code: 'function foo() { throw error; x = 1; }'
    #   errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
    # ,
    #   code: 'while (true) { break; x = 1; }'
    #   errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
    # ,
    #   code: 'while (true) { continue; x = 1; }'
    #   errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
    # ,
    #   code: 'function foo() { switch (foo) { case 1: return; x = 1; } }'
    #   errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
    # ,
    #   code: 'function foo() { switch (foo) { case 1: throw e; x = 1; } }'
    #   errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
    # ,
    #   code: 'while (true) { switch (foo) { case 1: break; x = 1; } }'
    #   errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
    # ,
    #   code: 'while (true) { switch (foo) { case 1: continue; x = 1; } }'
    #   errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
    # ,
    #   code: "var x = 1; throw 'uh oh'; var y = 2;"
    #   errors: [message: 'Unreachable code.', type: 'VariableDeclaration']
    # ,
    #   code:
    #     'function foo() { var x = 1; if (x) { return; } else { throw e; } x = 2; }'
    #   errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
    # ,
    #   code: 'function foo() { var x = 1; if (x) return; else throw -1; x = 2; }'
    #   errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
    # ,
    #   code: 'function foo() { var x = 1; try { return; } finally {} x = 2; }'
    #   errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
    # ,
    #   code: 'function foo() { var x = 1; try { } finally { return; } x = 2; }'
    #   errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
    # ,
    #   code: 'function foo() { var x = 1; do { return; } while (x); x = 2; }'
    #   errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
    # ,
    #   code:
    #     'function foo() { var x = 1; while (x) { if (x) break; else continue; x = 2; } }'
    #   errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
    # ,
    #   code: 'function foo() { var x = 1; for (;;) { if (x) continue; } x = 2; }'
    #   errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
    # ,
    #   code: 'function foo() { var x = 1; while (true) { } x = 2; }'
    #   errors: [message: 'Unreachable code.', type: 'ExpressionStatement']
    # ,

    #   # Merge the warnings of continuous unreachable nodes.
    #   code: "
    #               function foo() {
    #                   return;

    #                   a();  // ← ERROR: Unreachable code. (no-unreachable)

    #                   b()   // ↑ ';' token is included in the unreachable code, so this statement will be merged.
    #                   // comment
    #                   c();  // ↑ ')' token is included in the unreachable code, so this statement will be merged.
    #               }
    #           "
    #   errors: [
    #     message: 'Unreachable code.'
    #     type: 'ExpressionStatement'
    #     line: 5
    #     column: 21
    #     endLine: 9
    #     endColumn: 25
    #   ]
    # ,
    #   code: "
    #               function foo() {
    #                   return;

    #                   a();

    #                   if (b()) {
    #                       c()
    #                   } else {
    #                       d()
    #                   }
    #               }
    #           "
    #   errors: [
    #     message: 'Unreachable code.'
    #     type: 'ExpressionStatement'
    #     line: 5
    #     column: 21
    #     endLine: 11
    #     endColumn: 22
    #   ]
    # ,
    #   code: "
    #               function foo() {
    #                   if (a) {
    #                       return
    #                       b();
    #                       c();
    #                   } else {
    #                       throw err
    #                       d();
    #                   }
    #               }
    #           "
    #   errors: [
    #     message: 'Unreachable code.'
    #     type: 'ExpressionStatement'
    #     line: 5
    #     column: 25
    #     endLine: 6
    #     endColumn: 29
    #   ,
    #     message: 'Unreachable code.'
    #     type: 'ExpressionStatement'
    #     line: 9
    #     column: 25
    #     endLine: 9
    #     endColumn: 29
    #   ]
    # ,
    #   code: "
    #               function foo() {
    #                   if (a) {
    #                       return
    #                       b();
    #                       c();
    #                   } else {
    #                       throw err
    #                       d();
    #                   }
    #                   e();
    #               }
    #           "
    #   errors: [
    #     message: 'Unreachable code.'
    #     type: 'ExpressionStatement'
    #     line: 5
    #     column: 25
    #     endLine: 6
    #     endColumn: 29
    #   ,
    #     message: 'Unreachable code.'
    #     type: 'ExpressionStatement'
    #     line: 9
    #     column: 25
    #     endLine: 9
    #     endColumn: 29
    #   ,
    #     message: 'Unreachable code.'
    #     type: 'ExpressionStatement'
    #     line: 11
    #     column: 21
    #     endLine: 11
    #     endColumn: 25
    #   ]
  ]
