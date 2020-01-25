// Generated by CoffeeScript 2.5.0
(function() {
  /**
   * @fileoverview Rule to enforce consistent naming of "this" context variables
   * @author Raphael Pigulla
   */
  'use strict';
  var isNullOrUndefined,
    indexOf = [].indexOf;

  ({isNullOrUndefined} = require('../eslint-ast-utils'));

  //------------------------------------------------------------------------------
  // Rule Definition
  //------------------------------------------------------------------------------
  module.exports = {
    meta: {
      docs: {
        description: 'enforce consistent naming when capturing the current execution context',
        category: 'Stylistic Issues',
        recommended: false,
        url: 'https://eslint.org/docs/rules/consistent-this'
      },
      schema: {
        type: 'array',
        items: {
          type: 'string',
          minLength: 1
        },
        uniqueItems: true
      },
      messages: {
        aliasNotAssignedToThis: "Designated alias '{{name}}' is not assigned to 'this'.",
        unexpectedAlias: "Unexpected alias '{{name}}' for 'this'."
      }
    },
    create: function(context) {
      /**
       * Checks that an assignment to an identifier only assigns 'this' to the
       * appropriate alias, and the alias is only assigned to 'this'.
       * @param {ASTNode} node - The assigning node.
       * @param {Identifier} name - The name of the variable assigned to.
       * @param {Expression} value - The value of the assignment.
       * @returns {void}
       */
      /**
       * Ensures that a variable declaration of the alias in a program or function
       * is assigned to the correct value.
       * @param {string} alias alias the check the assignment of.
       * @param {Object} scope scope of the current code we are checking.
       * @private
       * @returns {void}
       */
      /**
       * Check each alias to ensure that is was assinged to the correct value.
       * @returns {void}
       */
      /**
       * Reports that a variable declarator or assignment expression is assigning
       * a non-'this' value to the specified alias.
       * @param {ASTNode} node - The assigning node.
       * @param {string}  name - the name of the alias that was incorrectly used.
       * @returns {void}
       */
      var aliases, checkAssignment, checkWasAssigned, ensureWasAssigned, isNullAssignment, reportBadAssignment;
      aliases = [];
      if (context.options.length === 0) {
        aliases.push('that');
      } else {
        aliases = context.options;
      }
      reportBadAssignment = function(node, name) {
        return context.report({
          node,
          messageId: 'aliasNotAssignedToThis',
          data: {name}
        });
      };
      isNullAssignment = function(node) {
        var currentNode;
        currentNode = node;
        while (currentNode) {
          if (isNullOrUndefined(currentNode)) {
            return true;
          }
          if (currentNode.type !== 'AssignmentExpression') {
            // handle chained null assignment
            return false;
          }
          currentNode = currentNode.right;
        }
      };
      checkAssignment = function(node, name, value) {
        var isNullDeclaration, isThis;
        isThis = value.type === 'ThisExpression';
        isNullDeclaration = node.left.declaration && isNullAssignment(value);
        if (indexOf.call(aliases, name) >= 0) {
          if (!(isThis || isNullDeclaration) || (node.operator && node.operator !== '=')) {
            return reportBadAssignment(node, name);
          }
        } else if (isThis) {
          return context.report({
            node,
            messageId: 'unexpectedAlias',
            data: {name}
          });
        }
      };
      checkWasAssigned = function(alias, scope) {
        var getsAssignedToThis, ref, variable;
        variable = scope.set.get(alias);
        if (!variable) {
          if (!(scope.type === 'global' && ((ref = scope.childScopes[0]) != null ? ref.type : void 0) === 'module')) {
            return;
          }
          return checkWasAssigned(alias, scope.childScopes[0]);
        }
        if (variable.defs.some(function(def) {
          return def.node.type === 'Identifier' && !isNullAssignment(def.node.parent.right);
        })) {
          return;
        }
        /*
         * The alias has been declared and not assigned: check it was
         * assigned later in the same scope.
         */
        // unless variable.references.some((reference) ->
        //   write = reference.writeExpr

        //   reference.from is scope and
        //     write and
        //     write.type is 'ThisExpression' and
        //     write.parent.operator is '='
        // )
        //   variable.defs
        //     .map (def) -> def.node
        //     .forEach (node) -> reportBadAssignment node, alias
        getsAssignedToThis = variable.references.some(function(reference) {
          var write;
          write = reference.writeExpr;
          return reference.from === scope && write && write.type === 'ThisExpression' && write.parent.operator === '=';
        });
        if (!getsAssignedToThis) {
          return variable.defs.map(function(def) {
            return def.node;
          }).forEach(function(node) {
            return reportBadAssignment(node, alias);
          });
        }
      };
      ensureWasAssigned = function() {
        var scope;
        scope = context.getScope();
        return aliases.forEach(function(alias) {
          return checkWasAssigned(alias, scope);
        });
      };
      return {
        'Program:exit': ensureWasAssigned,
        'FunctionExpression:exit': ensureWasAssigned,
        'FunctionDeclaration:exit': ensureWasAssigned,
        VariableDeclarator: function(node) {
          var id, isDestructuring, ref;
          ({id} = node);
          isDestructuring = (ref = id.type) === 'ArrayPattern' || ref === 'ObjectPattern';
          if (node.init !== null && !isDestructuring) {
            return checkAssignment(node, id.name, node.init);
          }
        },
        AssignmentExpression: function(node) {
          if (node.left.type === 'Identifier') {
            return checkAssignment(node, node.left.name, node.right);
          }
        }
      };
    }
  };

}).call(this);