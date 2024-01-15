pipeline {
  agent any
  triggers {
    cron '@daily'
  }
  options {
    buildDiscarder logRotator( numToKeepStr: '50' )
  }
  parameters {
    string( defaultValue: "https://download.eclipse.org/jakartaee/websocket/1.1/jakarta-websocket-tck-1.1.1.zip",
            description: 'Url to download TCK () do not change anything if you are not sure :)',
            name: 'TCK_WS_URL' )
    string( defaultValue: "jetty-10.0.x",
            description: 'Jetty 10.0.x branch to build',
            name: 'JETTY_BRANCH' )
  }
  stages {
    stage( 'Tck Run' ) {
      steps {
        script{
            def built = build( job: 'websockettck-run', propagate: false,
                           parameters: [string( name: 'JETTY_BRANCH', value: "${JETTY_BRANCH}" ),
                                        string( name: 'JDK', value: 'jdk11' ),
                                        string( name: 'JDKTCK', value: 'jdk11' ),
                                        string( name: 'TCK_WS_URL', value: "${TCK_WS_URL}" ),
                                        string( name: 'SVLT_NS', value: 'javax' )] )
            copyArtifacts(projectName: 'websockettck-run', selector: specific("${built.number}"));
        }
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
      }
    }
  }
}
