FROM registry.access.redhat.com/ubi9/python-39

LABEL maintainer="Wayne Sun <gsun@redhat.com>"

ENV NODEJS_VERSION=18

USER 0

RUN yum -y module enable nodejs:$NODEJS_VERSION && \
    MODULE_DEPS="make gcc gcc-c++ git openssl-devel" && \
    INSTALL_PKGS="$MODULE_DEPS nodejs npm nodejs-nodemon nss_wrapper" && \
    ln -s /usr/lib/node_modules/nodemon/bin/nodemon.js /usr/bin/nodemon && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    node -v | grep -qe "^v$NODEJS_VERSION\." && echo "Found VERSION $NODEJS_VERSION" && \
    yum -y clean all --enablerepo='*'

USER 1001

# Install snippet-enricher-cli npm package
RUN pip install --no-cache-dir "uvicorn[standard]" gunicorn

COPY ./start.sh ${APP_ROOT}/start.sh

COPY ./gunicorn_conf.py ${APP_ROOT}/gunicorn_conf.py

COPY ./start-reload.sh ${APP_ROOT}/start-reload.sh

USER 0
RUN chmod +x ${APP_ROOT}/start.sh ${APP_ROOT}/start-reload.sh
USER 1001

# Add npm bin in PATH
ENV PYTHONPATH=${APP_ROOT}/app \
    PATH=$HOME/node_modules/.bin/:$HOME/.npm-global/bin/:$PATH

# UBI expose 8080 for non-privileged user
EXPOSE 8080


# Run the start script, it will check for an /app/prestart.sh script (e.g. for migrations)
# And then will start Gunicorn with Uvicorn
CMD ["${APP_ROOT}/start.sh"]
