FROM nginx:alpine

WORKDIR /usr/share/nginx

RUN rm html/50x.html

COPY conf.d/default.conf /etc/nginx/conf.d

COPY certificate.crt /etc/ssl

COPY dhparam.pem /etc/ssl

COPY privateKey.key /etc/ssl

COPY init.sh .

EXPOSE 80

EXPOSE 443

ENTRYPOINT ["./init.sh"]