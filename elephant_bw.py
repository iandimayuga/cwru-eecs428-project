#!/usr/bin/env python
# grep '^-' trace.tr | grep ' tcp ' | python elephant_bw.py

import sys

elephants = {}
f = open("elephants.log", "r")
numelephants = 0
for i in f.readlines():
  elephants[int(i.strip())] = numelephants
  numelephants += 1
f.close()

def is_rWest(num):
  return num == 0

def is_rEast(num):
  return num == 1

bw = [0, 0, 0]
bwglobal = 0
lastsize = 0
lastinterval = 1
lasttime = [0, 0, 0]
lasttimeglobal = 0
interval = 10
nextpoint = 0.0
printnext = False
printtime = 0
headersize = 40

print '#Time(secs)\tBW0\tBW1\tBW2\tTotal(kbps)'

for i in sys.stdin:
  j = i.strip().split(' ')
  event = j[0]
  time = float(j[1])
  src = int(j[2])
  dst = int(j[3])
  type = j[4]
  size = int(j[5]) * 8 / 1024
  fid = int(j[7])
  seq = int(j[10])
  if event == '-' and fid in elephants and type == 'tcp' and is_rWest(src) and is_rEast(dst):
    elid = elephants[fid]
    bw[elid] += size
    bwglobal += size

    if time >= nextpoint:
      print '%f\t%d\t%d\t%d\t%d' % (time, bw[0] / interval, bw[1] / interval, bw[2] / interval, bwglobal / interval)
      sys.stdout.flush()
      bw = [0, 0, 0]
      bwglobal = 0
      nextpoint += interval

