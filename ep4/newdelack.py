#!/usr/bin/env python
# Run me like:
#  egrep '(^r|^\+)' trace.tr | python delack.py
# This script:
#	For any packet received by an end host, this script will keep
# 	track of the time until the acknowledgement is queued. When the
#	acknowledgement is queued, all outstanding packets from that
#	host are assumed to have been acknowledged and the time 
#	for all unacknowledged packets will be printed.
#
#	Note, this only considers packets of the types "pareto",
# 	"tcp", and "ack"

import sys
routers = {}
f = open("hosts_routers", "r")
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
	if j[0] != "+" and j[0] != "r":
		continue #Invalid row!
	if j[0] == "+" and (j[4] == "pareto" or j[4] == "tcp"):
		continue # Only care about received paretos and tcps
	if j[0] == "r" and j[4] == "ack":
		continue # Only care about enqueued acks, not delivery time
	# If a pareto or tcp thing is received by the dest
	if j[4] == "pareto" or j[4] == "tcp":
		if not is_end_host(dst):
			continue
		if dst not in outstanding:
			outstanding[dst] = []
		#print "Received packet for %s at time %s" % (dst, time)
		outstanding[dst].append(time)
	if j[4] == "ack":
		if not is_end_host(src):
			continue
		#print "Enqueued ACK from %s at time %s" % (src, time)
		if src in outstanding:
			pkt_time = outstanding[src][-1]
			diff = time - pkt_time
			print "%s" % (diff,)
			del outstanding[src]
		else:
			sys.stderr.write("ACK by host " + str(src) + " with no incoming traffic?!?\n")
			pass
