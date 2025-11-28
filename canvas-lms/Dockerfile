# Canvas LMS Docker Image

FROM ruby:3.4-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    NODE_VERSION=20.18.0 \
    NVM_DIR=/usr/local/nvm

# Install build dependencies
RUN apt-get update && apt-get install -y zlib1g-dev \
    libxml2-dev \
    libsqlite3-dev \
    libpq-dev \
    libxmlsec1-dev \
    libyaml-dev \
    libidn11-dev \
    curl \
    make \
    g++ \
    git \
    shared-mime-info \
    && rm -rf /var/lib/apt/lists/*

# Add Node and npm to path
ENV NODE_PATH=$NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules \
    PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Install NVM and Node.js
RUN mkdir -p $NVM_DIR \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default \
    && npm install -g npm@latest \
    && npm -g install yarn

# Install bundler
RUN gem install bundler

# Create canvas user
RUN useradd -m -s /bin/bash canvas

# Set working directory
WORKDIR /opt/canvas

# Clone Canvas LMS
ARG CANVAS_VERSION=release/2025-12-03.205
RUN git clone --depth 1 --branch ${CANVAS_VERSION} https://github.com/instructure/canvas-lms.git . \
    && chown -R canvas:canvas /opt/canvas

# Install Ruby dependencies
RUN bundle config set --local path 'vendor/bundle' \
    && bundle config set --local without 'development test' \
    && bundle install --jobs 4

# Install Node dependencies
RUN yarn install --frozen-lockfile --production
#
## Final stage - runtime
#FROM ruby:3.4.1-slim
#
## Set environment variables
#ENV DEBIAN_FRONTEND=noninteractive \
#    RAILS_ENV=production \
#    NODE_ENV=production \
#    NODE_VERSION=20.18.0 \
#    NVM_DIR=/usr/local/nvm
#
## Install only runtime dependencies
#RUN apt-get update && apt-get install -y \
#    libssl3 \
#    libreadline8 \
#    zlib1g \
#    libxml2 \
#    libsqlite3-0 \
#    libxmlsec1 \
#    libxmlsec1-openssl \
#    libcurl4 \
#    libpq5 \
#    libyaml-0-2 \
#    libidn12 \
#    postgresql-client \
#    curl \
#    git \
#    python3 \
#    ca-certificates \
#    tzdata \
#    && rm -rf /var/lib/apt/lists/*
#
## Copy NVM and Node.js from builder
#COPY --from=builder $NVM_DIR $NVM_DIR
#
## Add Node and npm to path
#ENV NODE_PATH=$NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules \
#    PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
#
## Copy bundler gem from builder
#COPY --from=builder /usr/local/bundle /usr/local/bundle
#
## Create canvas user
#RUN useradd -m -s /bin/bash canvas
#
## Create necessary directories
#RUN mkdir -p /opt/canvas/data /opt/canvas/log /opt/canvas/tmp/pids \
#    && chown -R canvas:canvas /opt/canvas
#
## Set working directory
#WORKDIR /opt/canvas
#
## Copy Canvas application from builder
#COPY --from=builder --chown=canvas:canvas /opt/canvas /opt/canvas
#
## Create config directory
#RUN mkdir -p /opt/canvas/config
#
# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose port
EXPOSE 3000

# Volume for persistence
VOLUME ["/opt/canvas/data"]

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Default command
CMD ["app:start"]
