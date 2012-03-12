#!/usr/bin/env python
# Run this like: grep '^r' trace.tr | grep ' pareto ' | python pareto_on_off.py
import sys
import scipy.stats as ss

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

def group_sending(l):
	time_segments = []
	last_start = float(l[0])
	last = float(l[0])
	for i in map(float,l):
		if i-last > 0.4:
			time_segments.append({"start": last_start, "end": last})
			last_start = i
		last = i
	time_segments.append({"start": last_start, "end": last})
	return time_segments

def dist_fit(pareto):
	#alpha,loc,beta = ss.pareto.fit(pareto)
	#print "Alpha: %s\tLoc: %s\tBeta: %s" % (alpha,loc,beta)
        print "Mean: %s" % (sum(pareto)/len(pareto),)

distributions = {}

for i in sys.stdin:
	if i[0] != "r":
		continue
	j = i.strip().split(" ")
	if j[4] != "pareto":
		continue
	src = j[2]
	dst = j[3]
	if not is_end_host(src) or not is_end_host(dst):
		continue
	if (src,dst) not in distributions:
		distributions[(src,dst)] = []
	distributions[(src,dst)].append( float(j[1]) )

#print distributions
off = []
on = []
for i,j in distributions.items():
	send_events = group_sending(j)
	for k in range(0, len(send_events)):
		on.append(send_events[k]["end"] - send_events[k]["start"])
		if k == 0:
			off.append(send_events[k]["start"])	
		else:
			off.append(send_events[k]["start"] - send_events[k-1]["end"])

print "Off: "
dist_fit(off)
print "On: "
dist_fit(on)
