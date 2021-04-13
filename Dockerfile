FROM chph/alpine-fio:v1.0.0

VOLUME /tmp
WORKDIR /tmp
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["fio"]
