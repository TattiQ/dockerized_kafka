node("docker") {
    docker.withRegistry('tattiq/kafka', 'a81ee946-40df-4fd2-bb05-97c059d4f417') {
    
        git url: "https://github.com/TattiQ/dockerized_kafka.git", credentialsId: 'bc0c1d03-45ce-4b48-93ae-7cdb27f59327'
    
        sh "git rev-parse HEAD > .git/commit-id"
        def commit_id = readFile('.git/commit-id').trim()
        println commit_id
    
        stage "build"
        def app = docker.build "dockerized_kafka"
    
        stage "publish"
        app.push 'master'
        app.push "${commit_id}"
    }
}
