# list justfile recipes
default:
    @just --list

# open jupyter lab on localhost
@lab:
    jupyter lab --ip=0.0.0.0 --allow-root
