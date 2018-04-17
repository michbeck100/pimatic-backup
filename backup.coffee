module.exports = (env) ->

  md5 = require 'md5'
  Client = require 'ftp'

  class BackupPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>

      @prev_hash = ''
      #create a client
      @client = new Client()

      # Set the connection options
      @client.connect({
        host: @config.host,
        port: @config.port,
        user: @config.username,
        password: @config.password
      })

      # When ready start backup
      @client.on "ready", =>
        @createBackup()
        setInterval () =>
          @createBackup()
        ,  @config.interval * 3600000

    createBackup: ->
      config = JSON.stringify(@framework.config)
      hash = md5(config)

      if @prev_hash != hash
        env.logger.debug "Creating backup"
        timestamp = new Date().toLocaleString()
        @config.path.endsWith('/') ? slash = '' : slash = '/'
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