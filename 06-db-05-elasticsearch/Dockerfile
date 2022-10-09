FROM docker.elastic.co/elasticsearch/elasticsearch:7.17.6
COPY --chown=elasticsearch:elasticsearch ./container-elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
RUN mkdir -p /var/lib/elasticsearch/data
RUN mkdir -p /var/lib/elasticsearch/snapshots
RUN chmod -R 777 /var/lib/elasticsearch
RUN chown -R 1000:0 /var/lib/elasticsearch

