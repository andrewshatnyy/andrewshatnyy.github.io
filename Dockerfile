FROM ruby:2.2.2
RUN apt-get update -qq
RUN apt-get install -y build-essential
RUN apt-get install -y nodejs

ADD Gemfile* /tmp/
WORKDIR /tmp
RUN bundle install

VOLUME ["/var/www"]
WORKDIR /var/www

EXPOSE 4000