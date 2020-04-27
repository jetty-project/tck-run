pipeline {
  agent none
  triggers {
    cron '@daily'
  }
  options {
    buildDiscarder logRotator( numToKeepStr: '4' )
    disableConcurrentBuilds()
  }
  parameters {
    string( defaultValue: "${env.JENKINS_URL}userContent/tcks/servlettck-4.0_latest.zip",
            description: 'Url to download TCK ()',
            name: 'TCKURL' )
    string( defaultValue: "jetty-10.0.x",
            description: 'Jetty 10.0.x branch to build',
            name: 'JETTY_BRANCH' )
  }
  stages {
    stage( 'Tck Run' ) {
      steps {
        script{
          result = build job: 'servlettck-run',
                         parameters: [string(name: 'JETTY_BRANCH', value: "${JETTY_BRANCH}" ),
                                      string(name: 'JDK', value: 'jdk11'),
                                      string(name: 'JDKTCK', value: 'jdk9'),
                                      string(name: 'TCKURL', value: "${TCKURL}"),
                                      string(name: 'SVLT_NS', value: 'javax')
                         ]
          echo "result $result"
        }
      }
    }
  }
}
