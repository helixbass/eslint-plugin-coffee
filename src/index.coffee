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

unusable = ['no-sequences']

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
        ...turnOff(unusable)
      }
    'eslint-recommended':
      plugins: ['coffee']
      parser: 'eslint-plugin-coffee'
      rules: {
        ...configureAsError(fpickBy('eslint-recommended') rules)
        ...turnOff(dontApply)
        ...turnOff(unusable)
      }
  parseForESLint
}
