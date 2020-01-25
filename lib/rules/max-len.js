// Generated by CoffeeScript 2.5.0
(function() {
  /**
   * @fileoverview Rule to check for max length on a line.
   * @author Matt DuVall <http://www.mattduvall.com>
   */
  'use strict';
  var OPTIONS_OR_INTEGER_SCHEMA, OPTIONS_SCHEMA, isString;

  ({isString} = require('lodash'));

  //------------------------------------------------------------------------------
  // Constants
  //------------------------------------------------------------------------------
  OPTIONS_SCHEMA = {
    type: 'object',
    properties: {
      code: {
        type: 'integer',
        minimum: 0
      },
      comments: {
        type: 'integer',
        minimum: 0
      },
      tabWidth: {
        type: 'integer',
        minimum: 0
      },
      ignorePattern: {
        type: 'string'
      },
      ignoreComments: {
        type: 'boolean'
      },
      ignoreStrings: {
        type: 'boolean'
      },
      ignoreUrls: {
        type: 'boolean'
      },
      ignoreTemplateLiterals: {
        type: 'boolean'
      },
      ignoreRegExpLiterals: {
        type: 'boolean'
      },
      ignoreTrailingComments: {
        type: 'boolean'
      }
    },
    additionalProperties: false
  };

  OPTIONS_OR_INTEGER_SCHEMA = {
    anyOf: [
      OPTIONS_SCHEMA,
      {
        type: 'integer',
        minimum: 0
      }
    ]
  };

  //------------------------------------------------------------------------------
  // Rule Definition
  //------------------------------------------------------------------------------
  module.exports = {
    meta: {
      docs: {
        description: 'enforce a maximum line length',
        category: 'Stylistic Issues',
        recommended: false,
        url: 'https://eslint.org/docs/rules/max-len'
      },
      schema: [OPTIONS_OR_INTEGER_SCHEMA, OPTIONS_OR_INTEGER_SCHEMA, OPTIONS_SCHEMA]
    },
    create: function(context) {
      /*
       * Inspired by http://tools.ietf.org/html/rfc3986#appendix-B, however:
       * - They're matching an entire string that we know is a URI
       * - We're matching part of a string where we think there *might* be a URL
       * - We're only concerned about URLs, as picking out any URI would cause
       *   too many false positives
       * - We don't care about matching the entire URL, any small segment is fine
       */
      /**
       * Check the program for max length
       * @param {ASTNode} node Node to examine
       * @returns {void}
       * @private
       */
      /**
       * Computes the length of a line that may contain tabs. The width of each
       * tab will be the number of spaces to the next tab stop.
       * @param {string} line The line.
       * @param {int} tabWidth The width of each tab stop in spaces.
       * @returns {int} The computed line length.
       * @private
       */
      /**
       * Ensure that an array exists at [key] on `object`, and add `value` to it.
       *
       * @param {Object} object the object to mutate
       * @param {string} key the object's key
       * @param {*} value the value to add
       * @returns {void}
       * @private
       */
      /**
       * Retrieves an array containing all RegExp literals in the source code.
       *
       * @returns {ASTNode[]} An array of RegExp literal nodes.
       */
      /**
       * Retrieves an array containing all strings (" or ') in the source code.
       *
       * @returns {ASTNode[]} An array of string nodes.
       */
      /**
       * Retrieves an array containing all template literals in the source code.
       *
       * @returns {ASTNode[]} An array of template literal nodes.
       */
      /**
       * A reducer to group an AST node by line number, both start and end.
       *
       * @param {Object} acc the accumulator
       * @param {ASTNode} node the AST node in question
       * @returns {Object} the modified accumulator
       * @private
       */
      /**
       * Tells if a comment encompasses the entire line.
       * @param {string} line The source line with a trailing comment
       * @param {number} lineNumber The one-indexed line number this is on
       * @param {ASTNode} comment The comment to remove
       * @returns {boolean} If the comment covers the entire line
       */
      /**
       * Gets the line after the comment and any remaining trailing whitespace is
       * stripped.
       * @param {string} line The source line with a trailing comment
       * @param {ASTNode} comment The comment to remove
       * @returns {string} Line without comment and trailing whitepace
       */
      var URL_REGEXP, allStringLiterals, allTemplateLiterals, checkProgramForMaxLength, computeLineLength, ensureArrayAndPush, getAllRegExpLiterals, getAllStrings, getAllTemplateLiterals, groupByLineNumber, ignoreComments, ignorePattern, ignoreRegExpLiterals, ignoreStrings, ignoreTemplateLiterals, ignoreTrailingComments, ignoreUrls, isFullLineComment, isTrailingComment, lastOption, maxCommentLength, maxLength, options, sourceCode, stripTrailingComment, tabWidth;
      URL_REGEXP = /[^:\/?#]:\/\/[^?#]/;
      sourceCode = context.getSourceCode();
      computeLineLength = function(line, tabWidth) {
        var extraCharacterCount;
        extraCharacterCount = 0;
        line.replace(/\t/g, function(match, offset) {
          var previousTabStopOffset, spaceCount, totalOffset;
          totalOffset = offset + extraCharacterCount;
          previousTabStopOffset = tabWidth ? totalOffset % tabWidth : 0;
          spaceCount = tabWidth - previousTabStopOffset;
          return extraCharacterCount += spaceCount - 1; // -1 for the replaced tab
        });
        return Array.from(line).length + extraCharacterCount;
      };
      // The options object must be the last option specified…
      lastOption = context.options[context.options.length - 1];
      options = typeof lastOption === 'object' ? Object.create(lastOption) : {};
      // …but max code length…
      if (typeof context.options[0] === 'number') {
        options.code = context.options[0];
      }
      // …and tabWidth can be optionally specified directly as integers.
      if (typeof context.options[1] === 'number') {
        options.tabWidth = context.options[1];
      }
      maxLength = options.code || 80;
      tabWidth = options.tabWidth || 4;
      ignoreComments = options.ignoreComments || false;
      ignoreStrings = options.ignoreStrings || false;
      ignoreTemplateLiterals = options.ignoreTemplateLiterals || false;
      ignoreRegExpLiterals = options.ignoreRegExpLiterals || false;
      ignoreTrailingComments = options.ignoreTrailingComments || options.ignoreComments || false;
      ignoreUrls = options.ignoreUrls || false;
      maxCommentLength = options.comments;
      ignorePattern = options.ignorePattern || null;
      if (ignorePattern) {
        ignorePattern = new RegExp(ignorePattern);
      }
      //--------------------------------------------------------------------------
      // Helpers
      //--------------------------------------------------------------------------
      /**
       * Tells if a given comment is trailing: it starts on the current line and
       * extends to or past the end of the current line.
       * @param {string} line The source line we want to check for a trailing comment on
       * @param {number} lineNumber The one-indexed line number for line
       * @param {ASTNode} comment The comment to inspect
       * @returns {boolean} If the comment is trailing on the given line
       */
      isTrailingComment = function(line, lineNumber, comment) {
        return comment && (comment.loc.start.line === lineNumber && lineNumber <= comment.loc.end.line) && (comment.loc.end.line > lineNumber || comment.loc.end.column === line.length);
      };
      isFullLineComment = function(line, lineNumber, comment) {
        var end, isFirstTokenOnLine, start;
        ({start, end} = comment.loc);
        isFirstTokenOnLine = !line.slice(0, comment.loc.start.column).trim();
        return (start.line < lineNumber || (start.line === lineNumber && isFirstTokenOnLine)) && (end.line > lineNumber || (end.line === lineNumber && end.column === line.length));
      };
      stripTrailingComment = function(line, comment) {
        // loc.column is zero-indexed
        return line.slice(0, comment.loc.start.column).replace(/\s+$/, '');
      };
      ensureArrayAndPush = function(object, key, value) {
        if (!Array.isArray(object[key])) {
          object[key] = [];
        }
        return object[key].push(value);
      };
      allStringLiterals = [];
      getAllStrings = function() {
        // sourceCode.ast.tokens.filter (token) ->
        //   token.type is 'String' or
        //   (token.type is 'JSXText' and
        //     sourceCode.getNodeByRangeIndex(token.range[0] - 1).type is
        //       'JSXAttribute')
        return allStringLiterals;
      };
      allTemplateLiterals = [];
      getAllTemplateLiterals = function() {
        // sourceCode.ast.tokens.filter (token) -> token.type is 'Template'
        return allTemplateLiterals;
      };
      getAllRegExpLiterals = function() {
        return sourceCode.ast.tokens.filter(function(token) {
          return token.type === 'RegularExpression';
        });
      };
      groupByLineNumber = function(acc, node) {
        var i;
        i = node.loc.start.line;
        while (i <= node.loc.end.line) {
          ensureArrayAndPush(acc, i, node);
          ++i;
        }
        return acc;
      };
      checkProgramForMaxLength = function(node) {
        var comments, commentsIndex, lines, regExpLiterals, regExpLiteralsByLine, strings, stringsByLine, templateLiterals, templateLiteralsByLine;
        // split (honors line-ending)
        ({lines} = sourceCode);
        // list of comments to ignore
        comments = ignoreComments || maxCommentLength || ignoreTrailingComments ? sourceCode.getAllComments() : [];
        // we iterate over comments in parallel with the lines
        commentsIndex = 0;
        strings = getAllStrings();
        stringsByLine = strings.reduce(groupByLineNumber, {});
        templateLiterals = getAllTemplateLiterals();
        templateLiteralsByLine = templateLiterals.reduce(groupByLineNumber, {});
        regExpLiterals = getAllRegExpLiterals();
        regExpLiteralsByLine = regExpLiterals.reduce(groupByLineNumber, {});
        return lines.forEach(function(line, i) {
          /*
           * if we're checking comment length; we need to know whether this
           * line is a comment
           */
          var comment, commentLengthApplies, lineIsComment, lineLength, lineNumber, textToMeasure;
          // i is zero-indexed, line numbers are one-indexed
          lineNumber = i + 1;
          lineIsComment = false;
          /*
           * We can short-circuit the comment checks if we're already out of
           * comments to check.
           */
          if (commentsIndex < comments.length) {
            // iterate over comments until we find one past the current line
            while ((comment = comments[++commentsIndex]) && comment.loc.start.line <= lineNumber) {}
            // and step back by one
            // eslint-disable-line no-empty
            comment = comments[--commentsIndex];
            if (isFullLineComment(line, lineNumber, comment)) {
              lineIsComment = true;
              textToMeasure = line;
            } else if (ignoreTrailingComments && isTrailingComment(line, lineNumber, comment)) {
              textToMeasure = stripTrailingComment(line, comment);
            } else {
              textToMeasure = line;
            }
          } else {
            textToMeasure = line;
          }
          // ignore this line
          if ((ignorePattern != null ? ignorePattern.test(textToMeasure) : void 0) || (ignoreUrls && URL_REGEXP.test(textToMeasure)) || (ignoreStrings && stringsByLine[lineNumber]) || (ignoreTemplateLiterals && templateLiteralsByLine[lineNumber]) || (ignoreRegExpLiterals && regExpLiteralsByLine[lineNumber])) {
            return;
          }
          lineLength = computeLineLength(textToMeasure, tabWidth);
          commentLengthApplies = lineIsComment && maxCommentLength;
          if (lineIsComment && ignoreComments) {
            return;
          }
          if (commentLengthApplies) {
            if (lineLength > maxCommentLength) {
              return context.report({
                node,
                loc: {
                  line: lineNumber,
                  column: 0
                },
                message: 'Line {{lineNumber}} exceeds the maximum comment line length of {{maxCommentLength}}.',
                data: {
                  lineNumber: i + 1,
                  maxCommentLength
                }
              });
            }
          } else if (lineLength > maxLength) {
            return context.report({
              node,
              loc: {
                line: lineNumber,
                column: 0
              },
              message: 'Line {{lineNumber}} exceeds the maximum line length of {{maxLength}}.',
              data: {
                lineNumber: i + 1,
                maxLength
              }
            });
          }
        });
      };
      return {
        //--------------------------------------------------------------------------
        // Public API
        //--------------------------------------------------------------------------
        TemplateLiteral: function(node) {
          return allTemplateLiterals.push(node);
        },
        Literal: function(node) {
          if (isString(node.value) && node.parent.type !== 'JSXElement') {
            return allStringLiterals.push(node);
          }
        },
        'Program:exit': checkProgramForMaxLength
      };
    }
  };

}).call(this);