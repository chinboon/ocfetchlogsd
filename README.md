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
ocfetchlogs.sh start [oc_endpoint] [oc_username] [oc_password]  [oc-project-name] [nfs-service-name]
```

Stopping the daemon

```
ocfetchlogs.sh stop
```

#### Examples

To fetch all logs from all pods in OpenShift project 'dev-in' and service 'bsoi'

```
ocfetchlogs.sh start ocp-console-rdc.np.ocp.standardchartered.com:8443 user password dev-in bsoi
```

To fetch all logs from all pods from all services in OpenShift project 'st-nfs-in'

```
ocfetchlogs.sh start ocp-console-rdc.np.ocp.standardchartered.com:8443 user password st-nfs-in
```

#### Sample run outputs

```
Ohs-MacBook-Pro:ocfetchlogsd chinboon$ ./ocfetchlogsd.sh start dev-in
Logging into OpenShift Console 'https://ocp-console-rdc.np.ocp.standardchartered.com:8443' using 'devel4' with password *******

Using project 'dev-in'

daemon started successfully

you can start tailing the logs in the current directory

EXAMPLES

    tail -f dev-in-podnfs-audit-v1-blue-1-9rnlz.log
    tail -f dev-in-podnfs-audit-v1-green-1-r48n8.log
    tail -f dev-in-podnfs-bmw-blue-5-hjcd6.log
    tail -f dev-in-podnfs-bmw-green-6-1jd1s.log
    tail -f dev-in-podnfs-boa-blue-1-t19s0.log
    tail -f dev-in-podnfs-boa-green-2-g2chd.log
    tail -f dev-in-podnfs-bsoi-blue-2-rklr4.log
    tail -f dev-in-podnfs-bsoi-green-2-cl0tg.log
    tail -f dev-in-podnfs-foa-blue-8-xh2st.log
    tail -f dev-in-podnfs-orr-virtue-blue-1-bq1t9.log
    tail -f dev-in-podnfs-orr-virtue-green-1-2gwm4.log
    tail -f dev-in-podnfs-picasso-bsoi-blue-1-8kx5b.log
    tail -f dev-in-podnfs-picasso-bsoi-green-1-2n06k.log
    tail -f dev-in-podnfs-picasso-shared-service-blue-1-1623q.log
    tail -f dev-in-podnfs-picasso-shared-service-green-1-p07cw.log
    tail -f dev-in-podnfs-special-service-blue-1-x0g41.log
    tail -f dev-in-podnfs-special-service-green-1-8wvvb.log
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
