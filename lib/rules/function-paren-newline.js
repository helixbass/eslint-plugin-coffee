// Generated by CoffeeScript 2.5.0
(function() {
  /**
   * @fileoverview enforce consistent line breaks inside function parentheses
   * @author Teddy Katz
   */
  'use strict';
  var astUtils;

  //------------------------------------------------------------------------------
  // Requirements
  //------------------------------------------------------------------------------
  astUtils = require('../eslint-ast-utils');

  //------------------------------------------------------------------------------
  // Rule Definition
  //------------------------------------------------------------------------------
  module.exports = {
    meta: {
      docs: {
        description: 'enforce consistent line breaks inside function parentheses',
        category: 'Stylistic Issues',
        recommended: false,
        url: 'https://eslint.org/docs/rules/function-paren-newline'
      },
      // fixable: 'whitespace'
      schema: [
        {
          oneOf: [
            {
              enum: ['always',
            'never',
            'consistent',
            'multiline']
            },
            {
              type: 'object',
              properties: {
                minItems: {
                  type: 'integer',
                  minimum: 0
                }
              },
              additionalProperties: false
            }
          ]
        }
      ],
      messages: {
        expectedBefore: "Expected newline before ')'.",
        expectedAfter: "Expected newline after '('.",
        unexpectedBefore: "Unexpected newline before '('.",
        unexpectedAfter: "Unexpected newline after ')'."
      }
    },
    create: function(context) {
      /**
       * Validates the parentheses for a node
       * @param {ASTNode} node The node with parens
       * @returns {void}
       */
      /**
       * Validates a list of arguments or parameters
       * @param {Object} parens An object with keys `leftParen` for the left paren token, and `rightParen` for the right paren token
       * @param {ASTNode[]} elements The arguments or parameters in the list
       * @returns {void}
       */
      var consistentOption, getParenTokens, minItems, multilineOption, rawOption, shouldHaveNewlines, sourceCode, validateNode, validateParens;
      sourceCode = context.getSourceCode();
      rawOption = context.options[0] || 'multiline';
      multilineOption = rawOption === 'multiline';
      consistentOption = rawOption === 'consistent';
      if (typeof rawOption === 'object') {
        ({minItems} = rawOption);
      } else if (rawOption === 'always') {
        minItems = 0;
      } else if (rawOption === 'never') {
        minItems = 2e308;
      } else {
        minItems = null;
      }
      //----------------------------------------------------------------------
      // Helpers
      //----------------------------------------------------------------------
      /**
       * Determines whether there should be newlines inside function parens
       * @param {ASTNode[]} elements The arguments or parameters in the list
       * @param {boolean} hasLeftNewline `true` if the left paren has a newline in the current code.
       * @returns {boolean} `true` if there should be newlines inside the function parens
       */
      shouldHaveNewlines = function(elements, hasLeftNewline) {
        if (multilineOption) {
          return elements.some(function(element, index) {
            return index !== elements.length - 1 && element.loc.end.line !== elements[index + 1].loc.start.line;
          });
        }
        if (consistentOption) {
          return hasLeftNewline;
        }
        return elements.length >= minItems;
      };
      validateParens = function(parens, elements) {
        var hasLeftNewline, hasRightNewline, leftParen, needsNewlines, rightParen, tokenAfterLeftParen, tokenBeforeRightParen;
        ({leftParen, rightParen} = parens);
        if (!(leftParen && rightParen)) {
          return;
        }
        tokenAfterLeftParen = sourceCode.getTokenAfter(leftParen);
        tokenBeforeRightParen = sourceCode.getTokenBefore(rightParen);
        hasLeftNewline = !astUtils.isTokenOnSameLine(leftParen, tokenAfterLeftParen);
        hasRightNewline = !astUtils.isTokenOnSameLine(tokenBeforeRightParen, rightParen);
        needsNewlines = shouldHaveNewlines(elements, hasLeftNewline);
        if (hasLeftNewline && !needsNewlines) {
          context.report({
            node: leftParen,
            messageId: 'unexpectedAfter'
          });
        // fix: (fixer) ->
        //   if sourceCode
        //     .getText()
        //     .slice leftParen.range[1], tokenAfterLeftParen.range[0]
        //     .trim()
        //     # If there is a comment between the ( and the first element, don't do a fix.
        //     null
        //   else
        //     fixer.removeRange [
        //       leftParen.range[1]
        //       tokenAfterLeftParen.range[0]
        //     ]
        } else if (!hasLeftNewline && needsNewlines) {
          context.report({
            node: leftParen,
            messageId: 'expectedAfter'
          });
        }
        // fix: (fixer) -> fixer.insertTextAfter leftParen, '\n'
        if (hasRightNewline && !needsNewlines) {
          return context.report({
            node: rightParen,
            messageId: 'unexpectedBefore'
          });
        // fix: (fixer) ->
        //   if sourceCode
        //     .getText()
        //     .slice tokenBeforeRightParen.range[1], rightParen.range[0]
        //     .trim()
        //     # If there is a comment between the last element and the ), don't do a fix.
        //     null
        //   else
        //     fixer.removeRange [
        //       tokenBeforeRightParen.range[1]
        //       rightParen.range[0]
        //     ]
        } else if (!hasRightNewline && needsNewlines) {
          return context.report({
            node: rightParen,
            messageId: 'expectedBefore'
          });
        }
      };
      // fix: (fixer) -> fixer.insertTextBefore rightParen, '\n'
      /**
       * Gets the left paren and right paren tokens of a node.
       * @param {ASTNode} node The node with parens
       * @returns {Object} An object with keys `leftParen` for the left paren token, and `rightParen` for the right paren token.
       * Can also return `null` if an expression has no parens (e.g. a NewExpression with no arguments, or an ArrowFunctionExpression
       * with a single parameter)
       */
      getParenTokens = function(node) {
        var firstToken, leftParen, rightParen;
        if (node.implicit) {
          return null;
        }
        switch (node.type) {
          case 'NewExpression':
          case 'CallExpression':
            if (node.type === 'NewExpression' && !node.arguments.length && !(astUtils.isOpeningParenToken(sourceCode.getLastToken(node, {
              skip: 1
            })) && astUtils.isClosingParenToken(sourceCode.getLastToken(node)))) {
              // If the NewExpression does not have parens (e.g. `new Foo`), return null.
              return null;
            }
            return {
              leftParen: sourceCode.getTokenAfter(node.callee, astUtils.isOpeningParenToken),
              rightParen: sourceCode.getLastToken(node)
            };
          case 'FunctionDeclaration':
          case 'FunctionExpression':
            leftParen = (function() {
              try {
                return sourceCode.getFirstToken(node, astUtils.isOpeningParenToken);
              } catch (error) {}
            })();
            if (!leftParen) {
              return null;
            }
            rightParen = node.params.length ? sourceCode.getTokenAfter(node.params[node.params.length - 1], astUtils.isClosingParenToken) : sourceCode.getTokenAfter(leftParen);
            return {leftParen, rightParen};
          case 'ArrowFunctionExpression':
            firstToken = sourceCode.getFirstToken(node);
            if (!astUtils.isOpeningParenToken(firstToken)) {
              // If the ArrowFunctionExpression has a single param without parens, return null.
              return null;
            }
            return {
              leftParen: firstToken,
              rightParen: sourceCode.getTokenBefore(node.body, astUtils.isClosingParenToken)
            };
          default:
            throw new TypeError(`unexpected node with type ${node.type}`);
        }
      };
      validateNode = function(node) {
        var parens;
        parens = getParenTokens(node);
        if (parens) {
          return validateParens(parens, astUtils.isFunction(node) ? node.params : node.arguments);
        }
      };
      return {
        //----------------------------------------------------------------------
        // Public
        //----------------------------------------------------------------------
        ArrowFunctionExpression: validateNode,
        CallExpression: validateNode,
        FunctionDeclaration: validateNode,
        FunctionExpression: validateNode,
        NewExpression: validateNode
      };
    }
  };

}).call(this);