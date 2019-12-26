{
  flow
  map
  flatten
  fromPairs
  keys
  mapValues
  pickBy
  reject
  filter
  omitBy
} = require 'lodash/fp'
mapWithKey = map.convert cap: no

{parseForESLint} = require './parser'

usable = [
  'no-console'
  'no-control-regex'
  'no-debugger'
  'no-dupe-keys'
  'no-duplicate-case'
  'no-empty'
  'no-ex-assign'
  'no-invalid-regexp'
  'no-irregular-whitespace'
  'no-obj-calls'
  'no-prototype-builtins'
  'no-sparse-arrays'
  'no-unsafe-finally'
  'accessor-pairs' # wouldn't work for backticked get/set
  'default-case'
  'max-classes-per-file'
  'no-alert'
  'no-caller'
  'no-eval'
  'no-extend-native'
  'no-global-assign' # only ++ applies since we generate declarations on other write references
  'no-implied-eval'
  'no-iterator'
  'no-new-func'
  'no-new-wrappers'
  'no-param-reassign'
  'no-proto'
  'no-restricted-properties'
  'no-script-url'
  'no-throw-literal'
  'no-useless-call'
  'no-useless-concat'
  'no-warning-comments'
  'prefer-promise-reject-errors'
  'radix'
  'no-delete-var'
  'no-restricted-globals'
  'global-require'
  'handle-callback-err'
  'no-buffer-constructor'
  'no-new-require'
  'no-path-concat'
  'no-process-env'
  'no-process-exit'
  'no-restricted-modules'
  'no-sync'
  'comma-spacing'
  'eol-last'
  'id-blacklist'
  'key-spacing'
  'line-comment-position'
  'linebreak-style'
  'max-lines'
  'max-nested-callbacks'
  'max-params'
  'max-statements'
  'new-cap'
  'new-parens'
  'no-array-constructor'
  'no-bitwise'
  'no-continue'
  'no-inline-comments'
  'no-multi-assign'
  'no-new-object'
  'no-plusplus'
  'no-restricted-syntax'
  'sort-keys'
  'constructor-super'
  'no-dupe-class-members'
  'no-duplicate-imports'
  'no-new-symbol'
  'no-restricted-imports'
  'no-useless-rename'
  'prefer-numeric-literals'
  'prefer-rest-params'
  'prefer-spread'
  'sort-imports'
  'symbol-description'
  # Got deprecated so didn't bother creating Coffeescript-specific version
  # after modifying catch variable scope behavior
  # 'no-catch-shadow'
  'import/no-webpack-loader-syntax'
  'import/first'
  'import/no-amd'
  'import/no-nodejs-modules'
  'import/exports-last'
  'import/no-namespace'
  'import/prefer-default-export'
  'import/max-dependencies'
  'import/newline-after-import'
  'import/group-exports'
  'no-misleading-character-class'
  'require-unicode-regexp'
  'unicode-bom'
  'no-tabs'
  'no-trailing-spaces'
  'quote-props'
  'require-atomic-updates'
  'no-floating-decimal'
  'computed-property-spacing'
  'no-undef'
  'space-in-parens'
  'jsx-quotes'
  'react/button-has-type'
  'react/forbid-component-props'
  'react/forbid-dom-props'
  'react/forbid-elements'
  'react/forbid-foreign-prop-types'
  'react/no-array-index-key'
  'react/no-children-prop'
  'react/no-danger'
  'react/no-did-mount-set-state'
  'react/no-did-update-set-state'
  'react/no-direct-mutation-state'
  'react/no-find-dom-node'
  'react/no-is-mounted'
  'react/no-set-state'
  'react/no-string-refs'
  'react/no-unknown-property'
  'react/no-unsafe'
  'react/no-will-update-set-state'
  'react/prefer-es6-class'
  'react/react-in-jsx-scope'
  'react/jsx-child-element-spacing'
  'react/jsx-closing-tag-location'
  'react/jsx-pascal-case'
  'react/jsx-no-target-blank'
  'react/jsx-curly-spacing'
  'react/jsx-equals-spacing'
  'react/jsx-filename-extension'
  'react/jsx-indent-props'
  'react/jsx-max-depth'
  'react/jsx-no-duplicate-props'
  'react/jsx-no-literals'
  'react/jsx-no-undef'
  'react/jsx-curly-brace-presence'
  'react/jsx-props-no-multi-spaces'
  'react/jsx-uses-react'
  'react/jsx-uses-vars'
  'react/void-dom-elements-no-children'
  'react-native/no-inline-styles'
  'no-empty-pattern'
  'react/require-optimization'
  'react/self-closing-comp'
  'react/jsx-sort-props'
  'import/default'
  'import/no-unresolved'
  'import/named'
  'import/no-restricted-paths'
  'import/no-absolute-path'
  'import/no-dynamic-require'
  'import/no-internal-modules'
  'import/no-self-import'
  'import/no-cycle'
  'import/no-useless-path-segments'
  'import/no-relative-parent-imports'
  'import/no-named-as-default'
  'import/no-extraneous-dependencies'
  'import/no-duplicates'
  'import/extensions'
  'import/no-unassigned-import'
  'import/no-named-default'
  'no-useless-catch'
  'react/static-property-placement'
]

# eslint-disable-next-line coffee/no-unused-vars
yet = [
  'no-extra-parens' # prettier: yes
  'strict' # airbnb-base: ['error', 'never']
  'comma-dangle' # prettier: yes, airbnb-base: ['error', {
  # arrays: 'always-multiline',
  # objects: 'always-multiline',
  # imports: 'always-multiline',
  # exports: 'always-multiline',
  # functions: 'always-multiline',
  # }]
  'indent' # prettier: yes, airbnb-base: ['error', 2, {
  # SwitchCase: 1,
  # VariableDeclarator: 1,
  # outerIIFEBody: 1,
  # // MemberExpression: null,
  # FunctionDeclaration: {
  #   parameters: 1,
  #   body: 1
  # },
  # FunctionExpression: {
  #   parameters: 1,
  #   body: 1
  # },
  # CallExpression: {
  #   arguments: 1
  # },
  # ArrayExpression: 1,
  # ObjectExpression: 1,
  # ImportDeclaration: 1,
  # flatTernaryExpressions: false,
  # // list derived from https://github.com/benjamn/ast-types/blob/HEAD/def/jsx.js
  # ignoredNodes: ['JSXElement', 'JSXElement > *', 'JSXAttribute', 'JSXIdentifier', 'JSXNamespacedName', 'JSXMemberExpression', 'JSXSpreadAttribute', 'JSXExpressionContainer', 'JSXOpeningElement', 'JSXClosingElement', 'JSXText', 'JSXEmptyExpression', 'JSXSpreadChild'],
  # ignoreComments: false
  # }]
  'multiline-ternary' # prettier: yes maybe this should be multiline-control and check all "inline" (non-postfix) forms of control structures (which use then)?
  'padded-blocks' # prettier: yes I think only leading padding would apply (since trailing padding is considered outside the block) airbnb-base: ['error', {
  # blocks: 'never',
  # classes: 'never',
  # switches: 'never',
  # }, {
  # allowSingleLineBlocks: true,
  # }]
  'padding-line-between-statements' # I think only leading padding would apply (since trailing padding is considered outside the block)
  'quotes' # prettier: yes, airbnb-base: ['error', 'single', {avoidEscape: true}]
  'no-dupe-else-if'
  'no-import-assign'
  'no-setter-return'
  'default-param-last'
  'grouped-accessor-pairs'
  'no-constructor-return'
  'prefer-named-capture-group'
  'prefer-regex-literals'
  'function-call-argument-newline'
  'prefer-exponentiation-operator'
  'react/prefer-read-only-props'
  'react/jsx-no-script-url'
  'react/jsx-no-useless-fragment'
  'react/jsx-props-no-spreading'
  'react/jsx-space-before-closing'
  'import/unambiguous'
  'react-native/sort-styles'
  'react-native/no-raw-text'
  'react-native/no-single-element-style-arrays'
  'lines-around-directive' # this is deprecated but is turned on by airbnb
  'no-spaced-func' # this is deprecated but is turned on by airbnb
]

dontApply = [
  'prefer-const'
  'no-const-assign'
  'func-style'
  'eqeqeq'
  'prefer-arrow-callback'
  'arrow-body-style'
  'no-var'
  'one-var'
  'no-void'
  'sort-vars'
  'no-octal'
  'no-octal-escape'
  'func-names'
  'no-ternary'
  'init-declarations'
  'import/no-mutable-exports' # since you can't control whether an exported member is const - might be nice to implement its "possible future behavior" of checking whether it in fact does get reassigned?)
  'no-label-var'
  'no-extra-label'
  'no-unused-labels'
  'no-labels'
  'no-with'
  'no-fallthrough'
  'no-undef-init'
  'no-undefined'
  'require-await'
  'require-yield'
  'no-dupe-args'
  'getter-return' # could be used for Object.defineProperty() calls?
  'func-name-matching'
  'no-func-assign'
  'max-statements-per-line'
  'no-mixed-requires'
  'no-redeclare'
  'for-direction'
  'no-shadow-restricted-names'
  'no-case-declarations'
  'no-lone-blocks'
  'curly'
  'wrap-iife'
  'template-tag-spacing'
  'switch-colon-spacing'
  'semi'
  'semi-spacing'
  'semi-style'
  'no-extra-semi'
  'no-unexpected-multiline'
  'no-mixed-spaces-and-tabs'
  'no-nested-ternary'
  'no-implicit-globals' # it seems like non-bare compilation covers this
  'array-callback-return' # though could presumably support allowImplicit: false checking and possibly detect implicit returns of nullish values?
  'consistent-return' # could probably do some form of comparing implicitly (and/or explicitly) returned values?
  'block-spacing'
  'brace-style'
  'nonblock-statement-body-position'
  'object-curly-newline'
  'one-var-declaration-per-line'
  'space-before-blocks'
  'space-before-function-paren'
  'arrow-parens'
  'generator-star-spacing'
  'no-confusing-arrow'
  'yield-star-spacing'
  'func-call-spacing'
  'react/require-render-return'
  'no-eq-null'
  'no-multi-str'
  'react/state-in-constructor'
]

rules =
  flow(
    mapWithKey (config, rule) -> [
      rule
      {
        ...config
        module: require "./rules/#{rule}"
      }
    ]
  ,
    fromPairs
  )(
    'use-isnan':
      'eslint-recommended': yes
      'airbnb-base': yes
    'no-self-compare':
      'airbnb-base': yes
    'valid-typeof':
      'eslint-recommended': yes
      'airbnb-base': ['error', {requireStringLiterals: yes}]
    'no-negated-condition': {}
    yoda:
      'airbnb-base': yes
    camelcase:
      'airbnb-base': [
        'error'
      ,
        properties: 'never'
        ignoreDestructuring: no
      ]
    'dot-notation':
      'airbnb-base': ['error', {allowKeywords: yes}]
    'no-compare-neg-zero':
      'eslint-recommended': yes
      'airbnb-base': yes
    'no-unreachable':
      'eslint-recommended': yes
      'airbnb-base': yes
    'object-shorthand':
      'airbnb-base': [
        'error'
        'always'
      ,
        ignoreConstructors: no
        avoidQuotes: yes
      ]
    'no-empty-character-class':
      'eslint-recommended': yes
      'airbnb-base': yes
    'no-extra-boolean-cast':
      'eslint-recommended': yes
      'airbnb-base': yes
    'no-regex-spaces':
      'eslint-recommended': yes
      'airbnb-base': yes
    'no-implicit-coercion': {}
    'no-magic-numbers': {}
    'no-self-assign':
      'eslint-recommended': yes
      'airbnb-base': ['error', {props: yes}]
    'operator-assignment':
      'airbnb-base': ['error', 'always']
    'no-unused-expressions':
      'airbnb-base': [
        'error'
      ,
        allowShortCircuit: no
        allowTernary: no
        allowTaggedTemplates: no
      ]
    'class-methods-use-this':
      'airbnb-base': yes
      airbnb: [
        'error'
      ,
        exceptMethods: [
          'render'
          'getInitialState'
          'getDefaultProps'
          'getChildContext'
          'componentWillMount'
          'UNSAFE_componentWillMount'
          'componentDidMount'
          'componentWillReceiveProps'
          'UNSAFE_componentWillReceiveProps'
          'shouldComponentUpdate'
          'componentWillUpdate'
          'UNSAFE_componentWillUpdate'
          'componentDidUpdate'
          'componentWillUnmount'
          'componentDidCatch'
          'getSnapshotBeforeUpdate'
        ]
      ]
    'no-await-in-loop':
      'airbnb-base': yes
    'prefer-destructuring':
      'airbnb-base': [
        'error'
      ,
        VariableDeclarator:
          array: false
          object: true
        AssignmentExpression:
          array: true
          object: false
      ,
        enforceForRenamedProperties: false
      ]
    'no-constant-condition':
      'eslint-recommended': yes
      'airbnb-base': ['warn']
    'no-template-curly-in-string':
      'airbnb-base': yes
    'no-unneeded-ternary':
      'airbnb-base': ['error', {defaultAssignment: no}]
    'no-unmodified-loop-condition': {}
    'no-unused-vars':
      'eslint-recommended': yes
      'airbnb-base': [
        'error'
      ,
        vars: 'all'
        args: 'after-used'
        ignoreRestSiblings: yes
      ]
    'no-use-before-define':
      'airbnb-base': [
        'error'
      ,
        functions: yes
        classes: yes
        variables: yes
      ]
    'max-depth': {}
    'vars-on-top':
      'airbnb-base': yes
    'guard-for-in':
      'airbnb-base': yes
    'no-useless-return':
      'airbnb-base': yes
    'arrow-spacing':
      prettier: yes
      'airbnb-base': ['error', {before: yes, after: yes}]
    'object-curly-spacing':
      prettier: yes
      'airbnb-base': ['error', 'always']
    'capitalized-class-names':
      plugin: no
    complexity: {}
    'max-len':
      prettier: yes
      'airbnb-base': [
        'error'
        100
        2
      ,
        ignoreUrls: true
        ignoreComments: false
        ignoreRegExpLiterals: true
        ignoreStrings: true
        ignoreTemplateLiterals: true
      ]
    'no-invalid-this': {}
    'lines-between-class-members':
      'airbnb-base': ['error', 'always', {exceptAfterSingleLine: no}]
    'max-lines-per-function': {}
    'no-backticks':
      plugin: no
    'space-infix-ops':
      prettier: yes
      'airbnb-base': yes
    'space-unary-ops':
      prettier: yes
      'airbnb-base': [
        'error'
      ,
        words: yes
        nonwords: no
        overrides: {}
      ]
    'english-operators':
      plugin: no
    'no-unnecessary-fat-arrow':
      plugin: no
    'no-this-before-super':
      'eslint-recommended': yes
      'airbnb-base': yes
    'no-cond-assign':
      'eslint-recommended': yes
      'airbnb-base': ['error', 'always']
    'no-inner-declarations':
      'eslint-recommended': yes
      'airbnb-base': yes
    'consistent-this': {}
    'no-unsafe-negation':
      'eslint-recommended': yes
      'airbnb-base': yes
    'spaced-comment':
      'airbnb-base': [
        'error'
        'always'
      ,
        line:
          exceptions: ['-', '+']
          markers: ['=', '!'] # space here to support sprockets directives
        block:
          exceptions: ['-', '+']
          markers: ['=', '!', ':', '::'] # space here to support sprockets directives and flow comment types
          balanced: true
      ]
    'capitalized-comments': {}
    'no-underscore-dangle':
      'airbnb-base': [
        'error'
      ,
        allow: []
        allowAfterThis: false
        allowAfterSuper: false
        enforceInMethodNames: true
      ]
      airbnb: [
        'error'
      ,
        allow: ['__REDUX_DEVTOOLS_EXTENSION_COMPOSE__']
        allowAfterThis: false
        allowAfterSuper: false
        enforceInMethodNames: true
      ]
    'prefer-template':
      'airbnb-base': yes
    'no-useless-escape':
      'eslint-recommended': yes
      'airbnb-base': yes
    'no-return-await':
      'airbnb-base': yes
    'no-anonymous-default-export':
      plugin: 'import'
    export:
      plugin: 'import'
      'airbnb-base': yes
    'no-commonjs':
      plugin: 'import'
    'no-default-export':
      plugin: 'import'
    'dynamic-import-chunkname':
      plugin: 'import'
    'no-lonely-if':
      'airbnb-base': yes
    'no-loop-func':
      'airbnb-base': yes
    'valid-jsdoc': {}
    'require-jsdoc': {}
    'multiline-comment-style': {}
    'no-div-regex': {}
    'no-extra-bind':
      'airbnb-base': yes
    'no-return-assign':
      'airbnb-base': ['error', 'always']
    'no-shadow':
      'airbnb-base': yes
    'no-class-assign':
      'eslint-recommended': yes
      'airbnb-base': yes
    'no-overwrite':
      plugin: no
    'block-scoped-var':
      'airbnb-base': yes
    'no-sequences':
      'airbnb-base': yes
    'no-empty-function':
      'airbnb-base': [
        'error'
      ,
        allow: ['arrowFunctions', 'functions', 'methods']
      ]
    'no-async-promise-executor':
      'airbnb-base': yes
    'array-bracket-newline':
      prettier: yes
    'array-bracket-spacing':
      prettier: yes
      'airbnb-base': ['error', 'never']
    'prefer-object-spread':
      'airbnb-base': yes
    'template-curly-spacing':
      prettier: yes
      'airbnb-base': yes
    'rest-spread-spacing':
      prettier: yes
      'airbnb-base': ['error', 'never']
    'no-multiple-empty-lines':
      prettier: yes
      'airbnb-base': ['error', {max: 2, maxBOF: 1, maxEOF: 0}]
    'newline-per-chained-call':
      prettier: yes
      'airbnb-base': ['error', {ignoreChainWithDepth: 4}]
    'no-multi-spaces':
      prettier: yes
      'airbnb-base': ['error', {ignoreEOLComments: no}]
    'array-element-newline':
      prettier: yes
    'wrap-regex':
      prettier: yes
    'keyword-spacing':
      prettier: yes
      'airbnb-base': [
        'error'
      ,
        before: true
        after: true
        overrides:
          return: after: true
          throw: after: true
          case: after: true
      ]
    'object-property-newline':
      prettier: yes
      'airbnb-base': ['error', {allowAllPropertiesOnSameLine: true}]
    'lines-around-comment':
      prettier: yes
    'function-paren-newline':
      prettier: yes
      'airbnb-base': ['error', 'consistent']
    'implicit-arrow-linebreak':
      prettier: yes
      'airbnb-base': ['error', 'beside']
    'no-mixed-operators':
      prettier: yes
      'airbnb-base': [
        'error'
      ,
        # the list of arthmetic groups disallows mixing `%` and `**`
        # with other arithmetic operators.
        groups: [
          ['%', '**']
          ['%', '+']
          ['%', '-']
          ['%', '*']
          ['%', '/']
          ['/', '*']
          ['&', '|', '<<', '>>', '>>>']
          ['==', '!=', '===', '!==']
          ['&&', '||']
        ]
        allowSamePrecedence: false
      ]
    'boolean-prop-naming':
      plugin: 'react'
    'default-props-match-prop-types':
      plugin: 'react'
      airbnb: ['error', {allowRequiredDefaults: no}]
    'destructuring-assignment':
      plugin: 'react'
      airbnb: ['error', 'always']
    'display-name':
      plugin: 'react'
      recommended: yes
    'forbid-prop-types':
      plugin: 'react'
      airbnb: [
        'error'
      ,
        forbid: ['any', 'array', 'object']
        checkContextTypes: true
        checkChildContextTypes: true
      ]
    'no-access-state-in-setstate':
      plugin: 'react'
      airbnb: yes
    'no-danger-with-children':
      plugin: 'react'
      airbnb: yes
    'no-deprecated':
      plugin: 'react'
      airbnb: yes
    'no-multi-comp':
      plugin: 'react'
    'no-redundant-should-component-update':
      plugin: 'react'
      airbnb: yes
    'no-render-return-value':
      plugin: 'react'
      airbnb: yes
    'no-typos':
      plugin: 'react'
      airbnb: yes
    'no-this-in-sfc':
      plugin: 'react'
      airbnb: yes
    'no-unescaped-entities':
      plugin: 'react'
      airbnb: yes
    'prefer-stateless-function':
      plugin: 'react'
      airbnb: ['error', {ignorePureComponents: yes}]
    'jsx-boolean-value':
      plugin: 'react'
      airbnb: ['error', 'never', {always: []}]
    'jsx-closing-bracket-location':
      plugin: 'react'
      prettier: yes
      airbnb: ['error', 'line-aligned']
    'jsx-first-prop-new-line':
      plugin: 'react'
      prettier: yes
      airbnb: ['error', 'multiline-multiprop']
    'jsx-handler-names':
      plugin: 'react'
    'jsx-indent':
      plugin: 'react'
      prettier: yes
      airbnb: ['error', 2]
    'jsx-key':
      plugin: 'react'
      recommended: yes
    'jsx-max-props-per-line':
      plugin: 'react'
      prettier: yes
      airbnb: ['error', {maximum: 1, when: 'multiline'}]
    'no-else-return':
      'airbnb-base': ['error', {allowElseIf: no}]
    'operator-linebreak':
      prettier: yes
      'airbnb-base': ['error', 'before', {overrides: '=': 'none'}]
    'jsx-no-bind':
      plugin: 'react'
      airbnb: [
        'error'
      ,
        ignoreRefs: true
        allowArrowFunctions: true
        allowFunctions: false
        allowBind: false
        ignoreDOMComponents: true
      ]
    'jsx-no-comment-textnodes':
      plugin: 'react'
      airbnb: yes
    'jsx-one-expression-per-line':
      plugin: 'react'
      prettier: yes
      airbnb: ['error', {allow: 'single-child'}]
    'jsx-sort-default-props':
      plugin: 'react'
    'jsx-tag-spacing':
      plugin: 'react'
      airbnb: [
        'error'
      ,
        closingSlash: 'never'
        beforeSelfClosing: 'always'
        afterOpening: 'never'
        beforeClosing: 'never'
      ]
    'jsx-wrap-multilines':
      plugin: 'react'
      prettier: yes
      airbnb: [
        'error'
      ,
        declaration: 'parens-new-line'
        assignment: 'parens-new-line'
        return: 'parens-new-line'
        arrow: 'parens-new-line'
        condition: 'parens-new-line'
        logical: 'parens-new-line'
        prop: 'parens-new-line'
      ]
    'no-unused-prop-types':
      plugin: 'react'
      airbnb: [
        'error'
      ,
        customValidators: []
        skipShapeProps: true
      ]
    'no-unused-state':
      plugin: 'react'
      airbnb: yes
    'prop-types':
      plugin: 'react'
      airbnb: [
        'error'
      ,
        ignore: []
        customValidators: []
        skipUndeclared: false
      ]
    'style-prop-object':
      plugin: 'react'
      airbnb: yes
    'sort-prop-types':
      plugin: 'react'
    'sort-comp':
      plugin: 'react'
      airbnb: [
        'error'
      ,
        order: [
          'static-variables'
          'static-methods'
          'instance-variables'
          'lifecycle'
          '/^on.+$/'
          'getters'
          'setters'
          '/^(get|set)(?!(InitialState$|DefaultProps$|ChildContext$)).+$/'
          'instance-methods'
          'everything-else'
          'rendering'
        ]
        groups:
          lifecycle: [
            'displayName'
            'propTypes'
            'contextTypes'
            'childContextTypes'
            'mixins'
            'statics'
            'defaultProps'
            'constructor'
            'getDefaultProps'
            'getInitialState'
            'state'
            'getChildContext'
            'getDerivedStateFromProps'
            'componentWillMount'
            'UNSAFE_componentWillMount'
            'componentDidMount'
            'componentWillReceiveProps'
            'UNSAFE_componentWillReceiveProps'
            'shouldComponentUpdate'
            'componentWillUpdate'
            'UNSAFE_componentWillUpdate'
            'getSnapshotBeforeUpdate'
            'componentDidUpdate'
            'componentDidCatch'
            'componentWillUnmount'
          ]
          rendering: ['/^render.+$/', 'render']
      ]
    'require-default-props':
      plugin: 'react'
      airbnb: ['error', {forbidDefaultForRequired: yes}]
    'implicit-object':
      plugin: no
      prettier: yes
    'implicit-call':
      plugin: no
      prettier: yes
    'empty-func-parens':
      plugin: no
      prettier: yes
    'id-match': {}
    'comma-style':
      prettier: yes
      'airbnb-base': [
        'error'
        'last'
      ,
        exceptions:
          ArrayExpression: no
          ArrayPattern: no
          ArrowFunctionExpression: no
          CallExpression: no
          FunctionDeclaration: no
          FunctionExpression: no
          ImportDeclaration: no
          ObjectExpression: no
          ObjectPattern: no
          VariableDeclaration: no
          NewExpression: no
      ]
    'no-unused-styles':
      plugin: 'react-native'
    'split-platform-components':
      plugin: 'react-native'
    'no-color-literals':
      plugin: 'react-native'
    'shorthand-this':
      plugin: no
    'spread-direction':
      plugin: no
    'id-length':
      'eslint-recommended': yes
    'no-new':
      'airbnb-base': yes
    'postfix-comprehension-assign-parens':
      plugin: no
    'no-nested-interpolation':
      plugin: no
    'no-private-function-fat-arrows':
      plugin: no
    'no-unnecessary-double-quotes':
      plugin: no
    'dot-location':
      prettier: yes
      'airbnb-base': ['error', 'property']
    'no-whitespace-before-property':
      'airbnb-base': yes
    'no-useless-computed-key':
      'airbnb-base': yes
    'no-useless-constructor':
      'airbnb-base': yes
    'callback-return': {}
    namespace:
      plugin: 'import'
    'no-unused-modules':
      plugin: 'import'
    'no-named-as-default-member':
      plugin: 'import'
      'airbnb-base': yes
    'no-deprecated--import':
      plugin: 'import'
      originalRuleName: 'no-deprecated'
    order:
      plugin: 'import'
      'airbnb-base': ['error', {groups: [['builtin', 'external', 'internal']]}]
    'no-named-export':
      plugin: 'import'
    'jsx-fragments':
      plugin: 'react'
      airbnb: ['error', 'syntax']
    'jsx-curly-newline':
      plugin: 'react'
      prettier: yes
      airbnb: [
        'error'
      ,
        multiline: 'consistent'
        singleline: 'consistent'
      ]
  )

configureAsError = flow(
  mapWithKey ({plugin, originalRuleName}, rule) -> [
    ["coffee/#{rule}", 'error']
    ...(
      unless plugin is no
        [
          [
            if plugin
              "#{plugin}/#{originalRuleName ? rule}"
            else
              rule
          ,
            'off'
          ]
        ]
      else
        []
    )
  ]
,
  flatten
  fromPairs
)

turnOn = flow(
  map (rule) -> [rule, 'error']
  fromPairs
)

turnOff = flow(
  map (rule) -> [rule, 'off']
  fromPairs
)

prettierConfig =
  extends: ['prettier']
  plugins: ['coffee']
  parser: 'eslint-plugin-coffee'
  rules: turnOff(
    flow(
      pickBy 'prettier'
      keys
      map (rule) -> "coffee/#{rule}"
    ) rules
  )

importConfig =
  plugins: ['import']
  settings:
    'import/extensions': ['.coffee', '.js', '.jsx']
    'import/parsers':
      'eslint-plugin-coffee/lib/parser': ['.coffee']
    'import/resolver':
      node:
        extensions: ['.coffee', '.js', '.jsx']

# would be "in the spirit" of the airbnb config to make changes:
# - import/extensions should include coffee: 'never'
# need to override these:
# - turn off jsx-filename-extension (since needs to be .coffee)
# airbnbConfig =
#   settings:
#     # override airbnb's .coffee ignore
#     'import/ignore': ['node_modules', '\\.(scss|css|less|hbs|svg|json)$']

module.exports = {
  rules: mapValues('module') rules
  configs:
    all:
      plugins: ['coffee']
      parser: 'eslint-plugin-coffee'
      rules: {
        ...configureAsError(omitBy('plugin') rules)
        ...turnOn(reject((rule) -> /\//.test rule) usable)
        ...turnOff(dontApply)
        ...turnOff(yet)
      }
    'eslint-recommended':
      plugins: ['coffee']
      parser: 'eslint-plugin-coffee'
      extends: ['eslint:recommended']
      rules: {
        ...configureAsError(pickBy('eslint-recommended') rules)
        ...turnOff(dontApply)
        ...turnOff(yet)
      }
    'react-recommended':
      plugins: ['coffee']
      parser: 'eslint-plugin-coffee'
      extends: ['plugin:react/recommended']
      rules: {
        ...configureAsError(pickBy(plugin: 'react', recommended: yes) rules)
        ...turnOff(dontApply)
        ...turnOff(yet)
      }
    'react-all':
      plugins: ['coffee']
      parser: 'eslint-plugin-coffee'
      extends: ['plugin:react/all']
      rules: {
        ...configureAsError(pickBy(plugin: 'react') rules)
        ...turnOff(dontApply)
        ...turnOff(yet)
      }
    import: importConfig
    'import-all': {
      ...importConfig
      rules: {
        ...turnOn(filter((rule) -> /^import\//.test rule) usable)
        ...configureAsError(pickBy(plugin: 'import') rules)
        ...turnOff(dontApply)
        ...turnOff(yet)
      }
    }
    prettier: prettierConfig
    'prettier-run-as-rule': {
      ...prettierConfig
      plugins: ['coffee', 'prettier']
      rules: {
        'prettier/prettier': ['error', {parser: 'coffeescript'}]
        ...prettierConfig.rules
      }
    }
  parseForESLint
}
