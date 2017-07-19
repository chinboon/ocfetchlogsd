# ocfetchlogsd

daemon to fetch logs from OpenShift by **service** or **project**

## ABOUT

TDLR: there is no OpenShift-way to fetch logs by service or even project level, one has
to get logs by the pod's name. When there is more than one pod per service,
it becomes tedious to get all logs from all pods of a service

Long Story: today, in order to get logs from OpenShift one has to use the command:

```
oc logs <pod-name>
```

and... because pod name is not fixed (due to auto-scaling of pods),
one would always have to first check on the pod name from OpenShift console

and most of the time... there can be more than one pod, if there are n-number of
pods in the service, then one has to execute n-number of
oc logs commands

## GETTING STARTED

Its really simple to start the daemon right away


#### Running

Starting the daemon

```
ocfetchlogs.sh start [oc_endpoint] [oc_username] [oc_password]  [oc-project-name] [oc-service-name]
```

Stopping the daemon

```
ocfetchlogs.sh stop
```

#### Examples

To fetch all logs from all pods in OpenShift project 'sample' and service 'eap'

```
ocfetchlogs.sh start 10.1.2.2:8443 user password sample eap
```

To fetch all logs from all pods from all services in OpenShift project 'sample'

```
ocfetchlogs.sh start 10.1.2.2:8443 user password sample
```

#### Sample run outputs

```
Ohs-MacBook-Pro:ocfetchlogsd chinboon$ ./ocfetchlogsd.sh start dev-in
Logging into OpenShift Console 'https://10.1.2.2:8443' using 'user' with password *******

Using project 'sample'

daemon started successfully

you can start tailing the logs in the current directory

EXAMPLES

    tail -f sample-eap-1-9rnlz.log
    tail -f sample-eap-1-r48n8.log
    
```

## LIMITATIONS

1. If there are more than one container in the pod, then this daemon might not work as expected
because it was not tested with pods having more than one container

2. This is a daemon that will run in the background, but it is not meant to replace an aggregator
or such log aggregating softwares (e.g. kibana, logstash) as it does not handle most exception scenarios,
such as timeouts, it is created as a DEV Tool and strictly to be used as such only

## CONTRIBUTING

Pull requests accepted

## ISSUES

Email me chinboon.oh@sc.com
