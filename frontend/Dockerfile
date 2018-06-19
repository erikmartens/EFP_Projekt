FROM nginx:alpine

WORKDIR /usr/share/nginx

RUN rm html/50x.html

COPY css html/css
COPY efp-frontend.js html/
COPY index.html html/
COPY init.sh .

COPY conf.d/default.conf /etc/nginx/conf.d

EXPOSE 80

ENTRYPOINT ["./init.sh"]