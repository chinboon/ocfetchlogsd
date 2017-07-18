#!/bin/sh
# script to fetch logs from OpenShift by service or project
# 
# today's problem
# --------------------------------------------------------------------------------
# TDLR: there is no openshift-way to get logs by service or project - one has
# to get logs by the pod-name 
#
# Long Story: today, in order to get logs from OpenShift one has to use the command:
#
#     oc logs <pod-name>
#
# and... because pod name is not fixed (due to auto-scaling of pods up and down),
# one would always have to first check the pod-name from OpenShift console
# 
# and most of the time... there can be more than one pod, if there are n-number of 
# pods in a service or project, then one has to execute n-number of
# oc logs commands 
#
#
# Author: Oh Chin Boon <chinboon.oh2@gmail.com>


# ##########################
# USER DEFINED SECTION START
# SET OC ENDPOINT
OC_ENDPOINT=
# SET OC USERNAME
OC_USERNAME=
# SET OC PASSWORD
OC_PASSWORD=
# USER DEFINED SECTION END
###########################




# input validation
if [ $# -eq 0 ]; then
    echo "missing input to the script"
    echo "exiting..."
    echo ""
    echo "USAGE"
    echo ""
    echo "    ocfetchlogsd.sh [start|stop] [oc-project-name] [service-name]"
    echo ""
    echo "EXAMPLES"
    echo ""
    echo "to fetch all logs from all pods in project 'project-springboot' and service 'api'"
    echo ""
    echo "    ocfetchlogsd.sh start project-springboot api"
    echo ""
    echo "to fetch all logs from all pods from all services in project 'project-springboot'"
    echo ""
    echo "    ocfetchlogsd.sh start project-springboot"
    echo ""
    exit 1
fi

OPERATION=$1
# e.g. dev-in
OC_PROJECT=$2
# e.g. bmw
OC_SERVICE=$3

# business validation
if [ $OPERATION != "start" ] && [ $OPERATION != "stop" ] ; then
    echo "cannot recognize '"$OPERATION"', should be 'start' or 'stop'"
    echo "exiting..."
    echo ""
    echo "USAGE"
    echo ""
    echo "    ocfetchlogsd.sh [start|stop] [oc-project-name] [service-name]"
    echo ""
    echo "EXAMPLES"
    echo ""
    echo "to fetch all logs from all pods in project 'project-springboot' and service 'api'"
    echo ""
    echo "    ocfetchlogsd.sh start project-springboot api"
    echo ""
    echo "to fetch all logs from all pods from all services in project 'project-springboot'"
    echo ""
    echo "    ocfetchlogsd.sh start project-springboot"
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
