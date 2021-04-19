FROM chph/alpine-fio:v1.0.0

VOLUME /tmp
WORKDIR /tmp
COPY ./perfraw-json.sh /
RUN chmod +x /perfraw-json.sh

ENTRYPOINT ["/perfraw-json.sh"]
CMD ["fio"]
