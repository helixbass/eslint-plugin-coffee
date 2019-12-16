###*
# @fileoverview Test file for require-jsdoc rule
# @author Gyandeep Singh
###
'use strict'

rule = require '../../rules/require-jsdoc'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

ruleTester.run 'require-jsdoc', rule,
  valid: [
    '''
      array = [1,2,3]
      array.forEach ->
    '''
    '''
      ###*
       @class MyClass
      ###
      MyClass = ->
    '''
    '''
      ###*
       Function doing something
      ###
      myFunction = ->
    '''
    '''
      ###*
       Function doing something
      ###
      myFunction = ->
    '''
    '''
      ###*
       Function doing something
      ###
      Object.myFunction = ->
    '''
    '''
      obj = 
        ###*
        # Function doing something
        ###
        myFunction: ->
    '''

    '''
      ###*
      # @func myFunction 
      ###
      myFunction = ->
    '''
    '''
      ###*
      # @method myFunction
      ###
      myFunction = ->
    '''
    '''
      ###*
      # @function myFunction
      ###
      myFunction = ->
    '''

    '''
      ###*
       @func myFunction 
      ###
      myFunction = ->
    '''
    '''
      ###*
      # @method myFunction
      ###
      myFunction = ->
    '''
    '''
      ###*
      # @function myFunction
      ###
      myFunction = ->
    '''

    '''
      ###*
      # @func myFunction 
      ###
      Object.myFunction = ->
    '''
    '''
      ###*
      # @method myFunction
      ###
      Object.myFunction = ->
    '''
    '''
      ###*
      # @function myFunction
      ###
      Object.myFunction = ->
    '''
    'do ->'

    '''
      object = 
        ###*
         @func myFunction - Some function 
        ###
        myFunction: ->
    '''
    '''
      object = {
        ###*
         @method myFunction - Some function 
        ###
        myFunction: ->
      }
    '''
    '''
      object = 
        ###*
         @function myFunction - Some function 
        ###
        myFunction: ->
    '''

    '''
      array = [1,2,3]
      array.filter ->
    '''
    '''
      Object.keys(@options.rules ? {}).forEach ((name) ->).bind @
    '''
    '''
      object = { name: 'key'}
      Object.keys(object).forEach ->
    '''
  ,
    code: '''
      myFunction = ->
    '''
    options: [
      require:
        FunctionExpression: no
        MethodDefinition: yes
        ClassDeclaration: yes
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
         ###
        constructor: (xs) ->
          @a = xs
    '''
    options: [
      require:
        MethodDefinition: yes
        ClassDeclaration: yes
    ]
  ,
    code: '''
      ###*
       * Description for A.
       ###
      class App extends Component
        ###*
         * Description for constructor.
         * @param {object[]} xs - xs
         ###
        constructor: (xs) ->
          super()
          this.a = xs
    '''
    options: [
      require:
        MethodDefinition: yes
        ClassDeclaration: yes
    ]
  ,
    code: '''
      ###*
       * Description for A.
       ###
      export default class App extends Component
        ###*
         * Description for constructor.
         * @param {object[]} xs - xs
         ###
        constructor: (xs) ->
          super()
          this.a = xs
    '''
    options: [
      require:
        MethodDefinition: yes
        ClassDeclaration: yes
    ]
  ,
    code: '''
      ###*
       * Description for A.
       ###
      export class App extends Component
        ###*
         * Description for constructor.
         * @param {object[]} xs - xs
         ###
        constructor: (xs) ->
          super()
          this.a = xs
    '''
    options: [
      require:
        MethodDefinition: yes
        ClassDeclaration: yes
    ]
  ,
    code: '''
      class A
        constructor: (xs) ->
          this.a = xs
    '''
    options: [
      require:
        MethodDefinition: no
        ClassDeclaration: no
    ]
  ,
    code: '''
      ###*
      # Function doing something
      ###
      myFunction = () => {}
    '''
    options: [
      require:
        FunctionExpression: yes
    ]
  ,
    code: '''
      ###*
       Function doing something
      ###
      myFunction = () => () => {}
    '''
    options: [
      require:
        FunctionExpression: yes
    ]
  ,
    code: 'setTimeout((() => {}), 10)'
    options: [
      require:
        FunctionExpression: yes
    ]
  ,
    code: '''
      ###*
      JSDoc Block
      ###
      foo = ->
    '''
    options: [
      require:
        FunctionExpression: yes
    ]
  ,
    code: '''
      foo = 
        ###*
        JSDoc Block
        ###
        bar: ->
    '''
    options: [
      require:
        FunctionExpression: yes
    ]
  ,
    code: '''
      foo = {
        ###*
        JSDoc Block
        ###
        bar: ->
      }
    '''
    options: [
      require:
        FunctionExpression: yes
    ]
  ,
    code: ' foo = { [(->)]: 1 }'
    options: [
      require:
        FunctionExpression: yes
    ]
  ]

  invalid: [
    code: '''
      ###*
       * Description for A.
       ###
      class A
        constructor: (@a) ->
    '''
    options: [
      require:
        MethodDefinition: yes
        ClassDeclaration: yes
    ]
    errors: [
      message: 'Missing JSDoc comment.'
      type: 'FunctionExpression'
    ]
  ,
    code: '''
      class A
        ###*
         * Description for constructor.
         * @param {object[]} xs - xs
         ###
        constructor: (xs) ->
          @a = xs
    '''
    options: [
      require:
        MethodDefinition: yes
        ClassDeclaration: yes
    ]
    errors: [
      message: 'Missing JSDoc comment.'
      type: 'ClassDeclaration'
    ]
  ,
    code: '''
      class A extends B
        ###*
         * Description for constructor.
         * @param {object[]} xs - xs
         ###
        constructor: (xs) ->
          super()
          this.a = xs
    '''
    options: [
      require:
        MethodDefinition: yes
        ClassDeclaration: yes
    ]
    errors: [
      message: 'Missing JSDoc comment.'
      type: 'ClassDeclaration'
    ]
  ,
    code: '''
      export class A extends B
        ###*
         * Description for constructor.
         * @param {object[]} xs - xs
         ###
        constructor: (xs) ->
            super()
            this.a = xs
    '''
    options: [
      require:
        MethodDefinition: yes
        ClassDeclaration: yes
    ]
    errors: [
      message: 'Missing JSDoc comment.'
      type: 'ClassDeclaration'
    ]
  ,
    code: '''
      export default class A extends B
        ###*
         * Description for constructor.
         * @param {object[]} xs - xs
         ###
        constructor: (xs) ->
          super()
          this.a = xs
    '''
    options: [
      require:
        MethodDefinition: yes
        ClassDeclaration: yes
    ]
    errors: [
      message: 'Missing JSDoc comment.'
      type: 'ClassDeclaration'
    ]
  ,
    code: 'myFunction = () => {}'
    options: [
      require:
        ArrowFunctionExpression: yes
    ]
    errors: [
      message: 'Missing JSDoc comment.'
      type: 'ArrowFunctionExpression'
    ]
  ,
    code: 'myFunction = () => () => {}'
    options: [
      require:
        ArrowFunctionExpression: yes
    ]
    errors: [
      message: 'Missing JSDoc comment.'
      type: 'ArrowFunctionExpression'
    ]
  ,
    code: 'foo = ->'
    options: [
      require:
        FunctionExpression: yes
    ]
    errors: [
      message: 'Missing JSDoc comment.'
      type: 'FunctionExpression'
    ]
  ,
    code: 'foo = bar: ->'
    options: [
      require:
        FunctionExpression: yes
    ]
    errors: [
      message: 'Missing JSDoc comment.'
      type: 'FunctionExpression'
    ]
  ]
