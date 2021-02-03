pipeline {
  agent { node { label 'linux' } }
  triggers {
    cron '@hourly'
  }
  options {
    buildDiscarder logRotator( numToKeepStr: '50' )
  }
  parameters {
    string( defaultValue: "https://download.eclipse.org/ee4j/jakartaee-tck/jakartaee9/promoted/servlet-tck-5.0.1.zip",
            description: 'Url to download TCK () do not change anything if you are not sure :)',
            name: 'TCK_SVLT_JAKARTA_URL' )
    string( defaultValue: "jetty-11.0.x",
            description: 'Jetty 11.0.x branch to build',
            name: 'JETTY_BRANCH' )
    string( defaultValue: 'jdk11', description: 'JDK to build Jetty', name: 'JDKBUILD' )
    string( defaultValue: 'jdk9', description: 'JDK to run TCK (use jdk9)', name: 'JDKTCK' )
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
      }
    }
  }
}
