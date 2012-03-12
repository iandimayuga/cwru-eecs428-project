#!/usr/bin/env python
# Run this like: grep '^r' trace.tr | grep ' pareto ' | python pareto_on_off.py
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

numbursts = 0
totalburst = 0.0
totalidle = 0.0
begintime = 0.0
lasttime = 0.0
lastinterval = 0.0
for i in sys.stdin:
  j = i.strip().split(' ')
  event = j[0]
  time = float(j[1])
  src = int(j[2])
  type = j[4]
  if event == 'r' and is_end_host(src) and type == 'pareto':
    interval = time - lasttime
    

print "Off: "
dist_fit(off)
print "On: "
dist_fit(on)
