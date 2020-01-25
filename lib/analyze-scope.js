// Generated by CoffeeScript 2.5.0
(function() {
  var Definition, OriginalReferencer, Reference, Referencer, ScopeManager, escope;

  escope = require('eslint-scope');

  ({Definition} = require('eslint-scope/lib/definition'));

  OriginalReferencer = require('eslint-scope/lib/referencer');

  Reference = require('eslint-scope/lib/reference');

  // PatternVisitor = require 'eslint-scope/lib/pattern-visitor'
  Referencer = class Referencer extends OriginalReferencer {
    visitClass(node) {
      var ref;
      if ((ref = node.id) != null ? ref.declaration : void 0) {
        this.currentScope().__define(node.id, new Definition('ClassName', node.id, node, null, null, null));
      }
      this.visit(node.superClass);
      this.scopeManager.__nestClassScope(node);
      if (node.id) {
        this.currentScope().__define(node.id, new Definition('ClassName', node.id, node));
        this.visit(node.id);
      }
      this.visit(node.body);
      return this.close(node);
    }

    markDoIifeParamsAsRead(node) {
      var i, len, param, ref, results;
      ref = node.params;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        param = ref[i];
        if (param.type !== 'AssignmentPattern') {
          results.push(this.visit(param));
        }
      }
      return results;
    }

    visitFunction(node) {
      // node.parent.type is 'UnaryExpression' and node.parent.operator is 'do'
      if (node._isDoIife) {
        this.markDoIifeParamsAsRead(node);
      }
      return super.visitFunction(node);
    }

    UnaryExpression(node) {
      var isDoIife;
      isDoIife = node.operator === 'do' && node.argument.type === 'FunctionExpression';
      if (isDoIife) {
        node.argument._isDoIife = true;
      }
      this.visitChildren(node);
      if (isDoIife) {
        return delete node.argument._isDoIife;
      }
    }

    OptionalMemberExpression(node) {
      this.visit(node.object);
      if (node.computed) {
        return this.visit(node.property);
      }
    }

    OptionalCallExpression(node) {
      var callee;
      ({callee} = node);
      if (!this.scopeManager.__ignoreEval() && callee.type === 'Identifier' && callee.name === 'eval') {
        this.currentScope().variableScope.__detectEval();
      }
      return this.visitChildren(node);
    }

    AssignmentExpression(node) {
      // @visit node.left if node.left.type is 'Identifier'
      this.visitPattern(node.left, (identifier) => {
        if (identifier.declaration) {
          return this._createScopeVariable(identifier);
        }
      });
      return super.AssignmentExpression(node);
    }

    For(node) {
      var visitForVariable;
      visitForVariable = (identifier) => {
        if (identifier.declaration) {
          this._createScopeVariable(identifier);
        }
        return this.currentScope().__referencing(identifier, Reference.WRITE, node.source, null, true, true);
      };
      this.visitPattern(node.name, visitForVariable);
      this.visitPattern(node.index, visitForVariable);
      return this.visitChildren(node);
    }

    Identifier(node) {
      if (!node.declaration) {
        return super.Identifier(node);
      }
    }

    // Identifier: (node) ->
    //   dump {node}
    //   @_createScopeVariable node if node.declaration
    //   super node
    _createScopeVariable(node) {
      // TODO: shouldBeStatically() in eslint-scope/lib/scope.js is breaking
      // if a Variable Definition doesn't have a parent
      // so for now passing `node` but don't know what the implications are
      return this.currentScope().variableScope.__define(node, new Definition('Variable', node, node, node, null, null));
    }

    ClassProperty(node) {
      return this.visitProperty(node);
    }

    ClassPrototypeProperty(node) {
      return this.visitProperty(node);
    }

  };

  ScopeManager = class ScopeManager extends escope.ScopeManager {
    // catch variables belong to outer scope in Coffeescript so don't create a
    // separate "catch scope" for the catch variables.
    __nestCatchScope() {
      return this.__currentScope;
    }

  };

  module.exports = function(ast, parserOptions) {
    var options, referencer, scopeManager;
    options = {
      fallback: 'iteration',
      sourceType: ast.sourceType,
      ecmaVersion: parserOptions.ecmaVersion || 2018, // TODO: what should this be? breaks without
      ignoreEval: true
    };
    scopeManager = new ScopeManager(options);
    referencer = new Referencer(options, scopeManager);
    // dump {ast}
    referencer.visit(ast);
    return scopeManager;
  };

  // dump = (obj) ->
//   console.log require('util').inspect obj, no, null

}).call(this);