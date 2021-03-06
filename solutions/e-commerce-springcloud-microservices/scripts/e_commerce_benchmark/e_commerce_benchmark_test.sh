#!/bin/bash

#
# Warning : Please make sure Jmeter client and Jmeter-server belong to the same subnetwork !
#

echo "Download json.jar for Jmeter ..."
if [ ! -f "/opt/jmeter/lib/java-json.jar" ] ; then
   wget -O /tmp/java-json.jar.zip http://www.java2s.com/Code/JarDownload/java-json/java-json.jar.zip
   unzip -d /opt/jmeter/lib/ /tmp/java-json.jar.zip 
fi

if [ -z "${1}" ] ; then
    echo "Usage: <e-commerce server ip> <e-commerce server port> <number_of_user> <time_in_sec> <order_create_percent> <cart_percent> <search_percent> <order_del_percent> <query_file> <remote_agent_hosts> <result_save_dir>"
    exit 0
fi

echo "                                  ********                                                      "
echo "Please make sure LOCAL_HOST and REMOTE_HOST have been set properly during distributed test!"
echo "                                  ********                                                      "

#Jmeter client which triggers Jmeter servers to start tests and manage test results. 
LOCAL_HOST="192.168.12.11"
echo "Use local IP address :${LOCAL_HOST}"

if [ -z "$(ps -aux | grep jmeter-server |  grep ${LOCAL_HOST} | grep -v grep)" ] ; then
    echo "Please execute /opt/jmeter/bin/jmeter-server -Djava.rmi.server.hostname=${LOCAL_HOST} on all remote jmeter servers firstly"
    exit 0
fi

#########################################################################################
# Please make sure jmeter-server have been started in all remote_hosts !
#
# /opt/jmeter/bin/jmeter-server -Djava.rmi.server.hostname=${LOCAL_HOST} &
# 
#Jmeter server (or agents) which perform real test works
#########################################################################################
REMOTE_HOST=${10:-"192.168.12.11"}

if [ -z "$(which jmeter 2>/dev/null)" ] ; then
    JMETER="/opt/jmeter/bin/jmeter"
else 
    JMETER="jmeter"
fi

CUR_DIR="$(cd `dirname $0`; pwd)"
BENCHMARK_JMX="${CUR_DIR}/e_commerce_restapi_benchmark.jmx"

HOST=${1:-"192.168.12.100"}
PORT=${2:-9000}
USER_NUM=${3:-1000}
DUR_TIME_INSEC=${4:-240}

ORDER_CREATE_GET_PERCENT=${5:-30}
CART_PERCENT=${6:-30}
SEARCH_PERCENT=${7:-30}
ORDER_DEL_PERCENT=${8:-10}

QUERY_FILE=${9:-"/home/estuaryapp/solr_benchmark/solr_query"}

#By default, the solr ansible scripts will install solr_query file under /home/estuaryapp/solr_benchmark directory
#Please also make sure this file exists on all remote_hosts servers.

CUR_DIR="$(cd `dirname $0`; pwd)"
if [ -f "${CUR_DIR}/e_commerce_benchmark_result.jtl" ] ; then
    echo "Delete old test logs ..."
    rm ${CUR_DIR}/e_commerce_benchmark_result.jtl
    rm ${CUR_DIR}/jmeter.log
fi

if [ -d ${CUR_DIR}/e_commerce_benchmark_report ] ; then
    rm -fr ${CUR_DIR}/e_commerce_benchmark_report 
fi

#Increase JMeter Heap Size to 8g
sed -i 's/HEAP\=\"\-Xms512m\ \-Xmx512m\"/HEAP\=\"\-Xms8g\ \-Xmx8g\"/g' /opt/jmeter/bin/jmeter

echo "Perform New E-commerce Test(LOCAL_HOST:${LOCAL_HOST}, REMOTE_HOST:${REMOTE_HOST}, Target Server:${HOST}, Target Port:${PORT}, NumberofUser:${USER_NUM}, TestTimeInSecs:${DUR_TIME_INSEC}, QUERY_FILE:${QUERY_FILE}"
taskset -c 2-60 ${JMETER} -n -t ${BENCHMARK_JMX} -Djava.rmi.server.hostname=${LOCAL_HOST} -Ghost=${HOST} -Gport=${PORT} -Gquery_filename="${QUERY_FILE}" -Gusers ${USER_NUM} -Gduration_in_secs ${DUR_TIME_INSEC} -Gsearch_percent ${SEARCH_PERCENT} -Gcart_percent ${CART_PERCENT} -Gorder_del_percent ${ORDER_DEL_PERCENT} -Gorder_create_get_percent ${ORDER_CREATE_GET_PERCENT} -l ${CUR_DIR}/e_commerce_benchmark_result.jtl -o ${CUR_DIR}/e_commerce_benchmark_report -e -R"${REMOTE_HOST}"

OUT_DIR="${11:-/estuarytest/e_commerce_testresults/}"
OUT_FILE="e_commerce_benchmark_report_${USER_NUM}users"

if [ ! -d ${OUT_DIR} ] ; then
    mkdir -p ${OUT_DIR}
else 
    rm -fr ${OUT_DIR}/${OUT_FILE}
fi

if [ -d ${CUR_DIR}/e_commerce_benchmark_report ] ; then
    mv ${CUR_DIR}/e_commerce_benchmark_report ${OUT_DIR}/${OUT_FILE}
    echo "Please check test report under ${OUT_DIR}/${OUT_FILE}"
fi
