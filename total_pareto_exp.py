#!/usr/bin/env python
# grep '^r' trace.tr | egrep '( pareto | exp )' | python total_pareto_exp.py

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

paretotal = 0
exptotal = 0
for i in sys.stdin:
  j = i.strip().split(' ')
  event = j[0]
  src = int(j[2])
  type = j[4]
  size = int(j[5])
  if event == 'r' and is_end_host(src):
    if type == 'pareto':
      paretotal += size
    elif type == 'exp':
      exptotal += size
    else:
      print 'ERROR: unknown type %s\n' % (type,)

print "Pareto Total: %d Bytes" % (paretotal,)
print "VOIP Total:   %d Bytes" % (exptotal,)
