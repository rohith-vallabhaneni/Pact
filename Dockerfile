# ubuntu:14.04 -- https://hub.docker.com/_/ubuntu/
# |==> phusion/baseimage:0.9.17 -- https://goo.gl/ZLt61q
#      |==> phusion/passenger-ruby22:0.9.17 -- https://goo.gl/xsnWOP
#           |==> HERE
FROM phusion/passenger-ruby22:0.9.17

EXPOSE 80
ENV APP_HOME=/home/app/pact_broker
ENV DRP_EV_POSTGRESQL_URL=postgres://postgres:Welcome1234@54.207.30.143:5432/postgres
#ENV PACT_BROKER_DATABASE_USERNAME=postgres
#ENV PACT_BROKER_DATABASE_PASSWORD=Welcome@1234
#ENV PACT_BROKER_DATABASE_HOST=54.207.30.143
#ENV PACT_BROKER_DATABASE_NAME=postgres
ENV DRP_CF_HTTP_PORT=85
EXPOSE $DRP_CF_HTTP_PORT
CMD ["/sbin/my_init"]
RUN rm -f /etc/service/nginx/down
RUN rm /etc/nginx/sites-enabled/default
ADD container /
ADD change.sh /bin/
ADD pact_broker/config.ru $APP_HOME/
ADD pact_broker/Gemfile $APP_HOME/
ADD pact_broker/Gemfile.lock $APP_HOME/
RUN chown -R app:app $APP_HOME
ENTRYPOINT ["/bin/change.sh"]
# Update system gems for:
# https://www.ruby-lang.org/en/news/2017/08/29/multiple-vulnerabilities-in-rubygems/
RUN gem update --system
RUN gem install bundler
RUN su app -c "cd $APP_HOME && bundle install --deployment --without='development test'"
ADD pact_broker/ $APP_HOME/
RUN chown -R app:app $APP_HOME
