This container is intended to allow the execution of any of the JMeter
load tests found within the
*ssh://git@stash.corp.synacor.com:7999/prf/zimbra-load-testing.git*
repository.

As such it does not utilize the scheduling mechanism that allows the tests to function within the SALT load generation framework.

Each image can be spun up with one or more replicas each executing the specified load test.
In so doing the test can be scaled up or down within a self-contained docker swarm.

## Setup

Update and sync the 'zimbra-load-testing' submodule that contains the actual JMeter load tests:

    git update --init

Copy the DOT-env file to a .env file and configure appropriately:

    ADMIN=admin
    ADMIN_PASS=test123
    ADMIN_PORT=9071

    TARGET=zmc-proxy
    PORT=993
    DOMAIN=load.zmc.com
    # IMAP / POP / SOAP - Configure based on the test chosen
    PROTOCOL=IMAP
    # Controls the number of accounts created
    NUM_ACCOUNTS=100
    # Controls the number of active clients
    LOOPCOUNT=50
    USERDURATION=30
    COMMANDS=100
    RAMPUP=0

    DURATION=''
    # JMX MUST be specified as the directory + the jmx file
    JMX=imap/imap.jmx
    # RESULTS Location inside container | Must match 'volumes' setting
    RESULTS=/opt/load/results

## Available Tests

The currently available tests are:
 - imap
 - imap_c_86
 - imap_sn_beta
 - imap_sn_ga
 - initial
 - pop
 - smpt_sn_ga
 - web_sn_ga

Each of those tests have multiple property files associated with them that control which servers are targetted and which set of users to utilize during the load test.
Please check the individual test for property file names and what affect they have on the load generation.

## Running the tests

The Load test framework can be initiated inside a swarm with some additional setup.

An overlay network must be created inside the docker swarm and the containers within need to be updated
to utilize said network.

    docker network create -d overlay zimbra-ha

Update all the services defined in *zm-docker* to use the *zimbra_ha* network by adding the following snippet to each container
defined within the *docker-compose.yml* file.

    networks:
    - zimbra-ha


At the end of the *docker-compose.yml* file define the *zimbra-ha* network as external:

    networks:
      zimbra-ha:
        external: true
