{
  force = true;
  default = "Startpage";
  order = [ "Startpage" "ddg" "google" ];
  engines = {
    "Nix Packages" = {
        urls = [{
            template = "https://search.nixos.org/packages";
            params = [
                { name = "type"; value = "packages"; }
                { name = "query"; value = "{searchTerms}"; }
            ];
        }];
        icon = "https://nixos.org/favicon.png";
        definedAliases = [ "@np" ];
    };

    "Nix Options" = {
        urls = [{
            template = "https://search.nixos.org/options";
            params = [
                { name = "type"; value = "options"; }
                { name = "query"; value = "{searchTerms}"; }
            ];
        }];
        icon = "https://nixos.org/favicon.png"; 
        definedAliases = [ "@no" ];
    };

    "Startpage" = {
        urls = [{
            template = "https://www.startpage.com/sp/search";
            params = [
                { name = "query"; value = "{searchTerms}"; }
            ];
        }];
        icon = "https://www.startpage.com/sp/cdn/favicons/favicon-256-a199a0cb.png";
        definedAliases = [ "@sp" ]; 
    };

    "bing".metaData.hidden = true;
  };
}
