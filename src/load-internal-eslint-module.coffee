pathModule = require 'path'

loadInternalEslintModule = (path) ->
  try
    require "eslint/#{path}"
  catch
    path = path.split '/'
    # per https://github.com/eslint/eslint/pull/14706#issuecomment-862329635
    require(
      pathModule.join(
        pathModule.resolve(pathModule.dirname(require.resolve 'eslint')),
        ...path[1...]
      )
    )

module.exports = {loadInternalEslintModule}
