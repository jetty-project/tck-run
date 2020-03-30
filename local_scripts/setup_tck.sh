# target/base/webapps/
set -x
cd /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target
rm -rf jetty-base
mkdir jetty-base
cd jetty-base
mkdir etc
#cd etc
#touch keystore
#cd ../
#/Library/Java/JavaVirtualMachines/jdk-11.0.2.jdk/Contents/Home/bin/java -jar ../jetty-home/start.jar --approve-all-licenses --create-startd --add-to-start=resources,server,http,https,http2c,webapp,deploy,jsp,logging-log4j2,annotations
/Library/Java/JavaVirtualMachines/jdk-11.0.2.jdk/Contents/Home/bin/java -jar ../jetty-home/start.jar --approve-all-licenses --create-startd --add-to-start=resources,server,http,http2c,webapp,deploy,jsp,annotations
cd /Users/olamy/dev/sources/open-sources/jetty/tck_tests/servlet-tck
find . -name "*.war" -exec cp {} /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base/webapps \;
cd /Users/olamy/dev/sources/open-sources/jetty/tck-run
cp realm.ini /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base/start.d/
cp realm.properties /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base/etc/
cp test-realm.xml /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base/etc/
cp clientcert.jks /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base/etc/
cp cacerts.jks /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base/etc/
cp cacerts.jks /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base/etc/keystore
cp log4j2.xml  /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base/resources
cp http.ini /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base/start.d/

cd /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base
/Library/Java/JavaVirtualMachines/jdk-11.0.2.jdk/Contents/Home/bin/java -Duser.language=en -Duser.country=US -jar ../jetty-home/start.jar 
#/Library/Java/JavaVirtualMachines/jdk-11.0.2.jdk/Contents/Home/bin/java    -Duser.language=en -Duser.country=US -Djavax.net.ssl.trustStore=etc/cacerts.jks -Djavax.net.ssl.keyStore=etc/clientcert.jks -Djavax.net.ssl.keyStorePassword=changeit -Dorg.eclipse.jetty.ssl.password=changeit -jar ../jetty-home/start.jar jetty.sslContext.trustStorePath=etc/cacerts.jks jetty.sslContext.keyStorePassword=changeit org.eclipse.jetty.ssl.password=changeit
