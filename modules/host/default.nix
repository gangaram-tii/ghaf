# Copyright 2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
#
# Modules that should be only imported to host
#
{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (builtins) replaceStrings;
  cliArgs = replaceStrings [ "\n" ] [ " " ] ''
    --name ${config.ghaf.givc.adminConfig.name}
    --addr ${config.ghaf.givc.adminConfig.addr}
    --port ${config.ghaf.givc.adminConfig.port}
    ${lib.optionalString config.ghaf.givc.enableTls "--cacert /run/givc/ca-cert.pem"}
    ${lib.optionalString config.ghaf.givc.enableTls "--cert /run/givc/ghaf-host-cert.pem"}
    ${lib.optionalString config.ghaf.givc.enableTls "--key /run/givc/ghaf-host-key.pem"}
    ${lib.optionalString (!config.ghaf.givc.enableTls) "--notls"}
  '';
in
{
  networking.hostName = lib.mkDefault "ghaf-host";

  # Overlays should be only defined for host, because microvm.nix uses the
  # pkgs that already has overlays in place. Otherwise the overlay will be
  # applied twice.
  nixpkgs.overlays = [ (import ../../overlays/custom-packages) ];
  imports = [
    # To push logs to central location
    ../common/logging/client.nix
  ];

  systemd.services.display-suspend = {
    enable = true;
    description = "Display Suspend Service";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.givc-cli}/bin/givc-cli ${cliArgs} suspend";
    };
    wantedBy = [ "sleep.target" ];
    before = [ "sleep.target" ];
  };

  systemd.services.display-resume = {
    enable = true;
    description = "Display Resume Service";
    serviceConfig = {
      Type = "oneshot";
      #TODO: Double check target
      ExecStart = "${pkgs.givc-cli}/bin/givc-cli ${cliArgs} wakeup";
    };
    wantedBy = [ "suspend.target" ];
    after = [ "suspend.target" ];
  };
}
