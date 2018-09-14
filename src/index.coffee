{
  flow
  map: fmap
  flatten: fflatten
  fromPairs: ffromPairs
  mapValues: fmapValues
  pickBy: fpickBy
} = require 'lodash/fp'
fmapWithKey = fmap.convert cap: no

{parseForESLint} = require './parser'

# eslint-disable-next-line coffee/no-unused-vars
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
  'dot-location'
  'max-classes-per-file'
  'no-alert'
  'no-caller'
  'no-eval'
  'no-extend-native'
  'no-global-assign' # only ++ applies since we generate declarations on other write references
  'no-implied-eval'
  'no-iterator'
  'no-multi-str'
  'no-new'
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
  'callback-return'
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
  'id-length'
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
  'no-useless-computed-key'
  'no-useless-constructor'
  'no-useless-rename'
  'prefer-numeric-literals'
  'prefer-rest-params'
  'prefer-spread'
  'sort-imports'
  'symbol-description'
  'no-catch-shadow'
  'import/no-webpack-loader-syntax'
  'import/prefer-default-export'
  'import/first'
  'import/no-amd'
  'import/no-nodejs-modules'
  'import/exports-last'
  'import/no-namespace'
  'import/prefer-default-export'
  'import/max-dependencies'
  'import/newline-after-export'
  'import/group-exports'
  'no-misleading-character-class'
  'require-unicode-regexp'
  'unicode-bom'
  'no-tabs'
  'no-trailing-spaces'
  'quote-props'
  'require-atomic-updates'
  'no-floating-decimal'
  'no-whitespace-before-property'
  'computed-property-spacing'
  'no-undef'
]

# eslint-disable-next-line coffee/no-unused-vars
yet = [
  'no-extra-parens'
  'no-else-return' # since we conflate else [nested if] with else if, can't currently just disallow the former
  'strict'
  'comma-dangle'
  'comma-style'
  'function-paren-newline'
  'id-match'
  'implicit-arrow-linebreak'
  'indent'
  'jsx-quotes'
  'lines-around-comment'
  'multiline-ternary' # maybe this should be multiline-control and check all "inline" (non-postfix) forms of control structures (which use then)?
  'no-mixed-operators'
  'operator-linebreak' # mostly doesn't apply as leading operators aren't allowed (when leading logical lands, could support that). could support "none" (don't allow breaking operators)
  'padded-blocks' # I think only leading padding would apply (since trailing padding is considered outside the block)
  'padding-line-between-statements' # I think only leading padding would apply (since trailing padding is considered outside the block)
  'quotes'
  'space-in-parens'
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
  'import/no-mutable-export' # since you can't control whether an exported member is const - might be nice to implement its "possible future behavior" of checking whether it in fact does get reassigned?)
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
]

rules =
  flow(
    fmapWithKey (config, rule) -> [
      rule
    ,
      {
        ...config
        module: require "./rules/#{rule}"
      }
    ]
    ffromPairs
  )(
    'use-isnan':
      'eslint-recommended': yes
    'no-self-compare': {}
    'no-eq-null': {}
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
    'arrow-spacing': {}
    'object-curly-spacing': {}
    'capitalized-class-names':
      plugin: no
    complexity: {}
    'max-len': {}
    'no-invalid-this': {}
    'lines-between-class-members': {}
    'max-lines-per-function': {}
    'no-backticks':
      plugin: no
    'space-infix-ops': {}
    'space-unary-ops': {}
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
    'array-bracket-newline': {}
    'array-bracket-spacing': {}
    'prefer-object-spread': {}
    'template-curly-spacing': {}
    'rest-spread-spacing': {}
    'no-multiple-empty-lines': {}
    'newline-per-chained-call': {}
    'no-multi-spaces': {}
    'array-element-newline': {}
    'wrap-regex': {}
    'keyword-spacing': {}
    'object-property-newline': {}
  )

configureAsError = flow(
  fmapWithKey ({plugin}, rule) -> [
    ["coffee/#{rule}", 'error']
    ...(
      unless plugin is no
        [
          [
            if plugin
              "#{plugin}/#{rule}"
            else
              rule
            'off'
          ]
        ]
      else
        []
    )
  ]
  fflatten
  ffromPairs
)

turnOff = flow fmap((rule) -> [rule, 'off']), ffromPairs

module.exports = {
  rules: fmapValues('module') rules
  configs:
    all:
      plugins: ['coffee']
      parser: 'eslint-plugin-coffee'
      rules: {
        ...configureAsError(rules)
        ...turnOff(dontApply)
        # ...turnOff(unusable)
      }
    'eslint-recommended':
      plugins: ['coffee']
      parser: 'eslint-plugin-coffee'
      rules: {
        ...configureAsError(fpickBy('eslint-recommended') rules)
        ...turnOff(dontApply)
        # ...turnOff(unusable)
      }
  parseForESLint
}
