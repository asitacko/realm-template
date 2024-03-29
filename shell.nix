let
  moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
  nixpkgs = import <nixpkgs> { overlays = [ moz_overlay ]; config = { allowUnfree = true; }; };
  rustChannels = nixpkgs.latest.rustChannels.stable;
in
  with nixpkgs;
  stdenv.mkDerivation {
    name = "amitu-env";
    buildInputs = [ rustChannels.rust rustChannels.clippy-preview ];

    nativeBuildInputs = [
      elmPackages.elm-format
      elmPackages.elm

      file
      zsh
      wget
      locale
      vim
      less
      htop
      fzf
      curl
      ripgrep
      cacert
      taskwarrior
      tokei
      man
      git
      gitAndTools.diff-so-fancy
      heroku
      openssl
      pkgconfig
      perl
      nixpkgs-fmt

      postgresql_11
      python37
      python37Packages.psycopg2
      python37Packages.pre-commit
    ]
    ++ (
         stdenv.lib.optionals stdenv.isDarwin [
           nixpkgs.darwin.apple_sdk.frameworks.CoreServices
           nixpkgs.darwin.apple_sdk.frameworks.Security
           nixpkgs.darwin.apple_sdk.frameworks.CoreFoundation
           nixpkgs.darwin.apple_sdk.frameworks.Foundation
         ]
       )
    ;

    RUST_BACKTRACE = 1;
    shellHook = ''
      export NIX_LDFLAGS="-F${nixpkgs.darwin.apple_sdk.frameworks.CoreServices}/Library/Frameworks -framework CoreServices -F${nixpkgs.darwin.apple_sdk.frameworks.CoreFoundation}/Library/Frameworks -framework CoreFoundation $NIX_LDFLAGS";
      export LD_LIBRARY_PATH=$(rustc --print sysroot)/lib:$LD_LIBRARY_PATH;
      export ZDOTDIR=`pwd`;
      export HISTFILE=~/.zsh_history
      echo "Using ${python37.name}, ${elmPackages.elm.name}, ${rustChannels.rust.name} and ${postgresql_11.name}."
    '';
  }
