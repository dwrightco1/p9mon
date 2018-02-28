#!/bin/bash

. ~root/admin_admin.rc

total=0

  echo "getting token1"
  export TOKEN1=`openstack token issue -c id -f value`
  echo "getting token2"
  export TOKEN2=`openstack token issue -c id -f value`

for i in `seq 1 2`;
do 
  BEGIN=`date +%s`

  echo "validating tokens"
# port 5000 default
# port 8080 nginx
  curl -g -i -X GET http://localhost:5000/keystone/v3/auth/tokens -H "x-auth-token: $TOKEN1" -H "x-subject-token: $TOKEN2" > /dev/null 2>&1
  END=`date +%s`
  let elapsed=$END-$BEGIN
  echo "RUN $i: $elapsed s"
  echo
  let total=total+elapsed
done

# exit cleanly
exit 0
