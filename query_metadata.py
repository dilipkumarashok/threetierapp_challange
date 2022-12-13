import json

import subprocess, re

rooturl = '''{}  "http://metadata.google.internal/computeMetadata/v1/instance/" -H "Metadata-Flavor: Google"'''.format("curl")

#output = ['attributes/', 'cpu-platform', 'description', 'disks/', 'guest-attributes/', 'hostname', 'id', 'image', 'licenses/', 'machine-type', 'maintenance-event', 'name', 'network-interfaces/', 'preempted', 'remaining-cpu-time', 'scheduling/', 'service-accounts/', 'tags', 'virtual-clock/', 'zone']

def fetch_instance_metadata(rooturl):
    a = []
    d = {}
    process = subprocess.Popen(rooturl,stdout=subprocess.PIPE,shell=True)
    output = process.stdout.read().decode("utf-8").splitlines()
    # print(output)
    for i in output:
        if i.endswith('/'):
            a.append(i)
        else:
            rooturl = '''{}  "http://metadata.google.internal/computeMetadata/v1/instance/{}" -H "Metadata-Flavor: Google"'''.format("curl",i)
            process = subprocess.Popen(rooturl,stdout=subprocess.PIPE,shell=True)
            d[i] = process.stdout.read().decode('utf-8')
    #print(json.dumps(d,indent=4))
    #print(a)
    return a     

def recursive_search(a):
    b = {}
    for i in a:
        rooturl = '''{}  "http://metadata.google.internal/computeMetadata/v1/instance/{}/?recursive=true" -H "Metadata-Flavor: Google"'''.format("curl",i)
        process = subprocess.Popen(rooturl,stdout=subprocess.PIPE,shell=True)
        b[i] = process.stdout.read().decode('utf-8').splitlines()
    #print(json.dumps(b,indent=4))
    return b

def format_output(b):
    c = {}
    for i,v in b.items():
        c.getprint(i,v)



format_output(recursive_search(fetch_instance_metadata(rooturl)))