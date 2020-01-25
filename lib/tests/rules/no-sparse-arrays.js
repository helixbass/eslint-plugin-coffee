// Generated by CoffeeScript 2.5.0
(function() {
  /**
   * @fileoverview Disallow sparse arrays
   * @author Nicholas C. Zakas
   */
  'use strict';
  var RuleTester, path, rule, ruleTester;

  //------------------------------------------------------------------------------
  // Requirements
  //------------------------------------------------------------------------------
  rule = require('eslint/lib/rules/no-sparse-arrays');

  ({RuleTester} = require('eslint'));

  path = require('path');

  //------------------------------------------------------------------------------
  // Tests
  //------------------------------------------------------------------------------
  ruleTester = new RuleTester({
    parser: path.join(__dirname, '../../..')
  });

  ruleTester.run('no-sparse-arrays', rule, {
    valid: ['a = [ 1, 2, ]'],
    invalid: [
      {
        code: 'a = [,]',
        errors: [
          {
            message: 'Unexpected comma in middle of array.',
            type: 'ArrayExpression'
          }
        ]
      },
      {
        code: 'a = [ 1,, 2]',
        errors: [
          {
            message: 'Unexpected comma in middle of array.',
            type: 'ArrayExpression'
          }
        ]
      }
    ]
  });

}).call(this);