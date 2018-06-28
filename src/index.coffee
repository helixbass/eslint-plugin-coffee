{flow, map: fmap, flatten: fflatten, fromPairs: ffromPairs} = require 'lodash/fp'

{parseForESLint} = require './parser'

rules = flow(
  (rule) -> [rule, require "./rules/#{rule}"]
  ffromPairs
) [
  'use-isnan'
]

configureAsError = flow(
  fmap (rule) -> [
    ["coffee/#{rule}", "error"]
    [rule, "off"]
  ]
  fflatten
  ffromPairs
)

module.exports = {
  rules
  configs:
    all:
      plugins: ['coffee']
      parser: 'coffee-eslint'
      rules: configureAsError rules
  parseForESLint
}
