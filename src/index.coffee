{
  flow
  concat: fconcat
  map: fmap
  flatten: fflatten
  fromPairs: ffromPairs
} = require 'lodash/fp'
fmapWithKey = fmap.convert cap: no

{parseForESLint} = require './parser'

unusable = ['no-sequences']

rules =
  flow(fmap((rule) -> [rule, require("./rules/#{rule}")]), ffromPairs) [
    'use-isnan'
    'no-self-compare'
    'no-eq-null'
    'valid-typeof'
    'no-negated-condition'
    'yoda'
    'camelcase'
    'dot-notation'
    'no-compare-neg-zero'
    'no-unreachable'
    'object-shorthand'
    'no-empty-character-class'
    'no-extra-boolean-cast'
    'no-regex-spaces'
    'no-implicit-coercion'
    'no-magic-numbers'
    'no-self-assign'
    'operator-assignment'
    'no-unused-expressions'
    'class-methods-use-this'
    'no-await-in-loop'
    'prefer-destructuring'
    'no-constant-condition'
    'no-template-curly-in-string'
    'no-unneeded-ternary'
    'no-unmodified-loop-condition'
    'no-unused-vars'
    'no-use-before-define'
    'max-depth'
    'vars-on-top'
    'guard-for-in'
    'no-useless-return'
    'arrow-spacing'
    'object-curly-spacing'
    'capitalized-class-names'
    'complexity'
    'max-len'
  ]

configureAsError = flow(
  fmapWithKey (_, rule) -> [["coffee/#{rule}", 'error'], [rule, 'off']]
  fflatten
  fconcat fmap((rule) -> [rule, 'off']) unusable
  ffromPairs
)

module.exports = {
  rules
  configs:
    all:
      plugins: ['coffee']
      parser: 'eslint-plugin-coffee'
      rules: configureAsError rules
  parseForESLint
}
