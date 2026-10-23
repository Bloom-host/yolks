#!/bin/bash
# Build-time patch for images whose JDK predates the CVE-2026-91403 fix. Fails the build unless at
# least one JDK under /opt was patched and every list found has the expected format.
set -euo pipefail

# CVE-2026-91403: merge OpenJDK's blocklist (the compromised eMudhra intermediates, including their
# AAA Certificate Services cross-signs) into each JDK's own list. A no-op once the JDK ships the fix.
lists=0
for list in $(find /opt -path '*/lib/security/*' \( -name blacklisted.certs -o -name blocked.certs \)); do
	[ "$(head -n1 "$list")" = "Algorithm=SHA-256" ]
	{ echo "Algorithm=SHA-256"; grep -hv -e '^#' -e '^Algorithm=' "$list" /tmp/blocked.certs | sort -u; } > "$list.new"
	mv "$list.new" "$list"
	lists=$((lists + 1))
done
[ "$lists" -gt 0 ]
