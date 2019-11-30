###*
# @fileoverview Validates JSDoc comments are syntactically correct
# @author Nicholas C. Zakas
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

rule = require '../../rules/valid-jsdoc'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'valid-jsdoc', rule,
  valid: [
    '''
      ###*
      # Description
      # @param {Object[]} screenings Array of screenings.
      # @param {Number} screenings[].timestamp its a time stamp 
       @return {void}
      ###
      foo = ->
    '''
    '''
      ###*
      # Description
       ###
      x = new Foo ->
    '''
    '''
      ###*
      # Description
      # @returns {void} ###
      foo = ->
    '''
    '''
      ###*
      * Description
      * @returns {undefined} ###
      foo = ->
    '''
    '''
      ###*
      * Description
      * @alias Test#test
      * @returns {void} ###
      foo = ->
    '''
    '''
      ###*
      * Description
      *@extends MyClass
      * @returns {void} ###
      foo = ->
    '''
    '''
      ###*
      * Description
      * @constructor ###
      Foo = ->
    '''
    '''
      ###*
      * Description
      * @class ###
      Foo = ->
    '''
    '''
      ###*
      * Description
      * @param {string} p bar
      * @returns {string} desc ###
      foo = (p) ->
    '''
    '''
      ###*
      * Description
      * @arg {string} p bar
      * @returns {string} desc ###
      foo = (p) ->
    '''
    '''
      ###*
      * Description
      * @argument {string} p bar
      * @returns {string} desc ###
      foo = (p) ->
    '''
    '''
      ###*
      * Description
      * @param {string} [p] bar
      * @returns {string} desc ###
      foo = (p) ->
    '''
    '''
      ###*
      * Description
      * @param {Object} p bar
      * @param {string} p.name bar
      * @returns {string} desc ###
      Foo.bar = (p) ->
    '''
    '''
      do ->
        ###*
        * Description
        * @param {string} p bar
        * @returns {string} desc ###
        foo = (p) ->
    '''
    '''
      o =
        ###*
        * Description
        * @param {string} p bar
        * @returns {string} desc ###
        foo: (p) ->
    '''
    '''
      ###*
      * Description
      * @param {Object} p bar
      * @param {string[]} p.files qux
      * @param {Function} cb baz
      * @returns {void} ###
      foo = (p, cb) ->
    '''
    '''
      ###*
      * Description
      * @override ###
      foo = (arg1, arg2) -> ''
    '''
    '''
      ###*
      * Description
      * @inheritdoc ###
      foo = (arg1, arg2) -> ''
    '''
    '''
      ###*
      * Description
      * @inheritDoc ###
      foo = (arg1, arg2) -> ''
    '''
    '''
      ###*
      * Description
      * @Returns {void} ###
      foo = ->
    '''
  ,
    code: '''
      call(
        ###*
         * Doc for a function expression in a call expression.
         * @param {string} argName This is the param description.
         * @return {string} This is the return description.
         ###
        (argName) ->
          return 'the return'
      )
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Create a new thing.
      ###
      thing = new Thing
        foo: ->
          return 'bar'
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Create a new thing.
      ###
      thing = new Thing {
        ###*
         * @return {string} A string.
         ###
        foo: ->
          'bar'
      }
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @return {void} ###
      foo = ->
    '''
    options: [{}]
  ,
    code: '''
      ###*
      * Description
      * @param {string} p bar
      * @returns {f} g
      ###
      Foo.bar = (p) => {}
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @param {string} p bar
      * @returns {f} g
      ###
      Foo.bar = ({p}) ->
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @param {string} p bar
      * @returns {f} g
      ###
      Foo.bar = (p) ->
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @param {string} p mytest
      * @returns {f} g
      ###
      Foo.bar = (p) -> t = -> p
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @param {string} p mytest
      * @returns {f} g
      ###
      Foo.bar = (p) -> func = -> return p
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @param {string} p mytest
      * @returns {f} g
      ###
      Foo.bar = (p) ->
        t = no
        return if t
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @param {string} p mytest
      * @returns {void} ###
      Foo.bar = (p) ->
        t = false
        if t
          return
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @param {string} p mytest
      * @returns {f} g
      ###
      Foo.bar = (p) -> t = -> name = -> return p
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @param {string} p mytest
      * @returns {h} i
      ###
      Foo.bar = (p) -> 
        t = ->
          name = ->
          return name
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @param {string} p
      * @returns {void}###
      Foo.bar = (p) ->
        t = ->
          name = ->
          name
    '''
    options: [requireParamDescription: no]
  ,
    code: '''
      ###*
      * Description
      * @param {string} p mytest
      * @returns {Object}###
      Foo.bar = (p) -> name
    '''
    options: [requireReturnDescription: no]
  ,

  ,
    code: '''
      ###*
       * Description for A.
       ###
      class A
        ###*
         * Description for constructor.
         * @param {object[]} xs - xs
         ###
        constructor: (xs) ->
          ###*
           * Description for this.xs;
           * @type {object[]}
           ###
           @xs = xs.filter (x) => x != null
    '''
  ,
    # options: [requireReturn: no]
    code: '###* @returns {object} foo ### foo = () => bar()'
  ,
    # options: [requireReturn: no]
    code: '###* @returns {object} foo ### foo = () => return bar()'
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Start with caps and end with period.
      * @return {void} ###
      foo = ->
    '''
    options: [matchDescription: '^[A-Z][A-Za-z0-9\\s]*[.]$']
  ,
    code: '''
      ###* Foo 
      @return {void} Foo
       ###
      foo = ->
    '''
    options: [prefer: return: 'return']
  ,
    code: '''
      ###* Foo 
      @return Foo
      ###
      foo = ->
    '''
    options: [requireReturnType: no]
  ,
    code: '''
      ###*
      * Description
      * @param p bar
      * @returns {void}###
      Foo.bar = (p) ->
        t = ->
          name = ->
          name
    '''
    options: [requireParamType: no]
  ,
    code: '''
      ###*
       * A thing interface. 
       * @interface
       ###
      Thing = ->
    '''
  ,
    # options: [requireReturn: yes]
    # classes
    code: '''
      ###*
       * Description for A.
       ###
      class A
        ###*
         * Description for constructor.
         * @param {object[]} xs - xs
         ###
        constructor: (xs) ->
          this.a = xs
    '''
  ,
    # options: [requireReturn: yes]
    code: '''
      ###*
       * Description for A.
       ###
      class A
        ###*
         * Description for method.
         * @param {object[]} xs - xs
         * @returns {f} g
         ###
        print: (xs)  ->
          @a = xs
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
       * Description for A.
       ###
      class A
        ###*
         * Description for constructor.
         * @param {object[]} xs - xs
         * @returns {void}
         ###
        constructor: (xs) ->
          this.a = xs
        ###*
         * Description for method.
         * @param {object[]} xs - xs
         * @returns {void}
         ###
        print: (xs) ->
          this.a = xs
    '''
    options: []
  ,
    code: '''
      ###*
       * Use of this with a 'namepath'.
       * @this some.name
       * @returns {f} g
       ###
      foo = ->
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
       * Use of this with a type expression.
       * @this {some.name}
       * @returns {j} k
       ###
      foo = ->
    '''
  ,
    # options: [requireReturn: no]
    # async function
    code: '''
      ###*
       * An async function. Options requires return.
       * @returns {Promise} that is empty
       ###
      a = -> await b
    '''
  ,
    # options: [requireReturn: yes]
    code: '''
      ###*
       * An async function. Options do not require return.
       * @returns {Promise} that is empty
       ###
      a = -> await b
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
       * An async function. Options do not require return.
       * @returns {h} i
       ###
      a = -> await b
    '''
  ,
    # options: [requireReturn: no]
    # type validations
    code: '''
      ###*
      * Foo
      * @param {Array.<*>} hi - desc
      * @returns {*} returns a node
      ###
      foo = (hi) ->
    '''
    options: [
      preferType:
        String: 'string'
        Astnode: 'ASTNode'
    ]
  ,
    code: '''
      ###*
      * Foo
      * @param {string} hi - desc
      * @returns {ASTNode} returns a node
      ###
      foo = (hi) ->
    '''
    options: [
      preferType:
        String: 'string'
        Astnode: 'ASTNode'
    ]
  ,
    code: '''
      ###*
      * Foo
      * @param {{20:string}} hi - desc
      * @returns {Astnode} returns a node
      ###
      foo = (hi) ->
    '''
    options: [
      preferType:
        String: 'string'
        astnode: 'ASTNode'
    ]
  ,
    code: '''
      ###*
      * Foo
      * @param {{String:foo}} hi - desc
      * @returns {ASTNode} returns a node
      ###
      foo = (hi) ->
    '''
    options: [
      preferType:
        String: 'string'
        astnode: 'ASTNode'
    ]
  ,
    code: '''
      ###*
      * Foo
      * @param {String|number|Test} hi - desc
      * @returns {Astnode} returns a node
      ###
      foo = (hi) ->
    '''
    options: [
      preferType:
        test: 'Test'
    ]
  ,
    code: '''
      ###*
      * Foo
      * @param {Array.<string>} hi - desc
      * @returns {Astnode} returns a node
      ###
      foo = (hi) =>
    '''
    options: [
      preferType:
        String: 'string'
        astnode: 'ASTNode'
    ]
  ,
    code: '''
      ###*
       * Test dash and slash.
       * @extends module:stb/emitter~Emitter
       * @returns {f} g
       ###
      foo = ->
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
       * Test dash and slash.
       * @requires module:config
       * @requires module:modules/notifications
       * @returns {f} g
       ###
      foo = ->
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
       * Foo
       * @module module-name
       * @returns {e} f
       ###
      foo = ->
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
       * Foo
       * @alias module:module-name
       * @returns {b} c
       ###
      foo = ->
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Foo
      * @param {Array.<string>} hi - desc
      * @returns {Array.<string|number>} desc
      ###
      foo = (hi) ->
    '''
    options: [
      preferType:
        String: 'string'
    ]
  ,
    code: '''
      ###*
      * Foo
      * @param {Array.<string|number>} hi - desc
      * @returns {Array.<string>} desc
      ###
      foo = (hi) ->
    '''
    options: [
      preferType:
        String: 'string'
    ]
  ,
    code: '''
      ###*
      * Foo
      * @param {Array.<{id: number, votes: number}>} hi - desc
      * @returns {Array.<{summary: string}>} desc
      ###
      foo = (hi) ->
    '''
    options: [
      preferType:
        Number: 'number'
        String: 'string'
    ]
  ,
    code: '''
      ###*
      * Foo
      * @param {Array.<[string, number]>} hi - desc
      * @returns {Array.<[string, string]>} desc
      ###
      foo = (hi) ->
    '''
    options: [
      preferType:
        Number: 'number'
        String: 'string'
    ]
  ,
    code: '''
      ###*
      * Foo
      * @param {Object<string,Object<string, number>>} hi - because why not
      * @returns {Boolean} desc
      ###
      foo = (hi) ->
    '''
    options: [
      preferType:
        Number: 'number'
        String: 'string'
    ]
  ,
    code: '''
      ###*
      * Description
      * @param {string} a bar
      * @returns {string} desc ###
      foo = (a = 1) ->
    '''
  ,
    code: '''
      ###*
      * Description
      * @param {string} b bar
      * @param {string} a bar
      * @returns {string} desc ###
      foo = (b, a = 1) ->
    '''
  ,
    # abstract
    code: '''
      ###*
      * Description
      * @abstract
      * @returns {Number} desc
      ###
      foo = -> throw new Error 'Not Implemented'
    '''
  ,
    # options: [requireReturn: no]
    # https://github.com/eslint/eslint/issues/9412 - different orders for jsodc tags
    code: '''
      ###*
      * Description
      * @return {Number} desc
      * @constructor
      * @override
      * @abstract
      * @interface
      '* @param {string} hi - desc
      ###
      foo = (hi) -> 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @returns {Number} desc
      * @class
      * @inheritdoc
      * @virtual
      * @interface
      * @param {string} hi - desc
      ###
      foo = (hi) -> return 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @return {Number} desc
      * @constructor 
      * @override
      * @abstract
      * @interface
      * @arg {string} hi - desc
      ###
      foo = (hi) -> 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @returns {Number} desc
      * @class 
      * @inheritdoc
      * @virtual
      * @interface
      * @arg {string} hi - desc
      ###
      foo = (hi) -> 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @return {Number} desc
      * @constructor 
      * @override
      * @abstract
      * @interface
      * @argument {string} hi - desc
      ###
      foo = (hi) -> 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @returns {Number} desc
      * @class 
      * @inheritdoc
      * @virtual
      * @interface
      * @argument {string} hi - desc
      ###
      foo = (hi) -> 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @constructor 
      * @override
      * @abstract
      * @interface
      * @param {string} hi - desc
      * @return {Number} desc
      ###
      foo = (hi) -> 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @class 
      * @inheritdoc
      * @virtual
      * @interface
      * @arg {string} hi - desc
      * @return {Number} desc
      ###
      foo = (hi) -> 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @argument {string} hi - desc
      * @return {Number} desc
      ###
      foo = (hi) -> return 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @constructor 
      * @override
      * @abstract
      * @interface
      * @param {string} hi - desc
      * @returns {Number} desc
      ###
      foo = (hi) -> 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @class 
      * @inheritdoc
      * @virtual
      * @interface
      * @arg {string} hi - desc
      * @returns {Number} desc
      ###
      foo = (hi) -> 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @argument {string} hi - desc
      * @returns {Number} desc
      ###
      foo = (hi) -> return 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @override
      * @abstract
      * @interface
      * @param {string} hi - desc
      * @return {Number} desc
      * @constructor
      ###
      foo = (hi) -> return 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @inheritdoc
      * @virtual
      * @interface
      * @arg {string} hi - desc
      * @returns {Number} desc
      * @constructor
      ###
      foo = (hi) -> 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @argument {string} hi - desc
      * @constructor
      ###
      foo = (hi) ->
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @override
      * @abstract
      * @interface
      * @param {string} hi - desc
      * @return {Number} desc
      * @class
      ###
      foo = (hi) -> 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @inheritdoc
      * @virtual
      * @interface
      * @arg {string} hi - desc
      * @returns {Number} desc
      * @class
      ###
      foo = (hi) -> 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @argument {string} hi - desc
      * @class 
      ###
      foo = (hi) ->
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @abstract
      * @interface
      * @param {string} hi - desc
      * @return {Number} desc
      * @constructor
      * @override
      ###
      foo = (hi) -> 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @virtual
      * @interface
      * @arg {string} hi - desc
      * @returns {Number} desc
      * @class
      * @override
      ###
      foo = (hi) -> 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @argument {string} hi - desc
      * @override
      ###
      foo = (hi) ->
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @abstract
      * @interface
      * @param {string} hi - desc
      * @return {Number} desc
      * @constructor
      * @inheritdoc
      ###
      foo = (hi) -> 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @virtual
      * @interface
      * @arg {string} hi - desc
      * @returns {Number} desc
      * @class
      * @inheritdoc
      ###
      foo = (hi) -> 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @argument {string} hi - desc
      * @inheritdoc
      ###
      foo = (hi) ->
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @interface
      * @param {string} hi - desc
      * @return {Number} desc
      * @constructor
      * @override
      * @abstract
      ###
      foo = (hi) -> 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @interface
      * @arg {string} hi - desc
      * @returns {Number} desc
      * @class
      * @override
      * @abstract
      ###
      foo = (hi) -> 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @argument {string} hi - desc
      * @abstract
      * @returns {ghi} jkl
      ###
      foo = (hi) ->
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @interface
      * @param {string} hi - desc
      * @return {Number} desc
      * @constructor
      * @override
      * @virtual
      ###
      foo = (hi) -> 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @interface
      * @arg {string} hi - desc
      * @returns {Number} desc
      * @class
      * @override
      * @virtual
      ###
      foo = (hi) -> 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @argument {string} hi - desc
      * @virtual
      * @returns {abc} def
      ###
      foo = (hi) ->
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @param {string} hi - desc
      * @return {Number} desc
      * @constructor 
      * @override
      * @abstract
      * @interface
      ###
      foo = (hi) -> 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @arg {string} hi - desc
      * @returns {Number} desc
      * @class
      * @override
      * @virtual
      * @interface
      ###
      foo = (hi) -> 1
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @argument {string} hi - desc
      * @interface
      ###
      foo = (hi) ->
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @virtual
      * @returns {Number} desc
      ###
      foo = -> throw new Error('Not Implemented')
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Description
      * @abstract
      * @returns {Number} desc
      ###
      foo = -> throw new Error('Not Implemented')
    '''
  ,
    # options: [requireReturn: yes]
    code: '''
      ###*
      * Description
      * @abstract
      * @returns {Number} desc
      ###
      foo = ->
    '''
  ,
    # options: [requireReturn: yes]
    code: '''
      ###*
       * @param {string} a - a.
       * @param {object} [obj] - obj.
       * @param {string} obj.b - b.
       * @param {string} obj.c - c.
       * @returns {void}
       ###
      foo = (a, {b, c} = {}) ->
        # empty
    '''
  ,
    code: '''
      ###*
       * @param {string} a - a.
       * @param {any[]} [list] - list.
       * @returns {void}
       ###
      foo = (a, [b, c] = []) ->
        # empty
    '''
  ,
    # https://github.com/eslint/eslint/issues/7184
    '''
      ###*
      * Foo
      * @param {{foo}} hi - desc
      * @returns {ASTNode} returns a node
      ###
      foo = (hi) ->
    '''
    '''
      ###*
      * Foo
      * @param {{foo:String, bar, baz:Array}} hi - desc
      * @returns {ASTNode} returns a node
      ###
      foo = (hi) ->
    '''
  ,
    code: '''
      ###*
      * Foo
      * @param {{String}} hi - desc
      * @returns {ASTNode} returns a node
      ###
      foo = (hi) ->
    '''
    options: [
      preferType:
        String: 'string'
        astnode: 'ASTNode'
    ]
  ,
    code: '''
      ###*
      * Foo
      * @param {{foo:string, astnode:Object, bar}} hi - desc
      * @returns {ASTNode} returns a node
      ###
      foo = (hi) ->
    '''
    options: [
      preferType:
        String: 'string'
        astnode: 'ASTNode'
    ]
  ,
    code: '''
      ###* Foo 
      @return {sdf} jkl
      ###
      foo = ->
    '''
    options: [
      prefer: return: 'return'
      # requireReturn: no
    ]
  ,
    code: '###* @returns {object} foo ### foo = () => bar()'
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Foo
      * @param {string} a desc
      @returns {MyClass} a desc###
      foo = (a) ->
        t = false
        if t
          process(t)
    '''
  ,
    # options: [requireReturn: no]
    code: '''
      ###*
      * Foo
      * @returns {string} something 
      * @param {string} p desc
      ###
      foo = (@p) ->
    '''
  ]

  invalid: [
    code: '''
      call(
        ###*
        # Doc for a function expression in a call expression.
        # @param {string} bogusName This is the param description.
        # @return {string} This is the return description.
        ###
        (argName) ->
          return 'the return'
      )
    '''
    output: null
    # options: [requireReturn: no]
    errors: [
      message: "Expected JSDoc for 'argName' but found 'bogusName'."
      type: 'Block'
      line: 4
      column: 5
      endLine: 4
      endColumn: 61
    ]
  ,
    code: '''
      ###* @@foo ###
      foo = ->
    '''
    output: null
    errors: [
      message: 'JSDoc syntax error.'
      type: 'Block'
    ]
  ,
    code: '''
      ###*
      # Create a new thing.
      ###
      thing = new Thing
        ###*
        # Missing return tag.
        ###
        foo: ->
          'bar'
    '''
    output: null
    # options: [requireReturn: no]
    errors: [
      message: 'Missing JSDoc @returns for function.'
      type: 'Block'
    ]
  ,
    code: '''
      ###* @@returns {void} Foo ###
      foo = ->
    '''
    output: null
    errors: [
      message: 'JSDoc syntax error.'
      type: 'Block'
    ]
  ,
    code: '''
      ###* Foo 
      @returns {void Foo
      ###
      foo = ->
    '''
    output: null
    errors: [
      message: 'JSDoc type missing brace.'
      type: 'Block'
    ]
  ,
    code: '''
      ###* Foo 
      # @return {void} Foo
      ###
      foo = ->
    '''
    output: '''
      ###* Foo 
      # @returns {void} Foo
      ###
      foo = ->
    '''
    options: [prefer: return: 'returns']
    errors: [
      message: 'Use @returns instead.'
      type: 'Block'
      line: 2
      column: 3
      endLine: 2
      endColumn: 10
    ]
  ,
    code: '''
      ###* Foo 
      @argument {int} bar baz
      ###
      foo = (bar) ->
    '''
    output: '''
      ###* Foo 
      @arg {int} bar baz
      ###
      foo = (bar) ->
    '''
    options: [prefer: argument: 'arg']
    errors: [
      message: 'Missing JSDoc @returns for function.'
      type: 'Block'
    ,
      message: 'Use @arg instead.'
      type: 'Block'
      line: 2
      column: 1
      endLine: 2
      endColumn: 10
    ]
  ,
    code: '''
      ###* Foo 
       ###
      foo = ->
    '''
    output: null
    options: [prefer: returns: 'return']
    errors: [
      message: 'Missing JSDoc @return for function.'
      type: 'Block'
    ]
  ,
    code: '''
      ###* Foo 
      @return {void} Foo
       ###
      foo.bar = () => {}
    '''
    output: '''
      ###* Foo 
      @returns {void} Foo
       ###
      foo.bar = () => {}
    '''
    options: [prefer: return: 'returns']
    errors: [
      message: 'Use @returns instead.'
      type: 'Block'
      line: 2
      column: 1
      endLine: 2
      endColumn: 8
    ]
  ,
    code: '''
      ###* Foo 
      @param {void Foo
       ###
      foo = ->
    '''
    output: null
    errors: [
      message: 'JSDoc type missing brace.'
      type: 'Block'
    ]
  ,
    code: '''
      ###* Foo 
      @param {} p Bar
       ###
      foo = ->
    '''
    output: null
    errors: [
      message: 'JSDoc syntax error.'
      type: 'Block'
    ]
  ,
    code: '''
      ###* Foo 
      @param {void Foo ###
      foo = ->
    '''
    output: null
    errors: [
      message: 'JSDoc type missing brace.'
      type: 'Block'
    ]
  ,
    code: '''
      ###* Foo
      * @param p Desc 
      ###
      foo = ->
    '''
    output: null
    errors: [
      message: 'Missing JSDoc @returns for function.'
      type: 'Block'
    ,
      message: "Missing JSDoc parameter type for 'p'."
      type: 'Block'
      line: 2
      column: 3
      endLine: 2
      endColumn: 16
    ]
  ,
    code: '''
      ###*
      * Foo
      * @param {string} p 
      ###
      foo = ->
    '''
    output: null
    errors: [
      message: 'Missing JSDoc @returns for function.'
      type: 'Block'
    ,
      message: "Missing JSDoc parameter description for 'p'."
      type: 'Block'
      line: 3
      column: 3
      endLine: 3
      endColumn: 20
    ]
  ,
    code: '''
      ###*
      * Foo
      * @param {string} p 
      ###
      foo = ->
    '''
    output: null
    errors: [
      message: 'Missing JSDoc @returns for function.'
      type: 'Block'
    ,
      message: "Missing JSDoc parameter description for 'p'."
      type: 'Block'
      line: 3
      column: 3
      endLine: 3
      endColumn: 20
    ]
  ,
    code: '''
      ###*
      * Foo
      * @param {string} p 
      ###
      foo = 
        ->
    '''
    output: null
    errors: [
      message: 'Missing JSDoc @returns for function.'
      type: 'Block'
    ,
      message: "Missing JSDoc parameter description for 'p'."
      type: 'Block'
      line: 3
      column: 3
      endLine: 3
      endColumn: 20
    ]
  ,
    code: '''
      ###*
       * Description for a
       ###
      A = 
        class
          ###*
           * Description for method.
           * @param {object[]} xs - xs
           ###
          print: (xs) ->
            this.a = xs
    '''
    output: null
    options: [
      # requireReturn: yes
      matchDescription: '^[A-Z][A-Za-z0-9\\s]*[.]$'
    ]
    errors: [
      message: 'JSDoc description does not satisfy the regex pattern.'
      type: 'Block'
    ,
      message: 'Missing JSDoc @returns for function.'
      type: 'Block'
    ]
  ,
    code: '''
      ###*
      * Foo
      * @returns {string} 
      ###
      foo = ->
    '''
    output: null
    errors: [
      message: 'Missing JSDoc return description.'
      type: 'Block'
    ]
  ,
    code: '''
      ###*
      * Foo
      * @returns {string} something 
      ###
      foo = (p) ->
    '''
    output: null
    errors: [
      message: "Missing JSDoc for parameter 'p'."
      type: 'Block'
    ]
  ,
    code: '''
      ###*
      * Foo
      * @returns {string} something 
      ###
      foo = (@p) ->
    '''
    output: null
    errors: [
      message: "Missing JSDoc for parameter 'p'."
      type: 'Block'
    ]
  ,
    code: '''
      ###*
      * Foo
      * @returns {string} something 
      ###
      foo = 
        (a = 1) ->
    '''
    output: null
    errors: [
      message: "Missing JSDoc for parameter 'a'."
      type: 'Block'
    ]
  ,
    code: '''
      ###*
      * Foo
      * @param {string} a Description 
      * @param {string} b Description 
      * @returns {string} something 
      ###
      foo = 
        (b, a = 1) ->
    '''
    output: null
    errors: [
      message: "Expected JSDoc for 'b' but found 'a'."
      type: 'Block'
      line: 3
      column: 3
      endLine: 3
      endColumn: 32
    ,
      message: "Expected JSDoc for 'a' but found 'b'."
      type: 'Block'
      line: 4
      column: 3
      endLine: 4
      endColumn: 32
    ]
  ,
    code: '''
      ###*
      * Foo
      * @param {string} p desc
      * @param {string} p desc 
      ###
      foo = ->
    '''
    output: null
    errors: [
      message: 'Missing JSDoc @returns for function.'
      type: 'Block'
    ,
      message: "Duplicate JSDoc parameter 'p'."
      type: 'Block'
      line: 4
      column: 3
      endLine: 4
      endColumn: 25
    ]
  ,
    code: '''
      ###*
      * Foo
      * @param {string} a desc
      @returns {void}###
      foo = (b) ->
    '''
    output: null
    errors: [
      message: "Expected JSDoc for 'b' but found 'a'."
      type: 'Block'
      line: 3
      column: 3
      endLine: 3
      endColumn: 25
    ]
  ,
    code: '''
      ###*
      * Foo
      * @override
      * @param {string} a desc
      ###
      foo = (b) ->
    '''
    output: null
    errors: [
      message: "Expected JSDoc for 'b' but found 'a'."
      type: 'Block'
      line: 4
      column: 3
      endLine: 4
      endColumn: 25
    ]
  ,
    code: '''
      ###*
      * Foo
      * @inheritdoc
      * @param {string} a desc
      ###
      foo = (b) ->
    '''
    output: null
    errors: [
      message: "Expected JSDoc for 'b' but found 'a'."
      type: 'Block'
      line: 4
      column: 3
      endLine: 4
      endColumn: 25
    ]
  ,
    code: '''
      ###*
      * Foo
      * @param {string} a desc
      ###
      foo = (a) ->
        t = false
        if t
          t
    '''
    output: null
    # options: [requireReturn: no]
    errors: [
      message: 'Missing JSDoc @returns for function.'
      type: 'Block'
    ]
  ,
    code: '''
      ###*
      * Foo
      * @param {string} a desc
      ###
      foo = (a) ->
        t = false
        if t then return null
    '''
    output: null
    # options: [requireReturn: no]
    errors: [
      message: 'Missing JSDoc @returns for function.'
      type: 'Block'
    ]
  ,
    code: '''
      ###*
       * Does something. 
      * @param {string} a - this is a 
      * @return {Array<number>} The result of doing it 
      ###
      export doSomething = (a) ->
    '''
    output: '''
      ###*
       * Does something. 
      * @param {string} a - this is a 
      * @returns {Array<number>} The result of doing it 
      ###
      export doSomething = (a) ->
    '''
    options: [prefer: return: 'returns']
    errors: [
      message: 'Use @returns instead.'
      type: 'Block'
      line: 4
      column: 3
      endLine: 4
      endColumn: 10
    ]
  ,
    code: '''
      ###*
      * Does something. 
      * @param {string} a - this is a 
      * @return {Array<number>} The result of doing it 
      ###
      export default doSomething = (a) ->
    '''
    output: '''
      ###*
      * Does something. 
      * @param {string} a - this is a 
      * @returns {Array<number>} The result of doing it 
      ###
      export default doSomething = (a) ->
    '''
    options: [prefer: return: 'returns']
    errors: [
      message: 'Use @returns instead.'
      type: 'Block'
      line: 4
      column: 3
      endLine: 4
      endColumn: 10
    ]
  ,
    code: '###* foo ### foo = () => bar()'
    output: null
    # options: [requireReturn: no]
    errors: [
      message: 'Missing JSDoc @returns for function.'
      type: 'Block'
    ]
  ,
    code: '###* foo ### foo = () => return bar()'
    output: null
    # options: [requireReturn: no]
    errors: [
      message: 'Missing JSDoc @returns for function.'
      type: 'Block'
    ]
  ,
    code: '''
      ###*
      * @param fields [Array]
       ###
      foo = ->
    '''
    output: null
    errors: [
      message: 'Missing JSDoc @returns for function.'
      type: 'Block'
    ,
      message: "Missing JSDoc parameter type for 'fields'."
      type: 'Block'
      line: 2
      column: 3
      endLine: 2
      endColumn: 24
    ]
  ,
    code: '''
      ###*
      * Start with caps and end with period
      * @return {void} ###
      foo = ->
    '''
    output: null
    options: [matchDescription: '^[A-Z][A-Za-z0-9\\s]*[.]$']
    errors: [
      message: 'JSDoc description does not satisfy the regex pattern.'
      type: 'Block'
    ]
  ,
    code: '''
      ###* Foo 
      @return Foo
      ###
      foo = ->
    '''
    output: null
    options: [prefer: return: 'return']
    errors: [
      message: 'Missing JSDoc return type.'
      type: 'Block'
    ]
  ,
    # classes
    code: '''
      ###*
       * Description for A
       ###
      class A
        ###*
         * Description for constructor
         * @param {object[]} xs - xs
         ###
        constructor: (xs) ->
          this.a = xs
    '''
    output: null
    options: [
      # requireReturn: no
      matchDescription: '^[A-Z][A-Za-z0-9\\s]*[.]$'
    ]
    errors: [
      message: 'JSDoc description does not satisfy the regex pattern.'
      type: 'Block'
    ,
      message: 'JSDoc description does not satisfy the regex pattern.'
      type: 'Block'
    ]
  ,
    code: '''
      ###*
       * Description for a
       ###
      A = class
        ###*
         * Description for constructor.
         * @param {object[]} xs - xs
         ###
        print: (xs) ->
          @a = xs
    '''
    output: null
    options: [
      # requireReturn: yes
      matchDescription: '^[A-Z][A-Za-z0-9\\s]*[.]$'
    ]
    errors: [
      message: 'JSDoc description does not satisfy the regex pattern.'
      type: 'Block'
    ,
      message: 'Missing JSDoc @returns for function.'
      type: 'Block'
    ]
  ,
    code: '''
      ###*
       * Description for A.
       ###
      class A
        ###*
         * Description for constructor.
         * @param {object[]} xs - xs
         * @returns {void}
         ###
        constructor: (xs) ->
          this.a = xs
        ###*
         * Description for method.
         ###
        print: (xs) ->
          this.a = xs
    '''
    output: null
    options: []
    errors: [
      message: 'Missing JSDoc @returns for function.'
      type: 'Block'
    ,
      message: "Missing JSDoc for parameter 'xs'."
      type: 'Block'
    ]
  ,
    code: '''
      ###*
       * Use of this with an invalid type expression
       * @this {not.a.valid.type.expression
       ###
      foo = ->
    '''
    output: null
    # options: [requireReturn: no]
    errors: [
      message: 'JSDoc type missing brace.'
      type: 'Block'
    ]
  ,
    code: '''
      ###*
       * Use of this with a type that is not a member expression
       * @this {Array<string>}
       ###
      foo = ->
    '''
    output: null
    # options: [requireReturn: no]
    errors: [
      message: 'JSDoc syntax error.'
      type: 'Block'
    ]
  ,
    # async function
    code: '''
      ###*
       * An async function. Options requires return.
       ###
      a = -> await b
    '''
    output: null
    # options: [requireReturn: yes]
    errors: [
      message: 'Missing JSDoc @returns for function.'
      type: 'Block'
    ]
  ,
    # type validations
    code: '''
      ###*
      * Foo
      * @param {String} hi - desc
      * @returns {Astnode} returns a node
      ###
      foo = (hi) ->
    '''
    output: '''
      ###*
      * Foo
      * @param {string} hi - desc
      * @returns {ASTNode} returns a node
      ###
      foo = (hi) ->
    '''
    options: [
      preferType:
        String: 'string'
        Astnode: 'ASTNode'
    ]
    errors: [
      message: "Use 'string' instead of 'String'."
      type: 'Block'
      line: 3
      column: 11
      endLine: 3
      endColumn: 17
    ,
      message: "Use 'ASTNode' instead of 'Astnode'."
      type: 'Block'
      line: 4
      column: 13
      endLine: 4
      endColumn: 20
    ]
  ,
    code: '''
      ###*
      * Foo
      * @param {{20:String}} hi - desc
      * @returns {Astnode} returns a node
      ###
      foo = (hi) ->
    '''
    output: '''
      ###*
      * Foo
      * @param {{20:string}} hi - desc
      * @returns {ASTNode} returns a node
      ###
      foo = (hi) ->
    '''
    options: [
      preferType:
        String: 'string'
        Astnode: 'ASTNode'
    ]
    errors: [
      message: "Use 'string' instead of 'String'."
      type: 'Block'
      line: 3
      column: 15
      endLine: 3
      endColumn: 21
    ,
      message: "Use 'ASTNode' instead of 'Astnode'."
      type: 'Block'
      line: 4
      column: 13
      endLine: 4
      endColumn: 20
    ]
  ,
    code: '''
      ###*
      * Foo
      * @param {String|number|test} hi - desc
      * @returns {Astnode} returns a node
      ###
      foo = (hi) ->
    '''
    output: '''
      ###*
      * Foo
      * @param {String|number|Test} hi - desc
      * @returns {Astnode} returns a node
      ###
      foo = (hi) ->
    '''
    options: [
      preferType:
        test: 'Test'
    ]
    errors: [
      message: "Use 'Test' instead of 'test'."
      type: 'Block'
      line: 3
      column: 25
      endLine: 3
      endColumn: 29
    ]
  ,
    code: '''
      ###*
      * Foo
      * @param {Array.<String>} hi - desc
      * @returns {Astnode} returns a node
      ###
      foo = (hi) ->
    '''
    output: '''
      ###*
      * Foo
      * @param {Array.<string>} hi - desc
      * @returns {Astnode} returns a node
      ###
      foo = (hi) ->
    '''
    options: [
      preferType:
        String: 'string'
        astnode: 'ASTNode'
    ]
    errors: [
      message: "Use 'string' instead of 'String'."
      type: 'Block'
      line: 3
      column: 18
      endLine: 3
      endColumn: 24
    ]
  ,
    code: '''
      ###*
      * Foo
      * @param {Array.<{id: Number, votes: Number}>} hi - desc
      * @returns {Array.<{summary: String}>} desc
      ###
      foo = (hi) ->
    '''
    output: '''
      ###*
      * Foo
      * @param {Array.<{id: number, votes: number}>} hi - desc
      * @returns {Array.<{summary: string}>} desc
      ###
      foo = (hi) ->
    '''
    options: [
      preferType:
        Number: 'number'
        String: 'string'
    ]
    errors: [
      message: "Use 'number' instead of 'Number'."
      type: 'Block'
      line: 3
      column: 23
      endLine: 3
      endColumn: 29
    ,
      message: "Use 'number' instead of 'Number'."
      type: 'Block'
      line: 3
      column: 38
      endLine: 3
      endColumn: 44
    ,
      message: "Use 'string' instead of 'String'."
      type: 'Block'
      line: 4
      column: 30
      endLine: 4
      endColumn: 36
    ]
  ,
    code: '''
      ###*
      * Foo
      * @param {Array.<[String, Number]>} hi - desc
      * @returns {Array.<[String, String]>} desc
      ###
      foo = (hi) ->
    '''
    output: '''
      ###*
      * Foo
      * @param {Array.<[string, number]>} hi - desc
      * @returns {Array.<[string, string]>} desc
      ###
      foo = (hi) ->
    '''
    options: [
      preferType:
        Number: 'number'
        String: 'string'
    ]
    errors: [
      message: "Use 'string' instead of 'String'."
      type: 'Block'
      line: 3
      column: 19
      endLine: 3
      endColumn: 25
    ,
      message: "Use 'number' instead of 'Number'."
      type: 'Block'
      line: 3
      column: 27
      endLine: 3
      endColumn: 33
    ,
      message: "Use 'string' instead of 'String'."
      type: 'Block'
      line: 4
      column: 21
      endLine: 4
      endColumn: 27
    ,
      message: "Use 'string' instead of 'String'."
      type: 'Block'
      line: 4
      column: 29
      endLine: 4
      endColumn: 35
    ]
  ,
    code: '''
      ###*
      * Foo
      * @param {object<String,object<String, Number>>} hi - because why not
      * @returns {Boolean} desc
      ###
      foo = (hi) ->
    '''
    output: '''
      ###*
      * Foo
      * @param {Object<string,Object<string, number>>} hi - because why not
      * @returns {Boolean} desc
      ###
      foo = (hi) ->
    '''
    options: [
      preferType:
        Number: 'number'
        String: 'string'
        object: 'Object'
    ]
    errors: [
      message: "Use 'Object' instead of 'object'."
      type: 'Block'
      line: 3
      column: 11
      endLine: 3
      endColumn: 17
    ,
      message: "Use 'string' instead of 'String'."
      type: 'Block'
      line: 3
      column: 18
      endLine: 3
      endColumn: 24
    ,
      message: "Use 'Object' instead of 'object'."
      type: 'Block'
      line: 3
      column: 25
      endLine: 3
      endColumn: 31
    ,
      message: "Use 'string' instead of 'String'."
      type: 'Block'
      line: 3
      column: 32
      endLine: 3
      endColumn: 38
    ,
      message: "Use 'number' instead of 'Number'."
      type: 'Block'
      line: 3
      column: 40
      endLine: 3
      endColumn: 46
    ]
  ,
    # https://github.com/eslint/eslint/issues/7184
    code: '''
      ###*
      * Foo
      * @param {{foo:String, astnode:Object, bar}} hi - desc
      * @returns {ASTnode} returns a node
      ###
      foo = (hi) ->
    '''
    output: '''
      ###*
      * Foo
      * @param {{foo:string, astnode:Object, bar}} hi - desc
      * @returns {ASTnode} returns a node
      ###
      foo = (hi) ->
    '''
    options: [
      preferType:
        String: 'string'
        astnode: 'ASTNode'
    ]
    errors: [
      message: "Use 'string' instead of 'String'."
      type: 'Block'
      line: 3
      column: 16
      endLine: 3
      endColumn: 22
    ]
  ]
