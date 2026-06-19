# SSH Connection Selector - by Aung Myat Thu

A simple terminal-based SSH connection selector for managing multiple SSH servers from one script.

Version: `v2.2.2`

## Features

* Interactive SSH server menu
* Direct connect by server ID
* Direct connect by server name
* Hacker-style loading animation
* Dry-run mode to preview SSH command
* Server list mode
* TTY enabled by default
* Does not use `ssh -T`
* Supports custom SSH key per server
* Safe SSH options:

  * `IdentitiesOnly=yes`
  * `RequestTTY=yes`
  * `ConnectTimeout`
  * `ServerAliveInterval`
  * `ServerAliveCountMax`

## Important Note About `ssh -T`

This script does not use:

```bash
ssh -T
```

Reason:

`ssh -T` disables TTY allocation. Some server-side `iptables`, `fail2ban`, or custom SSH monitoring rules may treat non-TTY SSH sessions as suspicious and ban your IP.

This script uses:

```bash
-o RequestTTY=yes
```

So SSH will open as a normal interactive terminal session.

## Installation

Create the script file:

```bash
nano ~/.ssh/ssh-selector.sh
```

Paste the script content, then save it.

Make it executable:

```bash
chmod +x ~/.ssh/ssh-selector.sh
```

Run it:

```bash
~/.ssh/ssh-selector.sh
```

## Server Configuration

Edit only the `SERVERS` section in the script.

Example:

```bash
SERVERS=(
    "1|Server 1|user1|server1.example.com|22|id_ed25519"
    "2|Server 2|user2|server2.example.com|22|id_ed25519"
    "3|Server 3|user3|server3.example.com|2222|id_rsa"
)
```

Format:

```text
ID|Server Name|SSH User|Host|Port|SSH Key Name
```

Example meaning:

```bash
"1|Server 1|user1|server1.example.com|22|id_ed25519"
```

This will connect as:

```bash
ssh -i ~/.ssh/id_ed25519 -p 22 user1@server1.example.com
```

## Usage

Open interactive menu:

```bash
~/.ssh/ssh-selector.sh
```

Connect by server ID:

```bash
~/.ssh/ssh-selector.sh 1
```

Connect by server name:

```bash
~/.ssh/ssh-selector.sh "Server 1"
```

List all servers:

```bash
~/.ssh/ssh-selector.sh --list
```

Preview SSH command without connecting:

```bash
~/.ssh/ssh-selector.sh --dry-run 1
```

Disable hacker loading animation:

```bash
~/.ssh/ssh-selector.sh --no-hacker 1
```

Show help:

```bash
~/.ssh/ssh-selector.sh --help
```

## Add Command Shortcut

You can add an alias to `.bashrc` or `.zshrc` so you can run the script from anywhere using a short command.

### For Bash

Add this to `~/.bashrc`:

```bash
alias sshmenu="$HOME/.ssh/ssh-selector.sh"
```

Reload Bash config:

```bash
source ~/.bashrc
```

Now you can run:

```bash
sshmenu
```

Direct connect:

```bash
sshmenu 1
```

### For Zsh

Add this to `~/.zshrc`:

```bash
alias sshmenu="$HOME/.ssh/ssh-selector.sh"
```

Reload Zsh config:

```bash
source ~/.zshrc
```

Now you can run:

```bash
sshmenu
```

Direct connect:

```bash
sshmenu 1
```

## Why Use `.bashrc` or `.zshrc`?

`.bashrc` and `.zshrc` are shell configuration files.

They are loaded when you open a terminal.

Adding an alias there allows you to run your SSH selector like a normal command instead of typing the full script path every time.

Without alias:

```bash
~/.ssh/ssh-selector.sh
```

With alias:

```bash
sshmenu
```

## Generate SSH Key

Recommended key type:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

When asked for file path, you can press Enter to use the default:

```text
~/.ssh/id_ed25519
```

Or create a custom key:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/server1_key -C "server1"
```

Then use this key name in the script:

```bash
SERVERS=(
    "1|Server 1|user1|server1.example.com|22|server1_key"
)
```

## Copy SSH Key to Server

Copy your public key to the server:

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub user1@server1.example.com
```

For custom port:

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub -p 2222 user1@server1.example.com
```

If `ssh-copy-id` is not available, manually copy the public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

Then add the output to this file on the server:

```bash
~/.ssh/authorized_keys
```

## SSH Permission Fix

Run these commands if SSH complains about bad permissions:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

If you use another key:

```bash
chmod 600 ~/.ssh/your_key_name
```

## Example Server Entry

```bash
SERVERS=(
    "1|Production|ubuntu|prod.example.com|22|id_ed25519"
    "2|Development|devuser|dev.example.com|2244|id_ed25519"
    "3|UAT|uatuser|uat.example.com|2245|id_rsa"
)
```

## Troubleshooting

### SSH key not found

Check your key file:

```bash
ls -la ~/.ssh
```

Make sure the key name in `SERVERS` matches the real file name.

Example:

```bash
id_ed25519
```

Not:

```bash
~/.ssh/id_ed25519
```

The script automatically adds:

```bash
~/.ssh/
```

### Permission denied

Test manually:

```bash
ssh -i ~/.ssh/id_ed25519 user1@server1.example.com
```

For custom port:

```bash
ssh -i ~/.ssh/id_ed25519 -p 2222 user1@server1.example.com
```

### Colors showing as `\033`

Make sure you are running the script in a real terminal.

You can also disable colors:

```bash
NO_COLOR=1 ~/.ssh/ssh-selector.sh
```

### IP banned by SSH security rule

Do not use:

```bash
ssh -T
```

Use normal SSH with TTY:

```bash
ssh -o RequestTTY=yes user1@server1.example.com
```

This script already uses `RequestTTY=yes`.

## License

Free to use and modify.
