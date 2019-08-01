FROM ruby:2.5-slim

RUN apt-get update -qq && apt-get install -y build-essential sqlite3 libsqlite3-dev

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN gem update bundler
RUN bundle install

ADD . $APP_HOME

EXPOSE 80
CMD ["bundle", "exec", "rackup", "config.ru", "-p", "80","-o", "0.0.0.0"]