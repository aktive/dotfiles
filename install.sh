#!/bin/bash
set -e

DOTFILES_DIR=~/dotfiles
FILES=".bash_aliases .bash_prompt .bash_history_config"

for FILE in $FILES; do
    TARGET="$HOME/$FILE"
    SOURCE="$DOTFILES_DIR/$FILE"

    if [ -L "$TARGET" ] && [ "$(readlink "$TARGET")" = "$SOURCE" ]; then
        echo "$FILE already linked"
        continue
    fi

    if [ -f "$TARGET" ] || [ -L "$TARGET" ]; then
        mv "$TARGET" "$TARGET.backup"
    fi

    ln -s "$SOURCE" "$TARGET"
done

# FIX: Ensure we write the text we are searching for!
if ! grep -q "load aktive dotfiles module" ~/.bashrc; then
    cat <<EOT >> ~/.bashrc

# load aktive dotfiles module
for file in $FILES; do
    [ -r "\$HOME/\$file" ] && . "\$HOME/\$file"
done
EOT
fi

echo "install complete. run: source ~/.bashrc"
echo ""