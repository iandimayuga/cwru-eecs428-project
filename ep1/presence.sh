#!/bin/sh

for i in  {1..123}
do
  if [ $i -ne 21 ] && [ $i -ne 62 ] && [ $i -ne 103 ]
  then
    cat ep1.tr | cut -d ' ' -f "2 8" | grep -m 1 " $i$"
  fi
done
