{ config, pkgs, lib, ... }:
    with lib;
    let
        cfg = config.gavin.build-tools;
    in
    {
        options.gavin.build-tools = {
            rust = {
                enable = mkOption {
                    type = types.bool;
                    default = true;
                    description = "Enable rust build tools";
                };
            };
            java = {
                enable = mkOption {
                    type = types.bool;
                    default = true;
                    description = "Enable java build tools";
                };
            };
            javascript = {
                enable = mkOption {
                    type = types.bool;
                    default = true;
                    description = "Enable javascript build tools";
                };
            };
            dotnet = {
                enable = mkOption {
                    type = types.bool;
                    default = true;
                    description = "Enable dotnet build and running tools";
                };
            };
        };
        config = {
            environment.systemPackages = with pkgs;
                (if cfg.rust.enable then [ rustup neovide neovim bacon gcc ] else [])
                ++ 
                (if cfg.java.enable then [ jdk ] else [])
                ++
                (if cfg.javascript.enable then [ nodejs nodePackages.npm nodePackages.pnpm ] else [])
                ++
                (if cfg.dotnet.enable then [ dotnet-runtime dotnet-sdk mono ] else []);
        };
    }
