# cloud_tools
binaries for openshift/kubernetes reporting



eoc is a tool for openshift reporting, It needs oc client and md5sum in your environment.
ekubectl is a tool for kubernetes reporting, It need kubectl client and md5sum in your environment


Install just put it inside /usr/bin folder



It takes one or two argument

first arg can be a number of days you want the reporting  or -p option to purge the eoc database
second arg can be only -p after first arg is the number of days

exemples :

eoc 10     ekubectl 10

  ==> It will produce a 10 last days report

eoc -p     ekubectl -p

  ==> It produces no report but purge the eoc/ekubectl database
  
eoc 2 -p   ekubectl 2 -p

  ==> It produces a report of the 2 last days and purge the eoc/ekubectl database


Return codes of the command :

  0 --> report is produce well
  
  1 --> arg is not numeric
  
  2 --> oc client is not present
  
  3 --> not logging to openshift
  
  4 --> md5sum is not present
  
  5 --> Another eoc process is running

  6 --> purge is done

  7 --> no arg present



eoc produces a report of changes done in the arg days before

It handles all this objects
It check errors too

deploy, replicasets, statefulsets, hpa, jobs, cronjobs, imagestreams, pods, services, routes, configmaps, secrets, replicationcontrolers


ekubectl produces a report of this type of objects :

deploy,  statefulsets, jobs, cronjobs, pods, services, ingresses,ingressroute, configmaps, secrets , replicationcontroler
