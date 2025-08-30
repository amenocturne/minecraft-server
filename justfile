# Minecraft Server Deployment Commands

# Default recipe - show available commands
default:
    @just --list

# Deploy the Minecraft server to the remote host
deploy server_ip:
    #!/usr/bin/env bash
    set -euo pipefail

    # Colors for output
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m'

    print_status() { echo -e "${GREEN}[INFO]${NC} $1"; }
    print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
    print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

    # Check if server IP is provided
    if [ -z "{{server_ip}}" ]; then
        print_error "Please provide the server IP address"
        echo "Usage: just deploy <server_ip>"
        echo "Example: just deploy 192.168.1.100"
        exit 1
    fi

    SERVER_IP="{{server_ip}}"

    # Check if required files exist
    if [ ! -f "inventory.yml" ]; then
        print_error "inventory.yml not found!"
        exit 1
    fi

    if [ ! -f "site.yml" ]; then
        print_error "site.yml not found!"
        exit 1
    fi

    if [ ! -f "$HOME/.ssh/bitlaunch" ]; then
        print_warning "SSH key ~/.ssh/bitlaunch not found. Please make sure the key exists."
    fi

    # Check if ansible is installed
    if ! command -v ansible-playbook &> /dev/null; then
        print_error "Ansible is not installed. Please install Ansible first."
        echo "Install with: pip install ansible"
        exit 1
    fi

    print_status "Starting Minecraft server deployment to $SERVER_IP"

    # Test SSH connection
    print_status "Testing SSH connection..."
    if ssh -i ~/.ssh/bitlaunch -o StrictHostKeyChecking=no -o ConnectTimeout=10 root@$SERVER_IP 'echo "SSH connection successful"' > /dev/null 2>&1; then
        print_status "SSH connection successful"
    else
        print_error "Failed to connect via SSH. Please check:"
        echo "  - Server IP address: $SERVER_IP"
        echo "  - SSH key path: ~/.ssh/bitlaunch"
        echo "  - Server accessibility"
        exit 1
    fi

    # Run the Ansible playbook
    print_status "Running Ansible playbook..."
    ansible-playbook -i inventory.yml site.yml -e server_ip=$SERVER_IP -v

    if [ $? -eq 0 ]; then
        print_status "Deployment completed successfully!"
        echo ""
        echo "Your Minecraft server is now running at:"
        echo "  Server Address: $SERVER_IP:25565"
        echo "  Version: Paper 1.16.5"
        echo ""
        echo "Server Management Commands (run on server):"
        echo "  Start:   /opt/minecraft-server/start.sh"
        echo "  Stop:    /opt/minecraft-server/stop.sh"
        echo "  Restart: /opt/minecraft-server/restart.sh"
        echo "  Logs:    /opt/minecraft-server/logs.sh"
        echo "  Backup:  /opt/minecraft-server/backup.sh"
        echo ""
        echo "The server will automatically start on boot and daily backups are scheduled at 3 AM."
    else
        print_error "Deployment failed!"
        exit 1
    fi

# Test SSH connection to server
test-ssh server_ip="":
    #!/usr/bin/env bash
    if [ -z "{{server_ip}}" ]; then
        echo "Usage: just test-ssh <server_ip>"
        exit 1
    fi
    echo "Testing SSH connection to {{server_ip}}..."
    ssh -i ~/.ssh/bitlaunch -o StrictHostKeyChecking=no -o ConnectTimeout=10 root@{{server_ip}} 'echo "SSH connection successful"'

# Check server status
status server_ip="":
    #!/usr/bin/env bash
    if [ -z "{{server_ip}}" ]; then
        echo "Usage: just status <server_ip>"
        exit 1
    fi
    echo "Checking Minecraft server status on {{server_ip}}..."
    ssh -i ~/.ssh/bitlaunch root@{{server_ip}} 'cd /opt/minecraft-server && docker-compose ps'

# View server logs
logs server_ip="":
    #!/usr/bin/env bash
    if [ -z "{{server_ip}}" ]; then
        echo "Usage: just logs <server_ip>"
        exit 1
    fi
    echo "Viewing Minecraft server logs on {{server_ip}}..."
    ssh -i ~/.ssh/bitlaunch root@{{server_ip}} 'cd /opt/minecraft-server && docker-compose logs -f minecraft'

# Start server
start server_ip="":
    #!/usr/bin/env bash
    if [ -z "{{server_ip}}" ]; then
        echo "Usage: just start <server_ip>"
        exit 1
    fi
    echo "Starting Minecraft server on {{server_ip}}..."
    ssh -i ~/.ssh/bitlaunch root@{{server_ip}} '/opt/minecraft-server/start.sh'

# Stop server
stop server_ip="":
    #!/usr/bin/env bash
    if [ -z "{{server_ip}}" ]; then
        echo "Usage: just stop <server_ip>"
        exit 1
    fi
    echo "Stopping Minecraft server on {{server_ip}}..."
    ssh -i ~/.ssh/bitlaunch root@{{server_ip}} '/opt/minecraft-server/stop.sh'

# Restart server
restart server_ip="":
    #!/usr/bin/env bash
    if [ -z "{{server_ip}}" ]; then
        echo "Usage: just restart <server_ip>"
        exit 1
    fi
    echo "Restarting Minecraft server on {{server_ip}}..."
    ssh -i ~/.ssh/bitlaunch root@{{server_ip}} '/opt/minecraft-server/restart.sh'

# Create backup
backup server_ip="":
    #!/usr/bin/env bash
    if [ -z "{{server_ip}}" ]; then
        echo "Usage: just backup <server_ip>"
        exit 1
    fi
    echo "Creating backup on {{server_ip}}..."
    ssh -i ~/.ssh/bitlaunch root@{{server_ip}} '/opt/minecraft-server/backup.sh'

# Update server configuration only
update-config server_ip="":
    #!/usr/bin/env bash
    set -euo pipefail
    
    if [ -z "{{server_ip}}" ]; then
        echo "Usage: just update-config <server_ip>"
        exit 1
    fi
    
    echo "Updating Minecraft server configuration on {{server_ip}}..."
    ansible-playbook -i inventory.yml playbooks/minecraft-update-config.yml -e server_ip={{server_ip}} -v

# Check prerequisites
check:
    @echo "Checking prerequisites..."
    @command -v ansible-playbook >/dev/null 2>&1 || { echo "❌ Ansible not installed"; exit 1; }
    @echo "✅ Ansible is installed"
    @test -f ${HOME}/.ssh/bitlaunch || { echo "❌ SSH key ~/.ssh/bitlaunch not found"; exit 1; }
    @echo "✅ SSH key found"
    @test -f inventory.yml || { echo "❌ inventory.yml not found"; exit 1; }
    @echo "✅ inventory.yml found"
    @test -f site.yml || { echo "❌ site.yml not found"; exit 1; }
    @echo "✅ site.yml found"
    @echo "All prerequisites met! ✅"

# Apply only security hardening (without Minecraft installation)
secure server_ip="":
    #!/usr/bin/env bash
    set -euo pipefail

    if [ -z "{{server_ip}}" ]; then
        echo "Usage: just secure <server_ip>"
        exit 1
    fi

    echo "Applying security hardening to {{server_ip}}..."
    ansible-playbook -i inventory.yml secure-site.yml -e server_ip={{server_ip}} -v

# Check security status of the server
security-status server_ip="":
    #!/usr/bin/env bash
    if [ -z "{{server_ip}}" ]; then
        echo "Usage: just security-status <server_ip>"
        exit 1
    fi
    echo "Checking security status on {{server_ip}}..."
    ssh -i ~/.ssh/bitlaunch root@{{server_ip}} '/usr/local/bin/fail2ban-status.sh'

# Check system updates
check-updates server_ip="":
    #!/usr/bin/env bash
    if [ -z "{{server_ip}}" ]; then
        echo "Usage: just check-updates <server_ip>"
        exit 1
    fi
    echo "Checking for available updates on {{server_ip}}..."
    ssh -i ~/.ssh/bitlaunch root@{{server_ip}} 'apt list --upgradable 2>/dev/null || yum check-update'

# View fail2ban logs
fail2ban-logs server_ip="":
    #!/usr/bin/env bash
    if [ -z "{{server_ip}}" ]; then
        echo "Usage: just fail2ban-logs <server_ip>"
        exit 1
    fi
    echo "Viewing fail2ban logs on {{server_ip}}..."
    ssh -i ~/.ssh/bitlaunch root@{{server_ip}} 'tail -50 /var/log/fail2ban.log'

# Unban IP from fail2ban
unban-ip server_ip="" ip="":
    #!/usr/bin/env bash
    if [ -z "{{server_ip}}" ] || [ -z "{{ip}}" ]; then
        echo "Usage: just unban-ip <server_ip> <ip_address>"
        exit 1
    fi
    echo "Unbanning {{ip}} on {{server_ip}}..."
    ssh -i ~/.ssh/bitlaunch root@{{server_ip}} "fail2ban-client unban {{ip}}"

# View system security logs
security-logs server_ip="":
    #!/usr/bin/env bash
    if [ -z "{{server_ip}}" ]; then
        echo "Usage: just security-logs <server_ip>"
        exit 1
    fi
    echo "Viewing security logs on {{server_ip}}..."
    ssh -i ~/.ssh/bitlaunch root@{{server_ip}} 'tail -50 /var/log/auth.log'

# Clean up deployment files (removes deploy.sh if it exists)
clean:
    @rm -f deploy.sh
    @echo "Cleaned up deployment files"
