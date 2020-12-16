pipeline {
  agent { node { label 'linux' } }
  triggers {
    cron '@daily'
  }
  options {
    buildDiscarder logRotator( numToKeepStr: '50' )
  }
  parameters {
    string( defaultValue: "https://download.eclipse.org/jakartaee/servlet/4.0/jakarta-servlet-tck-4.0.0.zip",
            description: 'Url to download TCK () do not change anything if you are not sure :)',
            name: 'TCKURL' )
    string( defaultValue: "jetty-10.0.x",
            description: 'Jetty 10.0.x branch to build',
            name: 'JETTY_BRANCH' )
    string( defaultValue: 'jdk11', description: 'JDK to build Jetty', name: 'JDK' )
    string( defaultValue: 'jdk9', description: 'JDK to run TCK (use jdk9)', name: 'JDKTCK' )
  }
  stages {
    stage( 'Tck Run' ) {
      steps {
        script{
            def built = build( job: 'servlettck-run', propagate: false,
                           parameters: [string( name: 'JETTY_BRANCH', value: "${JETTY_BRANCH}" ),
                                        string( name: 'JDK', value: "${JDK}" ),
                                        string( name: 'JDKTCK', value: "${JDKTCK}" ),
                                        string( name: 'TCKURL', value: "${TCKURL}" ),
                                        string( name: 'SVLT_NS', value: 'javax' )] )
            copyArtifacts(projectName: 'servlettck-run', selector: specific("${built.number}"));
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
