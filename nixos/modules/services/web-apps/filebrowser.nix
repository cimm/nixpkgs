{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.filebrowser;
in
{
  options = {
    services.filebrowser = {
      enable = mkEnableOption "File Browser";

      address = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Address to listen on.";
      };

      baseUrl = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Base URL path (everything after the FQDN).";
      };

      cacheDir = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "File cache directory (disabled if omitted). Needs to be a subdirectory of /var/lib/filebrowser since the service is sandboxed.";
      };

      cert = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "TLS certificate.";
      };

      database = mkOption {
        type = types.nullOr types.path;
        default = "/var/lib/filebrowser/filebrowser.db";
        description = "Path to the database. Needs live somewhere under /var/lib/filebrowser since the service is sandboxed.";
      };

      disableExec = mkOption {
        type = types.bool;
        default = false;
        description = "Disables the Command Runner feature.";
      };

      disablePreviewResize = mkOption {
        type = types.bool;
        default = false;
        description = "Disables resizing of image previews.";
      };

      disableThumbnails = mkOption {
        type = types.bool;
        default = false;
        description = "Disables image thumbnails.";
      };

      disableTypeDetectionByHeader = mkOption {
        type = types.bool;
        default = false;
        description = "Disables type detection by reading file headers.";
      };

      imgProcessors = mkOption {
        type = types.ints.positive;
        default = 4;
        description = "Image processors count.";
      };

      key = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "TLS key.";
      };

      log = mkOption {
        type = types.str;
        default = "stdout";
        description = "Where to log the output to.";
      };

      noauth = mkOption {
        type = types.bool;
        default = false;
        description = "Use the noauth auther when using quick setup.";
      };

      password = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Hashed password for the first user when using quick setup (default \"admin\").";
      };

      port = mkOption {
        type = types.port;
        default = 8080;
        description = "Port to listen on.";
      };

      root = mkOption {
        type = types.path;
        default = "/var/lib/filebrowser/files";
        description = "Root to prepend to relative paths. Needs to be a subdirectory of /var/lib/filebrowser since the service is sandboxed.";
      };

      socket = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Socket to listen to (cannot be used in combination with the address, port, cert nor key options).";
      };

      socketPerm = mkOption {
        type = types.ints.u32;
        default = 438;
        description = "Unix socket file permissions.";
      };

      username = mkOption {
        type = types.str;
        default = "admin";
        description = "Username for the first user when using quick setup.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.filebrowser = {
      after = [ "network.target" ];
      description = "File Browser";
      path = [ pkgs.getent ];
      serviceConfig = {
        DevicePolicy = "no";
        DynamicUser = "yes";
        ExecStart = ''
	        ${pkgs.filebrowser}/bin/filebrowser \
          ${optionalString (cfg.address != "127.0.0.1") "--address ${escapeShellArg cfg.address}"} \
          ${optionalString (cfg.baseUrl != null) "--baseurl ${escapeShellArg cfg.baseUrl}"} \
          ${optionalString (cfg.cacheDir != null) "--cache-dir ${escapeShellArg cfg.cacheDir}"} \
          ${optionalString (cfg.cert != null) "--cert ${escapeShellArg cfg.cert}"} \
          --database ${escapeShellArg cfg.database} \
	        ${optionalString cfg.disableExec "--disable-exec"} \
	        ${optionalString cfg.disablePreviewResize "--disable-preview-resize"} \
	        ${optionalString cfg.disableThumbnails "--disable-thumbnails"} \
	        ${optionalString cfg.disableTypeDetectionByHeader "--disable-type-detection-by-header"} \
	        ${optionalString (cfg.imgProcessors != 4) "--img-processors ${toString cfg.imgProcessors}"} \
          ${optionalString (cfg.key != null) "--key ${escapeShellArg cfg.key}"} \
          ${optionalString (cfg.log != "stdout") "--log ${escapeShellArg cfg.log}"} \
	        ${optionalString cfg.noauth "--noauth"} \
          ${optionalString (cfg.password != null) "--password ${escapeShellArg cfg.password}"} \
	        --root "${escapeShellArg cfg.root}" \
	        ${optionalString (cfg.port != 8080) "--port ${toString cfg.port}"} \
          ${optionalString (cfg.socket != null) "--socket ${escapeShellArg cfg.socket}"} \
          ${optionalString (cfg.socketPerm != 438) "--socket-perm ${toString cfg.socketPerm}"} \
          ${optionalString (cfg.username != "admin") "--username ${escapeShellArg cfg.username}"}
	      '';
        LockPersonality = "yes";
        MemoryDenyWriteExecute = "yes";
        PrivateDevices = "yes";
        ProtectControlGroups = "yes";
        ProtectKernelModules = "yes";
        ProtectKernelTunables = "yes";
        Restart = "on-failure";
        RestrictNamespaces = "yes";
        RestrictRealtime = "yes";
        RestrictSUIDSGID = "yes";
        StateDirectory = "filebrowser";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
