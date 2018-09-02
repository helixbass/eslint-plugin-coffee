// Generated by CoffeeScript 2.3.1
(function() {
  /**
   * @fileoverview Disallow the use of process.exit()
   * @author Nicholas C. Zakas
   */
  'use strict';
  var RuleTester, rule, ruleTester;

  //------------------------------------------------------------------------------
  // Requirements
  //------------------------------------------------------------------------------
  rule = require('eslint/lib/rules/no-process-exit');

  ({RuleTester} = require('eslint'));

  //------------------------------------------------------------------------------
  // Tests
  //------------------------------------------------------------------------------
  ruleTester = new RuleTester({
    parser: '../../..'
  });

  ruleTester.run('no-process-exit', rule, {
    valid: ['Process.exit()', 'exit = process.exit', 'f(process.exit)'],
    invalid: [
      {
        code: 'process.exit(0)',
        errors: [
          {
            message: "Don't use process.exit(); throw an error instead.",
            type: 'CallExpression'
          }
        ]
      },
      {
        code: 'process.exit(1)',
        errors: [
          {
            message: "Don't use process.exit(); throw an error instead.",
            type: 'CallExpression'
          }
        ]
      },
      {
        code: 'f(process.exit(1))',
        errors: [
          {
            message: "Don't use process.exit(); throw an error instead.",
            type: 'CallExpression'
          }
        ]
      }
    ]
  });

}).call(this);