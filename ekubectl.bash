#!/bin/bash
arg1=$1
PID=$$
arg2=$2
ps -ef|grep -v grep|grep "ekubectl "
if [ $? -eq 0 ];then
	echo "ekubectl v1.4 already running...exiting"
	exit 5

fi
if [[ "$arg1" == "" ]];then
	echo "ekubectl v1.4"
	echo "Arg is absent"
	exit 7
fi
if [ "$arg1" == "-p" ];then
        rm -f /var/tmp/ekubectl_database/* >/dev/null
	exit 6
fi

if [[ "$arg1" =~ ^[0-9]+$ ]];then
	echo
else
	echo "ekubectl v1.4"
	echo "Arg is not numeric . Arg is the number of days . ex: 1 for one day, 7 for seven days"
	echo "You can use -p argument as 1st arg or 2nd arg to purge database"
	echo "You can use -e argument as 1st arg or 2nd arg to exclude cronjob object from report"
	exit 1
fi
if [ "$arg2" == "-p" ];then
	rm -f /var/tmp/ekubectl_database/* >/dev/null
fi
if [ "$arg2" == "-e" ];then
	EXCLUD=1
fi
version()
{
	echo "----------" |tee -a /tmp/report.log.$PID |tee -a /tmp/reportfull.log.$PID
	echo "ekubectl v1.4 "|tee -a /tmp/report.log.$PID |tee -a /tmp/reportfull.log.$PID
	echo " kubernetes objects to check : deploy,  statefulsets, jobs, cronjobs, pods, services, ingresses,ingressroute, configmaps, secrets , replicationcontroler"|tee -a /tmp/report.log.$PID |tee -a /tmp/reportfull.log.$PID
	echo "----------" |tee -a /tmp/report.log.$PID |tee -a /tmp/reportfull.log.$PID

}

connect()
{
	which md5sum>/dev/null
	if [ $? -ne 0 ];then
		echo "No md5sum bin detected"
		exit 4
	fi
	which kubectl>/dev/null
	if [ $? -ne 0 ];then
		echo "No kubectl client detected"
		exit 2
	fi
	if [ -f /tmp/ekubelist ];then
	  rm -f /tmp/ekubelist >/dev/null
	fi
	cd /tmp >/dev/null

	kubectl get pods  2>&1 >/tmp/ekubelist
	chmod 777 /tmp/ekubelist
	#chmod 777 /tmp/nohup.out
	cd - >/dev/null
	ps -ef|grep "kubectl get pods"|awk '{ print $2} ' >/tmp/listpid.$PID >/dev/null
	while read ligne
	do
		kill -9 $ligne >/dev/null
	done</tmp/listpid.$PID
	sed -i '/Please/d' /tmp/ekubelist 
	nb=`cat /tmp/ekubelist|cut -d " " -f1|wc -l`
	if [ "$nb" == "0" ];then
		echo "Check your KUBECONFIG variable or config inside .kube folder to set a context"
		exit 3
	else
		kubectl get namespace|grep -v NAME|grep -v "kube-"|grep -v default|cut -d " " -f1>/tmp/proj.ekubectl.$PID
	fi
	#env|grep KUBECONFIG>/dev/null
	#if [ $? -eq 1 ] ;then
	#	echo "No KUBECONFIG variable detected...test if connected..."
	#	exit 8
	#else
        #        kubectl get namespace|grep -v NAME|cut -d " " -f1>/tmp/proj.ekubectl.$PID

	#fi
}

foldersdatabase()
{
	if [ ! -d /var/tmp/ekubectl_database ];then
		mkdir -p /var/tmp/ekubectl_database
	fi
}

init()
{

	rm -f /tmp/ekubectl*.$PID
	touch /tmp/ekubectl.temp.$PID
	touch /tmp/ekubectl.tempdetails.$PID
	rm -f /tmp/preparse*.$PID
	rm -f /var/tmp/ekubectl_database/*.toanalyse	>/dev/null
}
kubedeploy()
{
	kubectl get deploy |grep -v NAME|sort -r -k+6 >/tmp/ekubectl_full.log.$PID
        #cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]y' >/tmp/ekubectl_y.log.$PID
	#cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]s' >/tmp/ekubectl_s.log.$PID
        #cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]m' >/tmp/ekubectl_m.log.$PID
        #cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]d' >/tmp/ekubectl_d.log.$PID
        #cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]h' >/tmp/ekubectl_h.log.$PID
	touch /tmp/ekubectl_m.log.$PID /tmp/ekubectl_h.log.$PID /tmp/ekubectl_s.log.$PID /tmp/ekubectl_d.log.$PID /tmp/ekubectl_y.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "y" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_y.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "s" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_d.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "m" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_d.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "d" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_d.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "h" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_h.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID

        wcf=`wc -l /tmp/ekubectl_full.log.$PID|cut -d " " -f1`
        wcd=`wc -l /tmp/ekubectl_d.log.$PID|cut -d " " -f1`
        wcy=`wc -l /tmp/ekubectl_y.log.$PID|cut -d " " -f1`
        wch=`wc -l /tmp/ekubectl_h.log.$PID|cut -d " " -f1`
        wcm=`wc -l /tmp/ekubectl_m.log.$PID|cut -d " " -f1`
        wcs=`wc -l /tmp/ekubectl_s.log.$PID|cut -d " " -f1`
	label="deploy"
	details="y"
	custom="n"
	customedetails="n"
}
kubepods()
{
	kubectl get po |grep -v NAME|grep -v ekubectl|grep -v Completed|sort -r -k+4 >/tmp/ekubectl_full.log.$PID
	touch /tmp/ekubectl_m.log.$PID /tmp/ekubectl_h.log.$PID /tmp/ekubectl_s.log.$PID /tmp/ekubectl_d.log.$PID /tmp/ekubectl_y.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "y" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_y.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "s" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_d.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "m" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_d.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "d" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_d.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "h" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_h.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID

  #      cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]y' >/tmp/ekubectl_y.log.$PID
  #      cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]s' >/tmp/ekubectl_s.log.$PID
  #      cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]m' >/tmp/ekubectl_m.log.$PID
  #      cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]h' >/tmp/ekubectl_h.log.$PID
  #      cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]d' >/tmp/ekubectl_d.log.$PID
        wcf=`wc -l /tmp/ekubectl_full.log.$PID|cut -d " " -f1`
        wcd=`wc -l /tmp/ekubectl_d.log.$PID|cut -d " " -f1`
        wch=`wc -l /tmp/ekubectl_h.log.$PID|cut -d " " -f1`
        wcy=`wc -l /tmp/ekubectl_y.log.$PID|cut -d " " -f1`
        wcm=`wc -l /tmp/ekubectl_m.log.$PID|cut -d " " -f1`
        wcs=`wc -l /tmp/ekubectl_s.log.$PID|cut -d " " -f1`
	label="pods"
	details="y"
	custom="n"
	customedetails="n"
}
kubeservices()
{
	kubectl get svc |grep -v NAME|sort -r -k+6 >/tmp/ekubectl_full.log.$PID
	touch /tmp/ekubectl_m.log.$PID /tmp/ekubectl_h.log.$PID /tmp/ekubectl_s.log.$PID /tmp/ekubectl_d.log.$PID /tmp/ekubectl_y.log.$PID
	while read line
	do
		ligne=`echo $line`
		test=`echo "$line" |awk '{ print $NF }'|cut -d "y" -f1 `
		if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
			echo $ligne >>/tmp/ekubectl_y.log.$PID
		fi
	done</tmp/ekubectl_full.log.$PID
	while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "s" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_s.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
	while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "m" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_m.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
	while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "d" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_d.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
	while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "h" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_h.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID


        #cat /tmp/ekubectl_full.log.$PID |awk '{print $NF}'|grep '[0-9]y'  >/tmp/ekubectl_y.log.$PID
        #cat /tmp/ekubectl_full.log.$PID |awk '{print $NF}'|grep '[0-9]s'  >/tmp/ekubectl_s.log.$PID
        #cat /tmp/ekubectl_full.log.$PID |awk '{print $NF}'|grep '[0-9]m'  >/tmp/ekubectl_m.log.$PID
        #cat /tmp/ekubectl_full.log.$PID |awk '{print $NF}'|grep '[0-9]d'  >/tmp/ekubectl_d.log.$PID
        wcf=`wc -l /tmp/ekubectl_full.log.$PID|cut -d " " -f1`
        wcd=`wc -l /tmp/ekubectl_d.log.$PID|cut -d " " -f1`
        wcy=`wc -l /tmp/ekubectl_y.log.$PID|cut -d " " -f1`
        wcm=`wc -l /tmp/ekubectl_m.log.$PID|cut -d " " -f1`
        wcs=`wc -l /tmp/ekubectl_s.log.$PID|cut -d " " -f1`
        wch=`wc -l /tmp/ekubectl_h.log.$PID|cut -d " " -f1`
	label="services"
	details="y"
	custom="n"
	customedetails="n"
}
kubeconfigmaps()
{
	kubectl get configmaps|grep -v NAME|sort -r -k+3>/tmp/ekubectl_full.log.$PID
        touch /tmp/ekubectl_h.log.$PID /tmp/ekubectl_m.log.$PID /tmp/ekubectl_s.log.$PID /tmp/ekubectl_d.log.$PID  /tmp/ekubectl_y.log.$PID /tmp/preparse.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "y" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_y.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "s" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_s.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "m" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_m.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "d" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_d.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
	while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "h" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_h.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID

        wcf=`wc -l /tmp/ekubectl_full.log.$PID|cut -d " " -f1`
	if [ -f /var/tmp/ekubectl_database/${tenant}.configmaps.lasttime ];then
		mv /var/tmp/ekubectl_database/${tenant}.configmaps.lasttime /var/tmp/ekubectl_database/${tenant}.configmaps.toanalyse
		firstrun="0"
	else
		firstrun="1"
	fi
	while read linedatabase
	do
		linedata=`echo $linedatabase|cut -d " " -f1`
		result=`kubectl describe configmaps "$linedata" |sort|md5sum|cut -d " " -f1`
		echo "$linedata $result" >>/var/tmp/ekubectl_database/${tenant}.configmaps.lasttime

	done</tmp/ekubectl_full.log.$PID
	if [ -f /var/tmp/ekubectl_database/${tenant}.configmaps.lasttime ];then
	  cat /var/tmp/ekubectl_database/${tenant}.configmaps.lasttime |sort >/var/tmp/ekubectl_database/${tenant}.configmaps.lasttime_ && mv /var/tmp/ekubectl_database/${tenant}.configmaps.lasttime_ /var/tmp/ekubectl_database/${tenant}.configmaps.lasttime
	fi
	if [ -f /var/tmp/ekubectl_database/${tenant}.configmaps.toanalyse ];then
		echo ""|tee /tmp/report.log.$PID
		i=0
		while read analyse
		do
			line=`echo $analyse`
			name=`echo $analyse|cut -d " " -f1`
			md5=`echo $analyse|cut -d " " -f2`
			cat /var/tmp/ekubectl_database/${tenant}.configmaps.toanalyse|grep "$line">/dev/null
			if [ $? -eq 1 ];then
				echo " 1 WARNING on $name configmap - It has a content that changes - please check it" >>/tmp/preparse.$PID
				i=$(($i + 1))
			fi
		done</var/tmp/ekubectl_database/${tenant}.configmaps.lasttime
		echo " ">>/tmp/preparse.$PID
		echo " $i WARNING(S) Raise for coherence verification">>/tmp/preparse.$PID
	fi
        wcd=`wc -l /tmp/ekubectl_d.log.$PID|cut -d " " -f1`
        wcy=`wc -l /tmp/ekubectl_y.log.$PID|cut -d " " -f1`
        wcm=`wc -l /tmp/ekubectl_m.log.$PID|cut -d " " -f1`   
        wcs=`wc -l /tmp/ekubectl_s.log.$PID|cut -d " " -f1`   
	wch=`wc -l /tmp/ekubectl_s.log.$PID|cut -d " " -f1`
        label="configmaps"
        details="n"
        custom="configmaps"
        customedetails="n"
}

kubesecrets()
{
	kubectl get secrets |grep -v NAME|sort -r -k+4 >/tmp/ekubectl_full.log.$PID
        touch /tmp/ekubectl_m.log.$PID /tmp/ekubectl_h.log.$PID /tmp/ekubectl_s.log.$PID /tmp/ekubectl_d.log.$PID /tmp/ekubectl_y.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "y" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_y.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
	while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "s" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_s.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "m" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_m.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "d" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_d.log.$PID
                fi
	done</tmp/ekubectl_full.log.$PID
	while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "h" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_h.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
	wcf=`wc -l /tmp/ekubectl_full.log.$PID|cut -d " " -f1`
        if [ -f /var/tmp/ekubectl_database/${tenant}.secrets.lasttime ];then
                mv /var/tmp/ekubectl_database/${tenant}.secrets.lasttime /var/tmp/ekubectl_database/${tenant}.secrets.toanalyse
                firstrun="0"
        else
                firstrun="1"
        fi
        while read linedatabase
        do
                linedata=`echo $linedatabase|cut -d " " -f1`
                result=`kubectl describe secrets "$linedata" |sort|md5sum|cut -d " " -f1`
                echo "$linedata $result" >>/var/tmp/ekubectl_database/${tenant}.secrets.lasttime

        done</tmp/ekubectl_full.log.$PID
        cat /var/tmp/ekubectl_database/${tenant}.secrets.lasttime |sort >/var/tmp/ekubectl_database/${tenant}.secrets.lasttime_ && mv /var/tmp/ekubectl_database/${tenant}.secrets.lasttime_ /var/tmp/ekubectl_database/${tenant}.secrets.lasttime
        if [ -f /var/tmp/ekubectl_database/${tenant}.secrets.toanalyse ];then
                echo ""|tee /tmp/report.log.$PID
                i=0
                while read analyse
                do
                        line=`echo $analyse`
                        name=`echo $analyse|cut -d " " -f1`
                        md5=`echo $analyse|cut -d " " -f2`
                        cat /var/tmp/ekubectl_database/${tenant}.secrets.toanalyse|grep "$line">/dev/null
                        if [ $? -eq 1 ];then
                                echo " 1 WARNING on $name secrets - It has a content that changes - please check it" >>/tmp/preparse.$PID
                                i=$(($i + 1))
                        fi
                done</var/tmp/ekubectl_database/${tenant}.secrets.lasttime
                echo " ">>/tmp/preparse.$PID
                echo " $i WARNING(S) Raise for coherence verification">>/tmp/preparse.$PID
        fi

        wcf=`wc -l /tmp/ekubectl_full.log.$PID|cut -d " " -f1`
        wcd=`wc -l /tmp/ekubectl_d.log.$PID|cut -d " " -f1`
        wcy=`wc -l /tmp/ekubectl_y.log.$PID|cut -d " " -f1`   
        wch=`wc -l /tmp/ekubectl_h.log.$PID|cut -d " " -f1`   
        wcm=`wc -l /tmp/ekubectl_m.log.$PID|cut -d " " -f1`   
        wcs=`wc -l /tmp/ekubectl_s.log.$PID|cut -d " " -f1`
        label="secrets"
        details="n"
        custom="secrets"
        customedetails="n"
}
kuberc()
{
	kubectl get rc |grep -v NAME|sort -r -k+5 >/tmp/ekubectl_full.log.$PID
        touch /tmp/ekubectl_m.log.$PID /tmp/ekubectl_h.log.$PID /tmp/ekubectl_s.log.$PID /tmp/ekubectl_d.log.$PID /tmp/ekubectl_y.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "y" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_y.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "s" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_s.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "m" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_m.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "d" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_d.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "h" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_h.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID


        wcf=`wc -l /tmp/ekubectl_full.log.$PID|cut -d " " -f1`
        wcd=`wc -l /tmp/ekubectl_d.log.$PID|cut -d " " -f1`
        wcy=`wc -l /tmp/ekubectl_y.log.$PID|cut -d " " -f1`   
        wcm=`wc -l /tmp/ekubectl_m.log.$PID|cut -d " " -f1`   
        wcs=`wc -l /tmp/ekubectl_s.log.$PID|cut -d " " -f1`
        wch=`wc -l /tmp/ekubectl_h.log.$PID|cut -d " " -f1`
        label="replicationcontroler"
        details="y"
        custom="n"
        customedetails="rc"

}


kubestatefullsets()
{
	kubectl get statefulsets |grep -v NAME|sort -r -k+6>/tmp/ekubectl_full.log.$PID
        #cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]y' >/tmp/ekubectl_y.log.$PID
        #cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]s' >/tmp/ekubectl_s.log.$PID
        #cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]m' >/tmp/ekubectl_m.log.$PID
        #cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]d' >/tmp/ekubectl_d.log.$PID
	touch /tmp/ekubectl_m.log.$PID /tmp/ekubectl_h.log.$PID /tmp/ekubectl_s.log.$PID /tmp/ekubectl_d.log.$PID /tmp/ekubectl_y.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "y" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_y.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "s" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_s.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "m" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_m.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "d" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_d.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "h" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_h.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID

        #cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]h' >/tmp/ekubectl_h.log.$PID
        wcf=`wc -l /tmp/ekubectl_full.log.$PID|cut -d " " -f1`
        wcd=`wc -l /tmp/ekubectl_d.log.$PID|cut -d " " -f1`
        wcy=`wc -l /tmp/ekubectl_y.log.$PID|cut -d " " -f1`
        wch=`wc -l /tmp/ekubectl_h.log.$PID|cut -d " " -f1`
        wcm=`wc -l /tmp/ekubectl_m.log.$PID|cut -d " " -f1`
        wcs=`wc -l /tmp/ekubectl_s.log.$PID|cut -d " " -f1`
        label="statefulset"
	details="y"
	custom="n"
	customedetails="statefulset"
}

kubejobs()
{
	kubectl get jobs |grep -v NAME|grep -v ekubectl|sort -r -k+6>/tmp/ekubectl_full.log.$PID
        #cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]y' >/tmp/ekubectl_y.log.$PID
        #cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]s' >/tmp/ekubectl_s.log.$PID
        #cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]m' >/tmp/ekubectl_m.log.$PID
        #cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]d' >/tmp/ekubectl_d.log.$PID
        #cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]h' >/tmp/ekubectl_h.log.$PID
	  touch /tmp/ekubectl_m.log.$PID /tmp/ekubectl_h.log.$PID /tmp/ekubectl_s.log.$PID /tmp/ekubectl_d.log.$PID /tmp/ekubectl_y.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "y" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_y.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "s" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_s.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "m" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_m.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "d" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_d.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "h" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_h.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID

        wcf=`wc -l /tmp/ekubectl_full.log.$PID|cut -d " " -f1`
        wcd=`wc -l /tmp/ekubectl_d.log.$PID|cut -d " " -f1`
        wcy=`wc -l /tmp/ekubectl_y.log.$PID|cut -d " " -f1`
        wch=`wc -l /tmp/ekubectl_h.log.$PID|cut -d " " -f1`
        wcm=`wc -l /tmp/ekubectl_m.log.$PID|cut -d " " -f1`
        wcs=`wc -l /tmp/ekubectl_s.log.$PID|cut -d " " -f1`
        label="jobs"
	details="y"
	custom="n"
	customedetails="jobs"
}
kubecronjobs()
{
	kubectl get cronjobs |grep -v NAME|grep -v ekubectl|sort -r -k+6>/tmp/ekubectl_full.log.$PID
#	cat /tmp/ekubectl_full.log.$PID |awk '{ print $NF }'|cut -d "y" -f1` >/tmp/ekubectl_y.log.$PID
        #cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]y' >/tmp/ekubectl_y.log.$PID
        #cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]s' >/tmp/ekubectl_s.log.$PID
        #cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]m' >/tmp/ekubectl_m.log.$PID
        #cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]h' >/tmp/ekubectl_h.log.$PID
        #cat /tmp/ekubectl_full.log.$PID |grep ' [0-9]d' >/tmp/ekubectl_d.log.$PID
	  touch /tmp/ekubectl_m.log.$PID /tmp/ekubectl_h.log.$PID /tmp/ekubectl_s.log.$PID /tmp/ekubectl_d.log.$PID /tmp/ekubectl_y.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "y" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_y.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "s" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_s.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "m" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_m.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "d" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_d.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "h" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_h.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID

        wcf=`wc -l /tmp/ekubectl_full.log.$PID|cut -d " " -f1`
        wcd=`wc -l /tmp/ekubectl_d.log.$PID|cut -d " " -f1`
        wcy=`wc -l /tmp/ekubectl_y.log.$PID|cut -d " " -f1`
        wch=`wc -l /tmp/ekubectl_h.log.$PID|cut -d " " -f1`
        wcm=`wc -l /tmp/ekubectl_m.log.$PID|cut -d " " -f1`
        wcs=`wc -l /tmp/ekubectl_s.log.$PID|cut -d " " -f1`
        label="cronjobs"
	details="n"
	custom="n"
	customedetails="n"
}
kubeingress()
{
	rm -f /tmp/temp5.$PID /tmp/temp4.$PID >/dev/null
	touch /tmp/ekubectl_d.log.$PID /tmp/ekubectl_h.log.$PID /tmp/ekubectl_y.log.$PID /tmp/ekubectl_m.log.$PID /tmp/ekubectl_s.log.$PID
	kubectl get ingress |grep -v NAME|sort -r -k+1>/tmp/ekubectl_full.log.$PID
	while read line
	do
		full=`echo $line`
		name=`echo $line|cut -d " " -f1`
		kubectl describe ingress $name > /tmp/temp4.$PID
		recup=`cat /tmp/temp4.$PID|grep Created|cut -d ":" -f2`

		echo "$line $recup" >>/tmp/temp5.$PID
	done</tmp/ekubectl_full.log.$PID
	if [ -f /tmp/temp5.$PID ];then
	  cat /tmp/temp5.$PID >/tmp/ekubectl_full.log.$PID
	  rm -f /tmp/temp5.$PID /tmp/temp4.$PID
	fi
	while read ligne
        do
                recup=`echo $ligne|sed -rn 's/(^|(.* ))([^ ]*) years(( .*)|$)/\3/; T; p; q'`
                if [ "$recup" != "" ];then
                        echo $ligne >>/tmp/ekubectl_y.log.$PID
                fi
                recup=`echo $ligne|sed -rn 's/(^|(.* ))([^ ]*) year(( .*)|$)/\3/; T; p; q'`
                if [ "$recup" != "" ];then
                        echo $ligne >>/tmp/ekubectl_y.log.$PID
                fi
                recup=`echo $ligne|sed -rn 's/(^|(.* ))([^ ]*) month(( .*)|$)/\3/; T; p; q'`
                if [ "$recup" != "" ];then
                        echo $ligne >>/tmp/ekubectl_y.log.$PID
                fi
                recup=`echo $ligne|sed -rn 's/(^|(.* ))([^ ]*) months(( .*)|$)/\3/; T; p; q'`
                if [ "$recup" != "" ];then
                        echo $ligne >>/tmp/ekubectl_y.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
	while read ligne
        do
                recup=`echo $ligne|sed -rn 's/(^|(.* ))([^ ]*) weeks(( .*)|$)/\3/; T; p; q'`
		calcul=`echo $ligne|awk '{print $(NF-2)" "$(NF-1)" "$NF}'|cut -d " " -f3|sed 's/.$//'`
		calculday=$(($calcul * 7))
		if [ "$calculday" -lt "$arg1" ];then
                	if [ "$recup" != "" ];then
                       		echo $ligne >>/tmp/ekubectl_d.log.$PID
			else
				echo $ligne >>/tmp/ekubectl_y.log.$PID
                	fi
		fi
                recup=`echo $ligne|sed -rn 's/(^|(.* ))([^ ]*) week(( .*)|$)/\3/; T; p; q'`
		calcul=`echo $ligne|awk '{print $(NF-2)" "$(NF-1)" "$NF}'|cut -d " " -f3|sed 's/.$//'`
                calculday=$(($calcul * 7))
                if [ "$calculday" -lt "$arg1" ];then
                        if [ "$recup" != "" ];then
                                echo $ligne >>/tmp/ekubectl_d.log.$PID 
                        else
                                echo $ligne >>/tmp/ekubectl_y.log.$PID
                        fi

		fi
                if [ "$recup" != "" ];then
                        echo $ligne >>/tmp/ekubectl_y.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
	while read ligne
        do
                recup=`echo ligne|sed -rn 's/(^|(.* ))([^ ]*) second(( .*)|$)/\3/; T; p; q'`
                if [ "$recup" != "" ];then
                        echo $ligne >>/tmp/ekubectl_d.log.$PID
                fi  
                recup=`echo ligne|sed -rn 's/(^|(.* ))([^ ]*) seconds(( .*)|$)/\3/; T; p; q'`
                if [ "$recup" != "" ];then
                        echo $ligne >>/tmp/ekubectl_d.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read ligne
        do
                recup=`echo $ligne|sed -rn 's/(^|(.* ))([^ ]*) minute(( .*)|$)/\3/; T; p; q'`
                if [ "$recup" != "" ];then
                        echo $ligne >>/tmp/ekubectl_d.log.$PID
                fi
                recup=`echo $ligne|sed -rn 's/(^|(.* ))([^ ]*) minutes(( .*)|$)/\3/; T; p; q'`
                if [ "$recup" != "" ];then
                        echo $ligne >>/tmp/ekubectl_d.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read ligne
        do
                recup=`echo $ligne|sed -rn 's/(^|(.* ))([^ ]*) day(( .*)|$)/\3/; T; p; q'`
                if [ "$recup" != "" ];then
                        echo $ligne >>/tmp/ekubectl_d.log.$PID
                fi
                recup=`echo $ligne|sed -rn 's/(^|(.* ))([^ ]*) days(( .*)|$)/\3/; T; p; q'`
                if [ "$recup" != "" ];then
                        echo $ligne >>/tmp/ekubectl_d.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID


        wcf=`wc -l /tmp/ekubectl_full.log.$PID|cut -d " " -f1`
        wcd=`wc -l /tmp/ekubectl_d.log.$PID|cut -d " " -f1`
        wcy=`wc -l /tmp/ekubectl_y.log.$PID|cut -d " " -f1`
        wcm=`wc -l /tmp/ekubectl_m.log.$PID|cut -d " " -f1`
        wcs=`wc -l /tmp/ekubectl_s.log.$PID|cut -d " " -f1`
        wch=`wc -l /tmp/ekubectl_h.log.$PID|cut -d " " -f1`
        label="ingress"
	details="n"
	custom="n"
	customedetails="n"
}
kubeingressroute()
{
        touch /tmp/ekubectl_d.log.$PID /tmp/ekubectl_h.log.$PID /tmp/ekubectl_y.log.$PID /tmp/ekubectl_m.log.$PID /tmp/ekubectl_s.log.$PID
        kubectl get ingressroute |grep -v NAME|sort -r -k+1>/tmp/ekubectl_full.log.$PID
	while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "y" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_y.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "s" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_s.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do                              
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "m" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_m.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "d" -f1 `
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_d.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID                                                     
        while read line
        do
                ligne=`echo $line`
                test=`echo "$line" |awk '{ print $NF }'|cut -d "h" -f1 `                      
                if [ "$(echo $test | grep "^[[:digit:] ]*$")" ];then
                        echo $ligne >>/tmp/ekubectl_h.log.$PID
                fi
        done</tmp/ekubectl_full.log.$PID


        wcf=`wc -l /tmp/ekubectl_full.log.$PID|cut -d " " -f1`
        wcd=`wc -l /tmp/ekubectl_d.log.$PID|cut -d " " -f1`
        wcy=`wc -l /tmp/ekubectl_y.log.$PID|cut -d " " -f1`
        wcm=`wc -l /tmp/ekubectl_m.log.$PID|cut -d " " -f1`
        wcs=`wc -l /tmp/ekubectl_s.log.$PID|cut -d " " -f1`
        wch=`wc -l /tmp/ekubectl_h.log.$PID|cut -d " " -f1`
        label="ingressroute"
        details="n"
        custom="n"
        customedetails="n"


}

display()
{
	echo "" |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID 
	echo "==SCAN  TENANT $tenant for $label objects==" |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID
	echo "" |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID

	echo " $wcs WARNING TO CHECK - VERY RECENT new $label - check if it's normal"| tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID
        if [ "$wcs" -eq "0" ];then
                echo "" |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID
        else
                echo "" |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID
                cat /tmp/ekubectl_s.log.$PID |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID
                echo "" |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID
        fi
        echo " $wcm WARNING TO CHECK - RECENT new $label object - check if it's normal" |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID
        if [ "$wcm" -eq "0" ];then
                echo "" |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID
        else
                echo "" |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID
                cat /tmp/ekubectl_m.log.$PID |tee /tmp/report.log|tee -a  /tmp/reportfull.log
                echo "" |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID
        fi
        if [ "$wcd" -eq "0" ];then
                echo "" |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID
        else
                while read line
                do
			case $custom in
			n)
				dayline=`echo $line |awk '{ print $NF }'|cut -d "d" -f1`
				if [ "$(echo $dayline | grep "^[[:digit:] ]*$")" ] ;then
                        	  if [ "$dayline" -lt "$arg1" ];then
                                  	echo $line >>/tmp/ekubectl.temp.$PID
                        	  fi
				else
					echo $line >>/tmp/ekubectl.temp.$PID
				fi
				;;

			configmaps)
				dayline=`echo $line |awk '{ print $NF }'|cut -d "d" -f1`
				if [ "$(echo $dayline | grep "^[[:digit:] ]*$")" ] ;then
                                  if [ "$dayline" -lt "$arg1" ];then
                                        echo $line >>/tmp/ekubectl.temp.$PID
                                  fi
				fi
                                ;;

			secrets)
				dayline=`echo $line |awk '{ print $NF }'|cut -d "d" -f1`
				if [ "$(echo $dayline | grep "^[[:digit:] ]*$")" ] ;then
                                  if [ "$dayline" -lt "$arg1" ];then
                                        echo $line >>/tmp/ekubectl.temp.$PID
                                  fi
				fi
                                ;;

			rs)
				dayline=`echo $line |awk '{ print $NF }'|cut -d "d" -f1`
				if [ "$(echo $dayline | grep "^[[:digit:] ]*$")" ] ;then
                                  if [ "$dayline" -lt "$arg1" ];then
                                        echo $line >>/tmp/ekubectl.temp.$PID
                                  fi
				fi
                                ;;

			esac
			if [ -f /tmp/temp.$PID ];then
				rm -f /tmp/temp.$PID 
			fi
			if [ -f /tmp/temp2.$PID ];then
                                rm -f /tmp/temp2.$PID                
                        fi

                done </tmp/ekubectl_d.log.$PID
		cat /tmp/ekubectl_s.log.$PID >> /tmp/ekubectl.temp.$PID
		cat /tmp/ekubectl_h.log.$PID >> /tmp/ekubectl.temp.$PID
                warningnb=`wc -l /tmp/ekubectl.temp.$PID|cut -d " " -f1`
		if [ -f /tmp/preparse.$PID ];then
			nbc=`cat /tmp/preparse.$PID|wc -l`
                	warningnb=`wc -l /tmp/ekubectl.temp.$PID|cut -d " " -f1`
			if [ "$nbc" != "0" ];then
				cat /tmp/preparse.$PID >> /tmp/ekubectl.temp.$PID
			fi
		fi
#		warningvr=$((${warningnb} + ${wcm} + ${wcs} + ${wch}))
                echo "" |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID
                echo " $warningnb WARNING TO CHECK - $label object created before your argument - check if it's normal" |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID
                echo "" |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID
                cat /tmp/ekubectl.temp.$PID |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID
                echo "" |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID
		if [ "$details" == "y" ];then
                	while read lineerr
                	do
				case $customdetails in
				n)
                       			name=`echo $lineerr|cut -d " " -f1`
                        		desired=`echo $lineerr|cut -d " " -f2`
                        		current=`echo $lineerr|cut -d " " -f3`
					if [ "$desired" != "$current" ];then
                               			echo $lineerr >>/tmp/ekubectl.tempdetails.$PID
                        		else
                               			touch /tmp/ekubectl.tempdetails.$PID
                        		fi
					;;

				pods)
					name=`echo $lineerr|cut -d " " -f1`
					running=`echo $lineerr|awk '{print $3}'`
					if [ "$running" != "Running" ];then
						echo $lineerr >>/tmp/ekubectl.tempdetails.$PID
					else
						touch /tmp/tempdetails.$PID
					fi
					;;
				rc)
					name=`echo $lineerr|cut -d " " -f1`
                                        desired=`echo $lineerr|cut -d " " -f2`
                                        current=`echo $lineerr|cut -d " " -f4`
                                        if [ "$desired" != "$current" ];then
                                                echo $lineerr >>/tmp/ekubectl.tempdetails.$PID
                                        else
                                                touch /tmp/ekubectl.tempdetails.$PID
                                        fi
                                        ;;

				jobs)
					name=`echo $lineerr|cut -d " " -f1`
                                        desired=`echo $lineerr|cut -d " " -f2`
                                        current=`echo $lineerr|cut -d " " -f3`
                                        if [ "$desired" != "$current" ];then
                                                echo $lineerr >>/tmp/ekubectl.tempdetails.$PID
                                        else
                                                touch /tmp/ekubectl.tempdetails.$PID
                                        fi
                                        ;;
				cronjobs)
					name=`echo $lineerr|cut -d " " -f1`
                                        desired=`echo $lineerr|cut -d " " -f2`
                                        current=`echo $lineerr|cut -d " " -f3`
                                        if [ "$desired" != "$current" ];then
                                                echo $lineerr >>/tmp/ekubectl.tempdetails.$PID
                                        else
                                                touch /tmp/ekubectl.tempdetails.$PID
                                        fi
                                        ;;


				statefulset)
					name=`echo $lineerr|cut -d " " -f1`
                                        desired=`echo $lineerr|cut -d " " -f2`
                                        current=`echo $lineerr|cut -d " " -f3`
                                        if [ "$desired" != "$current" ];then
                                                echo $lineerr >>/tmp/ekubectl.tempdetails.$PID
                                        else
                                                touch /tmp/ekubectl.tempdetails.$PID
                                        fi
                                        ;;

				esac
			#		status=`echo $lineerr|cut -d " " -f4` 
			#		if [ "$status" != "Complete" ];then
			#			touch /tmp/ekubectl.tempdetails.$PID
			#		else
			#			echo $lineerr >>/tmp/tempdetails.$PID
			#		fi
                	done </tmp/ekubectl.temp.$PID
                	errorwc=`cat /tmp/ekubectl.tempdetails.$PID|wc -l`
                	if [ $errorwc -ne 0 ];then
				while read detail
				do
					det=`echo $detail`
                			echo "" |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID
                       			echo " $errorwc ERROR TO CORRECT - $label object are in error state - current value is not desired value" |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID
                			echo "" |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID
                        		echo " $errorwc ERROR TO CORRECT (details) - $label object are in error state " | tee -a  /tmp/reportfull.log.$PID
                        	        kubectl describe $label $det >>/tmp/reportfull.log.$PID
                			echo "" |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID
				done </tmp/ekubectl.tempdetails.$PID
                	else
		
                		echo "" |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID
                        	echo " 0 ERROR TO CORRECT for $label objects"|tee -a  /tmp/report.log.$PID
                		echo "" |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID
	
                	fi
		else
                	echo "" |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID
			echo " 0 ERROR TO CORRECT for $label objects"|tee -a  /tmp/report.log.$PID
                	echo "" |tee -a  /tmp/report.log.$PID|tee -a  /tmp/reportfull.log.$PID
        	fi
	fi
	if [ -f /tmp/preparse.$PID ];then
		cat /tmp/preparse.$PID >> /tmp/report.log.$PID
		rm -f /tmp/preparse.$PID >/dev/null
	fi

}
if [[ $arg1 == +([0-9]) ]]; then
	connect
	version
	foldersdatabase
	while read tenant
	do
		kubectl config set-context --current --namespace=$tenant
		tenant=`echo $tenant`
		init
		kubedeploy
		display
		init
		kubestatefullsets
		display
		init
		kubejobs
		display
		init
		kubecronjobs
		display
		init
		kubepods
		display
		init
		kubeservices
		display
		init
		kubeingress
		display
		init
		kubeingressroute
		display
		init
		kubeconfigmaps
		display
		init
		kubesecrets
		display
		init
		kuberc
		display
	done</tmp/proj.ekubectl.$PID
fi
cat /tmp/report.log.$PID >/tmp/report.log
cat /tmp/reportfull.log.$PID >/tmp/reportfull.log
#rm -f /tmp/*.$PID
rm -f /var/tmp/ekubectl_database/*.toanalyse
exit 0


