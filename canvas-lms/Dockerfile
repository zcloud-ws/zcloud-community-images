FROM ruby:3.4

ARG CANVAS_VERSION=release/2025-12-03.205

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    RAILS_ENV=production \
    NODE_ENV=production

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        zlib1g-dev \
        libxml2-dev \
        libsqlite3-dev \
        libpq-dev \
        libxmlsec1-dev \
        libyaml-dev \
        libidn11-dev \
        libicu-dev \
        locales \
        curl \
        make \
        g++ \
        python3-pygments \
        git \
        nginx \
        tzdata \
        shared-mime-info \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g \
    yarn@1.22.22 \
    npm@10.8.2

RUN groupadd -r canvaslms \
    && useradd -r -g canvaslms -d /home/canvaslms -s /bin/bash canvaslms \
    && install -d -o canvaslms -g canvaslms /home/canvaslms \
    && install -d -o canvaslms -g canvaslms /opt/canvas

USER canvaslms

RUN git clone --depth 1 --branch "${CANVAS_VERSION}" https://github.com/instructure/canvas-lms.git /opt/canvas
WORKDIR /opt/canvas

RUN gem install bundler \
    && bundle config set --local path vendor/bundle \
    && bundle install

RUN NODE_ENV=development yarn install --frozen-lockfile --network-timeout 100000 \
    && yarn add @babel/runtime-corejs3 -W \
    && yarn add @babel/runtime-corejs3 --dev --ignore-workspace-root-check \
    && yarn add -D \
        gulp@4.0.2 \
        gulp-cli@2.3.0 \
        gulp-load-plugins@1.6.0 \
        gulp-rename@1.4.0 \
        gulp-rev@7.1.0 \
        gulp-rev-replace@0.4.4 \
        gulp-filter@5.1.0 \
        gulp-concat@2.6.1 \
        gulp-uglify@3.0.2 \
        gulp-sourcemaps@2.6.5 \
        gulp-if@2.0.2 \
        gulp-util@3.0.8 \
        gulp-clean-css@4.3.0 \
        gulp-autoprefixer@7.0.1 \
        through2@2.0.5 --ignore-workspace-root-check \
    && mkdir -p /opt/canvas/data /opt/canvas/log /opt/canvas/tmp/pids

USER root

COPY --chown=canvaslms:canvaslms config/production.rb /opt/canvas/config/environments/production.rb
COPY --chown=canvaslms:canvaslms config/puma.rb /opt/canvas/config/puma.rb

COPY entrypoint.sh /usr/local/bin/

RUN rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default \
    && mkdir -p /opt/canvas/log /opt/canvas/tmp \
    && chown -R canvaslms:canvaslms /opt/canvas/log /opt/canvas/tmp \
    && chmod +x /usr/local/bin/entrypoint.sh

COPY ./config/nginx/nginxconfig.io /etc/nginx/nginxconfig.io
COPY config/nginx/sites-enabled /etc/nginx/sites-enabled
COPY config/nginx/sites-enabled /etc/nginx/sites-available
COPY ./config/nginx/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["app:start"]
