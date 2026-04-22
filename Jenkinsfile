pipeline {
    agent any

    environment {
        SONAR_URL   = "http://98.94.2.115:9000"
        IMAGE_NAME  = "foodapi"
        TF_DIR      = "${WORKSPACE}/terraform"
        SONAR_KEY   = "assignment7"
        GIT_REPO    = "https://github.com/vnak-3/assignment7.git"
        GIT_BRANCH  = "main"
    }

    stages {

        stage('Clone') {
            steps {
                git url: "${GIT_REPO}", branch: "${GIT_BRANCH}"
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    script {
                        def scannerHome = tool 'sonarqube-scanner'
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=${SONAR_KEY} \
                            -Dsonar.sources=./FoodAPI \
                            -Dsonar.host.url=${SONAR_URL}
                        """
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME} ./FoodAPI/"
            }
        }

        stage('Trivy Scan') {
            steps {
                sh "trivy image --exit-code 0 --severity HIGH,CRITICAL ${IMAGE_NAME}"
            }
        }

        stage('Terraform Provision') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    sh """
                        cd ${TF_DIR}
                        terraform init
                        terraform plan -out=tfplan
                        terraform apply -auto-approve tfplan
                        terraform output -raw app_public_ip > /tmp/app_ip.txt
                        echo "App EC2 IP: \$(cat /tmp/app_ip.txt)"
                    """
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    def appIp = sh(script: "cat /tmp/app_ip.txt", returnStdout: true).trim()

                    sh "docker save ${IMAGE_NAME} -o /tmp/${IMAGE_NAME}.tar"
                    sh "sleep 40"

                    sshagent(['app-ec2-ssh']) {
                        sh """
                            scp -o StrictHostKeyChecking=no /tmp/${IMAGE_NAME}.tar ubuntu@${appIp}:/home/ubuntu/
                            ssh -o StrictHostKeyChecking=no ubuntu@${appIp} '
                                docker load -i /home/ubuntu/${IMAGE_NAME}.tar
                                docker stop ${IMAGE_NAME} || true
                                docker rm ${IMAGE_NAME} || true
                                docker run -d --name ${IMAGE_NAME} -p 3000:3000 ${IMAGE_NAME}
                                docker ps
                            '
                        """
                    }

                    echo "App is live at http://${appIp}:3000"
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed! App deployed successfully."
        }
        failure {
            echo "Pipeline failed. Check the logs above."
        }
    }
}