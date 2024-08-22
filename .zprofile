eval $(/opt/homebrew/bin/brew shellenv)

export PATH="$HOME/.bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# Init direnv tool
eval "$(direnv hook zsh)"


if [[ ! -o interactive ]]; then
    export PATH="$HOME/.local/share/mise/shims:$PATH"
    echo "non interactive"
else 
    # Init mise tool
    eval "$(mise activate zsh)"
    echo "interactive"
fi

# pnpm
export PNPM_HOME="/Users/d-ivanov/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
