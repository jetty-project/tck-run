source config.sh

cd $jetty_base
$JAVA_HOME/bin/java -Duser.language=en -Duser.country=US -jar $jetty_home/start.jar
# $JAVA_HOME/bin/java -Duser.language=en -Duser.country=US -Djavax.net.ssl.trustStore=etc/cacerts.jks -Djavax.net.ssl.keyStore=etc/clientcert.jks -Djavax.net.ssl.keyStorePassword=changeit -jar $jetty_home/start.jar jetty.sslContext.trustStorePath=etc/cacerts.jks jetty.sslContext.keyStorePassword=changeit
