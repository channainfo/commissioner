# Base image using Ruby 3.2.0
FROM ruby:3.2.0

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  vim \
  libpq-dev \
  nodejs \
  yarn \
  git \
  curl

# Clean cache and temp files, fix permissions
RUN apt-get clean -qy \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


RUN bundle config --local deployment true && \
  bundle config --local path "vendor/bundle"

RUN gem install bundler -v 2.4.5

WORKDIR /gem

COPY Gemfile Gemfile.lock *.gemspec ./
COPY lib/ ./lib/

RUN bundle install --jobs 12 --retry 3

COPY . .

CMD ["bundle", "exec", "rake"]

# docker build -t central-market-comissioner_web .
# docker run -e DATABASE_URL=postgres://postgres:@192.168.1.136:5432/spree_cm_commissioner_spree_test -e RAILS_ENV=test -it central-market-comissioner_web bash