pipeline {
	agent any
	stages {
		stage('Linting') {
			steps {
				sh '''
					tidy -q -e *.html
					hadolint Dockerfile
				'''
			}
		}
		
		stage('Build Docker image') {
			steps {
				withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD']]){
					sh '''
						docker build -t mpadmanaban/mycapstone .
					'''
				}
			}
		}

		stage('Push Image To Dockerhub') {
			steps {
				withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD']]){
					sh '''
						docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
						docker push mpadmanaban/mycapstone
					'''
				}
			}
		}

		stage('Deploy blue container') {
			steps {
				withAWS(region:'us-east-2', credentials:'jenkins-aws') {
					sh '''
						kubectl config use-context arn:aws:eks:us-east-2:364071744232:cluster/blue-cluster
						kubectl apply -f ./blue-controller.json
					'''
				}
			}
		}
				
		stage('Set Route53 to blue') {
			steps {
				withAWS(region:'us-east-2', credentials:'jenkins-aws') {
					sh '''
						kubectl config use-context arn:aws:eks:us-east-2:364071744232:cluster/blue-cluster						
						kubectl delete service bluelb || :
						kubectl expose replicationcontroller blue --type=LoadBalancer --name bluelb
						chmod +x ./switchRoute53.sh
						./switchRoute53.sh bluelb blue
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
						kubectl apply -f ./green-controller.json
					'''
				}
			}
		}
		
		stage('Set Route53 to green') {
			steps {
				withAWS(region:'us-east-2', credentials:'jenkins-aws') {
					sh '''
						kubectl config use-context arn:aws:eks:us-east-2:364071744232:cluster/green-cluster						
						kubectl delete service greenlb || :
						kubectl expose replicationcontroller green --type=LoadBalancer --name greenlb
						./switchRoute53.sh greenlb green
					'''
				}
			}
		}
		
	}
}