###*
# @fileoverview Rule to flag use of variables before they are defined
# @author Ilya Volodin
###

'use strict'

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

SENTINEL_TYPE =
  /^(?:(?:Function|Class)(?:Declaration|Expression)|ArrowFunctionExpression|CatchClause|ImportDeclaration|ExportNamedDeclaration)$/
FOR_IN_OF_TYPE = /^For(?:In|Of)Statement$/

###*
# Parses a given value as options.
#
# @param {any} options - A value to parse.
# @returns {Object} The parsed options.
###
parseOptions = (options) ->
  functions = yes
  classes = yes
  variables = yes

  if typeof options is 'string'
    functions = options isnt 'nofunc'
  else if typeof options is 'object' and options isnt null
    functions = options.functions isnt no
    classes = options.classes isnt no
    variables = options.variables isnt no

  {functions, classes, variables}

###*
# Checks whether or not a given variable is a function declaration.
#
# @param {eslint-scope.Variable} variable - A variable to check.
# @returns {boolean} `true` if the variable is a function declaration.
###
isFunction = (variable, reference) ->
  {name} = variable.defs[0]
  return no unless (
    name.parent.type is 'AssignmentExpression' and
    name.parent.right.type is 'FunctionExpression'
  )
  variable.scope.variableScope isnt reference.from.variableScope

###*
# Checks whether or not a given variable is a class declaration in an upper function scope.
#
# @param {eslint-scope.Variable} variable - A variable to check.
# @param {eslint-scope.Reference} reference - A reference to check.
# @returns {boolean} `true` if the variable is a class declaration.
###
isOuterClass = (variable, reference) ->
  variable.defs[0].type is 'ClassName' and
  variable.scope.variableScope isnt reference.from.variableScope

###*
# Checks whether or not a given variable is a variable declaration in an upper function scope.
# @param {eslint-scope.Variable} variable - A variable to check.
# @param {eslint-scope.Reference} reference - A reference to check.
# @returns {boolean} `true` if the variable is a variable declaration.
###
isOuterVariable = (variable, reference) ->
  variable.defs[0].type is 'Variable' and
  variable.scope.variableScope isnt reference.from.variableScope

###*
# Checks whether or not a given location is inside of the range of a given node.
#
# @param {ASTNode} node - An node to check.
# @param {number} location - A location to check.
# @returns {boolean} `true` if the location is inside of the range of the node.
###
isInRange = (node, location) ->
  node and node.range[0] <= location and location <= node.range[1]

###*
# Checks whether or not a given reference is inside of the initializers of a given variable.
#
# This returns `true` in the following cases:
#
#     var a = a
#     var [a = a] = list
#     var {a = a} = obj
#     for (var a in a) {}
#     for (var a of a) {}
#
# @param {Variable} variable - A variable to check.
# @param {Reference} reference - A reference to check.
# @returns {boolean} `true` if the reference is inside of the initializers.
###
isInInitializer = (variable, reference) ->
  return no unless variable.scope is reference.from

  node = variable.identifiers[0].parent
  location = reference.identifier.range[1]

  while node
    if node.type is 'AssignmentExpression'
      return yes if isInRange node.right, location
      return yes if (
        FOR_IN_OF_TYPE.test(node.parent.parent.type) and
        isInRange node.parent.parent.right, location
      )
      break
    else if node.type is 'AssignmentPattern'
      return yes if isInRange node.right, location
    else if SENTINEL_TYPE.test node.type
      break

    node = node.parent

  no

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'disallow the use of variables before they are defined'
      category: 'Variables'
      recommended: no
      url: 'https://eslint.org/docs/rules/no-use-before-define'

    schema: [
      oneOf: [
        enum: ['nofunc']
      ,
        type: 'object'
        properties:
          functions: type: 'boolean'
          classes: type: 'boolean'
          variables: type: 'boolean'
        additionalProperties: no
      ]
    ]

  create: (context) ->
    options = parseOptions context.options[0]

    ###*
    # Determines whether a given use-before-define case should be reported according to the options.
    # @param {eslint-scope.Variable} variable The variable that gets used before being defined
    # @param {eslint-scope.Reference} reference The reference to the variable
    # @returns {boolean} `true` if the usage should be reported
    ###
    isForbidden = (variable, reference) ->
      return options.functions if isFunction variable, reference
      return options.classes if isOuterClass variable, reference
      return options.variables if isOuterVariable variable, reference
      yes

    ###*
    # Finds and validates all variables in a given scope.
    # @param {Scope} scope The scope object.
    # @returns {void}
    # @private
    ###
    findVariablesInScope = (scope) ->
      scope.references.forEach (reference) ->
        variable = reference.resolved

        ###
        # Skips when the reference is:
        # - initialization's.
        # - referring to an undefined variable.
        # - referring to a global environment variable (there're no identifiers).
        # - located preceded by the variable (except in initializers).
        # - allowed by options.
        ###
        return if (
          reference.init or
          reference.identifier?.declaration or
          not variable or
          variable.identifiers.length is 0 or
          (variable.identifiers[0].range[1] < reference.identifier.range[1] and
            not isInInitializer(variable, reference)) or
          not isForbidden variable, reference
        )

        # Reports.
        context.report
          node: reference.identifier
          message: "'{{name}}' was used before it was defined."
          data: reference.identifier

      scope.childScopes.forEach findVariablesInScope

    Program: -> findVariablesInScope context.getScope()
