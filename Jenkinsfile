pipeline {
	agent any
	stages {
		stage('Linting') {
			steps {
				sh 'tidy -q -e *.html'
			}
		}
		
		stage('Build Docker image') {
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

		stage('Deploy blue container') {
			steps {
				withAWS(region:'us-east-2', credentials:'jenkins-aws') {
					sh '''
						kubectl config use-context arn:aws:eks:us-east-2:364071744232:cluster/blue-cluster
						kubectl run bluecapstone --image=mpadmanaban/mycapstone:$BUILD_ID --port=80
					'''
				}
			}
		}		
				
		stage('Set Route53 to blue') {
			steps {
				withAWS(region:'us-east-2', credentials:'jenkins-aws') {
					sh '''
						kubectl config use-context arn:aws:eks:us-east-2:364071744232:cluster/blue-cluster
						kubectl expose deployment bluecapstone --type=LoadBalancer --port=80 --name capstonelb
						sh ./switchRoute53.sh capstonelb
					'''						
				}
			}
		}
		
		stage('Confirm green Deployment') {
			steps {
				timeout(time: 4, unit: "HOURS") {
					input message: 'Approve Deploy to Green?', ok: 'Yes'
				}
			}
		}
		
		stage('Deploy green container') {
			steps {
				withAWS(region:'us-east-2', credentials:'jenkins-aws') {
					sh '''
						kubectl config use-context arn:aws:eks:us-east-2:364071744232:cluster/green-cluster
						kubectl run greencapstone --image=mpadmanaban/mycapstone:$BUILD_ID --port=80
					'''
				}
			}
		}
		
		stage('Set Route53 to green') {
			steps {
				withAWS(region:'us-east-2', credentials:'jenkins-aws') {
					sh '''
						kubectl config use-context arn:aws:eks:us-east-2:364071744232:cluster/green-cluster
						kubectl expose deployment greencapstone --type=LoadBalancer --port=80 --name capstonelb
						sh ./switchRoute53.sh capstonelb
					'''						
				}
			}
		}
		
	}
}