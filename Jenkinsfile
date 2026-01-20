pipeline {
  agent any

  parameters {
    string(name: 'ENV', defaultValue: 'dev', description: 'Environment: dev or prod')
    string(name: 'GIT_REF', defaultValue: 'main', description: 'Git branch or tag')
  }

  environment {
    WORKDIR = 'nginx-spinnaker'
    DISTDIR = 'dist'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout([$class: 'GitSCM',
          branches: [[name: "*/${params.GIT_REF}"]],
          userRemoteConfigs: [[url: 'https://github.com/AnithaAnnem/nginx-spinnaker.git']]
        ])
      }
    }

    stage('Read parameters') {
      steps {
        script {
          // Use Jenkins Pipeline Utility Steps plugin
          def y = readYaml file: "${env.WORKDIR}/parameter.yaml"

          // Export as env vars
          y.each { k, v -> env[k] = v.toString() }

          // Derive REPLICAS based on ENV
          env.REPLICAS = (params.ENV == 'prod') ? env.REPLICAS_PROD.toString() : env.REPLICAS_DEV.toString()
        }
      }
    }

    stage('Render pipeline-vars.yaml') {
      steps {
        script {
          def tpl = readFile("${env.WORKDIR}/pipeline-vars.yaml")
          def rendered = tpl.replaceAll(/\$\{([A-Z0-9_]+)\}/) { all, key ->
            return env[key] ?: ''
          }
          sh "mkdir -p ${env.DISTDIR}"
          writeFile file: "${env.DISTDIR}/pipeline-vars.rendered.yaml", text: rendered
        }
      }
    }

    stage('Replace placeholders in manifests') {
      steps {
        script {
          // Work on a copy instead of overwriting source
          sh "cp -r ${env.WORKDIR} ${env.DISTDIR}/workdir"
          def files = sh(script: "find ${env.DISTDIR}/workdir -type f -name '*.yaml' -o -name '*.yml'", returnStdout: true).trim().split('\n')
          files.each { f ->
            def content = readFile(f)
            def replaced = content.replaceAll(/\$\{([A-Z0-9_]+)\}/) { all, key ->
              return env[key] ?: ''
            }
            writeFile file: f, text: replaced
          }
        }
      }
    }

    stage('Bake with kustomize') {
      steps {
        sh """
          cd ${DISTDIR}/workdir/overlay/${ENV}
          kustomize build . > ../../manifests.yaml
        """
      }
    }

    stage('Publish artifact to Spinnaker') {
      steps {
        archiveArtifacts artifacts: "${DISTDIR}/manifests.yaml", fingerprint: true
      }
    }

    stage('Trigger Spinnaker') {
      steps {
        sh """
          curl -X POST -H 'Content-Type: application/json' \\
            -d '{
              "env": "${params.ENV}",
              "artifactPath": "${env.DISTDIR}/manifests.yaml",
              "appName": "${env.APP_NAME}"
            }' \\
            https://spinnaker.example.com/webhooks/bake-deploy
        """
      }
    }
  }
}
