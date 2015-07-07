LogView = require './log-view'
{CompositeDisposable} = require 'atom'
{spawn} = require 'child_process'
AnsiHtmlStream = require 'ansi-html-stream'

module.exports = Android =
  subscriptions: null
  logView: null

  activate: (state) ->
    @logView = new LogView

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'android:build-gradle': => @buildGradle()

  deactivate: ->
    @subscriptions.dispose()
    @logView.destroy()

  buildGradle: ->
    @logView.open()

    editor = atom.workspace.getActiveTextEditor()
    rootDirs = atom.project.rootDirectories

    for i in [0...rootDirs.length]
      if rootDirs[i].contains editor.getPath()
        currentRootDir = rootDirs[i].path
        break

    options =
      cwd: currentRootDir
      env: process.env
    build = spawn "gradle", ["assembleDebug", "--console=rich"], options

    ansiHtmlStream = AnsiHtmlStream()

    ansiHtmlStream.on 'data', (data) =>
      @logView.addLine data

    build.stdout.pipe ansiHtmlStream

    build.stderr.on 'data', (data) ->
      console.log "stderr: #{data}"

    build.on 'close', (code) ->
      alert "Build completed successfully." if code is 0
      alert "Build faield. code #{code}" if code is not 0
      console.log "child process exited with code: #{code}"
