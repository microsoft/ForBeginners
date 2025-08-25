# Select base Docker image
FROM mcr.microsoft.com/devcontainers/python:3.11-bullseye

# Combine system & package updates into a single run command
# Clean up apt cache to reduce image size
RUN sudo apt-get update && sudo apt-get install -y \
    gcc \
    cmake \
    pkg-config \
    libdbus-1-dev \
    libglib2.0-dev \
 && python -m pip install --upgrade pip \
 && sudo apt-get clean \
 && sudo rm -rf /var/lib/apt/lists/*

# Copy requirements.txt and install the Python packages
COPY requirements.txt .

# Install key packages in one layer to reduce image size and build time
RUN pip install -r requirements.txt \    
    && pip install keyrings.alt dbus-python ipython ipykernel mkdocs-material

# Configure the IPython kernel
RUN ipython kernel install --name "python3" --user

# Install daily version of azd for latest changes
# See: https://github.com/Azure/azure-dev/tree/main/cli/installer#download-from-daily-builds
# NOTE: This command fails in dev container - but azd latest installed by feature
# RUN curl -fsSL https://aka.ms/install-azd.sh | bash -s -- --version daily

# ------------ Dev Container configuration -----------------
# Adapted from https://github.com/Azure-Samples/contoso-chat