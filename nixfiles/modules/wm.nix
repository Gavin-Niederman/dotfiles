{ config, pkgs, lib, ... }:
    with lib;
    let
        cfg = config.gavin.wm;

        dbus-sway-environment = pkgs.writeTextFile {
            name = "dbus-sway-environment";
            destination = "/bin/dbus-sway-environment";
            executable = true;

            text = ''
        dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
        systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
        systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
            '';
        };

        configure-gtk = pkgs.writeTextFile {
            name = "configure-gtk";
            destination = "/bin/configure-gtk";
            executable = true;
            text = let
                schema = pkgs.gsettings-desktop-schemas;
                datadir = "${schema}/share/gsettings-schemas/${schema.name}";
            in ''
                export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
                gnome_schema=org.gnome.desktop.interface
                gsettings set $gnome_schema gtk-theme 'Dracula'
                '';
        };
    in
    {
        options.gavin.wm = {
            i3 = {
                enable = mkOption {
                    type = types.bool;
                    default = false;
                    description = "Enable i3wm";
                };

                i3-gaps = mkOption {
                    type = types.bool;
                    default = false;
                    description = "Use the i3-gaps i3wm fork";
                };
            };

            awesome = {
                enable = mkOption {
                    type = types.bool;
                    default = false;
                    description = "Enable Awesome wm";
                };
            };

            sway = {
                enable = mkOption {
                    type = types.bool;
                    default = false;
                    description = "Enable sway wm";
                };
            };

            gnome-polkit = mkOption {
                type = types.bool;
                default = true;
                description = "Use the gnome polkit";
            };

            logid-service = mkOption {
                type = types.bool;
                default = true;
                description = "Start logid at launch";
            };
        };
        config = {
            services.dbus.enable = true;
            xdg.portal = {
                enable = true;
                wlr.enable = true;
                extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
            };

            services.xserver.windowManager.i3 = {
                enable = cfg.i3.enable;
                extraPackages = with pkgs; [
                    # dmenu
                    i3status 
                    i3lock-color
                    i3blocks
                ];
            };

            services.xserver.windowManager.awesome = {
                enable = cfg.awesome.enable;
                luaModules = with pkgs.luaPackages; [
                    luarocks
                    luadbi-mysql
                ];
            };

            services.xserver.displayManager.sddm.enable = cfg.awesome.enable;

            services.xserver.windowManager.i3.package = with pkgs; (if cfg.i3.i3-gaps then i3-gaps else i3 );
            services.xserver.displayManager.lightdm.background = "/backgrounds/bg-1.png";
            services.xserver.displayManager.lightdm.enable = cfg.i3.enable;
            services.xserver.displayManager.lightdm.greeters.slick = {
                enable = cfg.i3.enable;
                draw-user-backgrounds = false;
                extraConfig = ''
                background-color = #8ec07c
                show-clock = true
                clock-format = %H:%M:%S
                '';
            };

            programs.sway = {
                enable = cfg.sway.enable;
                wrapperFeatures.gtk = true;
            };

            systemd.user.services.picom = mkIf (cfg.i3.enable or cfg.awesome.enable) {
                wantedBy = [ "graphical-session.target" ];
                partOf = [ "graphical-session.target" ];

                serviceConfig = {
                    ExecStart = "${pkgs.picom}/bin/picom --config /home/gavin/.config/picom/picom.conf";
                    RestartSec = 3;
                    Restart = "always";
                };
            };

            programs.xwayland.enable = cfg.sway.enable;

            services.gnome.gnome-keyring.enable = true;
            
            environment.systemPackages = with pkgs;
                (if cfg.sway.enable then [
                    sway
                    dbus-sway-environment
                    configure-gtk
                    wayland
                    xdg-utils
                    glib
                    swaylock
                    swayidle
                    grim
                    slurp
                    wl-clipboard
                    bemenu
                    mako
                    logiops
                    escrotum
                    xclip
                ] else [
                    lxappearance
                    logiops
                    gnome.nautilus
                    feh
                    gnome.gnome-keyring
                    gnome.libgnome-keyring
                    gnome.seahorse
                    gnome.file-roller
                    monitor
                    xdg-utils
                    libsecret
                    gnupg
                    pass
                    pkgconfig
                    xorg.xorgserver
                    sysstat
                    killall
                    pulseaudio
                    flameshot
                    picom
                    rofi
                    polybar
                ]);

            systemd.user.services.polkit-gnome-authentication-agent-1 = {
                enable = cfg.gnome-polkit;
                wantedBy = [ "graphical-session.target" ];
                wants = [ "graphical-session.target" ];
                after = [ "graphical-session.target" ];
                serviceConfig = {
                    Type = "simple";
                    ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
                    Restart = "on-failure";
                    RestartSec = 1;
                    TimeoutStopSec = 10;
                };
            };
            systemd.services.logid = {
                enable = cfg.logid-service;
                wantedBy = [ "default.target" ];
                serviceConfig = {
                    Type = "simple";
                    ExecStart = "${pkgs.logiops}/bin/logid";
                };
            };
        };
    }
