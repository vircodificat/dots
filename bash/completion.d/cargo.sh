if [ -f "$HOME/.cargo/bin/rustup" ]; then
    source <($HOME/.cargo/bin/rustup completions bash cargo)
else 
    echo "NO RUST COMPLETION"
fi
