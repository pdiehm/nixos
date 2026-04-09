#!/usr/bin/env bash

SCRIPT="s/^\w+ \w+ \S+ \S+ ([^:[]+)[^:]*: (.+)$/\1::\2/;"
SCRIPT+="s/^sshd-session::(Accepted|Failed) password for (\w+) from (\S+) port \w+ ssh2$/[sshd] \1 password for \2 from \3/p;"
SCRIPT+="s/^sshd-session::(Accepted|Failed) publickey for (\w+) from (\S+) port \w+ ssh2: \S+ SHA256:\S+$/[sshd] \1 publickey for \2 from \3/p;"
SCRIPT+="s/^sshd-session::Invalid user (\w+) from (\S+) port \w+$/[sshd] Invalid user \1 from \2/p;"
SCRIPT+="s/^sshd-session::User (\w+) from (\S+) not allowed because not listed in AllowUsers$/[sshd] Denied user \1 from \2/p;"
SCRIPT+="s/^sudo::\s+(\w+) : .* USER=(\w+) .* COMMAND=(.+)$/[sudo] \1 as \2: \3/p;"
SCRIPT+="s/^systemd::(\S+): Failed with result '(.+)'\.$/[systemd] \1 failed: \2/p;"
SCRIPT+="s/^systemd::Startup finished in .+ = (.+)\.$/[systemd] Booted in \1/p;"

journalctl --follow --no-tail | sed -Enu "$SCRIPT" | while read -r MSG; do ntfy journal "$MSG" || true; done
