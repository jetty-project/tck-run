pipeline {
  agent { node { label 'linux' } }
  triggers {
    cron '@daily'
  }
  options {
    buildDiscarder logRotator( numToKeepStr: '50' )
  }
  parameters {
    string( defaultValue: "${env.JENKINS_URL}job/external_oss/job/tck_jakarta_master_build/lastSuccessfulBuild/artifact/standalone-bundles/servlet-tck-4.0.0.zip",
            description: 'Url to download TCK ()',
            name: 'TCKURL' )
    string( defaultValue: "jetty-11.0.x",
            description: 'Jetty 11.0.x branch to build',
            name: 'JETTY_BRANCH' )
  }
  stages {
    stage( 'Tck Run' ) {
      steps {
        script{
          def result
          try {
            def built = build( job: 'servlettck-run',
                           parameters: [string( name: 'JETTY_BRANCH', value: "${JETTY_BRANCH}" ),
                                        string( name: 'JDK', value: 'jdk11' ),
                                        string( name: 'JDKTCK', value: 'jdk9' ),
                                        string( name: 'TCKURL', value: "${TCKURL}" ),
                                        string( name: 'SVLT_NS', value: 'jakarta' )] )
            copyArtifacts(projectName: 'servlettck-run', selector: specific("${built.number}"));
          } finally {

          }
        }
      }
      post {
        always {
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
