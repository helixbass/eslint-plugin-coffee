// Generated by CoffeeScript 2.5.0
(function() {
  /**
   * @fileoverview Android and IOS components should be
   * used in platform specific React Native components.
   * @author Tom Hastjarjanto
   */
  'use strict';
  module.exports = function(context) {
    var androidMessage, androidPathRegex, conflictMessage, getName, hasNodeWithName, iosMessage, iosPathRegex, reactComponents, ref, ref1, reportErrors;
    reactComponents = [];
    androidMessage = 'Android components should be placed in android files';
    iosMessage = 'IOS components should be placed in ios files';
    conflictMessage = "IOS and Android components can't be mixed";
    iosPathRegex = ((ref = context.options[0]) != null ? ref.iosPathRegex : void 0) ? new RegExp(context.options[0].iosPathRegex) : /\.ios\.js$/;
    androidPathRegex = ((ref1 = context.options[0]) != null ? ref1.androidPathRegex : void 0) ? new RegExp(context.options[0].androidPathRegex) : /\.android\.js$/;
    getName = function(node) {
      var key;
      if (node.type === 'Property') {
        key = node.key || node.argument;
        return (key.type === 'Identifier' ? key.name : key.value);
      }
      if (node.type === 'Identifier') {
        return node.name;
      }
    };
    hasNodeWithName = function(nodes, name) {
      return nodes.some(function(node) {
        var nodeName;
        nodeName = getName(node);
        return nodeName != null ? nodeName.includes(name) : void 0;
      });
    };
    reportErrors = function(components, filename) {
      var containsAndroidAndIOS;
      containsAndroidAndIOS = hasNodeWithName(components, 'IOS') && hasNodeWithName(components, 'Android');
      return components.forEach(function(node) {
        var propName;
        propName = getName(node);
        if (propName.includes('IOS') && !filename.match(iosPathRegex)) {
          context.report(node, containsAndroidAndIOS ? conflictMessage : iosMessage);
        }
        if (propName.includes('Android') && !filename.match(androidPathRegex)) {
          return context.report(node, containsAndroidAndIOS ? conflictMessage : androidMessage);
        }
      });
    };
    return {
      AssignmentExpression: function(node) {
        var destructuring, statelessDestructuring;
        destructuring = node.left.type === 'ObjectPattern';
        statelessDestructuring = destructuring && node.right.name === 'React';
        if (destructuring && statelessDestructuring) {
          return reactComponents = reactComponents.concat(node.left.properties);
        }
      },
      VariableDeclarator: function(node) {
        var destructuring, statelessDestructuring;
        destructuring = node.init && node.id && node.id.type === 'ObjectPattern';
        statelessDestructuring = destructuring && node.init.name === 'React';
        if (destructuring && statelessDestructuring) {
          return reactComponents = reactComponents.concat(node.id.properties);
        }
      },
      ImportDeclaration: function(node) {
        if (node.source.value === 'react-native') {
          return node.specifiers.forEach(function(importSpecifier) {
            if (importSpecifier.type === 'ImportSpecifier') {
              return reactComponents = reactComponents.concat(importSpecifier.imported);
            }
          });
        }
      },
      'Program:exit': function() {
        var filename;
        filename = context.getFilename();
        return reportErrors(reactComponents, filename);
      }
    };
  };

  module.exports.schema = [
    {
      type: 'object',
      properties: {
        androidPathRegex: {
          type: 'string'
        },
        iosPathRegex: {
          type: 'string'
        }
      },
      additionalProperties: false
    }
  ];

}).call(this);