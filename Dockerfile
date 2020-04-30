FROM ruby:2.6.0

WORKDIR /tmp
ADD Gemfile* ./

RUN bundle install --jobs=20

ENV APP_HOME /app
COPY . $APP_HOME
WORKDIR $APP_HOME

ENV RAILS_ENV=production \
    RACK_ENV=production \
    PORT=3000

EXPOSE $PORT

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]