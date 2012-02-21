#! /usr/bin/env python

import sys

sent = acks = 0
for i in sys.stdin:
  if i[0] != "r":
    continue
  j = i.strip().split(" ")
  if j[4] == "tcp" or j[4] == "pareto":
    sent += 1
  if j[4] == "ack":
    acks += 1

print "TCP sent: %s\nTCP ackd: %s" % (sent, acks)
print "Total tcp/ack ratio: %f" % (float(sent) / float(acks),)
