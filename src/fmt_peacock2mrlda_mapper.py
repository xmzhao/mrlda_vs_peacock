#!/usr/bin/env python

import sys
import md5

if __name__ == '__main__':
  for l in sys.stdin:
    title = md5.new(l).digest().encode('hex')
    content = l.replace('\t', ' ')
    print >> sys.stdout, "%s\t%s" % (title, content) ,
