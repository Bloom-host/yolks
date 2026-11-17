#!/bin/bash

#
# Copyright (c) 2021 Matthew Penner
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Switch to the container's working directory
cd /home/container || exit 1

# Forge 1.13-1.16.5 before 36.2.26 ships ModLauncher < 8.1.3, which crashes on Java 8u321+ / 11.0.14+.
# Images that bundle a pre-break JRE in /opt/java/legacy switch to it for those servers only.
# @see https://github.com/McModLauncher/modlauncher/issues/91
if [ -d /opt/java/legacy ]; then
	for dir in libraries/cpw/mods/modlauncher/*/; do
		[ -d "$dir" ] || continue
		version=$(basename "$dir")
		if [ "$(printf '%s\n' "$version" 8.1.3 | sort -V | head -n1)" != "8.1.3" ]; then
			printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0mModLauncher %s found, using legacy Java for Forge compatibility\n" "$version"
			export JAVA_HOME=/opt/java/legacy PATH="/opt/java/legacy/bin:${PATH}"
			break
		fi
	done
fi

# CVE-2026-114938 (Java4Shell): HotSpot's AVX-512 Base64 decode intrinsic writes out of bounds.
# Turn it off for every JVM in the container, appended so an egg's own JAVA_TOOL_OPTIONS can't drop it.
# The Temurin 8 and OpenJ9 builds shipped here aren't affected and can refuse to start with the option, so
# they're skipped. They're identified from the JDK's release file rather than by running java, so egg
# options can't change the answer.
# Keep it: 18, 19 and 24 are EOL and will never be fixed, and the GraalVM and Azul images pin affected JDKs.
java4shell_java=$(readlink -f "$(command -v java || echo "${JAVA_HOME}/bin/java")")
if ! grep -qsE '^JAVA_VERSION="?1\.|^JVM_VARIANT="?Openj9' "${java4shell_java%/bin/java}/release" "${java4shell_java%/jre/bin/java}/release"; then
	export JAVA_TOOL_OPTIONS="${JAVA_TOOL_OPTIONS:+${JAVA_TOOL_OPTIONS} }-XX:-UseBASE64Intrinsics"
fi
unset java4shell_java

# Print Java version
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0mjava -version\n"
java -version

# Convert all of the "{{VARIABLE}}" parts of the command into the expected shell
# variable format of "${VARIABLE}" before evaluating the string and automatically
# replacing the values.
PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")

# Display the command we're running in the output, and then execute it with the env
# from the container itself.
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0m%s\n" "$PARSED"
# shellcheck disable=SC2086
exec env ${PARSED}
