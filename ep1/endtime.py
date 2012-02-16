#!/usr/bin/env python

import sys

tracefile = open('ep1.tr', 'r')
trace = tracefile.readlines()
lastsec = 0

i = 0
for line in reversed(trace):
  split = line.split()
  time = split[1]
  fid = split[7]

  second = int(float(time))
  if second != lastsec:
    sys.stdout.write("\r" + time)
    sys.stdout.flush()
    lastsec = second
    
  if fid == 21:
    print format('Elephant 1: %s seconds', time)
    i += 1
  elif fid == 62:
    print format('Elephant 2: %s seconds', time)
    i += 1
  elif fid == 103:
    print format('Elephant 3: %s seconds', time)
    i += 1

  if i >= 3:
    break

