###*
# @fileoverview Rule to enforce spacing before and after keywords.
# @author Toru Nagashima
###

'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------

astUtils = require '../eslint-ast-utils'
keywords = require 'eslint/lib/util/keywords'

#------------------------------------------------------------------------------
# Constants
#------------------------------------------------------------------------------

PREV_TOKEN = ///
  ^
  (?:
    # [-=] > |
    [ )\]}> ]
  )
  $
///
NEXT_TOKEN = ///
  ^
  (?:
    [-=] > |
    [ ([{<~! ] |
    \+\+? |
    --?
  )
  $
///
PREV_TOKEN_M = /^[)\]}>*]$/
NEXT_TOKEN_M = /^[{*]$/
TEMPLATE_OPEN_PAREN = /\$\{$/
TEMPLATE_CLOSE_PAREN = /^\}/
CHECK_TYPE = /^(?:JSXElement|RegularExpression|String|Template)$/
KEYS = keywords.concat [
  'as'
  'async'
  'await'
  'from'
  'get'
  'let'
  'of'
  'set'
  'yield'
  'then'
  'when'
  'unless'
  'until'
]

# check duplications.
do ->
  KEYS.sort()
  for i in [1...KEYS.length]
    if KEYS[i] is KEYS[i - 1]
      throw new Error "Duplication was found in the keyword list: #{KEYS[i]}"

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

###*
# Checks whether or not a given token is a "Template" token ends with "${".
#
# @param {Token} token - A token to check.
# @returns {boolean} `true` if the token is a "Template" token ends with "${".
###
isOpenParenOfTemplate = (token) ->
  token.type is 'Template' and TEMPLATE_OPEN_PAREN.test token.value

###*
# Checks whether or not a given token is a "Template" token starts with "}".
#
# @param {Token} token - A token to check.
# @returns {boolean} `true` if the token is a "Template" token starts with "}".
###
isCloseParenOfTemplate = (token) ->
  token.type is 'Template' and TEMPLATE_CLOSE_PAREN.test token.value

#------------------------------------------------------------------------------
# Rule Definition
#------------------------------------------------------------------------------

module.exports =
  meta:
    docs:
      description: 'enforce consistent spacing before and after keywords'
      category: 'Stylistic Issues'
      recommended: no
      url: 'https://eslint.org/docs/rules/keyword-spacing'

    fixable: 'whitespace'

    schema: [
      type: 'object'
      properties:
        before: type: 'boolean'
        after: type: 'boolean'
        overrides:
          type: 'object'
          properties: KEYS.reduce(
            (retv, key) ->
              retv[key] =
                type: 'object'
                properties:
                  before: type: 'boolean'
                  after: type: 'boolean'
                additionalProperties: no
              retv
            {}
          )
          additionalProperties: no
      additionalProperties: no
    ]

  create: (context) ->
    sourceCode = context.getSourceCode()

    ###*
    # Reports a given token if there are not space(s) before the token.
    #
    # @param {Token} token - A token to report.
    # @param {RegExp} pattern - A pattern of the previous token to check.
    # @returns {void}
    ###
    expectSpaceBefore = (token, pattern) ->
      prevToken = sourceCode.getTokenBefore token

      if (
        prevToken and
        (CHECK_TYPE.test(prevToken.type) or pattern.test(prevToken.value)) and
        not isOpenParenOfTemplate(prevToken) and
        astUtils.isTokenOnSameLine(prevToken, token) and
        not sourceCode.isSpaceBetweenTokens prevToken, token
      )
        context.report
          loc: token.loc.start
          message: 'Expected space(s) before "{{value}}".'
          data: token
          fix: (fixer) -> fixer.insertTextBefore token, ' '

    ###*
    # Reports a given token if there are space(s) before the token.
    #
    # @param {Token} token - A token to report.
    # @param {RegExp} pattern - A pattern of the previous token to check.
    # @returns {void}
    ###
    unexpectSpaceBefore = (token, pattern) ->
      prevToken = sourceCode.getTokenBefore token

      if (
        prevToken and
        (CHECK_TYPE.test(prevToken.type) or pattern.test(prevToken.value)) and
        not isOpenParenOfTemplate(prevToken) and
        astUtils.isTokenOnSameLine(prevToken, token) and
        sourceCode.isSpaceBetweenTokens prevToken, token
      )
        context.report
          loc: token.loc.start
          message: 'Unexpected space(s) before "{{value}}".'
          data: token
          fix: (fixer) -> fixer.removeRange [prevToken.range[1], token.range[0]]

    ###*
    # Reports a given token if there are not space(s) after the token.
    #
    # @param {Token} token - A token to report.
    # @param {RegExp} pattern - A pattern of the next token to check.
    # @returns {void}
    ###
    expectSpaceAfter = (token, pattern) ->
      nextToken = sourceCode.getTokenAfter token

      if (
        nextToken and
        (CHECK_TYPE.test(nextToken.type) or pattern.test(nextToken.value)) and
        not isCloseParenOfTemplate(nextToken) and
        astUtils.isTokenOnSameLine(token, nextToken) and
        not sourceCode.isSpaceBetweenTokens token, nextToken
      )
        context.report
          loc: token.loc.start
          message: 'Expected space(s) after "{{value}}".'
          data: token
          fix: (fixer) -> fixer.insertTextAfter token, ' '

    ###*
    # Reports a given token if there are space(s) after the token.
    #
    # @param {Token} token - A token to report.
    # @param {RegExp} pattern - A pattern of the next token to check.
    # @returns {void}
    ###
    unexpectSpaceAfter = (token, pattern) ->
      nextToken = sourceCode.getTokenAfter token

      if (
        nextToken and
        (CHECK_TYPE.test(nextToken.type) or pattern.test(nextToken.value)) and
        not isCloseParenOfTemplate(nextToken) and
        astUtils.isTokenOnSameLine(token, nextToken) and
        sourceCode.isSpaceBetweenTokens token, nextToken
      )
        context.report
          loc: token.loc.start
          message: 'Unexpected space(s) after "{{value}}".'
          data: token
          fix: (fixer) -> fixer.removeRange [token.range[1], nextToken.range[0]]

    ###*
    # Parses the option object and determines check methods for each keyword.
    #
    # @param {Object|undefined} options - The option object to parse.
    # @returns {Object} - Normalized option object.
    #      Keys are keywords (there are for every keyword).
    #      Values are instances of `{"before": function, "after": function}`.
    ###
    parseOptions = (options) ->
      before = not options or options.before isnt no
      after = not options or options.after isnt no
      defaultValue =
        before: if before then expectSpaceBefore else unexpectSpaceBefore
        after: if after then expectSpaceAfter else unexpectSpaceAfter
      overrides = options?.overrides or {}
      retv = Object.create null

      for key in KEYS
        override = overrides[key]

        if override
          thisBefore = if 'before' of override then override.before else before
          thisAfter = if 'after' of override then override.after else after

          retv[key] =
            before:
              if thisBefore then expectSpaceBefore else unexpectSpaceBefore
            after: if thisAfter then expectSpaceAfter else unexpectSpaceAfter
        else
          retv[key] = defaultValue

      retv

    checkMethodMap = parseOptions context.options[0]

    ###*
    # Reports a given token if usage of spacing followed by the token is
    # invalid.
    #
    # @param {Token} token - A token to report.
    # @param {RegExp|undefined} pattern - Optional. A pattern of the previous
    #      token to check.
    # @returns {void}
    ###
    checkSpacingBefore = (token, pattern) ->
      checkMethodMap[token.value].before token, pattern or PREV_TOKEN

    ###*
    # Reports a given token if usage of spacing preceded by the token is
    # invalid.
    #
    # @param {Token} token - A token to report.
    # @param {RegExp|undefined} pattern - Optional. A pattern of the next
    #      token to check.
    # @returns {void}
    ###
    checkSpacingAfter = (token, pattern) ->
      checkMethodMap[token.value].after token, pattern or NEXT_TOKEN

    ###*
    # Reports a given token if usage of spacing around the token is invalid.
    #
    # @param {Token} token - A token to report.
    # @returns {void}
    ###
    checkSpacingAround = (token) ->
      checkSpacingBefore token
      checkSpacingAfter token

    ###*
    # Reports the first token of a given node if the first token is a keyword
    # and usage of spacing around the token is invalid.
    #
    # @param {ASTNode|null} node - A node to report.
    # @returns {void}
    ###
    checkSpacingAroundFirstToken = (node) ->
      firstToken = node and sourceCode.getFirstToken node

      if firstToken and firstToken.type is 'Keyword'
        checkSpacingAround firstToken

    ###*
    # Reports the first token of a given node if the first token is a keyword
    # and usage of spacing followed by the token is invalid.
    #
    # This is used for unary operators (e.g. `typeof`), `function`, and `super`.
    # Other rules are handling usage of spacing preceded by those keywords.
    #
    # @param {ASTNode|null} node - A node to report.
    # @returns {void}
    ###
    checkSpacingBeforeFirstToken = (node) ->
      firstToken = node and sourceCode.getFirstToken node

      if firstToken?.type is 'Keyword'
        checkSpacingBefore firstToken

    ###*
    # Reports the previous token of a given node if the token is a keyword and
    # usage of spacing around the token is invalid.
    #
    # @param {ASTNode|null} node - A node to report.
    # @returns {void}
    ###
    checkSpacingAroundTokenBefore = (node) ->
      if node
        token = sourceCode.getTokenBefore node, astUtils.isKeywordToken

        checkSpacingAround token

    ###*
    # Reports `async` or `function` keywords of a given node if usage of
    # spacing around those keywords is invalid.
    #
    # @param {ASTNode} node - A node to report.
    # @returns {void}
    ###
    checkSpacingForFunction = (node) ->
      firstToken = node and sourceCode.getFirstToken node

      if (
        firstToken and
        ((firstToken.type is 'Keyword' and firstToken.value is 'function') or
          firstToken.value is 'async')
      )
        checkSpacingBefore firstToken

    ###*
    # Reports `class` and `extends` keywords of a given node if usage of
    # spacing around those keywords is invalid.
    #
    # @param {ASTNode} node - A node to report.
    # @returns {void}
    ###
    checkSpacingForClass = (node) ->
      checkSpacingAroundFirstToken node
      checkSpacingAroundTokenBefore node.superClass

    ###*
    # Reports `if` and `else` keywords of a given node if usage of spacing
    # around those keywords is invalid.
    #
    # @param {ASTNode} node - A node to report.
    # @returns {void}
    ###
    checkSpacingForIfStatement = (node) ->
      if node.postfix
        checkSpacingAroundTokenBefore node.test
      else
        checkSpacingAroundFirstToken node
      token = sourceCode.getTokenBefore node.consequent, astUtils.isKeywordToken
      unless token?.value is 'then'
        token = sourceCode.getFirstToken node.consequent
      checkSpacingAround token if token?.value is 'then'
      if node.alternate
        token = sourceCode.getTokenBefore(
          node.alternate
          astUtils.isKeywordToken
        )
        unless token?.value is 'else'
          token = sourceCode.getFirstToken node.alternate
        checkSpacingAround token if token?.value is 'else'

    ###*
    # Reports `try`, `catch`, and `finally` keywords of a given node if usage
    # of spacing around those keywords is invalid.
    #
    # @param {ASTNode} node - A node to report.
    # @returns {void}
    ###
    checkSpacingForTryStatement = (node) ->
      checkSpacingAroundFirstToken node
      checkSpacingAroundFirstToken node.handler
      checkSpacingAroundTokenBefore node.finalizer

    ###*
    # Reports `do` and `while` keywords of a given node if usage of spacing
    # around those keywords is invalid.
    #
    # @param {ASTNode} node - A node to report.
    # @returns {void}
    ###
    checkSpacingForDoWhileStatement = (node) ->
      checkSpacingAroundFirstToken node
      checkSpacingAroundTokenBefore node.test

    checkSpacingForWhileStatement = (node) ->
      if node.postfix
        checkSpacingAroundTokenBefore node.test
      else
        checkSpacingAroundFirstToken node
      token = sourceCode.getTokenBefore node.body, astUtils.isKeywordToken
      unless token?.value is 'then'
        token = sourceCode.getFirstToken node.body
      checkSpacingAround token if token?.value is 'then'

    ###*
    # Reports `for` and `in` keywords of a given node if usage of spacing
    # around those keywords is invalid.
    #
    # @param {ASTNode} node - A node to report.
    # @returns {void}
    ###
    checkSpacingForForInStatement = (node) ->
      checkSpacingAroundFirstToken node
      checkSpacingAroundTokenBefore node.right

    ###*
    # Reports `for` and `of` keywords of a given node if usage of spacing
    # around those keywords is invalid.
    #
    # @param {ASTNode} node - A node to report.
    # @returns {void}
    ###
    checkSpacingForForOfStatement = (node) ->
      if node.await
        checkSpacingBefore sourceCode.getFirstToken node, 0
        checkSpacingAfter sourceCode.getFirstToken node, 1
      else
        checkSpacingAroundFirstToken node
      checkSpacingAround(
        sourceCode.getTokenBefore node.right, astUtils.isNotOpeningParenToken
      )

    checkSpacingForFor = (node) ->
      if node.postfix
        # TODO: postfix await, when, by
        # if node.await
        #   checkSpacingBefore sourceCode.getFirstToken node, 0
        #   checkSpacingAfter sourceCode.getFirstToken node, 1
        # else
        checkSpacingAround sourceCode.getTokenAfter node.body
      else if node.await
        checkSpacingBefore sourceCode.getFirstToken node, 0
        checkSpacingAfter sourceCode.getFirstToken node, 1
      else
        checkSpacingAroundFirstToken node

      checkSpacingAround(
        sourceCode.getTokenBefore node.source, astUtils.isNotOpeningParenToken
      )

      token = sourceCode.getTokenBefore node.body, astUtils.isKeywordToken
      unless token?.value is 'then'
        token = sourceCode.getFirstToken node.body
      checkSpacingAround token if token?.value is 'then'

    ###*
    # Reports `import`, `export`, `as`, and `from` keywords of a given node if
    # usage of spacing around those keywords is invalid.
    #
    # This rule handles the `*` token in module declarations.
    #
    #     import*as A from "./a"; /*error Expected space(s) after "import".
    #                               error Expected space(s) before "as".
    #
    # @param {ASTNode} node - A node to report.
    # @returns {void}
    ###
    checkSpacingForModuleDeclaration = (node) ->
      firstToken = sourceCode.getFirstToken node

      checkSpacingBefore firstToken, PREV_TOKEN_M
      checkSpacingAfter firstToken, NEXT_TOKEN_M

      if node.source
        fromToken = sourceCode.getTokenBefore node.source

        checkSpacingBefore fromToken, PREV_TOKEN_M
        checkSpacingAfter fromToken, NEXT_TOKEN_M

    ###*
    # Reports `as` keyword of a given node if usage of spacing around this
    # keyword is invalid.
    #
    # @param {ASTNode} node - A node to report.
    # @returns {void}
    ###
    checkSpacingForImportNamespaceSpecifier = (node) ->
      asToken = sourceCode.getFirstToken node, 1

      checkSpacingBefore asToken, PREV_TOKEN_M

    ###*
    # Reports `static`, `get`, and `set` keywords of a given node if usage of
    # spacing around those keywords is invalid.
    #
    # @param {ASTNode} node - A node to report.
    # @returns {void}
    ###
    checkSpacingForProperty = (node) ->
      if node.static then checkSpacingAroundFirstToken node
      if (
        node.kind in ['get', 'set'] or
        ((node.method or node.type is 'MethodDefinition') and node.value.async)
      )
        token = sourceCode.getTokenBefore node.key, (tok) ->
          switch tok.value
            when 'get', 'set', 'async'
              return yes
            else
              return no

        unless token
          throw new Error(
            'Failed to find token get, set, or async beside method name'
          )

        checkSpacingAround token

    ###*
    # Reports `await` keyword of a given node if usage of spacing before
    # this keyword is invalid.
    #
    # @param {ASTNode} node - A node to report.
    # @returns {void}
    ###
    checkSpacingForAwaitExpression = (node) ->
      checkSpacingBefore sourceCode.getFirstToken node

    # Statements
    DebuggerStatement: checkSpacingAroundFirstToken
    WithStatement: checkSpacingAroundFirstToken

    # Statements - Control flow
    BreakStatement: checkSpacingAroundFirstToken
    ContinueStatement: checkSpacingAroundFirstToken
    ReturnStatement: checkSpacingAroundFirstToken
    ThrowStatement: checkSpacingAroundFirstToken
    TryStatement: checkSpacingForTryStatement

    # Statements - Choice
    IfStatement: checkSpacingForIfStatement
    ConditionalExpression: checkSpacingForIfStatement
    SwitchStatement: checkSpacingAroundFirstToken
    SwitchCase: checkSpacingAroundFirstToken

    # Statements - Loops
    DoWhileStatement: checkSpacingForDoWhileStatement
    ForInStatement: checkSpacingForForInStatement
    ForOfStatement: checkSpacingForForOfStatement
    For: checkSpacingForFor
    ForStatement: checkSpacingAroundFirstToken
    WhileStatement: checkSpacingForWhileStatement

    # Statements - Declarations
    ClassDeclaration: checkSpacingForClass
    ExportNamedDeclaration: checkSpacingForModuleDeclaration
    ExportDefaultDeclaration: checkSpacingAroundFirstToken
    ExportAllDeclaration: checkSpacingForModuleDeclaration
    FunctionDeclaration: checkSpacingForFunction
    ImportDeclaration: checkSpacingForModuleDeclaration
    VariableDeclaration: checkSpacingAroundFirstToken

    # Expressions
    ArrowFunctionExpression: checkSpacingForFunction
    AwaitExpression: checkSpacingForAwaitExpression
    ClassExpression: checkSpacingForClass
    FunctionExpression: checkSpacingForFunction
    NewExpression: checkSpacingBeforeFirstToken
    Super: checkSpacingBeforeFirstToken
    ThisExpression: checkSpacingBeforeFirstToken
    UnaryExpression: checkSpacingAroundFirstToken
    YieldExpression: checkSpacingBeforeFirstToken

    # Others
    ImportNamespaceSpecifier: checkSpacingForImportNamespaceSpecifier
    MethodDefinition: checkSpacingForProperty
    Property: checkSpacingForProperty
