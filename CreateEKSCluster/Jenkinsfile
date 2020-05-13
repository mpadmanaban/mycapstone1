pipeline {
	agent any
	stages {	
		stage('Create bluecluster') {
			steps {
				withAWS(region:'us-east-2', credentials:'jenkins-aws') {
					sh '''
						eksctl create cluster -f blue-cluster.yaml
					'''
				}
			}
		}

		stage('create bluecluster kubectl config') {
			steps {
				withAWS(region:'us-east-2', credentials:'jenkins-aws') {
					sh '''
						aws eks --region us-east-2 update-kubeconfig --name blue-cluster
					'''
				}
			}
		}
		
		stage('Create greencluster') {
			steps {
				withAWS(region:'us-east-2', credentials:'jenkins-aws') {
					sh '''
						eksctl create cluster -f green-cluster.yaml
					'''
				}
			}
		}

		stage('create greencluster kubectl config') {
			steps {
				withAWS(region:'us-east-2', credentials:'jenkins-aws') {
					sh '''
						aws eks --region us-east-2 update-kubeconfig --name green-cluster
					'''
				}
			}
		}

	}
}
