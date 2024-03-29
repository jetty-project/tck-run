pipeline {
  agent any
  triggers {
    //cron ('H */12 * * *')
    cron '@daily'
  }
  options {
    buildDiscarder logRotator( numToKeepStr: '50' )
  }
  parameters {
    string( defaultValue: "https://download.eclipse.org/jakartaee/servlet/5.0/jakarta-servlet-tck-5.0.2.zip",
            description: 'Url to download TCK () do not change anything if you are not sure :)',
            name: 'TCK_SVLT_JAKARTA_URL' )
    string( defaultValue: "jetty-11.0.x",
            description: 'Jetty 11.0.x branch to build',
            name: 'JETTY_BRANCH' )
    string( defaultValue: 'jdk11', description: 'JDK to build Jetty', name: 'JDKBUILD' )
    string( defaultValue: 'jdk11', description: 'JDK to run TCK (use jdk11)', name: 'JDKTCK' )
  }
  stages {
    stage( 'Tck Run' ) {
      steps {
        script{
            def built = build( job: 'servlettck-run', propagate: false,
                           parameters: [string( name: 'JETTY_BRANCH', value: "${JETTY_BRANCH}" ),
                                        string( name: 'JDKBUILD', value: "${JDKBUILD}" ),
                                        string( name: 'JDKTCK', value: "${JDKTCK}" ),
                                        string( name: 'TCKURL', value: "${TCK_SVLT_JAKARTA_URL}" ),
                                        string( name: 'SVLT_NS', value: 'jakarta' )] )
            copyArtifacts(projectName: 'servlettck-run', selector: specific("${built.number}"));
        }
        //unarchive mapping: ['**/**' : '.']
      }
      post {
        always {
          tckreporttojunit tckReportTxtPath: "${env.WORKSPACE}/JTReport/text/summary.txt", junitFolderPath: 'surefire-reports'
          junit testResults: '**/surefire-reports/*.xml'
          script{
            currentBuild.description = "Run TCK branch ${JETTY_BRANCH}"
          }
          archiveArtifacts artifacts: "**/surefire-reports/*.xml",allowEmptyArchive: true
          archiveArtifacts artifacts: "JTReport/**",allowEmptyArchive: true
          archiveArtifacts artifacts: "jetty-home/target/jetty-base/logs/*.*",allowEmptyArchive: true
          publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: "${env.WORKSPACE}/JTReport/html", reportFiles: 'report.html', reportName: 'TCK Report', reportTitles: ''])
        }
        failure {
          slackNotif()
        }
        unstable {
          slackNotif()
        }
        fixed {
          slackNotif()
        }
      }
    }
  }
}

def slackNotif() {
  script {
    try
    {
      //BUILD_USER = currentBuild.rawBuild.getCause(Cause.UserIdCause).getUserId()
      // by ${BUILD_USER}
      COLOR_MAP = ['SUCCESS': 'good', 'FAILURE': 'danger', 'UNSTABLE': 'danger', 'ABORTED': 'danger']
      slackSend channel: '#jenkins',
                color: COLOR_MAP[currentBuild.currentResult],
                message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} - ${env.BUILD_URL}"

    } catch (Exception e) {
      e.printStackTrace()
      echo "skip failure slack notification: " + e.getMessage()
    }
  }
}
