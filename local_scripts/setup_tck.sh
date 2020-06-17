source config.sh

# target/base/webapps/
set -x
mkdir -p $jetty_base
rm -rf $jetty_base/*
cd $jetty_base
mkdir etc
#cd etc
#touch keystore
#cd ../
#$JAVA_HOME/bin/java -jar $jetty-home/start.jar --approve-all-licenses --create-startd --add-to-start=resources,server,http,https,http2c,webapp,deploy,jsp,logging-log4j2,annotations
$JAVA_HOME/bin/java -jar $jetty_home/start.jar --approve-all-licenses --create-startd --add-to-start=resources,server,http,http2c,webapp,deploy,jsp,annotations
cd $servlet_tck
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
#$JAVA_HOME/bin/java -Duser.language=en -Duser.country=US -Djavax.net.ssl.trustStore=etc/cacerts.jks -Djavax.net.ssl.keyStore=etc/clientcert.jks -Djavax.net.ssl.keyStorePassword=changeit -Dorg.eclipse.jetty.ssl.password=changeit -jar $jetty-home/start.jar jetty.sslContext.trustStorePath=etc/cacerts.jks jetty.sslContext.keyStorePassword=changeit org.eclipse.jetty.ssl.password=changeit
