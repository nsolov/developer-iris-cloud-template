ARG IRIS_IMAGE=intersystemsdc/iris-community:2025.3
FROM ${IRIS_IMAGE}

USER root

COPY iris.cpf /tmp/iris.cpf
COPY iris.script /tmp/iris.script
COPY src /opt/app/src

RUN mkdir -p /data /usr/irissys/mgr/APP-CODE \
    && chown -R irisowner:irisowner \
        /data \
        /usr/irissys/mgr/APP-CODE \
        /opt/app \
        /tmp/iris.cpf \
        /tmp/iris.script

USER irisowner

# Configure IRIS and compile the application into the image. Application data
# is kept separately in /data, which Developer Cloud mounts as persistent storage.
RUN iris start IRIS quietly \
    && iris merge IRIS /tmp/iris.cpf \
    && iris session IRIS < /tmp/iris.script \
    && iris stop IRIS quietly \
    && rm /tmp/iris.cpf /tmp/iris.script \
    && date > "${ISC_PACKAGE_INSTALLDIR}/iris.init"

