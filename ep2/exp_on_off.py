#!/usr/bin/env python
# Run this like: grep '^r' trace.tr | grep ' exp ' | python exp_on_off.py
import sys
import scipy.stats as ss

def is_end_host(i):
	return (int(i) >= 2)

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

def dist_fit(exp):
	alpha,loc,beta = ss.gamma.fit(exp)
	print "Alpha: %s\tLoc: %s\tBeta: %s" % (alpha,loc,beta)
        print "Mean: %s" % (sum(exp)/len(exp),)

distributions = {}

for i in sys.stdin:
	if i[0] != "r":
		continue
	j = i.strip().split(" ")
	if j[4] != "exp":
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
