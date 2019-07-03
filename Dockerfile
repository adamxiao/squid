FROM alpine:latest
MAINTAINER adamxiao <iefcuxy@gmail.com>
ADD start-squid.sh /start-squid.sh
ADD ./files /files                                                                                    
RUN apk add --no-cache squid curl ruby && \
        chown -R squid:squid /var/cache/squid && \
        chown -R squid:squid /var/log/squid && \
        chmod +x /start-squid.sh && \
        mv /files/squid/* /etc/squid/ && \
        chmod +x /etc/squid/url_rewriter.rb && \
        squid -z && \
        /usr/lib/squid/security_file_certgen -c -s /var/cache/squid/ssl_db -M 4MB && \
        chown -R squid:squid /var/cache/squid/ssl_db
EXPOSE 3128
#ENTRYPOINT ["/usr/sbin/squid","-NYCd","1"]
ENTRYPOINT ["/start-squid.sh"]
