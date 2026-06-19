# SSH Connection Selector

```text
╭─────────────────────────────────────────────────────────╮
│                 SSH Connection Selector                 │
│              Terminal SSH Access Manager                │
│              by Aung Myat Thu / w01f                    │
╰─────────────────────────────────────────────────────────╯
```

A terminal-based SSH connection selector for managing multiple SSH servers from one script.

Version: `v2.3.2`

---

## Features

```text
[+] Interactive SSH server menu
[+] Direct connect by server ID
[+] Direct connect by server name
[+] Hacker-style loading animation
[+] Dry-run mode to preview SSH command
[+] Server list mode
[+] SSH key authentication support
[+] Password prompt authentication support
[+] TTY enabled by default
[+] Does not use ssh -T
[+] Supports custom SSH key per server
```

Safe SSH options included:

```text
IdentitiesOnly=yes
RequestTTY=yes
ConnectTimeout
ServerAliveInterval
ServerAliveCountMax
```

---

## Authentication Modes

The script supports two authentication modes:

```text
key     = SSH private key login
prompt  = SSH password prompt login
```

### Key Login

Use `key` when the server uses SSH key authentication.

```bash
"1|Server 1|user1|server1.example.com|22|key|id_ed25519"
```

This will connect like:

```bash
ssh -i ~/.ssh/id_ed25519 -p 22 user1@server1.example.com
```

### Password Prompt Login

Use `prompt` when the server requires a password.

```bash
"9|Server 9|user9|server9.example.com|22|prompt|"
```

The password is not saved in the script.

The password is not printed in the terminal.

The password is requested directly by SSH using its normal hidden input prompt.

Do not store passwords like this:

```bash
"9|Server 9|user9|server9.example.com|22|password|my_password_here"
```

Use this instead:

```bash
"9|Server 9|user9|server9.example.com|22|prompt|"
```

---

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

So SSH opens as a normal interactive terminal session.

---

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

---

## Server Configuration

Edit only the `SERVERS` section in the script.

```bash
SERVERS=(
    "1|Server 1|user1|server1.example.com|22|key|id_ed25519"
    "2|Server 2|user2|server2.example.com|22|key|id_ed25519"
    "3|Server 3|user3|server3.example.com|2222|key|id_rsa"
    "4|Server 4|user4|server4.example.com|22|prompt|"
)
```

Format:

```text
ID|Server Name|SSH User|Host|Port|Auth Type|SSH Key Name
```

Field meaning:

```text
ID           = Menu number
Server Name  = Display name
SSH User     = SSH username
Host         = Server IP address or domain
Port         = SSH port
Auth Type    = key or prompt
SSH Key Name = Key file name inside ~/.ssh
```

For key login:

```bash
"1|Production|ubuntu|prod.example.com|22|key|id_ed25519"
```

For password prompt login:

```bash
"2|Legacy Server|root|legacy.example.com|22|prompt|"
```

---

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

---

## Example Output

```text
╭─────────────────────────────────────────────────────────╮
│                 SSH Connection Selector                 │
│          v2.3.2 by Aung Myat Thu / w01f                 │
╰─────────────────────────────────────────────────────────╯

Select a server to connect:

 1) Server 1         [key]    user1@server1.example.com:22
 2) Server 2         [key]    user2@server2.example.com:22
 3) Server 3         [key]    user3@server3.example.com:22
 4) Server 4         [secure] user4@server4.example.com:22

 r) Reload menu
 l) List servers
 q) Quit

Enter your choice:
```

---

## Loading Animation

When connecting, the script shows a terminal-style loading sequence:

```text
[+] Initializing secure terminal...
[+] Loading SSH profile...
[+] Checking authentication mode...
[+] Preparing encrypted channel...
[+] Target locked: user1@server1.example.com:22...
[+] Launching session...
```

To disable it:

```bash
~/.ssh/ssh-selector.sh --no-hacker 1
```

---

## Add Command Shortcut

You can add an alias to `.bashrc` or `.zshrc` so you can run the script from anywhere using a short command.

---

## Bash Setup

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

---

## Zsh Setup

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

---

## Why Use `.bashrc` or `.zshrc`?

`.bashrc` and `.zshrc` are shell configuration files.

They are loaded when you open a terminal.

Adding an alias allows you to run your SSH selector like a normal command instead of typing the full script path every time.

Without alias:

```bash
~/.ssh/ssh-selector.sh
```

With alias:

```bash
sshmenu
```

---

## Generate SSH Key

Recommended key type:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

When asked for file path, you can press Enter to use the default:

```text
~/.ssh/id_ed25519
```

Create a custom key:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/server1_key -C "server1"
```

Then use this key name in the script:

```bash
SERVERS=(
    "1|Server 1|user1|server1.example.com|22|key|server1_key"
)
```

---

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

---

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

---

## Example Server Entries

```bash
SERVERS=(
    "1|Production|ubuntu|prod.example.com|22|key|id_ed25519"
    "2|Development|devuser|dev.example.com|2244|key|id_ed25519"
    "3|UAT|uatuser|uat.example.com|2245|key|id_rsa"
    "4|Legacy|root|legacy.example.com|22|prompt|"
)
```

---

## Troubleshooting

### SSH key not found

Check your key file:

```bash
ls -la ~/.ssh
```

Make sure the key name in `SERVERS` matches the real file name.

Correct:

```text
id_ed25519
```

Wrong:

```text
~/.ssh/id_ed25519
```

The script automatically adds:

```text
~/.ssh/
```

---

### Permission denied with key login

Test manually:

```bash
ssh -i ~/.ssh/id_ed25519 user1@server1.example.com
```

For custom port:

```bash
ssh -i ~/.ssh/id_ed25519 -p 2222 user1@server1.example.com
```

---

### Password server does not ask password

Make sure the server entry uses `prompt`:

```bash
"4|Legacy|root|legacy.example.com|22|prompt|"
```

Also make sure the server allows password login in SSH server config.

On the server, check:

```bash
sudo grep -E "PasswordAuthentication|KbdInteractiveAuthentication" /etc/ssh/sshd_config
```

Example server-side config:

```text
PasswordAuthentication yes
KbdInteractiveAuthentication yes
```

Then restart SSH on the server:

```bash
sudo systemctl restart ssh
```

---

### Colors showing as `\033`

Make sure you are running the script in a real terminal.

You can also disable colors:

```bash
NO_COLOR=1 ~/.ssh/ssh-selector.sh
```

---

### IP banned by SSH security rule

Do not use:

```bash
ssh -T
```

Use normal SSH with TTY:

```bash
ssh -o RequestTTY=yes user1@server1.example.com
```

This script already uses:

```bash
-o RequestTTY=yes
```

---

## Security Notes

```text
[+] Do not store real passwords in the script
[+] Use prompt mode for password-based servers
[+] Use key mode for production servers when possible
[+] Keep private keys permission as 600
[+] Keep ~/.ssh permission as 700
[+] Do not commit real server IPs, domains, users, or keys to public GitHub repositories
[+] Do not use ssh -T if your server security rules ban non-TTY sessions
```

---

## License

Free to use and modify.
