#! /usr/bin/env python

import sys

elephants = ["1", "42", "83"]
endtimes = {}

for i in sys.stdin:
  if i[0] != "r":
    continue
  j = i.strip().split(" ")
  if j[7] in elephants:
    endtimes[j[7]] = j[1]

print "Elephant 1: %s\nElephant 2: %s\n Elephant 3: %s\n" % (endtimes[elephants[0]], endtimes[elephants[1]], endtimes[elephants[2]])
