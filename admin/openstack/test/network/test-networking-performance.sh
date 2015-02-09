#!/bin/bash

TEST_HOME="$MNG_ROOT/openstack/test/network"

# 1. create vm

# 2. configure vm networking

# 3. configure test nodes networking
$TEST/config-test-node-networks.sh

# 4. perform networking test - iperf

# 5. perform networking test - httperf

# 6. destroy vm

