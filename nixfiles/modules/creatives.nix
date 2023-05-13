{ config, pkgs, lib, ... }:
    with lib;
    let
        cfg = config.gavin.creatives;
    in
    {
        options.gavin.creatives = {
            image-editing = {
                enable = mkOption {
                    type = types.bool;
                    default = true;
                    description = "Enable image editing tools";
                };
            };
            modeling = {
                enable = mkOption {
                    type = types.bool;
                    default = true;
                    description = "Enable modeling tools";
                };
            };
            video-creation = {
                enable = mkOption {
                    type = types.bool;
                    default = true;
                    description = "Enable video creation tools";
                };
            };
        };
        config = {
            environment.systemPackages = with pkgs;
                (if cfg.image-editing.enable then [ gimp inkscape ] else [ ])
                ++
                (if cfg.video-creation.enable then [ obs-studio obs-studio-plugins.obs-pipewire-audio-capture davinci-resolve ffmpeg ] else [ ])
                ++
                (if cfg.modeling.enable then [ blender ] else [ ]);
        };
    }
