default:
    @just --list

build:
    docker compose build

up:
    docker compose up -d

down:
    docker compose down

sh:
    docker compose run --rm gem sh

lint:
    docker compose run --rm gem bundle exec rubocop

lint-fix:
    docker compose run --rm gem bundle exec rubocop -A

syntax:
    docker compose run --rm gem sh -c "find lib -name '*.rb' -exec ruby -c {} +"
