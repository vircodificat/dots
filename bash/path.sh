paths=$(cat ~/.path | grep -v '^\s*#' | tr '\n' ':')
unset PATH
export PATH=$paths
