#!/bin/bash
for filename in tests/*.asm; do
  echo ""
  echo "************************************************************"
  echo "Testing $filename"
  echo "************************************************************"
  python3 6502_asm.py $filename
  base=$(basename $filename | cut -d"." -f1)
  answer="tests/$base.bin"
  #cp rom.bin $answer
  DIFF=$(diff rom.bin $answer)
  if [ "$DIFF" != "" ]
  then
    echo "Test failed!"
    hexdump rom.bin
    echo "------------------------------------------------------------"
    hexdump $answer
  else
    echo "Pass"
  fi
done
