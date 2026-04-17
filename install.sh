#!/bin/bash
# Awesome-Bear Linux/macOS Installation Script
# Run with: chmod +x install.sh && sudo ./install.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║            🐻 AWESOME-BEAR INSTALLATION SCRIPT               ║"
echo "║                     Cybersecurity Tool                       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}⚠️  Warning: Not running as root. Some features may be limited.${NC}"
    echo -e "${YELLOW}   Run with sudo for full functionality.${NC}"
    echo ""
fi

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            OS="debian"
        elif [ -f /etc/redhat-release ]; then
            OS="redhat"
        elif [ -f /etc/arch-release ]; then
            OS="arch"
        else
            OS="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        OS="unknown"
    fi
    echo -e "${GREEN}✅ Detected OS: $OS${NC}"
}

# Install Python dependencies
install_python_deps() {
    echo -e "${BLUE}📦 Installing Python dependencies...${NC}"
    
    # Check Python version
    python_version=$(python3 --version 2>&1 | grep -Po '(?<=Python )\d+\.\d+')
    if [[ $(echo "$python_version < 3.7" | bc) -eq 1 ]]; then
        echo -e "${RED}❌ Python 3.7+ required. Current: $python_version${NC}"
        exit 1
    fi
    
    # Install pip if not present
    if ! command -v pip3 &> /dev/null; then
        echo -e "${YELLOW}📦 Installing pip3...${NC}"
        if [[ "$OS" == "debian" ]]; then
            apt-get update && apt-get install -y python3-pip
        elif [[ "$OS" == "macos" ]]; then
            python3 -m ensurepip --upgrade
        fi
    fi
    
    # Upgrade pip
    pip3 install --upgrade pip
    
    # Install requirements
    if [ -f "requirements.txt" ]; then
        pip3 install -r requirements.txt
    else
        echo -e "${RED}❌ requirements.txt not found!${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Python dependencies installed${NC}"
}

# Install system dependencies
install_system_deps() {
    echo -e "${BLUE}🔧 Installing system dependencies...${NC}"
    
    case "$OS" in
        debian)
            apt-get update
            apt-get install -y \
                nmap \
                nikto \
                traceroute \
                dnsutils \
                net-tools \
                iputils-ping \
                curl \
                wget \
                openssh-client \
                iptables \
                chromium-browser \
                chromium-driver \
                python3-pip \
                python3-venv \
                git
            ;;
        redhat)
            yum install -y epel-release
            yum install -y \
                nmap \
                nikto \
                traceroute \
                bind-utils \
                net-tools \
                iputils \
                curl \
                wget \
                openssh-clients \
                iptables \
                chromium \
                chromedriver \
                python3-pip \
                git
            ;;
        arch)
            pacman -Syu --noconfirm
            pacman -S --noconfirm \
                nmap \
                nikto \
                traceroute \
                dnsutils \
                net-tools \
                iputils \
                curl \
                wget \
                openssh \
                iptables \
                chromium \
                chromedriver \
                python-pip \
                git
            ;;
        macos)
            if ! command -v brew &> /dev/null; then
                echo -e "${YELLOW}🍺 Installing Homebrew...${NC}"
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew install \
                nmap \
                nikto \
                traceroute \
                bind \
                net-tools \
                curl \
                wget \
                openssh \
                chromedriver \
                python@3.11 \
                git
            ;;
        *)
            echo -e "${YELLOW}⚠️  Unknown OS. Skipping system dependencies.${NC}"
            echo -e "${YELLOW}   Please install manually: nmap, nikto, traceroute, dig, curl${NC}"
            ;;
    esac
    
    echo -e "${GREEN}✅ System dependencies installed${NC}"
}

# Create directory structure
create_directories() {
    echo -e "${BLUE}📁 Creating directory structure...${NC}"
    
    mkdir -p ~/.awesomebear
    mkdir -p ~/.awesomebear/payloads
    mkdir -p ~/.awesomebear/workspaces
    mkdir -p ~/.awesomebear/scans
    mkdir -p ~/.awesomebear/nikto_results
    mkdir -p ~/.awesomebear/whatsapp_session
    mkdir -p ~/.awesomebear/phishing_pages
    mkdir -p ~/.awesomebear/traffic_logs
    mkdir -p ~/.awesomebear/phishing_templates
    mkdir -p ~/.awesomebear/captured_credentials
    mkdir -p ~/.awesomebear/ssh_keys
    mkdir -p ~/.awesomebear/ssh_logs
    mkdir -p ~/.awesomebear/time_history
    mkdir -p ~/.awesomebear/wordlists
    mkdir -p ~/.awesomebear/custom_phishing
    
    chmod -R 755 ~/.awesomebear
    
    echo -e "${GREEN}✅ Directories created${NC}"
}

# Create configuration
create_config() {
    echo -e "${BLUE}⚙️  Creating default configuration...${NC}"
    
    cat > ~/.awesomebear/config.json << 'EOF'
{
    "monitoring": {
        "enabled": true,
        "port_scan_threshold": 10
    },
    "scanning": {
        "default_ports": "1-1000",
        "timeout": 30
    },
    "security": {
        "auto_block": false,
        "log_level": "INFO"
    },
    "nikto": {
        "enabled": true,
        "timeout": 300
    },
    "traffic_generation": {
        "enabled": true,
        "max_duration": 300,
        "allow_floods": false
    },
    "social_engineering": {
        "enabled": true,
        "default_port": 8080,
        "capture_credentials": true
    },
    "ssh": {
        "enabled": true,
        "default_timeout": 30,
        "max_connections": 5
    }
}
EOF
    
    echo -e "${GREEN}✅ Configuration created${NC}"
}

# Create desktop entry (Linux)
create_desktop_entry() {
    if [[ "$OS" == "debian" ]] || [[ "$OS" == "redhat" ]]; then
        echo -e "${BLUE}🖥️  Creating desktop entry...${NC}"
        
        cat > /usr/share/applications/awesomebear.desktop << EOF
[Desktop Entry]
Name=Awesome-Bear
Comment=Cybersecurity Command Center
Exec=x-terminal-emulator -e "python3 $(pwd)/awesomebear.py"
Icon=utilities-terminal
Terminal=true
Type=Application
Categories=Network;Security;
Keywords=cybersecurity;security;network;
EOF
        
        chmod +x /usr/share/applications/awesomebear.desktop
        echo -e "${GREEN}✅ Desktop entry created${NC}"
    fi
}

# Create alias
create_alias() {
    echo -e "${BLUE}🔗 Creating shell alias...${NC}"
    
    SHELL_CONFIG=""
    if [ -f "$HOME/.bashrc" ]; then
        SHELL_CONFIG="$HOME/.bashrc"
    elif [ -f "$HOME/.zshrc" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    fi
    
    if [ -n "$SHELL_CONFIG" ]; then
        echo "alias awesomebear='python3 $(pwd)/awesomebear.py'" >> "$SHELL_CONFIG"
        echo "alias ab='python3 $(pwd)/awesomebear.py'" >> "$SHELL_CONFIG"
        echo -e "${GREEN}✅ Aliases added to $SHELL_CONFIG${NC}"
        echo -e "${YELLOW}   Run 'source $SHELL_CONFIG' to use aliases${NC}"
    fi
}

# Create service file (systemd)
create_service() {
    if command -v systemctl &> /dev/null; then
        echo -e "${BLUE}🛠️  Creating systemd service...${NC}"
        
        cat > /etc/systemd/system/awesomebear.service << EOF
[Unit]
Description=Awesome-Bear Cybersecurity Tool
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$(pwd)
ExecStart=/usr/bin/python3 $(pwd)/awesomebear.py
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
        
        systemctl daemon-reload
        echo -e "${GREEN}✅ Systemd service created${NC}"
        echo -e "${YELLOW}   Run 'sudo systemctl enable awesomebear' to start on boot${NC}"
        echo -e "${YELLOW}   Run 'sudo systemctl start awesomebear' to start now${NC}"
    fi
}

# Main installation
main() {
    detect_os
    install_system_deps
    install_python_deps
    create_directories
    create_config
    
    # Copy main script if not already in current directory
    if [ ! -f "awesomebear.py" ]; then
        echo -e "${RED}❌ awesomebear.py not found in current directory!${NC}"
        echo -e "${YELLOW}   Please copy awesomebear.py to $(pwd) and run again${NC}"
        exit 1
    fi
    
    # Make script executable
    chmod +x awesomebear.py
    
    create_desktop_entry
    create_alias
    create_service
    
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ AWESOME-BEAR INSTALLATION COMPLETE!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}🚀 Quick Start:${NC}"
    echo -e "   python3 awesomebear.py"
    echo -e "   or"
    echo -e "   awesomebear (after sourcing shell config)"
    echo ""
    echo -e "${CYAN}🌐 Web Interface:${NC}"
    echo -e "   http://localhost:8080"
    echo ""
    echo -e "${CYAN}📁 Configuration Directory:${NC}"
    echo -e "   ~/.awesomebear/"
    echo ""
    echo -e "${CYAN}📝 Log File:${NC}"
    echo -e "   ~/.awesomebear/awesomebear.log"
    echo ""
    echo -e "${YELLOW}⚠️  For full functionality, run with sudo:${NC}"
    echo -e "   sudo python3 awesomebear.py"
    echo ""
}

# Run main installation
main