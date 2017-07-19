#!/bin/sh
# script to fetch logs from OpenShift by 'service' / 'application'
#
# today's problem
# --------------------------------------------------------------------------------
# TDLR: there is no openshift-way to get logs by 'service' / 'application', one has
# to get logs by the pod-name, and there could be more than one pod per 'service' /
# application, it becomes tedious to get all logs from all pods of a 'service' /
# application
#
# Long Story: today, in order to get logs from OpenShift one has to use the command:
#
#     oc logs <pod-name>
#
# and... because pod name is not fixed (due to auto-scaling of pods up and down),
# one would always have to first check the pod-name from OpenShift console
#
# and most of the time... there can be more than one pod, if there are n-number of
# pods in the 'service' / 'application', then one has to execute n-number of
# oc logs commands
#
# solution
# --------------------------------------------------------------------------------
# TDLR:



# input validation
if [ $# -eq 0 ]; then
    echo "missing input to the script"
    echo "exiting..."
    echo ""
    echo "USAGE"
    echo ""
    echo "    ocfetchlogs.sh [start|stop] [oc_endpoint] [oc_username] [oc_password]  [oc-project-name] [oc-service-name]"
    echo ""
    echo "EXAMPLES"
    echo ""
    echo "to fetch all logs from all pods in project 'sample' and application 'eap'"
    echo ""
    echo "    ocfetchlogs.sh start 10.1.2.2:8443 user password sample eap"
    echo ""
    echo "to fetch all logs from all pods from all applications in project 'sample'"
    echo ""
    echo "    ocfetchlogs.sh start 10.1.2.2:8443 user password eap"
    echo ""
    exit 1
fi


# USER DEFINED
OPERATION=$1

# SET OC ENDPOINT
OC_ENDPOINT=$2
# SET OC USERNAME
OC_USERNAME=$3
# SET OC PASSWORD
OC_PASSWORD=$4

# e.g. dev-in
OC_PROJECT=$5
# e.g. bmw
OC_SERVICE=$6

# business validation
if [ $OPERATION != "start" ] && [ $OPERATION != "stop" ] ; then
    echo "cannot recognize '"$OPERATION"', should be 'start' or 'stop'"
    echo "exiting..."
    echo ""
    echo "USAGE"
    echo ""
    echo "    ocfetchlogs.sh [start|stop] [oc_endpoint] [oc_username] [oc_password] [oc-project-name] [oc-service-name]"
    echo ""
    echo "EXAMPLES"
    echo ""
    echo "to fetch all logs from all pods in project 'sample' and service 'eap'"
    echo ""
    echo "    ocfetchlogs.sh start 10.1.2.2:8443 user password sample eap"
    echo ""
    echo "to fetch all logs from all pods from all applications in project 'sample'"
    echo ""
    echo "    ocfetchlogs.sh start 10.1.2.2:8443 user password sample"
    echo ""
    exit 1
fi


# stop previous spawned processes
DIE=$(ps -ef | awk '/[p]od/{print $2}')
if [ ! -z "$DIE" ]; then
   kill $DIE
fi

# if operation is to stop the daemon, exit after killing existing processes
if [ "$OPERATION" == "stop" ]; then
    echo "daemon stopped"
    exit 1
fi

if [ -z "$OC_ENDPOINT" -a -z "$OC_USERNAME" -a -z "$OC_PASSWORD" ]; then
    echo "error: openshift login "
    echo "You need to specify one of OC_ENDPOINT, OC_USERNAME and OC_PASSWORD"
    exit 1
fi

echo "Logging into OpenShift Console '"$OC_ENDPOINT"' using '"$OC_USERNAME"' with password *******"
echo ""
oc login $OC_ENDPOINT -u $OC_USERNAME -p $OC_PASSWORD >/dev/null

echo "Using project '"$OC_PROJECT"'"
echo ""
oc project $OC_PROJECT >/dev/null

if [ -n "$OC_SERVICE" ]; then
    PODS=$(oc get pods --show-all=false --output name | grep $OC_SERVICE)
else
    PODS=$(oc get pods --show-all=false --output name)
fi

for POD in $PODS
do
    (oc logs $POD -f --timestamps=true --since=1s >> ${OC_PROJECT}-${POD///}.log &)
done

echo "daemon started successfully"
echo ""
echo "you can start tailing the logs in the current directory"
echo ""
echo "EXAMPLES"
echo ""
for POD in $PODS
do
    echo "    tail -f "${OC_PROJECT}-${POD///}.log
done
