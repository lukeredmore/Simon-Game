#!/bin/sh
function updatefilelistproj() {
  cwd=$(pwd)
  cd ~/Library/CloudStorage/OneDrive-DukeUniversity/ECE\ 350/Simon-Game
  realpath `find . -type f \( -iname "*.v" ! -iname "*_tb.v" ! -path "./Simon-Vivado/*" \)` > ./icarus/FileList.txt
  cd $cwd
}

function projcomp() {
  cwd2=$(pwd)
  assemblyfile=`realpath $1`
  testname=${assemblyfile:t:r}
  cd ~/Library/CloudStorage/OneDrive-DukeUniversity/ECE\ 350/Simon-Game
  ./assembler/asm $assemblyfile
  mv ./$testname.mem ./assembler-out/$testname.mem
  cd $cwd2
  proj $testname
}

function proj() {
  # Setup
  updatefilelistproj
  cwd=$(pwd)
  cd ~/Library/CloudStorage/OneDrive-DukeUniversity/ECE\ 350/Simon-Game

  # Find tb file
  tb=./icarus/Wrapper_tb.v
  realpath $tb >> ./icarus/FileList.txt

  iverilog -o projtest -c ./icarus/FileList.txt -s Wrapper_tb -Wimplicit -P Wrapper_tb.FILE=\"`echo $1`\"
  vvp projtest
  rm projtest

  # Return
  cd $cwd
}
