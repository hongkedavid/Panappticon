import sys

payload = {}

with open(sys.argv[1],  'r') as f:
    lines = f.readlines()
    for line in lines:
        str = line.rstrip().split(' ')
        if str[0] not in payload:
           payload[str[0]] = 0
        payload[str[0]] += long(str[1])

for key in payload:
    print key, payload[key]
