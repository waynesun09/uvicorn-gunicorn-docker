FROM registry.access.redhat.com/ubi8/python-38

LABEL maintainer="Wayne Sun <gsun@redhat.com>"

# Install snippet-enricher-cli npm package
RUN pip install --no-cache-dir "uvicorn[standard]" gunicorn && \
    npm install snippet-enricher-cli

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
