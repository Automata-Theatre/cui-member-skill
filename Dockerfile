FROM pytorch/pytorch:2.3.1-cuda12.1-cudnn8-runtime

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ffmpeg \
    git \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# Create workspace
WORKDIR /workspace

# Install and upgrade yt-dlp with JavaScript challenge solver
RUN pip install --upgrade yt-dlp pyarmor
ENV PATH="/root/.local/bin:${PATH}"

ENTRYPOINT ["tail", "-f", "/dev/null"]
