#!/usr/bin/env python
# Run me like:
#  egrep '(^r|^\+)' trace.tr | python delack.py
# This script:
#   Keeps track of (flow_id, seq_number) tuples and prints the
#   time between when a packet was received by the destination
# 	node and when the destination node enqueues the ack for that
#	packet.
#
#	Note, this only considers packets of the types "pareto",
# 	"tcp", and "ack"

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


outstanding = {}
for i in sys.stdin:
  j = i.strip().split(" ")
  time = float(j[1])
  src = int(j[2])
  dst = int(j[3])
  flow_id = j[7]
  seq_no = j[10]
  if j[0] == "r" and (j[4] == "pareto" or j[4] == "tcp") and is_end_host(dst):
    if dst not in outstanding:
      outstanding[dst] = []
    outstanding[dst].append(time)
  if j[0] == "+" and j[4] == "ack" and is_end_host(src):
    if src in outstanding:
      diff = time - outstanding[src][-1]
      print "%s" % (diff,)
      del outstanding[src]
    else:
      pass
            #print "Error: ACK for unsent packet, flow!"

