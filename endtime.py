#! /usr/bin/env python

import sys

f = open("elephants.log", "r")
elephants = [ int(i.strip()) for i in f.readlines()]
f.close()
endtimes = {}

for i in sys.stdin:
  if i[0] != "r":
    continue
  j = i.strip().split(" ")
  if int(j[7]) in elephants:
    endtimes[int(j[7])] = j[1]

print "Elephant 1: %s\nElephant 2: %s\nElephant 3: %s\n" % (endtimes[elephants[0]], endtimes[elephants[1]], endtimes[elephants[2]])
