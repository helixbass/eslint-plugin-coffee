// Generated by CoffeeScript 2.5.0
(function() {
  /**
   * @fileoverview Enforce boolean attributes notation in JSX
   * @author Yannick Croissant
   */
  'use strict';
  var ALWAYS, NEVER, docsUrl, errorData, exceptionsSchema, getErrorData, isAlways, isNever;

  docsUrl = require('eslint-plugin-react/lib/util/docsUrl');

  // ------------------------------------------------------------------------------
  // Rule Definition
  // ------------------------------------------------------------------------------
  exceptionsSchema = {
    type: 'array',
    items: {
      type: 'string',
      minLength: 1
    },
    uniqueItems: true
  };

  ALWAYS = 'always';

  NEVER = 'never';

  errorData = new WeakMap();

  getErrorData = function(exceptions) {
    var exceptionProps, exceptionsMessage;
    if (!errorData.has(exceptions)) {
      exceptionProps = Array.from(exceptions, function(name) {
        return `\`${name}\``;
      }).join(', ');
      exceptionsMessage = exceptions.size > 0 ? ` for the following props: ${exceptionProps}` : '';
      errorData.set(exceptions, {exceptionsMessage});
    }
    return errorData.get(exceptions);
  };

  isAlways = function(configuration, exceptions, propName) {
    var isException;
    isException = exceptions.has(propName);
    if (configuration === ALWAYS) {
      return !isException;
    }
    return isException;
  };

  isNever = function(configuration, exceptions, propName) {
    var isException;
    isException = exceptions.has(propName);
    if (configuration === NEVER) {
      return !isException;
    }
    return isException;
  };

  module.exports = {
    meta: {
      docs: {
        description: 'Enforce boolean attributes notation in JSX',
        category: 'Stylistic Issues',
        recommended: false,
        url: docsUrl('jsx-boolean-value')
      },
      fixable: 'code',
      schema: {
        anyOf: [
          {
            type: 'array',
            items: [
              {
                enum: [ALWAYS,
              NEVER]
              }
            ],
            additionalItems: false
          },
          {
            type: 'array',
            items: [
              {
                enum: [ALWAYS]
              },
              {
                type: 'object',
                additionalProperties: false,
                properties: {
                  [NEVER]: exceptionsSchema
                }
              }
            ],
            additionalItems: false
          },
          {
            type: 'array',
            items: [
              {
                enum: [NEVER]
              },
              {
                type: 'object',
                additionalProperties: false,
                properties: {
                  [ALWAYS]: exceptionsSchema
                }
              }
            ],
            additionalItems: false
          }
        ]
      }
    },
    create: function(context) {
      var ALWAYS_MESSAGE, NEVER_MESSAGE, configObject, configuration, exceptions;
      configuration = context.options[0] || NEVER;
      configObject = context.options[1] || {};
      exceptions = new Set((configuration === ALWAYS ? configObject[NEVER] : configObject[ALWAYS]) || []);
      NEVER_MESSAGE = 'Value must be omitted for boolean attributes{{exceptionsMessage}}';
      ALWAYS_MESSAGE = 'Value must be set for boolean attributes{{exceptionsMessage}}';
      return {
        JSXAttribute: function(node) {
          var data, propName, ref, value;
          propName = (ref = node.name) != null ? ref.name : void 0;
          ({value} = node);
          if (isAlways(configuration, exceptions, propName) && value === null) {
            data = getErrorData(exceptions);
            context.report({
              node,
              message: ALWAYS_MESSAGE,
              data,
              fix: function(fixer) {
                return fixer.insertTextAfter(node, '={true}');
              }
            });
          }
          if (isNever(configuration, exceptions, propName) && value && value.type === 'JSXExpressionContainer' && value.expression.value === true) {
            data = getErrorData(exceptions);
            return context.report({
              node,
              message: NEVER_MESSAGE,
              data,
              fix: function(fixer) {
                return fixer.removeRange([node.name.range[1], value.range[1]]);
              }
            });
          }
        }
      };
    }
  };

}).call(this);