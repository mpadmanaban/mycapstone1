pipeline {
	agent any
	stages {
		stage('Lint HTML') {
			steps {
				sh 'tidy -q -e *.html'
			}
		}
		
		stage('Build Docker Image') {
			steps {
				withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD']]){
					sh '''
						docker build -t mpadmanaban/mycapstone:$BUILD_ID .
					'''
				}
			}
		}

		stage('Push Image To Dockerhub') {
			steps {
				withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD']]){
					sh '''
						docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
						docker push mpadmanaban/mycapstone:$BUILD_ID
					'''
				}
			}
		}

		stage('Set kubectl context to blue cluster') {
			steps {
				withAWS(region:'us-east-2', credentials:'jenkins-aws') {
					sh '''
						kubectl config use-context arn:aws:eks:us-east-2:364071744232:cluster/blue-cluster
					'''
				}
			}
		}

		stage('Run blue container') {
			steps {
				withAWS(region:'us-east-2', credentials:'jenkins-aws') {
					sh '''
						kubectl run bluecapstone --image=mpadmanaban/mycapstone:$BUILD_ID --port=80
					'''
				}
			}
		}

		stage('Expose container port') {
			steps {
				withAWS(region:'us-east-2', credentials:'jenkins-aws') {
					sh '''
						kubectl expose deployment bluecapstone --type=LoadBalancer --port=80
					'''
				}
			}
		}

		stage('setup LoadBalancer') {
			steps {
				withAWS(region:'us-east-2', credentials:'jenkins-aws') {
					sh '''
						kubectl apply -f ./blue-green-deploy.json
					'''						
				}
			}
		}
		
		stage('LoadBalancer redirect blue') {
			steps {
				withAWS(region:'us-east-2', credentials:'jenkins-aws') {
					sh '''
						kubectl apply -f ./blue-controller.json
					'''						
				}
			}
		}
		
	}
}