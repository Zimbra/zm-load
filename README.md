This container is intended to allow the execution of any of the JMeter load tests found within the *ssh://git@stash.corp.synacor.com:7999/prf/zimbra-load-testing.git* repository.

As such it does not utilize the scheduling mechanism that allows the tests to function within the SALT load generation framework.

Each image can be spun up with one or more replicas each executing the specified load test.
In so doing the test can be scaled up or down within a self-contained docker swarm.

## Setup

Update and sync the 'zimbra-load-testing' submodule that contains the actual JMeter load tests:

    git update --init

Copy the DOT-env file to a .env file and configure appropriately:

    TARGET_HOST=zimbra.zcs-foss.test
    TARGET_PORT=143
    TEST_NAME=imap                            #test suite to execute


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
