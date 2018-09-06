CodePathAnalyzer = require './code-path-analysis/code-path-analyzer'

module.exports = ->
  ESLintCodePathAnalyzer = require(
    'eslint/lib/code-path-analysis/code-path-analyzer'
  )
  throw new ReferenceError "Couldn't resolve eslint CodePathAnalyzer" unless (
    ESLintCodePathAnalyzer
  )
  # ESLintCodePathAnalyzer:: = CodePathAnalyzer::
  for key in ['enterNode', 'leaveNode', 'onLooped']
    ESLintCodePathAnalyzer::[key] = CodePathAnalyzer::[key]
  ESLintCodePathAnalyzer.__monkeypatched = yes
