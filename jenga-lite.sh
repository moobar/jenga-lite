#!/usr/bin/env bash

DEFAULT_BIN_DIR="_build/default/bin"

shutdown()
{
  echo ""
  echo "Exiting... 'JENGA'"
  exit 0
}

trap shutdown 2 

now=0
last_run=0

check_diff() {
  now=$1
  last=$2

  diff=$(($now - $last))
  [[ $diff -gt 1 ]] && return
} 

# This apparently is a little brittle. Dune doesn't like exe files in 
# the bin/lib directory. So maybe I have to leave the annoying _build 
# files in place
copy_binaries_to_root() {
  if [[ -d "$DEFAULT_BIN_DIR" ]]; then
    cp "$DEFAULT_BIN_DIR"/*.exe .
  fi 
}

echo "Starting 'JENGA' ;)"
inotifywait -m -r -e create,modify,close_write --format '%w%f' . 2> /dev/null| while read FILE
do
  if [[ $FILE == *".ml" || $FILE == *".mli" || $FILE == "jbuild" || $FILE == "dune" ]]; then
    now=$(date '+%s')
    if check_diff $now $last_run; then 
      dune build
      last_run=$(date '+%s')
      if [[ $? == 0 ]]; then
        copy_binaries_to_root
      fi
    fi
  fi
done

