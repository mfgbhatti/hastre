if (( $+commands[starship] )); then
  # ignore oh-my-zsh theme

  eval "$(starship init zsh)"
else
  echo '[oh-my-zsh] starship not found, please install it from https://starship.rs'
fi
