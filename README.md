# pimatic-backup
Backup your pimatic config via FTP

### Options

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
    interval:
      description: "Backup interval in hours"
      type: "number"
      default: 24