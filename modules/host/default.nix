# Copyright 2022-2023 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    # TODO remove this when the minimal config is defined
    # Replace with the baseModules definition
    # UPDATE 26.07.2023:
    # This line breaks build of GUIVM. No investigations of a
    # root cause are done so far.
    #(modulesPath + "/profiles/minimal.nix")

    ../../overlays/custom-packages

    ./kernel.nix

    # TODO: Refactor this under virtualization/microvm/host/networking.nix
    ./networking.nix
  ];

  config = {
    networking.hostName = "ghaf-host";
    system.stateVersion = lib.trivial.release;
    nix.enable = config.ghaf.profiles.debug.enable;

    ####
    # temp means to reduce the image size
    # TODO remove this when the minimal config is defined
    appstream.enable = false;
    boot.enableContainers = false;
    ##### Remove to here
  };
}
