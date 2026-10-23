#!/usr/bin/env bash
set -euo pipefail

# Default command will query the server on /etc/resolv.conf and return an A
# record for the domain specified.

dig portugal.gov.pt

# Querying a specific DNS server and a specific record.

dig @1.1.1.1 portugal.gov.pt TXT

# Useful flags for more readable output.

dig @1.1.1.1 portugal.gov.pt TXT +noall +answer
