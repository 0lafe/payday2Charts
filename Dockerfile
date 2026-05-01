# syntax=docker/dockerfile:1

FROM ruby:3.4.1

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    yarn \
    git

WORKDIR /app

# Install gems first (better caching)
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy app code
COPY . .

# Precompile assets (optional depending on setup)
RUN bundle exec rails assets:precompile

CMD ["bundle exec", "puma", "-C", "config/puma.rb"]