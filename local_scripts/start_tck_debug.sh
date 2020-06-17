source config.sh

cd $jetty_base
$JAVA_HOME/bin/java -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8000 -Duser.language=en -Duser.country=US -jar $jetty_home/start.jar
# $JAVA_HOME/bin/java -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8000 -Duser.language=en -Duser.country=US -Djavax.net.ssl.trustStore=etc/cacerts.jks -Djavax.net.ssl.keyStore=etc/clientcert.jks -Djavax.net.ssl.keyStorePassword=changeit -Dorg.eclipse.jetty.ssl.password=changeit -jar $jetty_home/start.jar jetty.sslContext.trustStorePath=etc/cacerts.jks jetty.sslContext.keyStorePassword=changeit org.eclipse.jetty.ssl.password=changeit
