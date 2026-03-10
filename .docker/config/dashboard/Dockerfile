FROM ruby:3.2-slim

WORKDIR /app

# Install build dependencies for native extensions
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile ./
RUN bundle install

COPY . .

EXPOSE 4000

CMD ["ruby", "app.rb"]
