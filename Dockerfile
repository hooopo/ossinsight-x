# Use an Ubuntu-based Ruby image
FROM ruby:3.2-buster

# Set the working directory
WORKDIR /

# Install MySQL client and development libraries
RUN apt-get update -qq && \
    apt-get install -y default-mysql-client default-libmysqlclient-dev ca-certificates

# Set argument variables
ARG CONSUMER_KEY
ARG CONSUMER_SECRET
ARG ACCESS_TOKEN
ARG ACCESS_TOKEN_SECRET
ARG OPENAI_ACCESS_TOKEN

# Set environment variables
ENV CONSUMER_KEY=$CONSUMER_KEY
ENV CONSUMER_SECRET=$CONSUMER_SECRET
ENV ACCESS_TOKEN=$ACCESS_TOKEN
ENV ACCESS_TOKEN_SECRET=$ACCESS_TOKEN_SECRET
ENV OPENAI_ACCESS_TOKEN=$OPENAI_ACCESS_TOKEN

# Copy the Gemfile and Gemfile.lock
COPY . .

# Install dependencies
RUN bundle config set --local without 'development test' && \
    bundle install --jobs $(nproc) --retry 3 && \
    rm -rf /usr/local/bundle/cache/*.gem

# Run the migration and sync GitHub Repo Data scripts
CMD ls && pwd && ruby main.rb