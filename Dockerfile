FROM golang:alpine
MAINTAINER "kainlite <kainlite@gmail.com>"

ARG TERRAFORM_VERSION=0.12.7
ENV TERRAFORM_VERSION=$TERRAFORM_VERSION

RUN apk --no-cache add curl git unzip gcc g++ make ca-certificates && \
    curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

RUN mkdir tmp && \
    curl "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o tmp/terraform.zip && \
    unzip tmp/terraform.zip -d /usr/local/bin && \
    rm -rf tmp/

ARG GOPROJECTPATH=/go/src/github.com/kainlite/serverless-cognito
COPY ./ $GOPROJECTPATH

WORKDIR $GOPROJECTPATH/test

RUN dep ensure -v

CMD ["go", "test", " -timeout", "90m", "."]
