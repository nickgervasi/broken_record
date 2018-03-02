FROM ruby:2.3.1

RUN mkdir /broken-record
WORKDIR /broken-record

ADD . /broken-record

RUN bundle install
