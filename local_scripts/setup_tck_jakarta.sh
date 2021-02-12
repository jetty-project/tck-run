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
/Library/Java/JavaVirtualMachines/jdk-11.0.2.jdk/Contents/Home/bin/java -jar ../jetty-home/start.jar --approve-all-licenses --create-startd --add-module=resources,server,http,https,http2c,webapp,deploy,jsp,annotations,ssl,logging-log4j2
cd /Users/olamy/dev/sources/open-sources/jetty/tck_tests/jakarta_tck/servlet-tck
find . -name "*.war" -exec cp {} /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base/webapps \;
cd /Users/olamy/dev/sources/open-sources/jetty/tck-run
cp realm.ini /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base/start.d/
cp realm.properties /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base/etc/
cp test-realm.xml /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base/etc/
cp clientcert.jks /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base/etc/
cp cacerts.jks /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base/etc/
cp log4j2.xml  /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base/resources
cp http.ini /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base/start.d/
cp ssl.ini /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base/start.d/
cp tck.ini /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base/start.d/
cp tck.xml /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base/etc/
cp servlet_spec_fragment_web/webdefault.xml /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base/etc/
cp servlet_spec_fragment_web/servlet_spec_fragment_web.xml /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base/webapps/
cp servlet_spec_errorpage_web/servlet_spec_errorpage_web.xml /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base/webapps/

cd /Users/olamy/dev/sources/open-sources/jetty/jetty.project/jetty-home/target/jetty-base
/Library/Java/JavaVirtualMachines/jdk-11.0.2.jdk/Contents/Home/bin/java -Djava.locale.providers=COMPAT,CLDR -Duser.language=en -Duser.country=US -jar ../jetty-home/start.jar 
