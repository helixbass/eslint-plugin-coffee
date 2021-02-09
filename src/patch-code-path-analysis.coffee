CodePathAnalyzer = require './code-path-analysis/code-path-analyzer'

PROGRAM_NODE_KEY = '__coffee__'

monkeypatchMethod = (ESLintCodePathAnalyzer, isCurrentFileCoffeescript, key) ->
  original = ESLintCodePathAnalyzer::[key]
  dynamicallyDelegatingMonkeypatch = (...args) ->
    if isCurrentFileCoffeescript.current
      # eslint-disable-next-line coffee/no-invalid-this
      CodePathAnalyzer::[key].apply @, args
    else
      # eslint-disable-next-line coffee/no-invalid-this
      original.apply @, args
  if key is 'enterNode'
    ESLintCodePathAnalyzer::[key] = (...args) ->
      [node] = args
      isCurrentFileCoffeescript.current = !!node[PROGRAM_NODE_KEY] if (
        node?.type is 'Program'
      )
      dynamicallyDelegatingMonkeypatch.apply @, args
  else
    ESLintCodePathAnalyzer::[key] = dynamicallyDelegatingMonkeypatch

module.exports =
  patchCodePathAnalysis: ->
    try
      ESLintCodePathAnalyzer = require(
        'eslint/lib/code-path-analysis/code-path-analyzer'
      )
    catch
      try
        ESLintCodePathAnalyzer = require(
          'eslint/lib/linter/code-path-analysis/code-path-analyzer'
        )
      catch
        throw new ReferenceError "Couldn't resolve eslint CodePathAnalyzer"
    return if ESLintCodePathAnalyzer.__monkeypatched
    # ESLintCodePathAnalyzer:: = CodePathAnalyzer::
    isCurrentFileCoffeescript = current: no
    monkeypatchMethod(
      ESLintCodePathAnalyzer
      isCurrentFileCoffeescript
      key
    ) for key in ['enterNode', 'leaveNode', 'onLooped']
    ESLintCodePathAnalyzer.__monkeypatched = yes
  PATCH_CODE_PATH_ANALYSIS_PROGRAM_NODE_KEY: PROGRAM_NODE_KEY
