{flow, map: fmap, flatten: fflatten, fromPairs: ffromPairs} = require 'lodash/fp'
fmapWithKey = fmap.convert cap: no

{parseForESLint} = require './parser'

rules = flow(
  fmap (rule) -> [rule, require "./rules/#{rule}"]
  ffromPairs
) [
  'use-isnan'
  'no-self-compare'
  'no-eq-null'
]

configureAsError = flow(
  fmapWithKey (_, rule) -> [
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
      parser: 'eslint-plugin-coffee'
      rules: configureAsError rules
  parseForESLint
}
