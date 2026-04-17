# syntax=docker/dockerfile:1.7

FROM ruby:3.3-alpine AS builder

ENV BUNDLE_RETRY=5 \
    BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_NO_CACHE=1

RUN apk add --no-cache build-base git yaml-dev

WORKDIR /gem

COPY Gemfile shadcn-rb.gemspec ./
COPY lib/shadcn-rb.rb ./lib/shadcn-rb.rb
RUN bundle install && \
    find /usr/local/bundle -name "*.o" -delete && \
    find /usr/local/bundle -name "*.c" -delete && \
    find /usr/local/bundle -type d -name .git -prune -exec rm -rf {} + && \
    rm -rf /usr/local/bundle/cache

FROM ruby:3.3-alpine AS development

ENV RUBY_YJIT_ENABLE=1 \
    BUNDLE_RETRY=5 \
    BUNDLE_SILENCE_ROOT_WARNING=1

RUN apk add --no-cache git tzdata libstdc++ && \
    git config --system --add safe.directory '*'

COPY --from=builder /usr/local/bundle /usr/local/bundle

WORKDIR /gem

CMD ["sh"]
