#!/bin/bash
# Build-time patches for images that bundle a current JDK in /opt/java/openjdk and a pre-8u321/11.0.14
# JDK in /opt/java/legacy (see java/8/Dockerfile). Fails the build unless both JDKs were patched.
set -euo pipefail

# CVE-2026-91403: merge OpenJDK's blocklist (the compromised eMudhra intermediates, including their
# AAA Certificate Services cross-signs) into each JDK's own list. The legacy JDK will never get it.
lists=0
for list in $(find /opt/java -name blacklisted.certs -o -name blocked.certs); do
	[ "$(head -n1 "$list")" = "Algorithm=SHA-256" ]
	{ echo "Algorithm=SHA-256"; grep -hv -e '^#' -e '^Algorithm=' "$list" /tmp/blocked.certs | sort -u; } > "$list.new"
	mv "$list.new" "$list"
	lists=$((lists + 1))
done
[ "$lists" -eq 2 ]

# 8u351+/11.0.17+ treat SHA-1 signed JARs as unsigned, which breaks old mods that check their own
# signature. Restore the behaviour the pinned 8u312/11.0.13 images had. JAR signatures only, TLS is untouched.
configs=0
for config in $(find /opt/java -name java.security); do
	sed -i 's/ SHA1 denyAfter 2019-01-01,//' "$config"
	if grep -q 'SHA1 denyAfter' "$config"; then exit 1; fi
	configs=$((configs + 1))
done
[ "$configs" -eq 2 ]
