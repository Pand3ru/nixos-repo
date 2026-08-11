{ pkgs, ... }:
{
  # Rules only fire on diverted buttons; the diversion itself is a per-device
  # setting stored on the mouse (set once via `solaar config`), not something
  # rules.yaml can express. Solaar also has to actually be running to receive
  # the diverted HID++ notifications and act on them, hence the autostart entry.
  xdg.autostart.entries = [ "${pkgs.solaar}/share/applications/solaar.desktop" ];

  xdg.configFile."solaar/rules.yaml".text = ''
    %YAML 1.3
    ---
    - Key: [Mouse_Gesture_Button, pressed]
    - KeyPress: [Super_L]
    ...
    ---
    - MouseGesture: [Middle Button, Mouse Right]
    - KeyPress: [Super_L, Page_Down]
    ...
    ---
    - MouseGesture: [Middle Button, Mouse Left]
    - KeyPress: [Super_L, Page_Up]
    ...
  '';
}
