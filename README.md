# Secure Minecraft Server Deployment

Automated deployment of a Paper Minecraft 1.16.5 server with enterprise-grade security using Ansible and Docker.

## Features

- **Paper Minecraft 1.16.5** in Docker container
- **Persistent world storage** with automatic backups
- **Essential security hardening**:
  - Firewall protection (UFW/firewalld)
  - SSH hardening with key-only authentication
  - Fail2Ban intrusion prevention
  - Automatic security updates
- **One-command deployment** using Just

## Prerequisites

- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [Just](https://github.com/casey/just#installation) command runner
- SSH key at `~/.ssh/bitlaunch`
- Root access to target server

## Quick Start

1. **Check prerequisites:**
   ```bash
   just check
   ```

2. **Deploy secure Minecraft server:**
   ```bash
   just deploy <server_ip>
   ```

3. **Connect to your server:**
   - Server address: `<server_ip>:25565`
   - Version: Paper 1.16.5
   - **Cracked clients allowed** (no Minecraft license required)

## Available Commands

### Deployment
```bash
just deploy <server_ip>    # Full deployment with security
just secure <server_ip>    # Security hardening only
```

### Server Management
```bash
just status <server_ip>    # Check server status
just start <server_ip>     # Start server
just stop <server_ip>      # Stop server
just restart <server_ip>   # Restart server
just logs <server_ip>      # View server logs
just backup <server_ip>    # Create world backup
just update-config <server_ip>  # Update server settings only
```

### Security Monitoring
```bash
just security-status <server_ip>     # Security status report
just check-updates <server_ip>       # Check for system updates
just fail2ban-logs <server_ip>       # View blocked IPs
just security-logs <server_ip>       # View auth logs
just unban-ip <server_ip> <ip>       # Unban IP address
```

### Utilities
```bash
just test-ssh <server_ip>  # Test SSH connection
just check                 # Verify prerequisites
just clean                 # Clean up files
```

## Server Management (On Server)

After deployment, these scripts are available on the server at `/opt/minecraft-server/`:

- `./start.sh` - Start server
- `./stop.sh` - Stop server  
- `./restart.sh` - Restart server
- `./logs.sh` - View logs
- `./backup.sh` - Create backup

## Security Features

- **Firewall**: Only SSH (22) and Minecraft (25565) ports open
- **SSH**: Key-only authentication, rate limiting, secure ciphers
- **Fail2Ban**: Automatic IP banning for failed login attempts
- **Updates**: Daily security updates automatically applied
- **Backups**: Daily world backups at 3 AM (7-day retention)

## File Structure

```
├── justfile                      # Command definitions
├── inventory.yml                 # Ansible inventory
├── site.yml                     # Full deployment playbook
├── secure-site.yml              # Security-only playbook
├── docker-compose.yml           # Minecraft server config
└── playbooks/
    ├── docker-setup.yml         # Docker installation
    ├── minecraft-deploy.yml     # Minecraft deployment
    ├── firewall-security.yml    # Firewall configuration
    ├── ssh-hardening.yml        # SSH security
    ├── fail2ban-setup.yml       # Intrusion prevention
    └── system-hardening.yml     # System security
```

## Customization

### Server Settings
Edit `docker-compose.yml` to modify:
- Memory allocation (default: 2GB)
- Player limit (default: 20)
- Game difficulty, PvP, etc.
- Online mode (currently: false - allows cracked clients)

After editing, run: `just update-config <server_ip>`

### Security Settings
Edit playbook files in `playbooks/` to adjust:
- Firewall rules
- SSH configuration
- Fail2Ban thresholds

## Troubleshooting

- **SSH key issues**: Ensure `~/.ssh/bitlaunch` exists and has correct permissions
- **Connection timeout**: Check server IP and firewall settings
- **Permission denied**: Verify root access and SSH key authentication

## Support

For issues or feature requests, check the server logs:
```bash
just logs <server_ip>
```