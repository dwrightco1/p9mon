#!/bin/bash

cachet_ip="38.140.51.154:81"
cachet_token="fwCWWIlR88uOSkSdiArL"
serviceDir=/etc/init.d
apiMap=instance-map.dat

usage() {
  echo "usage: $0 [<serviceName>|all]"
  exit 1
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
      component_desc="Component is operating normally"
      ;;
    *)
      component_code=4
      component_desc="Component has failed"
      ;;
    esac

    # update component in dashboard
    if [ -r ${apiMap} ]; then
      id=$(grep "^${serviceName}|" ${apiMap} | cut -d \| -f2)
      echo "--> setting dashboard.id=${id} to ${component_code} (${component_desc})"
      curl -i -H "X-Cachet-Token: ${cachet_token}" -H "Content-Type: application/json" -X PUT -d "{ 'description':'${component_desc}', 'status':'${component_code}' }" http://${cachet_ip}/api/v1/components/${id} > /dev/null 2>&1
    fi

  fi

done

# exit cleanly
exit 0
