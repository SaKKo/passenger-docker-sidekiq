FROM phusion/passenger-full:latest
MAINTAINER SaKKo "saklism@gmail.com"
ENV HOME /root
CMD ["/sbin/my_init"]
EXPOSE 80
# RUN apt-get install libpq-dev tmux vim

RUN mkdir -p /tmp
WORKDIR /tmp
ADD Gemfile Gemfile.lock ./
RUN chown -R app.app /tmp && gem install bundler && bundle install --jobs 40 --retry 10
RUN rm -f /etc/service/nginx/down && rm /etc/nginx/sites-enabled/default
RUN rm -f /etc/service/redis/down

RUN mkdir /etc/service/sidekiq
ADD docker_configs/sidekiq.sh /etc/service/sidekiq/run

ADD docker_configs/webapp.conf /etc/nginx/sites-enabled/webapp.conf
ADD docker_configs/secret_key.conf /etc/nginx/main.d/secret_key.conf
ADD docker_configs/gzip_max.conf /etc/nginx/conf.d/gzip_max.conf
ADD docker_configs/postgres-env.conf /etc/nginx/main.d/postgres-env.conf


RUN mkdir -p /home/app/webapp
WORKDIR /home/app/webapp
ADD . ./
ADD docker_configs/database.yml /home/app/webapp/config/database.yml
ADD docker_configs/sidekiq.yml /home/app/webapp/config/sidekiq.yml
ADD docker_configs/production.yml /home/app/webapp/config/settings/production.yml
RUN chown -R app:app /home/app/webapp && setuser app rake assets:clobber RAILS_ENV=production && setuser app rake assets:precompile RAILS_ENV=production

RUN mkdir -p /home/app/webapp/log && touch /home/app/webapp/log/production.log && chown -R app:app /home/app/webapp/log && chmod 0664 /home/app/webapp/log/production.log

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
