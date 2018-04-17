module.exports = {
  title: "Backup config"
  type: "object"
  properties:
    debug:
      description: "Log information for debugging"
      type: "boolean"
      default: false
    interval:
      description: "The inteval for creating backups"
      type: "integer"
      default: 24
    driver:
      description: "The backup driver to use"
      type: "string"
      enum: ["FTP"]
      defines:
        property: "driverOptions"
        options:
          FTP:
            title: "FTP driver options"
            type: "object"
            properties:
              host:
                description: "Url to the backup server"
                type: "string"
              port:
                description: "Port of the backup server"
                type: "number"
                default: 21
              username:
                description: "Username of the backup server"
                type: "string"
              password:
                description: "Password of the backup server"
                type: "string"
              path:
                description: "Remote path of the backup server where the config should be saved"
                type: "string"
    driverOptions:
      description: "Options for the driver"
      type: "object"
}