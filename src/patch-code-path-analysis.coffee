CodePathAnalyzer = require './code-path-analysis/code-path-analyzer'

module.exports = ->
  try
    ESLintCodePathAnalyzer = require(
      'eslint/lib/code-path-analysis/code-path-analyzer'
    )
  catch
    throw new ReferenceError "Couldn't resolve eslint CodePathAnalyzer"
  return if ESLintCodePathAnalyzer.__monkeypatched
  # ESLintCodePathAnalyzer:: = CodePathAnalyzer::
  for key in ['enterNode', 'leaveNode', 'onLooped']
    ESLintCodePathAnalyzer::[key] = CodePathAnalyzer::[key]
  ESLintCodePathAnalyzer.__monkeypatched = yes
