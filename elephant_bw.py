#!/usr/bin/env python
# grep '^r' trace.tr | grep ' tcp ' | python elephant_bw.py

import sys

routers = {}
f = open("routers.log", "r")
for i in f.readlines():
  routers[int(i.strip())] = 1
f.close()

elephants = {}
f = open("elephants.log", "r")
numelephants = 0
for i in f.readlines():
  elephants[int(i.strip())] = numelephants
  numelephants += 1
f.close()

def is_end_host(num):
  return not num in routers

bw = [0, 0, 0]
bwglobal = 0
lasttime = [0, 0, 0]
lasttimeglobal = 0
interval = 10
nextpoint = 0.0

print '#Time\tBandwidth\tBandwidth\tBandwidth\tTotal'

for i in sys.stdin:
  j = i.strip().split(' ')
  event = j[0]
  time = float(j[1])
  src = int(j[2])
  type = j[4]
  size = int(j[5])
  fid = int(j[7])
  seq = int(j[10])
  if event == 'r' and fid in elephants and type == 'tcp' and is_end_host(src):
    elid = elephants[fid]
    bw[elid] = size / (time - lasttime[elid])
    bwglobal = size / (time - lasttimeglobal)
    
  if time >= nextpoint:
    print '%f\t%d\t%d\t%d\t%d' % (time, bw[0], bw[1], bw[2], bwglobal)
    sys.stdout.flush()
    nextpoint += interval

    lasttime[elid] = lasttimeglobal = time

