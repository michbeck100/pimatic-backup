module.exports = (env) ->

  events = env.require 'events'
  md5 = require 'md5'

  class BackupPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>

      @prev_hash = ''
      #create a client
      if @config.driver == 'FTP'
        @driver = new FtpDriver(@config.driverOptions)

      @driver.on "ready", =>
        @createBackup()
        setInterval () =>
          @createBackup()
        , @config.interval * 3600000

    createBackup: ->
      # Get the config and convert it to a string
      config = JSON.stringify(@framework.config)
      # Generate a md5 hash of the current config
      hash = md5(config)
      # Check if the hash is the same as the backup before
      # If not the same create a new backup
      if @prev_hash != hash
        env.logger.debug "Creating backup"
        # Create a timestamp to identify the backup
        timestamp = new Date().toLocaleString()
        # Upload the config to the server
        @driver.upload(config, timestamp + '.json')
        @prev_hash = hash
      else
        env.logger.debug "Hash still the same, don't backup"

  class FtpDriver extends events.EventEmitter

    constructor: (options) ->

      @options = options
      FtpClient = require 'ftp'
      @client = new FtpClient()

      # Catch any error
      @client.on "error", (err) =>
        env.logger.error err

      # When ready start backup
      @client.on "ready", =>
        @emit "ready"

      # Set the connection options
      @client.connect({
        host: @options.host,
        port: @options.port or 21,
        user: @options.username,
        password: @options.password
      })

    upload: (data, name) =>
      # If the path does not end with a slash, add one
      if @options.path.endsWith('/')
        slash = ''
      else
        slash = '/'
      @client.put data, @options.path + slash + name, (err) =>
        if err
          env.logger.error err
        else
          env.logger.debug "Backup created"

  backupPlugin = new BackupPlugin
  return backupPlugin