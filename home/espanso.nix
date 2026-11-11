{ lib, ... } : {
    services.espanso = {
        enable = true;
        waylandSupport = true; 
        matches.base.matches = lib.mapAttrsToList (from: to: {
            trigger = "${from} ";
            replace = to;
            propagate_case = true;
        }) {
          oe = "ö";
          ae = "ä";
          ue = "ü";
          ss = "ß";
        };
    };
}
