FROM debian:latest

RUN apt update && apt upgrade -y
RUN apt install openssl

WORKDIR /root
COPY ssl.sh .
RUN chmod +x ssl.sh

ENV DOMAIN="example.com"

CMD ./ssl.sh $DOMAIN
