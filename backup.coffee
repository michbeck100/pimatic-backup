module.exports = (env) ->

  md5 = require 'md5'
  Client = require 'ftp'

  class BackupPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>

      @prev_hash = ''
      #create a client
      @client = new Client()

      # Catch any error
      @client.on "error", (err) =>
        env.logger.error err

      # When ready start backup
      @client.on "ready", =>
        @createBackup()
        setInterval () =>
          @createBackup()
        ,  @config.interval * 3600000

      # Set the connection options
      @client.connect({
        host: @config.host,
        port: @config.port,
        user: @config.username,
        password: @config.password
      })

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
        # If the path does not end with a slash, add one
        if @config.path.endsWith('/')
          slash = ''
        else
          slash = '/'
        # Upload the config to the server
        @client.put config, @config.path + slash + timestamp + '.json', (err) =>
          if err
            env.logger.error err
          else
            @prev_hash = hash
            env.logger.debug "Backup created"
      else
        env.logger.debug "Hash still the same, don't backup"

  backupPlugin = new BackupPlugin
  return backupPlugin