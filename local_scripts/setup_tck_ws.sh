source config.sh

set -x
mkdir -p $jetty_base
rm -rf $jetty_base/*
cd $jetty_base
mkdir etc
java -jar $jetty_home/start.jar --approve-all-licenses --create-startd --add-to-start=resources,server,http,https,test-keystore,http2c,webapp,deploy,jsp,websocket,logging-log4j2,
cd $ws_tck
find . -name "*.war" -exec cp {} $jetty_base/webapps \;
cd $tck_run
cp realm.ini $jetty_base/start.d/
cp realm.properties $jetty_base/etc/
cp test-realm.xml $jetty_base/etc/
cp clientcert.jks $jetty_base/etc/
cp cacerts.jks $jetty_base/etc/
cp cacerts.jks $jetty_base/etc/keystore
cp log4j2.xml  $jetty_base/resources
cp http.ini $jetty_base/start.d/

cd $jetty_base
$JAVA_HOME/bin/java -Duser.language=en -Duser.country=US -jar $jetty_home/start.jar
