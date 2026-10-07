#!/usr/bin/env bash
# Regenerate the STLs (print orientation) and preview images.
# Needs OpenSCAD 2021.01 or newer. Images also need a display; on a
# headless box run it as:  xvfb-run -a ./build.sh
set -euo pipefail
cd "$(dirname "$0")"
SCAD=mac_rack_shelf.scad
mkdir -p stl images

for p in side_frame_left side_frame_right floor top_bar separator; do
  echo "STL  $p"
  openscad -q -D "part=\"$p\"" -o "stl/$p.stl" "$SCAD" &
done
wait

img() { # name, camera, extra -D args...
  local name=$1 cam=$2; shift 2
  echo "PNG  $name"
  openscad -q "$@" -o "images/$name.png" --imgsize=1600,1200 --viewall --autocenter \
    --camera="$cam" --colorscheme=Tomorrow "$SCAD"
}

img assembly_m1     0,0,0,62,0,28,0    -D 'config="m1"'
img assembly_m4     0,0,0,62,0,28,0    -D 'config="m4"'
img rear_m4         0,0,0,60,0,215,0   -D 'config="m4"'
img front_m1        0,0,0,90,0,0,0     -D 'config="m1"' --projection=o
img front_m4        0,0,0,90,0,0,0     -D 'config="m4"' --projection=o
img front_m1_m4     0,0,0,90,0,0,0     -D 'config="m1_m4"' --projection=o
img exploded        0,0,0,62,0,28,0    -D 'config="m1"' -D 'show_devices=false' -D 'explode=45'
img floor_slots     0,0,0,0,0,0,0      -D 'part="floor"' --projection=o
