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
        definedAliases = [ "@no" ];
    };

    "Startpage" = {
        urls = [{
            template = "https://www.startpage.com/sp/search";
            params = [
                { name = "query"; value = "{searchTerms}"; }
            ];
            definedAliases = [ "@sp" ];
        }];
    };

    "bing".metaData.hidden = true;
  };
}
