{
  description = "NixOS for Raspberry Pi 5 (via rpi-nix)";

  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixos-25.11";
    rpi-nix.url      = "github:nix-community/raspberry-pi-nix";
  };

  outputs = { self, nixpkgs, rpi-nix, ... }:
  let
    system = "aarch64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ rpi-nix.overlays.core ];
    };
  in {
    nixosConfigurations.pi5 = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        # Pi hardware + firmware
        rpi-nix.nixosModules."raspberry-pi"
        # SD-image builder
        rpi-nix.nixosModules."sd-image"

        # Your custom settings:
        ({ config, pkgs, ... }: {
          # <-- tell it which SoC you have:
          raspberry-pi-nix.board = "bcm2712";

          networking.hostName       = "my-pi";
          users.users.pi = {
            isNormalUser            = true;
            extraGroups             = [ "wheel" ];
          };
          environment.systemPackages = with pkgs; [ vim git ];
          services.openssh.enable   = true;
        })
      ];

      # point nixosSystem at the pkg set we imported
      pkgs = pkgs;
    };
  };
}
