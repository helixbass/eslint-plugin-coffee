{
  flow
  map
  flatten
  fromPairs
  keys
  mapValues
  pickBy
  reject
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
]

# eslint-disable-next-line coffee/no-unused-vars
yet = [
  'no-extra-parens' # prettier: yes
  'strict'
  'comma-dangle' # prettier: yes
  'indent' # prettier: yes
  'multiline-ternary' # prettier: yes maybe this should be multiline-control and check all "inline" (non-postfix) forms of control structures (which use then)?
  'padded-blocks' # prettier: yes I think only leading padding would apply (since trailing padding is considered outside the block)
  'padding-line-between-statements' # I think only leading padding would apply (since trailing padding is considered outside the block)
  'quotes' # prettier: yes
  'no-dupe-else-if'
  'no-import-assign'
  'no-setter-return'
  'default-param-last'
  'grouped-accessor-pairs'
  'no-constructor-return'
  'no-useless-catch'
  'prefer-named-capture-group'
  'prefer-regex-literals'
  'function-call-argument-newline'
  'prefer-exponentiation-operator'
  'react/prefer-read-only-props'
  'react/state-in-constructor'
  'react/static-property-placement'
  'react/jsx-curly-newline'
  'react/jsx-no-script-url'
  'react/jsx-no-useless-fragment'
  'react/jsx-fragments'
  'react/jsx-props-no-spreading'
  'react/jsx-space-before-closing'
  'import/no-extraneous-dependencies'
  'import/unambiguous'
  'import/no-duplicates'
  'import/extensions'
  'import/order'
  'import/no-unassigned-import'
  'import/no-named-default'
  'import/no-named-export'
  'react-native/sort-styles'
  'react-native/no-raw-text'
  'react-native/no-single-element-style-arrays'
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
    'no-self-compare': {}
    'valid-typeof':
      'eslint-recommended': yes
    'no-negated-condition': {}
    yoda: {}
    camelcase: {}
    'dot-notation': {}
    'no-compare-neg-zero':
      'eslint-recommended': yes
    'no-unreachable':
      'eslint-recommended': yes
    'object-shorthand': {}
    'no-empty-character-class':
      'eslint-recommended': yes
    'no-extra-boolean-cast':
      'eslint-recommended': yes
    'no-regex-spaces':
      'eslint-recommended': yes
    'no-implicit-coercion': {}
    'no-magic-numbers': {}
    'no-self-assign':
      'eslint-recommended': yes
    'operator-assignment': {}
    'no-unused-expressions': {}
    'class-methods-use-this': {}
    'no-await-in-loop': {}
    'prefer-destructuring': {}
    'no-constant-condition':
      'eslint-recommended': yes
    'no-template-curly-in-string': {}
    'no-unneeded-ternary': {}
    'no-unmodified-loop-condition': {}
    'no-unused-vars':
      'eslint-recommended': yes
    'no-use-before-define': {}
    'max-depth': {}
    'vars-on-top': {}
    'guard-for-in': {}
    'no-useless-return': {}
    'arrow-spacing':
      prettier: yes
    'object-curly-spacing':
      prettier: yes
    'capitalized-class-names':
      plugin: no
    complexity: {}
    'max-len':
      prettier: yes
    'no-invalid-this': {}
    'lines-between-class-members': {}
    'max-lines-per-function': {}
    'no-backticks':
      plugin: no
    'space-infix-ops':
      prettier: yes
    'space-unary-ops':
      prettier: yes
    'english-operators':
      plugin: no
    'no-unnecessary-fat-arrow':
      plugin: no
    'no-this-before-super':
      'eslint-recommended': yes
    'no-cond-assign':
      'eslint-recommended': yes
    'no-inner-declarations':
      'eslint-recommended': yes
    'consistent-this': {}
    'no-unsafe-negation':
      'eslint-recommended': yes
    'spaced-comment': {}
    'capitalized-comments': {}
    'no-underscore-dangle': {}
    'prefer-template': {}
    'no-useless-escape':
      'eslint-recommended': yes
    'no-return-await': {}
    'no-anonymous-default-export':
      plugin: 'import'
    export:
      plugin: 'import'
    'no-commonjs':
      plugin: 'import'
    'no-default-export':
      plugin: 'import'
    'dynamic-import-chunkname':
      plugin: 'import'
    'no-lonely-if': {}
    'no-loop-func': {}
    'valid-jsdoc': {}
    'require-jsdoc': {}
    'multiline-comment-style': {}
    'no-div-regex': {}
    'no-extra-bind': {}
    'no-return-assign': {}
    'no-shadow': {}
    'no-class-assign':
      'eslint-recommended': yes
    'no-overwrite':
      plugin: no
    'block-scoped-var': {}
    'no-sequences': {}
    'no-empty-function': {}
    'no-async-promise-executor': {}
    'array-bracket-newline':
      prettier: yes
    'array-bracket-spacing':
      prettier: yes
    'prefer-object-spread': {}
    'template-curly-spacing':
      prettier: yes
    'rest-spread-spacing':
      prettier: yes
    'no-multiple-empty-lines':
      prettier: yes
    'newline-per-chained-call':
      prettier: yes
    'no-multi-spaces':
      prettier: yes
    'array-element-newline':
      prettier: yes
    'wrap-regex':
      prettier: yes
    'keyword-spacing':
      prettier: yes
    'object-property-newline':
      prettier: yes
    'lines-around-comment':
      prettier: yes
    'function-paren-newline':
      prettier: yes
    'implicit-arrow-linebreak':
      prettier: yes
    'no-mixed-operators':
      prettier: yes
    'boolean-prop-naming':
      plugin: 'react'
    'default-props-match-prop-types':
      plugin: 'react'
    'destructuring-assignment':
      plugin: 'react'
    'display-name':
      plugin: 'react'
      recommended: yes
    'forbid-prop-types':
      plugin: 'react'
    'no-access-state-in-setstate':
      plugin: 'react'
    'no-danger-with-children':
      plugin: 'react'
    'no-deprecated':
      plugin: 'react'
    'no-multi-comp':
      plugin: 'react'
    'no-redundant-should-component-update':
      plugin: 'react'
    'no-render-return-value':
      plugin: 'react'
    'no-typos':
      plugin: 'react'
    'no-this-in-sfc':
      plugin: 'react'
    'no-unescaped-entities':
      plugin: 'react'
    'prefer-stateless-function':
      plugin: 'react'
    'jsx-boolean-value':
      plugin: 'react'
    'jsx-closing-bracket-location':
      plugin: 'react'
      prettier: yes
    'jsx-first-prop-new-line':
      plugin: 'react'
      prettier: yes
    'jsx-handler-names':
      plugin: 'react'
    'jsx-indent':
      plugin: 'react'
      prettier: yes
    'jsx-key':
      plugin: 'react'
      recommended: yes
    'jsx-max-props-per-line':
      plugin: 'react'
      prettier: yes
    'no-else-return': {}
    'operator-linebreak':
      prettier: yes
    'jsx-no-bind':
      plugin: 'react'
    'jsx-no-comment-textnodes':
      plugin: 'react'
    'jsx-one-expression-per-line':
      plugin: 'react'
      prettier: yes
    'jsx-sort-default-props':
      plugin: 'react'
    'jsx-tag-spacing':
      plugin: 'react'
    'jsx-wrap-multilines':
      plugin: 'react'
      prettier: yes
    'no-unused-prop-types':
      plugin: 'react'
    'no-unused-state':
      plugin: 'react'
    'prop-types':
      plugin: 'react'
    'style-prop-object':
      plugin: 'react'
    'sort-prop-types':
      plugin: 'react'
    'sort-comp':
      plugin: 'react'
    'require-default-props':
      plugin: 'react'
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
    'no-new': {}
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
    'no-whitespace-before-property': {}
    'no-useless-computed-key': {}
    'no-useless-constructor': {}
    'callback-return': {}
    namespace:
      plugin: 'import'
    'no-unused-modules':
      plugin: 'import'
    'no-named-as-default-member':
      plugin: 'import'
    'no-deprecated--import':
      plugin: 'import'
      originalRuleName: 'no-deprecated'
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
      }
    'eslint-recommended':
      plugins: ['coffee']
      parser: 'eslint-plugin-coffee'
      extends: ['eslint:recommended']
      rules: {
        ...configureAsError(pickBy('eslint-recommended') rules)
        ...turnOff(dontApply)
      }
    'react-recommended':
      plugins: ['coffee']
      parser: 'eslint-plugin-coffee'
      extends: ['plugin:react/recommended']
      rules: {
        ...configureAsError(pickBy(plugin: 'react', recommended: yes) rules)
        ...turnOff(dontApply)
      }
    'react-all':
      plugins: ['coffee']
      parser: 'eslint-plugin-coffee'
      extends: ['plugin:react/all']
      rules: {
        ...configureAsError(pickBy(plugin: 'react') rules)
        ...turnOff(dontApply)
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
