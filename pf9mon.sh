#!/bin/bash

cachet_ip="38.140.51.154:81"
cachet_token="fwCWWIlR88uOSkSdiArL"
serviceDir=/etc/init.d
apiMap=instance-map.dat

usage() {
  echo -e "usage: $0 [<serviceName>|all]\n"
  exit 1
}

assert() {
  if [ $# -eq 1 ]; then echo "ASSERT: ${1}"; fi
  exit 1
}

# validate parameters
if [ $# -ne 1 ]; then usage; fi
filter=${1}

if [ ! -r ${apiMap} ]; then
  assert "cannot open file: ${apiMap}"
fi 

# check service status
for service in ${serviceDir}/*; do
  # parse serviceName
  serviceName=$(basename ${service})

  # apply service filter (commandline argument != all)
  if [ "${filter}" != "all" -a "${serviceName}" != "${filter}" ]; then continue; fi

  # skip administratively disabled services
  service_status=$(grep "^${serviceName}|" ${apiMap} | cut -d \| -f3)
  if [ "${service_status}" == "disabled" ]; then continue; fi

  if [[ ${serviceName} == pf9* || ${serviceName} == openstack* ]]; then 
    # get service status
    echo "Checking service status: ${serviceName}"
    systemctl status ${serviceName} > /dev/null 2>&1

    # set component status/code
    component_status=$?
    case ${component_status} in
    0)
      component_code=1
      component_desc="Component is operating normally"
      echo "--> ${component_desc}"
      ;;
    *)
      component_code=4
      component_desc="Component has failed"
      echo "--> *** ERROR: ${component_desc}"
      ;;
    esac

    # update component in dashboard
    id=$(grep "^${serviceName}|" ${apiMap} | cut -d \| -f2)
    curl -i -H "X-Cachet-Token: ${cachet_token}" -H "Content-Type: application/json" -X PUT \
         -d "{\"description\":\"${component_desc}\",\"status\":\"${component_code}\"}" http://${cachet_ip}/api/v1/components/${id} > /dev/null 2>&1
  fi
done

# exit cleanly
exit 0
