#!/usr/bin/env python

import argparse 
import sys, os.path

def check_arg(args=None):
    parser = argparse.ArgumentParser(description='Initialize a P9 Kubernetes Instance to Monitor')
    parser.add_argument('-H', '--host',
                        required='True',
                        help='IP/Hostname for Cachet Server',
                        default='localhost')
    parser.add_argument('-p', '--port',
                        required='True',
                        help='Port for Cachet Server',
                        default='80')
    parser.add_argument('-t', '--token',
                        required='True',
                        help='API Token for Cachet Server')
    parser.add_argument('-c', '--config',
                        required='True',
                        help='Config File for Kubernetes Instance')

    results = parser.parse_args(args)
    return (results.host,
            results.port,
            results.token,
            results.config)

def abort(message):
    print("ASSERT: " + message)
    sys.exit(1)

def cachet_initGroup(hostname, port, token, configLine):
    import httplib2
    import json
    import time
    import datetime

    httplib2.debuglevel = 0
    http = httplib2.Http()
    content_type_header = "application/json"
    url = "http://{}:{}/api/v1/components/groups".format(hostname,port)
    data = {'name': configLine[0], 'description': configLine[1], 'status': 1}
    headers = {'Content-Type': content_type_header, 'X-Cachet-Token': token}
    print("Posting %s" % data)
    response, content = http.request( url, 'POST', json.dumps(data), headers=headers)
    mydict = json.loads(content)
    return(mydict["data"]["id"])

def cachet_initInstance(hostname, port, token, id, configLine):
    import httplib2
    import json
    import time
    import datetime

    httplib2.debuglevel = 0
    http = httplib2.Http()
    content_type_header = "application/json"
    url = "http://{}:{}/api/v1/components".format(hostname,port)
    data = {'name': configLine[0], 'description': configLine[1], 'status': 1, 'group_id': id}
    headers = {'Content-Type': content_type_header, 'X-Cachet-Token': token}
    print("Posting %s" % data)
    response, content = http.request( url, 'POST', json.dumps(data), headers=headers)

# main
if __name__ == '__main__':
    hostname, port, token, configFile = check_arg(sys.argv[1:])

    # read config file
    try:
        fp = open(configFile)
        configLines = fp.readlines()
        fp.close()
    except OSError:
        abort("Cannot read config file: {}".format(configFile))

    # process config file
    for l in configLines:
        tline = l.split("=")
        if tline[0] == "instanceGroup":
            id = cachet_initGroup(hostname,port,token,tline[1].rstrip().split("|"))
        if tline[0] == "instance":
            cachet_initInstance(hostname,port,token,id,tline[1].rstrip().split("|"))
