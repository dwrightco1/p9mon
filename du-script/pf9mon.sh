#!/bin/bash

cachet_ip="172.16.7.36"
cachet_token="fwCWWIlR88uOSkSdiArL"
serviceDir=/etc/init.d
apiMap=instance-map.dat

usage() {
  echo "usage: $0 [<serviceName>|all]"
  exit 1
}

update_cachet() {
  if [ $# -ne 2 ]; then return 0; fi
  component_name=${1}
  component_code=${2}

  if [ -r ${apiMap} ]; then
    id=$(grep ^${component_name} ${apiMap} | cut -d \| -f2)
    #curl -i -H "X-Cachet-Token: ${cachet_token}" -H "Content-Type: application/json" \
    #     -X PUT -d '{"description":"Component has failed","status":4}' http://${cachet_ip}/api/v1/components/${id}
    echo "curl -i -H \"X-Cachet-Token: ${cachet_token}\" -H \"Content-Type: application/json\" -X PUT -d '{\"description\":\"Component has failed\",\"status\":${component_code}}' http://${cachet_ip}/api/v1/components/${id}"
  fi
}

# validate parameters
if [ $# -ne 1 ]; then usage; fi
filter=${1}

# check service status
for service in ${serviceDir}/*; do
  # parse serviceName
  serviceName=$(basename ${service})

  # apply service filter (commandline argument != all)
  if [ "${filter}" != "all" -a "${serviceName}" != "${filter}" ]; then continue; fi

  if [[ ${serviceName} == pf9* || ${serviceName} == openstack* ]]; then
    # skip disabled services
    serviceStatus=$(systemctl show ${serviceName} | grep ActiveState | awk -F = '{print $2}')
    if [ "${serviceStatus}" == "inactive" ]; then continue; fi

    # get service status
    echo "Checking service status: ${serviceName}"
    systemctl status ${serviceName} > /dev/null 2>&1

    # set component status/code
    component_status=$?
    case ${component_status} in
    0)
      component_code=1
      ;;
    *)
      component_code=4
      ;;
    esac

    # update component in dashboard
    update_cachet ${serviceName} ${component_code}
  fi

done

# exit cleanly
exit 0
