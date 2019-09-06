# amitu_heroku

This repository contains various experiments by me. Everything is a single big realm
app, to be deployed on heroku. It supports multiple domains, every domain to be mapped
to same app.

## One Time Setup: Mac

### If using Catalina

```bash
$ sudo mkdir -p /System/Volumes/Data/nix
$ sudo chown -R `whoami` /System/Volumes/Data/nix
$ echo "nix\t/System/Volumes/Data/nix" | sudo tee /etc/synthetic.conf
```

And reboot.

### Install nix

```bash
$ export NIX_IGNORE_SYMLINK_STORE=1
$ curl https://nixos.org/nix/install | sh
```

You may also have to do the following:

```bash
$ nix-store --add-fixed --recursive sha256 /Applications/Xcode.app
```

### Run nix shell

Use nix shell in pure mode to work on our code.

```bash
$ nix-shell --pure --run zsh
```

Ensure [postgresql-11] is installed and running. Setup tables:

```bash
$ recreatedb
```

You may want to run `scripts/80.sh`.

## Day To Day Development

To test: `ctest`, or `cargo check --all` for quicker type errors.

Run the service using `cargo run -- --test`, and visit http://127.0.0.1:3000

## PyCharm Setup

Tested using PyCharm PyCharm 2018.3.7 (Professional Edition). Note: later PyCharms
2019.2 etc, there are some issues.

1. **Python**: On Preferences -> Project: amitu_heroku -> Project Interpreter ->
   Gear Icon -> Add -> Virtual Environment -> Existing Environment -> `...` -> Add,
   select `/usr/local/opt/pyenv/versions/amitu_heroku/bin/python`.

2. **Rust**: Ensure [Rust Plugin], tested: `v0.2.99.2127-183`, is installed. Optionally
   install [Pest Plugin], _essential_ if editing [`.pest` files].

3. **Elm**: Ensure [Elm Plugin], tested: v3.2.1, is installed. In Preferences ->
   Languages & Frameworks -> Elm, click "Auto Discover" both in "Elm Compiler" and
   "elm-format". Then open any elm file in "frontend", and select corresponding
   folder's `elm.json` file after clicking "Attach elm.json (or elm-package.json)".


[Rust Plugin]: https://intellij-rust.github.io
[Pest Plugin]: https://plugins.jetbrains.com/plugin/12046-pest
[`.pest` files]: https://pest.rs/book/
[Elm Plugin]: https://plugins.jetbrains.com/plugin/10268-elm/
[postgresql-11]: https://postgresapp.com
