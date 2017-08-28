node("docker") {
    def app

    stage('Clone repository') {
        /* Let's make sure we have the repository cloned to our workspace */

        checkout scm
    }

    agent {
        docker {
            image 'jplock/zookeeper'
            args '--net=host --name zookeeper -d'
        }
    }
    stages {
        stage('Test') {
            steps {
                sh 'ls'
            }
        }
    }
    stage('Build image') {
        /* This builds the actual image; synonymous to
         * docker build on the command line */

        app = docker.build("kafka_11")
    }
    environment {
    ip='hostname -I | cut -d " " -f1'
    } 
    agent {
        docker {
            image 'kafka_11'
            args '--net=host --env KAFKA_ADVERTISED_HOST_NAME=$ip --env ZOOKEEPER_IP=$ip --name kafka -d'
        }
    }
    stage('Test image') {
        /* Ideally, we would run a test framework against our image.
         * For this example, we're using a Volkswagen-type approach ;-) */

        app.inside {
            sh 'ls'
        }
    }

    stage('Push image') {
        /* Finally, we'll push the image with two tags:
         * First, the incremental build number from Jenkins
         * Second, the 'latest' tag.
         * Pushing multiple tags is cheap, as all the layers are reused. */
        docker.withRegistry('https://registry.hub.docker.com', 'a81ee946-40df-4fd2-bb05-97c059d4f417') {
            app.push("kafka_11:${env.BUILD_ID}")
        }
    }
}
