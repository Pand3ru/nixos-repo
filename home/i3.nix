{ config, pkgs, ...}:
let
  wallpaper = "/home/panderu/nixos/assets/wallpaper.png";
  fontName = "JetBrainsMono Nerd Font";
  fontSize = 12;
in
{
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = "Mod4";
      terminal = "${pkgs.alacritty}/bin/alacritty";
      bars = [];
      workspaceLayout = "default";
      
      fonts = {
        names = [ fontName ];
        size = fontSize * 1.0;
      };

      keybindings = let
        mod = "Mod4";
      in {
         # === WORKSPACE NAVIGATION (Super + hjkl;) ===
        "${mod}+j" = "workspace dev[j]";
        "${mod}+k" = "workspace media[k]";
        "${mod}+l" = "workspace chat[l]";
        "${mod}+semicolon" = "workspace settings[semicolon]";
        "${mod}+h" = "workspace ffa[h]";

        # === MOVE WINDOW TO WORKSPACE (Super + Shift + hjkl;) ===
        "${mod}+Shift+j" = "move container to workspace dev[j]";
        "${mod}+Shift+k" = "move container to workspace media[k]";
        "${mod}+Shift+l" = "move container to workspace chat[l]";
        "${mod}+Shift+semicolon" = "move container to workspace settings[semicolon]";
        "${mod}+Shift+h" = "move container to workspace ffa[h]";

        # === WINDOW SELECTION (Alt + jk) ===
        "Mod1+j" = "focus left";
        "Mod1+k" = "focus right";

        # === ACTIONS (Alt) ===
        "${mod}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
        "Mod1+semicolon" = "exec ${pkgs.bemenu}/bin/bemenu-run";
        "${mod}+comma" = "kill";
        "Mod1+l" = "exec ${pkgs.i3lock}/bin/i3lock -c 000000";

        # === LAYOUT (Super) ===
        "${mod}+f" = "layout toggle tabbed split";
        "${mod}+a" = "floating toggle";

        # === SYSTEM ===
        "${mod}+Shift+r" = "restart";      };

      modes = {
        resize = {
          "h" = "resize shrink width 10 px or 10 ppt";
          "j" = "resize grow height 10 px or 10 ppt";
          "k" = "resize shrink height 10 px or 10 ppt";
          "l" = "resize grow width 10 px or 10 ppt";
          "Escape" = "mode default";
          "Return" = "mode default";
        };
      };

      startup = [
        { command = "${pkgs.pywal}/bin/wal -i ${wallpaper}"; always = true; }
        { command = "${pkgs.feh}/bin/feh --bg-scale ${wallpaper}"; always = true; }
      ];
      window.commands = [
        # === MEDIA WORKSPACE ===
        { criteria = { class = "firefox"; }; command = "move to workspace media[k]"; }
        { criteria = { class = "Firefox"; }; command = "move to workspace media[k]"; }
        { criteria = { class = "Spotify"; }; command = "move to workspace media[k]"; }
        { criteria = { class = "spotify"; }; command = "move to workspace media[k]"; }

        # === CHAT WORKSPACE ===
        { criteria = { class = "Signal"; }; command = "move to workspace chat[l]"; }
        { criteria = { class = "signal"; }; command = "move to workspace chat[l]"; }
        { criteria = { class = "thunderbird"; }; command = "move to workspace chat[l]"; }
        { criteria = { class = "Thunderbird"; }; command = "move to workspace chat[l]"; }
        { criteria = { class = "discord"; }; command = "move to workspace chat[l]"; }
        { criteria = { class = "Discord"; }; command = "move to workspace chat[l]"; }

        # === SETTINGS WORKSPACE ===
        { criteria = { class = "^Xfce4-.*"; }; command = "move to workspace settings[semicolon]"; }
        { criteria = { class = "Arandr"; }; command = "move to workspace settings[semicolon]"; }
        { criteria = { class = "Pavucontrol"; }; command = "move to workspace settings[semicolon]"; }
        { criteria = { class = "Blueman-manager"; }; command = "move to workspace settings[semicolon]"; }

        # === FLOATING WINDOWS ===
        { criteria = { class = "dolphin"; }; command = "floating enable"; }
        { criteria = { class = "Dolphin"; }; command = "floating enable"; }
        { criteria = { class = "Pavucontrol"; }; command = "floating enable"; }
        { criteria = { class = "pavucontrol"; }; command = "floating enable"; }
        { criteria = { class = "Blueman-manager"; }; command = "floating enable"; }
        { criteria = { class = "blueman-manager"; }; command = "floating enable"; }
      ];
    };

    extraConfig = ''
      bar {
        font pango:${fontName} ${toString fontSize}
        status_command ${pkgs.i3status}/bin/i3status
        tray_output primary
        separator_symbol " | "

        colors {
          background $bg
          statusline $fg
          separator  $color8

          focused_workspace       $color4   $color4    $bg
          active_workspace        $color8   $color8    $fg
          inactive_workspace      $bg       $bg        $color8
          urgent_workspace        $color1   $color1    $bg
        }
      }

      exec --no-startup-id i3-msg 'workspace dev[j]'

      set_from_resource $fg i3wm.color7 #f0f0f0
      set_from_resource $bg i3wm.color0 #1e1e1e
      set_from_resource $color0 i3wm.color0 #000000
      set_from_resource $color1 i3wm.color1 #ff0000
      set_from_resource $color2 i3wm.color2 #00ff00
      set_from_resource $color3 i3wm.color3 #ffff00
      set_from_resource $color4 i3wm.color4 #0000ff
      set_from_resource $color5 i3wm.color5 #ff00ff
      set_from_resource $color6 i3wm.color6 #00ffff
      set_from_resource $color7 i3wm.color7 #ffffff
      set_from_resource $color8 i3wm.color8 #808080

      # class                 border    backgr.   text  indicator child_border
      client.focused          $color4   $color4   $bg   $color4   $color4
      client.focused_inactive $color8   $color8   $fg   $color8   $color8
      client.unfocused        $bg       $bg       $color8 $bg     $bg
      client.urgent           $color1   $color1   $bg   $color1   $color1
      client.placeholder      $bg       $bg       $fg   $bg       $bg
    '';
  };
}
