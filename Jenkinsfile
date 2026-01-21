// pipeline {
//   agent any

//   parameters {
//     string(name: 'ENV', defaultValue: 'dev', description: 'Environment: dev or prod')
//     string(name: 'GIT_REF', defaultValue: 'main', description: 'Git branch or tag')
//   }

//   environment {
//     DISTDIR = 'dist'
//   }

//   stages {
//     stage('Checkout') {
//       steps {
//         checkout([$class: 'GitSCM',
//           branches: [[name: "*/${params.GIT_REF}"]],
//           userRemoteConfigs: [[url: 'https://github.com/AnithaAnnem/nginx-spinnaker.git']]
//         ])
//       }
//     }

//     stage('Read parameters') {
//       steps {
//         script {
//           def y = readYaml file: "parameter.yaml"

//           def envList = []
//           y.each { k, v -> envList << "${k}=${v}" }

//           def replicas = (params.ENV == 'prod') ? y.REPLICAS_PROD.toString() : y.REPLICAS_DEV.toString()
//           envList << "REPLICAS=${replicas}"

//           env.BUILD_ENV_LIST = envList.join('\n')
//         }
//       }
//     }

//     stage('Render pipeline-vars.yaml') {
//       steps {
//         script {
//           withEnv(env.BUILD_ENV_LIST.readLines()) {
//             def tpl = readFile("pipeline-vars.yaml")
//             def rendered = tpl.replaceAll(/\$\{([A-Za-z0-9_]+)\}/) { all, key ->
//               return env[key] ?: ''
//             }
//             sh "mkdir -p ${env.DISTDIR}"
//             writeFile file: "${env.DISTDIR}/pipeline-vars.rendered.yaml", text: rendered
//           }
//         }
//       }
//     }

//     stage('Replace placeholders in manifests') {
//       steps {
//         script {
//           withEnv(env.BUILD_ENV_LIST.readLines()) {
//             def files = sh(
//               script: "find base overlay -type f \\( -name '*.yaml' -o -name '*.yml' \\)",
//               returnStdout: true
//             ).trim().split('\n')

//             files.each { f ->
//               def content = readFile(f)
//               def replaced = content.replaceAll(/\$\{([A-Za-z0-9_]+)\}/) { all, key ->
//                 return env[key] ?: ''
//               }
//               writeFile file: f, text: replaced
//             }
//           }
//         }
//       }
//     }

//     stage('Bake with kustomize') {
//       steps {
//         sh """
//           mkdir -p ${env.DISTDIR}
//           kustomize build overlay/${params.ENV} > ${env.DISTDIR}/manifests.yaml
//         """
//       }
//     }

//     stage('Publish artifact to Spinnaker') {
//       steps {
//         archiveArtifacts artifacts: "${DISTDIR}/manifests.yaml", fingerprint: true
//       }
//     }

//     stage('Trigger Spinnaker') {
//       steps {
//         script {
//           withEnv(env.BUILD_ENV_LIST.readLines()) {
//             sh """
//               curl -X POST -H 'Content-Type: application/json' \\
//                 -d '{
//                   "env": "${params.ENV}",
//                   "artifactPath": "${env.DISTDIR}/manifests.yaml",
//                   "appName": "${APP_NAME}"
//                 }' \\
//                 https://spinnaker.example.com/webhooks/bake-deploy
//             """
//           }
//         }
//       }
//     }
//   }
// }

pipeline {
  agent any

  parameters {
    string(name: 'ENV', defaultValue: 'dev', description: 'Environment: dev or prod')
    string(name: 'GIT_REF', defaultValue: 'main', description: 'Git branch or tag')
  }

  environment {
    DISTDIR = 'dist'
  }

  stages {

    stage('Checkout') {
      steps {
        checkout([
          $class: 'GitSCM',
          branches: [[name: "*/${params.GIT_REF}"]],
          userRemoteConfigs: [[
            url: 'https://github.com/AnithaAnnem/nginx-spinnaker.git'
          ]]
        ])
      }
    }

    stage('Read parameters') {
      steps {
        script {
          def paramsYaml = readYaml file: 'parameter.yaml'

          // Export all parameters as environment variables
          paramsYaml.each { k, v ->
            env[k.toString()] = v.toString()
          }

          // Environment-specific logic
          if (params.ENV == 'prod') {
            env.REPLICAS = env.REPLICAS_PROD
          } else {
            env.REPLICAS = env.REPLICAS_DEV
          }

          echo "ENV=${params.ENV}"
          echo "APP_NAME=${env.APP_NAME}"
          echo "REPLICAS=${env.REPLICAS}"
        }
      }
    }

    stage('Replace placeholders in manifests') {
      steps {
        script {
          def files = sh(
            script: "find base overlay -type f \\( -name '*.yaml' -o -name '*.yml' \\)",
            returnStdout: true
          ).trim().split('\n')

          files.each { f ->
            def content = readFile(f)

            def replaced = content.replaceAll(/\$\{([A-Za-z0-9_]+)\}/) { all, key ->
              if (!env[key]) {
                error "❌ Missing required variable: ${key} (used in ${f})"
              }
              return env[key]
            }

            writeFile file: f, text: replaced
          }
        }
      }
    }

    stage('Validate placeholders') {
      steps {
        sh '''
          echo "🔍 Validating unresolved placeholders..."
          if grep -R '\${' base overlay; then
            echo "❌ ERROR: Unresolved placeholders found"
            exit 1
          fi
          echo "✅ All placeholders resolved"
        '''
      }
    }

    stage('Bake with kustomize') {
      steps {
        sh '''
          mkdir -p dist
          kustomize build overlay/${ENV} > dist/manifests.yaml
        '''
      }
    }

    stage('Publish artifact to Spinnaker') {
      steps {
        archiveArtifacts artifacts: 'dist/manifests.yaml', fingerprint: true
      }
    }
  }

  post {
    success {
      echo "✅ Pipeline completed successfully"
    }
    failure {
      echo "❌ Pipeline failed"
    }
  }
}




