# defaultParserOptions =
#   ecmaVersion: 2018
#   ecmaFeatures:
#     experimentalObjectRestSpread: yes
#     jsx: yes

parserOptionsMapper = ({code, errors, options = [], parserOptions = {}}) -> {
  code
  errors
  options
  parserOptions: {
    # ...defaultParserOptions
    ...parserOptions
  }
}

module.exports = default: parserOptionsMapper
