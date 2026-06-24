#!/usr/bin/env bash
set -e
### Docker Installing Script ### 
echo "[*] Installing Docker..."
sudo pacman -S --needed --noconfirm docker

echo "[*] Enabling Docker service..."
sudo systemctl enable --now docker.service

echo "[*] Adding user to the docker group..."
sudo usermod -aG docker "$USER"

echo "[*] Creating workspace..."
mkdir -p "$HOME/docker"

echo "[*] Creating custom Dockerfile..."
cat > "$HOME/docker/Dockerfile" <<'EOF'
FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
        bash \
        git \
        curl \
        which \
        wget \
        jq \
        python \
        python-pip \
        go \
        ca-certificates \
        bind \
        gcc \
        unzip && \
        pacman -Scc --noconfirm

RUN go install github.com/ffuf/ffuf/v2@latest && \
    go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest && \
    go install github.com/projectdiscovery/httpx/cmd/httpx@latest && \
    go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest && \
    go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest && \
    go install github.com/projectdiscovery/katana/cmd/katana@latest && \
    go install github.com/lc/gau/v2/cmd/gau@latest && \
    go install github.com/tomnomnom/waybackurls@latest && \
    go install github.com/hahwul/dalfox/v2@latest

RUN git clone https://github.com/danielmiessler/SecLists.git /opt/SecLists && \
    git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git /opt/PayloadsAllTheThings   
    
RUN pip install uro
    

ENV PATH="/root/go/bin:${PATH}"

WORKDIR /work

RUN /root/go/bin/nuclei -update-templates

CMD ["/bin/bash"]
EOF

echo "[*] Building Docker image..."
cd "$HOME/docker"
docker build -t bbtools .

echo "[*] Detecting shell..."
SHELL_NAME="$(basename "$SHELL")"

case "$SHELL_NAME" in
    bash)
        RC_FILE="$HOME/.bashrc"
        ;;
    zsh)
        RC_FILE="$HOME/.zshrc"
        ;;
    *)
        echo "[!] Unsupported shell: $SHELL_NAME"
        exit 1
        ;;
esac

echo "[*] Adding alias to $RC_FILE..."
ALIAS_LINE="alias bbtools='docker run --rm -it -v \$HOME/docker:/work bbtools'"

if ! grep -Fxq "$ALIAS_LINE" "$RC_FILE" 2>/dev/null; then
    echo "$ALIAS_LINE" >> "$RC_FILE"
    echo "[+] Added alias to $RC_FILE"
else
    echo "[*] Alias already exists in $RC_FILE"
fi

echo "[+] Setup complete."
echo "[+] Log out and log back in."
