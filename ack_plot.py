#!/usr/bin/env python
# grep '^r' trace.tr | grep ' ack ' | python ack_plot.py

import sys

routers = {}
f = open("routers.log", "r")
for i in f.readlines():
  routers[int(i.strip())] = 1
f.close()

def is_end_host(num):
  """
  You may need to customize this to whatever hosts are your end hosts.
  """
  return not num in routers

bytesacked = 0
lastseqnum = {}
bytesperpkt = 1500
nextpoint = 0.0
interval = 10

print '#Time\tBytesACKed'

for i in sys.stdin:
  j = i.strip().split(' ')
  event = j[0]
  time = float(j[1])
  dst = int(j[3])
  type = j[4]
  fid = int(j[7])
  seq = int(j[10])
  if event == 'r' and is_end_host(dst) and type == 'ack':
    if not fid in lastseqnum:
      lastseqnum[fid] = 0

    #scale ack bytes by number of packets, determined by seq interval
    if seq < lastseqnum[fid]:
      print "#WARNING: SEQUENCE ROLLOVER"
      lastseqnum[fid] = seq

    bytesacked += bytesperpkt * (seq - lastseqnum[fid] + 1)
    lastseqnum[fid] = seq
    
    if time >= nextpoint:
      print '%f\t%d' % (time, bytesacked)
      sys.stdout.flush()
      nextpoint += interval

