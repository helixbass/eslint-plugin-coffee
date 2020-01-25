// Generated by CoffeeScript 2.5.0
(function() {
  /**
   * @fileoverview enforce or disallow capitalization of the first letter of a comment
   * @author Kevin Partington
   */
  'use strict';
  /*
   * Base schema body for defining the basic capitalization rule, ignorePattern,
   * and ignoreInlineComments values.
   * This can be used in a few different ways in the actual schema.
   */
  /**
   * Creates a regular expression for each ignorePattern defined in the rule
   * options.
   *
   * This is done in order to avoid invoking the RegExp constructor repeatedly.
   *
   * @param {Object} normalizedOptions The normalized rule options.
   * @returns {void}
   */
  /**
   * Get normalized options for block and line comments.
   *
   * @param {Object|string} rawOptions The user-provided options.
   * @returns {Object} An object with "Line" and "Block" keys and corresponding
   * normalized options objects.
   */
  /**
   * Get normalized options for either block or line comments from the given
   * user-provided options.
   * - If the user-provided options is just a string, returns a normalized
   *   set of options using default values for all other options.
   * - If the user-provided options is an object, then a normalized option
   *   set is returned. Options specified in overrides will take priority
   *   over options specified in the main options object, which will in
   *   turn take priority over the rule's defaults.
   *
   * @param {Object|string} rawOptions The user-provided options.
   * @param {string} which Either "line" or "block".
   * @returns {Object} The normalized options.
   */
  var DEFAULTS, DEFAULT_IGNORE_PATTERN, LETTER_PATTERN, MAYBE_URL, SCHEMA_BODY, WHITESPACE, astUtils, createRegExpForIgnorePatterns, getAllNormalizedOptions, getNormalizedOptions;

  //------------------------------------------------------------------------------
  // Requirements
  //------------------------------------------------------------------------------
  LETTER_PATTERN = (function() {
    try {
      return require('eslint/lib/util/patterns/letters');
    } catch (error) {
      return require('eslint/lib/rules/utils/patterns/letters');
    }
  })();

  astUtils = require('../eslint-ast-utils');

  //------------------------------------------------------------------------------
  // Helpers
  //------------------------------------------------------------------------------
  DEFAULT_IGNORE_PATTERN = astUtils.COMMENTS_IGNORE_PATTERN;

  WHITESPACE = /\s/g;

  MAYBE_URL = /^\s*[^:\/?#\s]+:\/\/[^?#]/; // TODO: Combine w/ max-len pattern?

  DEFAULTS = {
    ignorePattern: null,
    ignoreInlineComments: false,
    ignoreConsecutiveComments: false
  };

  SCHEMA_BODY = {
    type: 'object',
    properties: {
      ignorePattern: {
        type: 'string'
      },
      ignoreInlineComments: {
        type: 'boolean'
      },
      ignoreConsecutiveComments: {
        type: 'boolean'
      }
    },
    additionalProperties: false
  };

  getNormalizedOptions = function(rawOptions, which) {
    if (!rawOptions) {
      return {...DEFAULTS};
    }
    return {...DEFAULTS, ...(rawOptions[which] || rawOptions)};
  };

  getAllNormalizedOptions = function(rawOptions) {
    return {
      Line: getNormalizedOptions(rawOptions, 'line'),
      Block: getNormalizedOptions(rawOptions, 'block')
    };
  };

  createRegExpForIgnorePatterns = function(normalizedOptions) {
    return Object.keys(normalizedOptions).forEach(function(key) {
      var ignorePatternStr, regExp;
      ignorePatternStr = normalizedOptions[key].ignorePattern;
      if (ignorePatternStr) {
        regExp = RegExp(`^\\s*(?:${ignorePatternStr})`);
        return normalizedOptions[key].ignorePatternRegExp = regExp;
      }
    });
  };

  //------------------------------------------------------------------------------
  // Rule Definition
  //------------------------------------------------------------------------------
  module.exports = {
    meta: {
      docs: {
        description: 'enforce or disallow capitalization of the first letter of a comment',
        category: 'Stylistic Issues',
        recommended: false,
        url: 'https://eslint.org/docs/rules/capitalized-comments'
      },
      fixable: 'code',
      schema: [
        {
          enum: ['always',
        'never']
        },
        {
          oneOf: [
            SCHEMA_BODY,
            {
              type: 'object',
              properties: {
                line: SCHEMA_BODY,
                block: SCHEMA_BODY
              },
              additionalProperties: false
            }
          ]
        }
      ],
      messages: {
        unexpectedLowercaseComment: 'Comments should not begin with a lowercase character',
        unexpectedUppercaseComment: 'Comments should not begin with an uppercase character'
      }
    },
    create: function(context) {
      /**
       * Check a comment to determine if it is valid for this rule.
       *
       * @param {ASTNode} comment The comment node to process.
       * @param {Object} options The options for checking this comment.
       * @returns {boolean} True if the comment is valid, false otherwise.
       */
      /**
       * Determine if a comment follows another comment.
       *
       * @param {ASTNode} comment The comment to check.
       * @returns {boolean} True if the comment follows a valid comment.
       */
      /**
       * Process a comment to determine if it needs to be reported.
       *
       * @param {ASTNode} comment The comment node to process.
       * @returns {void}
       */
      var capitalize, isCommentValid, isConsecutiveComment, isInlineComment, normalizedOptions, processComment, sourceCode;
      capitalize = context.options[0] || 'always';
      normalizedOptions = getAllNormalizedOptions(context.options[1]);
      sourceCode = context.getSourceCode();
      createRegExpForIgnorePatterns(normalizedOptions);
      //----------------------------------------------------------------------
      // Helpers
      //----------------------------------------------------------------------
      /**
       * Checks whether a comment is an inline comment.
       *
       * For the purpose of this rule, a comment is inline if:
       * 1. The comment is preceded by a token on the same line; and
       * 2. The command is followed by a token on the same line.
       *
       * Note that the comment itself need not be single-line!
       *
       * Also, it follows from this definition that only block comments can
       * be considered as possibly inline. This is because line comments
       * would consume any following tokens on the same line as the comment.
       *
       * @param {ASTNode} comment The comment node to check.
       * @returns {boolean} True if the comment is an inline comment, false
       * otherwise.
       */
      isInlineComment = function(comment) {
        var nextToken, previousToken;
        previousToken = sourceCode.getTokenBefore(comment, {
          includeComments: true
        });
        nextToken = sourceCode.getTokenAfter(comment, {
          includeComments: true
        });
        return Boolean(previousToken && nextToken && comment.loc.start.line === previousToken.loc.end.line && comment.loc.end.line === nextToken.loc.start.line);
      };
      isConsecutiveComment = function(comment) {
        var previousTokenOrComment;
        previousTokenOrComment = sourceCode.getTokenBefore(comment, {
          includeComments: true
        });
        return Boolean(previousTokenOrComment && ['Block', 'Line'].indexOf(previousTokenOrComment.type) !== -1);
      };
      isCommentValid = function(comment, options) {
        var commentWithoutAsterisks, commentWordCharsOnly, firstWordChar, isLowercase, isUppercase, ref;
        if (DEFAULT_IGNORE_PATTERN.test(comment.value)) {
          // 1. Check for default ignore pattern.
          return true;
        }
        // 2. Check for custom ignore pattern.
        commentWithoutAsterisks = comment.value.replace(/\*/g, '');
        if ((ref = options.ignorePatternRegExp) != null ? ref.test(commentWithoutAsterisks) : void 0) {
          return true;
        }
        if (options.ignoreInlineComments && isInlineComment(comment)) {
          // 3. Check for inline comments.
          return true;
        }
        if (options.ignoreConsecutiveComments && isConsecutiveComment(comment)) {
          // 4. Is this a consecutive comment (and are we tolerating those)?
          return true;
        }
        if (MAYBE_URL.test(commentWithoutAsterisks)) {
          // 5. Does the comment start with a possible URL?
          return true;
        }
        // 6. Is the initial word character a letter?
        commentWordCharsOnly = commentWithoutAsterisks.replace(WHITESPACE, '');
        if (commentWordCharsOnly.length === 0) {
          return true;
        }
        firstWordChar = commentWordCharsOnly[0];
        if (!LETTER_PATTERN.test(firstWordChar)) {
          return true;
        }
        // 7. Check the case of the initial word character.
        isUppercase = firstWordChar !== firstWordChar.toLocaleLowerCase();
        isLowercase = firstWordChar !== firstWordChar.toLocaleUpperCase();
        if (capitalize === 'always' && isLowercase) {
          return false;
        }
        if (capitalize === 'never' && isUppercase) {
          return false;
        }
        return true;
      };
      processComment = function(comment) {
        var commentValid, messageId, options;
        options = normalizedOptions[comment.type];
        commentValid = isCommentValid(comment, options);
        if (!commentValid) {
          messageId = capitalize === 'always' ? 'unexpectedLowercaseComment' : 'unexpectedUppercaseComment';
          return context.report({
            node: null, // Intentionally using loc instead
            loc: comment.loc,
            messageId,
            fix: function(fixer) {
              var isBlock, match, offset;
              match = comment.value.match(LETTER_PATTERN);
              isBlock = comment.type.toLowerCase() === 'block';
              offset = (isBlock ? '###' : '#').length;
              // Offset match.index by 2 to account for the first 2 characters that start the comment (// or /*)
              return fixer.replaceTextRange([comment.range[0] + match.index + offset, comment.range[0] + match.index + offset + 1], capitalize === 'always' ? match[0].toLocaleUpperCase() : match[0].toLocaleLowerCase());
            }
          });
        }
      };
      return {
        //----------------------------------------------------------------------
        // Public
        //----------------------------------------------------------------------
        Program: function() {
          var comments;
          comments = sourceCode.getAllComments();
          return comments.filter(function(token) {
            return token.type !== 'Shebang';
          }).forEach(processComment);
        }
      };
    }
  };

}).call(this);