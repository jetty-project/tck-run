#!groovy

pipeline {
  agent { node { label 'linux' } }
  options {
    buildDiscarder logRotator( numToKeepStr: '50' )
  }
  parameters {
    string( defaultValue: 'jetty-12.0.x', description: 'Jetty branch to build',
            name: 'JETTY_BRANCH' )
    string( defaultValue: 'jdk17', description: 'JDK to build Jetty', name: 'JDKBUILD' )
    string( defaultValue: 'jdk11', description: 'JDK to run TCK (use jdk11)', name: 'JDKTCK' )
    string( defaultValue: "https://download.eclipse.org/jakartaee/servlet/6.0/jakarta-servlet-tck-6.0.0.zip",
            description: 'Url to download TCK ()',
            name: 'TCKURL' )
    string( defaultValue: 'ee10', description: 'EE version (ee8, ee9 ee10)', name: 'EEX' )
    string( defaultValue: 'standard', name: 'TCKBUILD')
    string( defaultValue: 'master', name: 'TCKRUN_BRANCH')
  }
  stages {
    stage("cleanup"){
      steps {
        sh "rm -rf *"
      }
    }
    stage("Checkout TCK Run") {
      steps {
        git url: "https://github.com/jetty-project/tck-run.git", branch: "$TCKRUN_BRANCH"
        stash name: 'ts.jte', includes: 'ts.jte'
        stash name: 'ts.jte.jdk11', includes: 'ts.jte.jdk11'
        stash name: 'realm.ini', includes: 'realm.ini'
        stash name: 'realm.properties', includes: 'realm.properties'
        stash name: 'test-realm.xml', includes: 'test-realm.xml'
        stash name: 'log4j2.xml', includes: 'log4j2.xml'
        stash name: 'http.ini', includes: 'http.ini'
        stash name: 'ssl.ini', includes: 'ssl.ini'
        stash name: 'tck.ini', includes: 'tck.ini'
        stash name: 'tck.xml', includes: 'tck.xml'
        stash name: 'servlet_spec_fragment_web', includes: "servlet_spec_fragment_web/*"
        stash name: 'servlet_spec_errorpage_web', includes: "servlet_spec_errorpage_web/*"
        sh "ls -lrt"
      }
    }

    stage("Checkout Jetty") {
      steps {
        git url: "https://github.com/eclipse/jetty.project.git", branch: "$JETTY_BRANCH"
      }
    }
    stage("Build Jetty") {
      steps {
        container('jetty-build') {
        timeout(time: 30, unit: 'MINUTES') {
          withEnv(["JAVA_HOME=${ tool "$JDKBUILD" }",
                   "PATH+MAVEN=${env.JAVA_HOME}/bin:${tool "maven3"}/bin",
                   "MAVEN_OPTS=-Xms2g -Xmx4g -Djava.awt.headless=true"]) {
            configFileProvider(
                    [configFile(fileId: 'oss-settings.xml', variable: 'GLOBAL_MVN_SETTINGS')]) {
              sh "mvn -Pfast --no-transfer-progress -s $GLOBAL_MVN_SETTINGS -V -B -U -Psnapshot-repositories -pl jetty-home -am clean install -DskipTests -T6 -e"
            }
          }
        }
      }    
      }
    }
    stage("Setup servlet tck"){
      steps {
        container('jetty-build') {
          echo "Starting withEnv()"
          withEnv(["JAVA_HOME=${tool "$JDKBUILD"}", "PATH=${tool "$JDKBUILD"}/bin:${env.PATH}"]) {

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

            echo "Fetching servlettck from ${tckUrl}"
            sh "wget -q -O servlettck.zip ${tckUrl}"

            echo "Unpacking Servlet TCK"
            sh "unzip -q servlettck.zip"

            sh "cd jetty-home/target/ && mkdir jetty-base"
            sh "cd jetty-home/target/jetty-base && mkdir etc && cd .."

            sh "ls -la jetty-home/target/"
            sh "ls -la jetty-home/target/jetty-base"

            echo "Running home to create startd"

            sh "cd jetty-home/target/jetty-base && java -jar ../jetty-home/start.jar --approve-all-licenses --create-startd --add-module=resources,server,http,https,http2c,$EEX-webapp,$EEX-deploy,$EEX-jsp,$EEX-annotations,ssl,logging-log4j2"

            sh "ls -la jetty-home/target/jetty-base"
            sh "ls -la jetty-home/target/jetty-base/start.d"

            echo "Copying war from servlet TCK to webapps"
            sh 'find servlet-tck -name *.war -exec cp {} jetty-home/target/jetty-base/webapps/ \\;'
            // because the issue has been fixed then reverted see https://github.com/eclipse-ee4j/jakartaee-tck/issues/45
            script {
              if (EEX == 'ee8') {
                echo "wrong war name file pwd"
                sh 'pwd'
                sh "ls -lrt ${env.WORKSPACE}/jetty-home/target/jetty-base/webapps/servlet_sec_denyUncovered_web.war"
                //def warFile = new File("${env.WORKSPACE}/jetty-home/target/jetty-base/webapps/servlet_sec_denyUncovered_web.war");
                if (fileExists("${env.WORKSPACE}/jetty-home/target/jetty-base/webapps/servlet_sec_denyUncovered_web.war")) {
                  echo "copy wrong named war servlet_sec_denyUncovered_web.war"
                  sh 'mv jetty-home/target/jetty-base/webapps/servlet_sec_denyUncovered_web.war jetty-home/target/jetty-base/webapps/servlet_sec_denyUncovered.war'
                } else {
                  echo "file not exists: ${env.WORKSPACE}/jetty-home/target/jetty-base/webapps/servlet_sec_denyUncovered_web.war"
                }
              }
            }

            echo "Unstashing ts.jte"
            unstash name: 'ts.jte'
            // replace values in ts.jte
            script {
              def text = readFile "ts.jte"
              text = text.replaceAll("@WORKSPACE@", "${env.WORKSPACE}")
              writeFile file: "servlet-tck/bin/ts.jte", text: text
            }

            script {
              if (EEX != 'ee8') {
                sh "mkdir -p ${env.WORKSPACE}/tmp/jdk-bundles"
                echo "Unstashing 'ts.jte.jdk11'"
                unstash name: 'ts.jte.jdk11'
                // replace values in ts.jte.jdk11
                script {
                  def text = readFile "ts.jte.jdk11"
                  text = text.replaceAll("@WORKSPACE@", "${env.WORKSPACE}")
                  writeFile file: "servlet-tck/bin/ts.jte", text: text
                }
              }
            }

            echo "Unstashing realm.ini"
            unstash name: 'realm.ini'
            sh "cp realm.ini jetty-home/target/jetty-base/start.d/"

            echo "Unstashing realm.properties"
            unstash name: 'realm.properties'
            sh "cp realm.properties jetty-home/target/jetty-base/etc/"

            echo "Unstashing test-realm.xml"
            unstash name: 'test-realm.xml'
            sh "cp test-realm.xml jetty-home/target/jetty-base/etc/"

            // generate certificate/trustore etc...
            withEnv(["JAVA_HOME=${tool "${jdktck}"}", "PATH+ANT=${tool 'ant-latest'}/bin:${env.JAVA_HOME}/bin"]) {
              sh "$JAVA_HOME/bin/keytool -import -noprompt -alias cts -dname \"CN=CTS, OU=Java Software, O=Sun Microsystems Inc., L=Burlington, ST=MA, C=US\" -file servlet-tck/bin/certificates/cts_cert -storetype JKS  -keystore cacerts.jks -storepass changeit -keypass changeit"
              sh "cp cacerts.jks servlet-tck/bin/certificates"
              sh "cp cacerts.jks jetty-home/target/jetty-base/etc/"
              sh "cp servlet-tck/bin/certificates/clientcert.jks jetty-home/target/jetty-base/etc/"
            }

            unstash name: 'log4j2.xml'
            sh "cp log4j2.xml jetty-home/target/jetty-base/resources/"

            unstash name: 'http.ini'
            sh "cp http.ini jetty-home/target/jetty-base/start.d/"

            unstash name: 'ssl.ini'
            sh "cp ssl.ini jetty-home/target/jetty-base/start.d/"

            unstash name: 'servlet_spec_fragment_web'
            sh "cp servlet_spec_fragment_web/webdefault.xml jetty-home/target/jetty-base/etc/"
            sh "cp servlet_spec_fragment_web/servlet_spec_fragment_web.xml jetty-home/target/jetty-base/webapps/"

            unstash name: 'servlet_spec_errorpage_web'
            sh "cp servlet_spec_errorpage_web/servlet_spec_errorpage_web.xml jetty-home/target/jetty-base/webapps/"

            script {
              // download servlet-api
              if (EEX == 'ee8') {
                sh "wget -q -O servlet-api.jar http://10.0.0.15:8081/repository/maven-public/javax/servlet/javax.servlet-api/4.0.1/javax.servlet-api-4.0.1.jar"
                sh "cp servlet-api.jar servlet-tck/lib/servlet-api.jar"
                sh "wget -q -O annotation-api.jar http://10.0.0.15:8081/repository/maven-public/javax/annotation/javax.annotation-api/1.3/javax.annotation-api-1.3.jar"
                sh "cp annotation-api.jar servlet-tck/lib/annotation-api.jar"
              } else if (EEX == 'ee9'){
                sh "wget -q -O servlet-api.jar http://10.0.0.15:8081/repository/maven-public/jakarta/servlet/jakarta.servlet-api/5.0.0/jakarta.servlet-api-5.0.0.jar"
                sh "cp servlet-api.jar servlet-tck/lib/servlet-api.jar"
                sh "wget -q -O annotation-api.jar http://10.0.0.15:8081/repository/maven-public/jakarta/annotation/jakarta.annotation-api/2.0.0/jakarta.annotation-api-2.0.0.jar"
                sh "cp annotation-api.jar servlet-tck/lib/annotation-api.jar"
              } else {
                sh "wget -q -O servlet-api.jar http://10.0.0.15:8081/repository/maven-public/jakarta/servlet/jakarta.servlet-api/6.0.0/jakarta.servlet-api-6.0.0.jar"
                sh "cp servlet-api.jar servlet-tck/lib/servlet-api.jar"
                sh "wget -q -O annotation-api.jar http://10.0.0.15:8081/repository/maven-public/jakarta/annotation/jakarta.annotation-api/2.1.1/jakarta.annotation-api-2.1.1.jar"
                sh "cp annotation-api.jar servlet-tck/lib/annotation-api.jar"                
              }
            }

            echo "Unstashing tck.ini"
            unstash name: 'tck.ini'
            sh "cp tck.ini jetty-home/target/jetty-base/start.d/"

            echo "Unstashing tck.xml"
            unstash name: 'tck.xml'
            sh "cp tck.xml jetty-home/target/jetty-base/etc/"

            sh "ls -la jetty-home/target/jetty-base"

            echo "Running Jetty Instance ..."
            sh "cd jetty-home/target/jetty-base && java -Duser.language=en -Duser.country=US -Djava.locale.providers=COMPAT,CLDR -jar ../jetty-home/start.jar &"
          }
        }
      }
    }
    stage("run servlet tck"){
      steps {
        container('jetty-build') {
        timeout( time: 3, unit: 'HOURS' ) {
          withAnt( installation: 'ant-latest', jdk: "${jdktck}") {
            withEnv(["JAVA_HOME=${ tool "${jdktck}" }", "PATH+ANT=${tool 'ant-latest'}/bin:${env.JAVA_HOME}/bin"]) {
              sh "ls -la jetty-home/target/jetty-base"
              script {
                try {
                  sh "cd servlet-tck/bin && ant run.all"
                }catch(ex){
                  unstable('Script failed!' + ex.getMessage())
                }
              }
            }
          }
        }
        }
      }
      post {
        always {
          tckreporttojunit tckReportTxtPath: "${env.WORKSPACE}/JTReport/text/summary.txt", junitFolderPath: 'surefire-reports'
          junit testResults: '**/surefire-reports/*.xml'
          script{
            currentBuild.description = "Build branch $JETTY_BRANCH with TCKBUILD $TCKBUILD from $TCKURL"
          }
          archiveArtifacts artifacts: "**/surefire-reports/*.xml",allowEmptyArchive: true
          archiveArtifacts artifacts: "JTReport/**",allowEmptyArchive: true
          archiveArtifacts artifacts: "jetty-home/target/jetty-base/logs/*.*",allowEmptyArchive: true
          publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: "${env.WORKSPACE}/JTReport/html", reportFiles: 'report.html', reportName: 'TCK Report', reportTitles: ''])
        }
      }
    }
  }
}


// vim:syntax=groovy expandtab tabstop=2 softtabstop=2 shiftwidth=2
