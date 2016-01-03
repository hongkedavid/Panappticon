import networkx as nx
from IO import *
from Global import Global
import sys
import string

def RenderGraphFile(filename):
  g = LoadGraph(filename)
  dot = nx.to_agraph(g)
  print(dot)
  str = filename.split('/')
  gfile = str[2].split('.')
  dot.layout(prog='dot')
  dot.draw('%s.pdf' % gfile[0])

if __name__ == '__main__':
  if len(sys.argv) < 2:
    print('Usage: python draw_graph.py <path to a transaction>')
    sys.exit(0)
  else:
    RenderGraphFile(sys.argv[1]);
