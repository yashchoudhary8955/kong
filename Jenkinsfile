pipeline {
    agent none
    options {
        retry(1)
        timeout(time: 2, unit: 'HOURS')
    }
    environment {
        UPDATE_CACHE = "true"
        DOCKER_CREDENTIALS = credentials('dockerhub')
        DOCKER_USERNAME = "${env.DOCKER_CREDENTIALS_USR}"
        DOCKER_PASSWORD = "${env.DOCKER_CREDENTIALS_PSW}"
        KONG_PACKAGE_NAME = "kong"
        DOCKER_CLI_EXPERIMENTAL = "enabled"
    }
    stages {
        stage('Alpine Release'){
            agent {
                node {
                    label 'bionic'
                }
            }
            environment {
                PACKAGE_TYPE = 'deb'
                RESTY_IMAGE_BASE = 'debian'
                KONG_SOURCE_LOCATION = "${env.WORKSPACE}"
                KONG_BUILD_TOOLS_LOCATION = "${env.WORKSPACE}/../kong-build-tools"
                BINTRAY_USR = 'kong-inc_travis-ci@kong'
                BINTRAY_KEY = credentials('bintray_travis_key')
                AWS_ACCESS_KEY = credentials('AWS_ACCESS_KEY')
                AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
                KONG_VERSION = '2.2.0rc.1'
                REPOSITORY_NAME = 'kong-prerelease'
                REPOSITORY_OS_NAME = 'alpine'
                DEBUG = 0
            }
            steps {
                sh 'echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin || true'
                sh 'make setup-kong-build-tools'
                sh 'CACHE=false DOCKER_MACHINE_ARM64_NAME="kong-"`cat /proc/sys/kernel/random/uuid` PACKAGE_TYPE=apk RESTY_IMAGE_BASE=alpine RESTY_IMAGE_TAG=3 make release'
            }
        }
    }
}
