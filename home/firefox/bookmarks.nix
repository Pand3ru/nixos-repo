let 
  sep = "seperator"
  b = n: u: t ? []: { name = n; url = u; tags = t; };
in
{
  name = "Bookmarks";
  toolbar = true;
  bookmarks = [
    {
      name = "Dev";
      bookmarks = [
        (b "GitHub" "https://github.com/" [ "code" "repo" ])

        {
          name = "Rust";
          bookmarks = [
            (b "crates.io" "https://crates.io/" [ "rust" "packages" ])
            (b "Rust Documentation" "https://doc.rust-lang.org/" [ "rust" "docs" ])
            (b "docs.rs" "https://docs.rs/" [ "rust" "docs" ])
          ];
        }

        (b "keymapper.dev" "https://keymapper.dev/" [ "keyboard" "tools" ])

        {
          name = "Infosec";
          bookmarks = [
            (b "PayloadsAllTheThings" "https://github.com/swisskyrepo/PayloadsAllTheThings" [ "security" "payloads" ])
            (b "Exploit-DB" "https://www.exploit-db.com/" [ "security" "exploits" ])
            (b "Hack The Box" "https://www.hackthebox.com/" [ "security" "practice" ])
            (b "Pentest Monkey" "https://pentestmonkey.net/" [ "security" "cheatsheet" ])
          ];
        }

        sep

        {
          name = "Blogs";
          bookmarks = [
            (b "Hacker News" "https://news.ycombinator.com/" [ "news" "tech" ])
            (b "Lobsters" "https://lobste.rs/" [ "news" "tech" ])
          ];
        }
      ];
    }

    {
      name = "System";
      bookmarks = [
        (b "Desk" "http://desk.home:8080/" [ "local" "dashboard" ])

        {
          name = "Nix";
          bookmarks = [
            (b "Home Manager Options" "https://home-manager-options.extranix.com/" [ "nix" "docs" ])
            (b "Explainix" "https://zaynetro.com/explainix" [ "nix" "learning" ])
            (b "Awesome Nix" "https://nix-community.github.io/awesome-nix/" [ "nix" "resources" ])
            (b "Nix Package Search" "https://search.nixos.org/packages" [ "nix" "packages" ])
            (b "NixOS Wiki" "https://nixos.wiki/" [ "nix" "docs" ])
            (b "Nix Pills" "https://nixos.org/guides/nix-pills/" [ "nix" "learning" ])
            (b "Noogle" "https://noogle.dev/" [ "nix" "search" ])
            (b "Nixpkgs GitHub" "https://github.com/NixOS/nixpkgs" [ "nix" "source" ])
          ];
        }
      ];
    }

    {
      name = "Media";
      bookmarks = [
        (b "r/Piracy Megathread" "https://www.reddit.com/r/Piracy/wiki/megathread/")
        (b "RealDebrid" "https://real-debrid.com/")
        (b "Premiumize" "https://www.premiumize.me/")
        sep
        {
          name = "Stream";
          bookmarks = [
            (b "1shows" "https://www.1shows.nl/tv" [ "movie" "show" ])
            (b "streameast" "https://v4.gostreameast.link/" [ "sports" ])
          ];
        }
        {
          name = "Downloads";
          bookmarks = [
            (b "WatchSoMuch" "https://watchsomuch.to/" [ "torrent" ])
            (b "FilmFans" "https://filmfans.org/" [ "movie" "ger" "debrid" ])
            (b "FilmFans" "https://serienfans.org/" [ "show" "ger" "debrid" ])
            (b "PirateBay" "https://thepiratebay.org/" [ "show" "movie" "software" "torrent" ])
            (b "Annas Archive" "https://annas-archive.pk/" [ "direct" "books" ])
            (b "AudiozDownload" "https://audioz.download/" [ "software" "debrid" ])
          ];
        }
      ];
    }
  ];
}
