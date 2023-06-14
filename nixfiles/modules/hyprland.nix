{ config, pkgs, lib, ... }:
with lib;
let cfg = config.gavin.hyprland;
in
{
  options.gavin.hyprland = {
    enable = mkOption {
        type = types.bool;
        default = false;
    };
  };
  config = {
    programs.hyprland = {
      enable = cfg.enable;
      nvidiaPatches = true;
      xwayland.enable = true;
    };

    programs.regreet = {
      enable = cfg.enable;
      settings = fromTOML ''
        [background]
        path = "/home/gavin/Pictures/bg.jpg"

        [GTK]
        application_prefer_dark_theme = true
      '';
    };

    services.gnome.gnome-keyring.enable = cfg.enable;

    environment.sessionVariables.NIXOS_OZONE_WL = (if cfg.enable then "1" else null);

    environment.systemPackages = with pkgs; (if cfg.enable then [
      egl-wayland
      mesa
      libglvnd
      libdrm
      vulkan-tools
      seatd
      
      qt6.qtwayland
      qt5.qtwayland

      gnome.gnome-keyring
      gnome.libgnome-keyring
      gnome.seahorse
      gnome.file-roller
      polkit_gnome
      libsecret
      gnupg
      pass
      pkgconfig
      gnome.dconf-editor
      libinput
      glib
      gnome.nautilus
      xdg-utils
      libnotify

      gtk3
      gtk-layer-shell
      pango
      cairo
      gdk-pixbuf

      dunst

      swaybg
      cage

      wofi
      swaylock
      swayidle

      grim
      slurp

      eww-wayland

      jq
      socat
      pamixer
    ] else [ ]);

    systemd = {
        user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
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
    };
  };
}