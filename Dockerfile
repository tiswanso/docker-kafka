FROM alpine:latest AS kafka_dist

ARG scala_version=2.13
ARG kafka_version=3.1.0
ARG kafka_distro_base_url=https://dlcdn.apache.org/kafka

ENV kafka_distro=kafka_$scala_version-$kafka_version.tgz
ENV kafka_distro_asc=$kafka_distro.asc

RUN apk add --no-cache gnupg

WORKDIR /var/tmp

RUN wget -q $kafka_distro_base_url/$kafka_version/$kafka_distro
RUN wget -q $kafka_distro_base_url/$kafka_version/$kafka_distro_asc
RUN wget -q $kafka_distro_base_url/KEYS

RUN gpg --import KEYS
RUN gpg --verify $kafka_distro_asc $kafka_distro

RUN tar -xzf $kafka_distro 
RUN rm -r kafka_$scala_version-$kafka_version/bin/windows


FROM eclipse-temurin:17.0.3_7-jre

ARG scala_version=2.13
ARG kafka_version=3.1.0

ENV KAFKA_VERSION=$kafka_version \
    SCALA_VERSION=$scala_version \
    KAFKA_HOME=/opt/kafka

ENV PATH=${PATH}:${KAFKA_HOME}/bin

RUN mkdir ${KAFKA_HOME} && apt-get update && apt-get install curl -y && apt-get clean

COPY --from=kafka_dist /var/tmp/kafka_$scala_version-$kafka_version ${KAFKA_HOME}

RUN chmod a+x ${KAFKA_HOME}/bin/*.sh

CMD ["kafka-server-start.sh"]
