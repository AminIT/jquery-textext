{ opts } = $.fn.textext

describe 'utils', ->
  describe '.opts', ->
    hash =
      version : 1
      paramLength : 10
      settings :
        name : 'bob'
        paths :
          home : '/users'
          systemLogs : '/logs'
        hostNames :
          remoteEnd : 'bob-remote'

    it 'returns undefined without options', -> expect(opts null, 'version').toBe undefined
    it 'returns undefined when not found', -> expect(opts hash, 'invalid').toBe undefined
    it 'returns single word value', -> expect(opts hash, 'version').toBe 1
    it 'returns two word option', -> expect(opts hash, 'paramLength').toBe 10

    describe 'nested values', ->
      describe 'separated with camel casing', ->
        it 'returns values one level deep', -> expect(opts hash, 'settingsName').toBe 'bob'
        it 'returns values two levels deep', -> expect(opts hash, 'settingsPathsHome').toBe '/users'

      describe 'separated with dot', ->
        it 'returns values one level deep', -> expect(opts hash, 'settings.name').toBe 'bob'
        it 'returns values two levels deep', -> expect(opts hash, 'settings.paths.home').toBe '/users'

      describe 'separated with dash', ->
        it 'returns values one level deep', -> expect(opts hash, 'settings-name').toBe 'bob'
        it 'returns values two levels deep', -> expect(opts hash, 'settings-paths-home').toBe '/users'

      describe 'separated with underscore', ->
        it 'returns values one level deep', -> expect(opts hash, 'settings_name').toBe 'bob'
        it 'returns values two levels deep', -> expect(opts hash, 'settings_paths_home').toBe '/users'

      describe 'mixed separation', ->
        it 'returns values two levels deep using casing', -> expect(opts hash, 'settings_pathsHome').toBe '/users'
        it 'returns values two levels deep and mixed name', -> expect(opts hash, 'settings_paths_systemLogs').toBe '/logs'
        it 'returns values two levels deep and mixed names at multiple levels', -> expect(opts hash, 'settings_hostNames_remoteEnd').toBe 'bob-remote'
