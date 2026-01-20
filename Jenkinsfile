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
          userRemoteConfigs: [[url: 'git@your-repo:nginx-spinnaker.git']]
        ])
      }
    }

    stage('Read parameters') {
      steps {
        script {
          def paramsYaml = readFile("${env.WORKDIR}/parameter.yaml")
          // Parse YAML to map
          def y = new org.yaml.snakeyaml.Yaml().load(paramsYaml)

          // Export as env vars
          y.each { k, v -> env[k] = v.toString() }

          // Derive REPLICAS based on ENV
          env.REPLICAS = (params.ENV == 'prod') ? env.REPLICAS_PROD : env.REPLICAS_DEV
        }
      }
    }

    stage('Render pipeline-vars.yaml') {
      steps {
        script {
          def tpl = readFile("${env.WORKDIR}/pipeline-vars.yaml")
          // Simple token replacement: ${KEY} -> env[KEY]
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
          // Replace placeholders in base and overlay files
          def files = sh(script: "find ${env.WORKDIR} -type f -name '*.yaml' -o -name '*.yml'", returnStdout: true).trim().split('\n')
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
          cd ${WORKDIR}/overlay/${ENV}
          kustomize build . > ../../${DISTDIR}/manifests.yaml
        """
      }
    }

    stage('Publish artifact to Spinnaker') {
      steps {
        // Example: archive or push to artifact store Spinnaker can read
        archiveArtifacts artifacts: "${DISTDIR}/manifests.yaml", fingerprint: true
      }
    }

    stage('Trigger Spinnaker') {
      steps {
        // Use your Spinnaker/Jenkins integration (e.g., spinnaker stage or webhook)
        // Option A: Jenkins Spinnaker plugin
        // Option B: curl webhook to Spinnaker with artifact reference
        sh """
          curl -X POST -H 'Content-Type: application/json' \\
            -d '{
              "env": "${params.ENV}",
              "artifactPath": "${env.WORKDIR}/${env.DISTDIR}/manifests.yaml",
              "appName": "${env.APP_NAME}"
            }' \\
            https://spinnaker.example.com/webhooks/bake-deploy
        """
      }
    }
  }
}
