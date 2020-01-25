// Generated by CoffeeScript 2.5.0
(function() {
  /**
   * @fileoverview Rule to enforce spacing around embedded expressions of template strings
   * @author Toru Nagashima
   */
  'use strict';
  var astUtils;

  //------------------------------------------------------------------------------
  // Requirements
  //------------------------------------------------------------------------------
  astUtils = require('../eslint-ast-utils');

  // Rule Definition
  //------------------------------------------------------------------------------
  module.exports = {
    meta: {
      docs: {
        description: 'require or disallow spacing around embedded expressions of template strings',
        category: 'ECMAScript 6',
        recommended: false,
        url: 'https://eslint.org/docs/rules/template-curly-spacing'
      },
      fixable: 'whitespace',
      schema: [
        {
          enum: ['always',
        'never']
        }
      ]
    },
    create: function(context) {
      var always, checkExpression, prefix, sourceCode;
      sourceCode = context.getSourceCode();
      always = context.options[0] === 'always';
      prefix = always ? 'Expected' : 'Unexpected';
      checkExpression = function(node) {
        var closingCurlyToken, firstToken, lastToken, openingCurlyToken;
        firstToken = sourceCode.getFirstToken(node);
        if (firstToken == null) {
          return;
        }
        openingCurlyToken = sourceCode.getTokenBefore(firstToken);
        if ((openingCurlyToken != null ? openingCurlyToken.value : void 0) !== '#{') {
          return;
        }
        if (astUtils.isTokenOnSameLine(openingCurlyToken, firstToken) && sourceCode.isSpaceBetweenTokens(openingCurlyToken, firstToken) !== always) {
          context.report({
            loc: {
              line: openingCurlyToken.loc.end.line,
              column: openingCurlyToken.loc.end.column - 2
            },
            message: '{{prefix}} space(s) after \'#{\'.',
            data: {prefix},
            fix: function(fixer) {
              if (always) {
                return fixer.insertTextAfter(openingCurlyToken, ' ');
              }
              return fixer.removeRange([openingCurlyToken.range[1], firstToken.range[0]]);
            }
          });
        }
        lastToken = sourceCode.getLastToken(node);
        closingCurlyToken = sourceCode.getTokenAfter(lastToken);
        if ((closingCurlyToken != null ? closingCurlyToken.value : void 0) !== '}') {
          return;
        }
        if (astUtils.isTokenOnSameLine(lastToken, closingCurlyToken) && sourceCode.isSpaceBetweenTokens(lastToken, closingCurlyToken) !== always) {
          return context.report({
            loc: closingCurlyToken.loc.start,
            message: "{{prefix}} space(s) before '}'.",
            data: {prefix},
            fix: function(fixer) {
              if (always) {
                return fixer.insertTextBefore(closingCurlyToken, ' ');
              }
              return fixer.removeRange([lastToken.range[1], closingCurlyToken.range[0]]);
            }
          });
        }
      };
      return {
        TemplateLiteral: function(node) {
          var expression, i, len, ref, ref1, results;
          if (!((ref = node.expressions) != null ? ref.length : void 0)) {
            return;
          }
          ref1 = node.expressions;
          results = [];
          for (i = 0, len = ref1.length; i < len; i++) {
            expression = ref1[i];
            results.push(checkExpression(expression));
          }
          return results;
        }
      };
    }
  };

}).call(this);