#!groovy
pipeline {
  agent { node { label 'linux' } }
  options {
    buildDiscarder logRotator( numToKeepStr: '50' )
  }
  parameters {
    string( defaultValue: 'jetty-10.0.x', description: 'Jetty branch to build',
            name: 'JETTY_BRANCH' )
    string( defaultValue: 'jdk11', description: 'JDK to build Jetty', name: 'JDK' )
    string( defaultValue: 'jdk11', description: 'JDK to run TCK (use jdk11)', name: 'JDKTCK' )
    string( defaultValue: "${env.JENKINS_URL}userContent/tcks/pages-tck-javax.zip",
            description: 'Url to download TCK ()',
            name: 'TCK_WS_URL' )
    string( defaultValue: 'javax', description: 'Servlet Namespace (javax or jakarta)', name: 'SVLT_NS' )
    string( defaultValue: 'standard', name: 'TCKBUILD')
  }
  stages {
    stage( "cleanup" ) {
      steps {
        sh "rm -rf *"
      }
    }
    stage( "Checkout TCK Run" ) {
      steps {
        git url: "https://github.com/jetty-project/tck-run.git", branch: "master"
        stash name: 'jspts.jte', includes: 'jspts.jte'
        stash name: 'log4j2.xml', includes: 'log4j2.xml'
      }
    }
    stage( "Checkout Jetty" ) {
      steps {
        git url: "https://github.com/eclipse/jetty.project.git", branch: "$JETTY_BRANCH"
      }
    }
    stage( "Build Jetty" ) {
      steps {
        timeout( time: 30, unit: 'MINUTES' ) {
          withMaven( maven: 'maven3',
                     jdk: "$jdk",
                     publisherStrategy: 'EXPLICIT',
                     globalMavenSettingsConfig: 'oss-settings.xml',
                     mavenOpts: '-Xms1g -Xmx4g',
                     mavenLocalRepo: ".repository" ) {
            script{
              pom = readMavenPom file: 'pom.xml'
              jettyVersion = pom.version
            }
            sh "mvn -V -B -pl jetty-home -am clean install -DskipTests -T6 -e"
          }
        }
      }
    }
    stage( "Setup websocket tck" ) {
      steps {
        withEnv(["JAVA_HOME=${ tool "$jdk" }", "PATH=${ tool "$jdk" }/bin:${env.PATH}"]) {
          //env.JAVA_HOME = "${tool "$jdk"}"
          //env.PATH = "${env.JAVA_HOME}/bin:${env.PATH}"
          echo "JAVA_HOME=${env.JAVA_HOME}"
          echo "PATH=${env.PATH}"

          sh "ls -la ${env.JAVA_HOME}"

          // Execute some simple lookups of required command line applications
          // If the application isn't found, then it fails the build
          sh "which curl"
          sh "which wget"
          sh "which unzip"
          sh "which find"
          sh "which java"

          echo "Fetching jsptck from ${TCK_WS_URL}"
          sh "wget -O pages-tck.zip ${TCK_WS_URL}"

          sh "unzip pages-tck.zip"
          sh "mv pages-tck pagestck"
          sh "ls -lrt"
          sh "cd jetty-home/target/ && mkdir jetty-base"
          script{
            if(SVLT_NS=='javax'){
              sh "cd jetty-home/target/jetty-base && java -jar ../jetty-home/start.jar --approve-all-licenses --create-startd --add-to-start=resources,server,http,webapp,deploy,annotations,jsp,logging-log4j2"
            } else {
              sh "cd jetty-home/target/jetty-base && java -jar ../jetty-home/start.jar --approve-all-licenses --create-startd --add-to-start=resources,server,http,webapp,deploy,annotations,jsp,logging-log4j2"
            }
          }
          sh 'find pagestck -name *.war -exec cp {} jetty-home/target/jetty-base/webapps/ \\;'

          unstash name: 'jspts.jte'
          // replace values in ts.jte
          script {
            def text = readFile "jspts.jte"
            text = text.replaceAll( "@WORKSPACE@", "${env.WORKSPACE}" )
            text = text.replaceAll( "@JETTY_VERSION@", jettyVersion )
            writeFile file: "pagestck/bin/ts.jte", text: text
          }

          sh "ls -lrt jetty-home/target/jetty-home/"

          sh "cat pagestck/bin/ts.jte"

          unstash name: 'log4j2.xml'
          sh "cp log4j2.xml jetty-home/target/jetty-base/resources/"

          //sh "wget -O realm.ini https://raw.githubusercontent.com/jetty-project/tck-run/master/realm.ini"
          //sh "cp realm.ini jetty-distribution/target/jetty-base/start.d"

          //sh "wget -O realm.properties https://github.com/jetty-project/tck-run/raw/master/realm.properties"
          //sh "cp realm.properties jetty-distribution/target/jetty-base/etc"

          //sh "wget -O test-realm.xml https://github.com/jetty-project/tck-run/raw/master/test-realm.xml"
          //sh "cp test-realm.xml jetty-distribution/target/jetty-base/etc"

          //sh "wget -O cacerts.jks https://github.com/jetty-project/tck-run/raw/master/cacerts.jks"
          //sh "cp cacerts.jks servlettck/bin/certificates"
          //sh "cp cacerts.jks jetty-distribution/target/jetty-base/etc"

          //sh "wget -O clientcert.jks https://github.com/jetty-project/tck-run/raw/master/clientcert.jks"
          //sh "cp clientcert.jks servlettck/bin/certificates"
          //sh "cp clientcert.jks jetty-distribution/target/jetty-base/etc"

          script{
            // download servlet-api
            if(SVLT_NS=='javax'){
              sh "wget -q -O servlet-api.jar https://repo.maven.apache.org/maven2/javax/servlet/javax.servlet-api/4.0.1/javax.servlet-api-4.0.1.jar"
              sh "cp servlet-api.jar pagestck/lib/servlet-api.jar"
              sh "wget -q -O jsp-api.jar https://repo.maven.apache.org/maven2/jakarta/servlet/jsp/jakarta.servlet.jsp-api/2.3.4/jakarta.servlet.jsp-api-2.3.4.jar"
              sh "cp jsp-api.jar pagestck/lib/jsp-api.jar"
              sh "wget -q -O el-api.jar https://repo.maven.apache.org/maven2/jakarta/el/jakarta.el-api/3.0.3/jakarta.el-api-3.0.3.jar"
              sh "cp el-api.jar pagestck/lib/el-api.jar"
            } else {
              sh "wget -q -O servlet-api.jar https://repo.maven.apache.org/maven2/jakarta/servlet/jakarta.servlet-api/5.0.0-M1/jakarta.servlet-api-5.0.0-M1.jar"
              sh "cp servlet-api.jar pagestck/lib/servlet-api.jar"
              sh "wget -q -O jsp-api.jar https://repo.maven.apache.org/maven2/jakarta/servlet/jsp/jakarta.servlet.jsp-api/3.0.0-M1/jakarta.servlet.jsp-api-3.0.0-M1.jar"
              sh "cp jsp-api.jar pagestck/lib/jsp-api.jar"
              sh "wget -q -O el-api.jar https://repo.maven.apache.org/maven2/jakarta/el/jakarta.el-api/4.0.0.M1/jakarta.el-api-4.0.0.M1.jar"
              sh "cp el-api.jar pagestck/lib/el-api.jar"
            }
          }

          //sh "cd jetty-distribution/target/jetty-base && java -Duser.language=en -Duser.country=US -Djavax.net.ssl.trustStore=etc/cacerts.jks -Djavax.net.ssl.keyStore=etc/clientcert.jks -Djavax.net.ssl.keyStorePassword=changeit -jar ../distribution/start.jar jetty.sslContext.trustStorePath=etc/cacerts.jks &"
          sh "cd jetty-home/target/jetty-base && java -Duser.language=en -Duser.country=US -jar ../jetty-home/start.jar  &"
        }
      }
    }
    stage( "run websocket tck" ) {
      steps {
        timeout( time: 3, unit: 'HOURS' ) {
          withAnt( installation: 'ant-latest', jdk: "$jdk" ) {
            withEnv(["JAVA_HOME=${ tool "${jdktck}" }", "PATH+ANT=${tool 'ant-latest'}/bin:${env.JAVA_HOME}/bin"]) {
              script {
                try {
                  sh "cd pagestck/bin && ant run.all"
                }catch(ex){
                  unstable('Script failed!' + ex.getMessage())
                }
              }
            }
          }
        }
      }
      post {
        always {
          tckreporttojunit tckReportTxtPath: "${env.WORKSPACE}/JTReport/text/summary.txt",
                           junitFolderPath: 'surefire-reports'
          junit testResults: '**/surefire-reports/*.xml'
          script{
            currentBuild.description = "Build branch $JETTY_BRANCH with TCKBUILD $TCKBUILD from $TCK_WS_URL"
          }
          archiveArtifacts artifacts: "**/surefire-reports/*.xml",allowEmptyArchive: true
          archiveArtifacts artifacts: "JTReport/**", allowEmptyArchive: true
          archiveArtifacts artifacts: "jetty-home/target/jetty-base/logs/*.*", allowEmptyArchive: true
          publishHTML( [allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: "${env.WORKSPACE}/JTReport/html", reportFiles: 'report.html', reportName: 'TCK Report', reportTitles: ''] )
        }
      }
    }
  }
}

// vim:syntax=groovy expandtab tabstop=2 softtabstop=2 shiftwidth=2
