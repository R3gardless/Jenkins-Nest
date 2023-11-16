pipeline {
    // 스테이지 별로 다른 거
    agent any // 아무 Jenkins 사용

    environment {
      AWS_ACCESS_KEY_ID = credentials('awsAccessKeyId') // AWS IAM 기반 Credentials ID 설정
      AWS_SECRET_ACCESS_KEY = credentials('awsSecretAccessKey') // AWS IAM 기반 Credentials ID 설정
      AWS_DEFAULT_REGION = 'ap-northeast-2'
      HOME = '.' // Avoid npm root owned
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'Jenkins_Study',
                    url: 'https://github.com/R3gardless/Jenkins-Nest.git'
            }
        }
        // 레포지토리를 다운로드 받음
        stage('Prepare') {
            agent any
            
            steps {
                // echo "Lets start Long Journey! ENV: ${ENV}"
                echo 'Clonning Repository'

                git url: 'https://github.com/R3gardless/Jenkins-Nest.git',
                    branch: 'main',
                    credentialsId: 'Jenkins_Study' // Jenkins Crediential 등록한 ID
            }

            post {
                // If Maven was able to run the tests, even if some of the test
                // failed, record the test results and archive the jar file.
                success {
                    echo 'Successfully Cloned Repository'
                }

                always { // 실패 여부 상관 없음
                  echo "i tried..."
                }

                cleanup { // post 전부 완료
                  echo "after all other post condition"
                }
            }
        }

        // stage('Only for production') {
        //     when {
        //         branch 'production'
        //         environment name: 'APP_ENV', value: 'prod'
        //         anyOf {
        //             environment name: 'DEPLOY_TO', value: 'production'
        //             environment name: 'DEPLOY_TO', value: 'staging'
        //         }
        //     }
        // }
        
        stage('Lint Backend') {
            // Docker plugin and Docker Pipeline 두개를 깔아야 사용가능!
            agent {
              docker {
                image 'node:lts'
              }
            }
            
            steps {
              dir ('./src'){
                  sh '''
                  rm -rf /var/lib/jenkins/workspace/Jenkins_Study@2/node_modules
                  npm install&&
                  npm run lint
                  '''
              }
            }
        }
        
        stage('Test Backend') {
          agent {
            docker { // Jenkins 에 노드가 없으니 Docker를 사용하여 Node 사용
              image 'node:lts'
            }
          }
          steps {
            echo 'Test Backend'

            dir ('./src'){
                sh '''
                npm install
                npm run test
                '''
            }
          }
        }
        
        stage('Bulid Backend') {
          agent any
          steps {
            echo 'Build Backend'

            dir ('./src'){ // Jenkins node 에 docker 설치 필요
                sh """
                docker build . -t server --build-arg env=${PROD}
                """
            }
          }

          post {
            failure { // 실패 시 pipeline stops 없을 경우 다음 stage 로 넘어감
              error 'This pipeline stops here...'
            }
          }
        }
        
        stage('Deploy Backend') {
          agent any

          steps {
            echo 'Build Backend'

            dir ('./src'){
                // docker rm -f $(docker ps -aq) = 실행 중인 docker container 다 shutdown
                sh '''
                docker run -p 80:80 -d server
                '''
            }
          }

          post {
            success {
              echo 'Deploy Backend Success'
            }
          }
        }
    }
}
