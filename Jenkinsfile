pipeline {
    agent any

    environment {
        IMAGE     = 'maison-arabica'
        TAG       = "${env.BUILD_NUMBER}"
        HOST_PORT = '8085'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        timestamps()
        timeout(time: 15, unit: 'MINUTES')
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Build image') {
            steps {
                sh "docker build --pull -t ${IMAGE}:${TAG} -t ${IMAGE}:latest ."
            }
        }

        stage('Test container') {
            steps {
                sh """
                    docker run -d --rm --name arabica-test -p 18080:8080 ${IMAGE}:${TAG}
                    for i in \$(seq 1 15); do
                      if curl -fsS http://localhost:18080/ | grep -q 'Maison Arabica'; then
                        echo "OK"; exit 0
                      fi
                      sleep 1
                    done
                    echo "Test échoué"; exit 1
                """
            }
            post {
                always { sh 'docker stop arabica-test || true' }
            }
        }

        stage('Deploy local :8085') {
            steps {
                sh """
                    docker stop arabica || true
                    docker rm   arabica || true
                    docker run -d \
                      --name arabica \
                      --restart unless-stopped \
                      -p ${HOST_PORT}:8080 \
                      ${IMAGE}:${TAG}
                """
            }
        }

        stage('Smoke test') {
            steps {
                sh """
                    for i in \$(seq 1 15); do
                      if curl -fsS http://localhost:${HOST_PORT}/ | grep -q 'Maison Arabica'; then
                        echo "Site en ligne sur http://localhost:${HOST_PORT}"; exit 0
                      fi
                      sleep 1
                    done
                    echo "Smoke test échoué"; exit 1
                """
            }
        }
    }

    post {
        success { echo "✅ Déployé sur http://<ip-vm>:${HOST_PORT} (build ${TAG})" }
        failure { echo "❌ Pipeline en échec — l'ancien conteneur est conservé si possible" }
        always  {
            sh '''
                docker image prune -f || true
                docker builder prune -f --filter "until=24h" || true
            '''
        }
    }
}
