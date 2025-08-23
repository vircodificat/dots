paths=$(cat ~/.path | grep -v '^\s*#' | grep -v '^$' | sed -z 's/\n$//' | tr '\n' ':' )
unset PATH
export PATH=$paths
