hput () {
  eval hash "$1"='$2'
}

hget () {
  eval echo '${hash'"$1"'#hash}'
}
