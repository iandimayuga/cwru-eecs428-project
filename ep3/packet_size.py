#! /usr/bin/env python

import sys

total = 0

for i in sys.stdin:
  if i[0] != "r":
    continue
  j = i.strip().split(" ")
  if j[4] == "ack" or j[10] == "0":
    continue

  if j[5] != "1500":
    print i
    total += 1

print "Total packets not 1500B (excluding acks and syns): %s" % (total,)
