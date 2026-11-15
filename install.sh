#!/bin/sh
# Install obelisk-assignment as a local Typst package.
#   ./install.sh          copy it (re-run to update)
#   ./install.sh --link   symlink it, so edits in this folder apply immediately
set -e
cd "$(dirname "$0")"

version=$(sed -n 's/^version = "\(.*\)"/\1/p' typst.toml)
case "$(uname)" in
  Darwin) data="$HOME/Library/Application Support" ;;
  *)      data="${XDG_DATA_HOME:-$HOME/.local/share}" ;;
esac
dest="$data/typst/packages/local/obelisk-assignment/$version"

rm -rf "$dest"
mkdir -p "$(dirname "$dest")"
if [ "$1" = "--link" ]; then
  ln -s "$PWD" "$dest"
else
  mkdir -p "$dest"
  cp -R *.typ typst.toml template "$dest"/
fi
echo "Installed to $dest"
echo "Start a sheet with:  typst init @local/obelisk-assignment:$version my-sheet"
