FROM nginx:alpine

WORKDIR /usr/share/nginx

RUN rm html/50x.html

COPY conf.d/default.conf /etc/nginx/conf.d

COPY init.sh .

EXPOSE 80

ENTRYPOINT ["./init.sh"]