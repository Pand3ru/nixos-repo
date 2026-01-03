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
        "${mod}+Shift+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
        "${mod}+p" = "exec ${pkgs.bemenu}/bin/bemenu-run";
        "${mod}+Shift+c" = "kill";
        "${mod}+Shift+r" = "restart";

        # Workspace switching
        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+9" = "workspace number 9";
        "${mod}+0" = "workspace number 10";

        # Move to workspace
        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";
        "${mod}+Shift+7" = "move container to workspace number 7";
        "${mod}+Shift+8" = "move container to workspace number 8";
        "${mod}+Shift+9" = "move container to workspace number 9";
        "${mod}+Shift+0" = "move container to workspace number 10";

        "${mod}+j" = "focus left";
        "${mod}+k" = "focus right";

        "${mod}+Return" = "mark _swap; focus left; swap container with mark _swap; unmark _swap";

        # Layout switching
        "${mod}+t" = "layout tabbed";
        "${mod}+s" = "layout stacking";
        "${mod}+e" = "layout toggle split";
        "${mod}+f" = "fullscreen toggle";
        "${mod}+space" = "floating toggle";
        "${mod}+Shift+space" = "focus mode_toggle";

        "${mod}+Shift+a" = "floating toggle";

        "${mod}+v" = "split v";
        "${mod}+b" = "split h";

        "${mod}+l" = "resize shrink width 10 px or 10 ppt";
        "${mod}+h" = "resize grow width 10 px or 10 ppt";
      };

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
