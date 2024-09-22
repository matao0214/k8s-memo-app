FROM ruby:3.2.2

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

WORKDIR /api

COPY Gemfile Gemfile.lock /api/

RUN bundle install

COPY . /api/
