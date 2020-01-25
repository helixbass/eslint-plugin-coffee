// Generated by CoffeeScript 2.5.0
(function() {
  /**
   * @fileoverview Detects color literals
   * @author Aaron Greenwald
   */
  'use strict';
  var Components, StyleSheets, astHelpers, util;

  util = require('util');

  Components = require('../util/react/Components');

  ({StyleSheets, astHelpers} = require('../util/react-native/stylesheet'));

  module.exports = Components.detect(function(context) {
    var checkAssignment, reportColorLiterals, styleSheets;
    styleSheets = new StyleSheets();
    reportColorLiterals = function(colorLiterals) {
      if (colorLiterals) {
        return colorLiterals.forEach(function(style) {
          var expression;
          if (style) {
            expression = util.inspect(style.expression);
            return context.report({
              node: style.node,
              message: 'Color literal: {{expression}}',
              data: {expression}
            });
          }
        });
      }
    };
    checkAssignment = function(node) {
      var styles;
      if (astHelpers.isStyleSheetDeclaration(node)) {
        styles = astHelpers.getStyleDeclarations(node);
        if (styles) {
          return styles.forEach(function(style) {
            var literals;
            literals = astHelpers.collectColorLiterals(style.value, context);
            return styleSheets.addColorLiterals(literals);
          });
        }
      }
    };
    return {
      VariableDeclarator: checkAssignment,
      AssignmentExpression: checkAssignment,
      JSXAttribute: function(node) {
        var literals;
        if (astHelpers.isStyleAttribute(node)) {
          literals = astHelpers.collectColorLiterals(node.value, context);
          return styleSheets.addColorLiterals(literals);
        }
      },
      'Program:exit': function() {
        return reportColorLiterals(styleSheets.getColorLiterals());
      }
    };
  });

  module.exports.schema = [];

}).call(this);