fs            = require "fs-extra"
path          = require 'path'
uuid          = require 'node-uuid'
# sauce         = require '../sauce/sauce.coffee'
chokidar      = require 'chokidar'
IdGenerator   = require './id_generator'
Log           = require "./log"
SecretSauce   = require "../lib/util/secret_sauce_loader"

class Socket
  fs: fs
  Log: Log

  constructor: (io, app) ->
    if not (@ instanceof Socket)
      return new Socket(io, app)

    if not app
      throw new Error("Instantiating lib/socket requires an app!")

    if not io
      throw new Error("Instantiating lib/socket requires an io instance!")

    @app         = app
    @io          = io
    @idGenerator = IdGenerator(@app)

  startListening: ->
    @_startListening(chokidar, path).then (watchedFiles) =>

      ## when our app closes lets nuke the
      ## watched files and close down io
      @app.once "close", @close.bind(@, watchedFiles)

      return watchedFiles

  close: (watchedFiles) ->
    @io.close()

    watchedFiles.close() if watchedFiles

SecretSauce.mixin("Socket", Socket)

module.exports = Socket