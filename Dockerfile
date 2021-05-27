# Copyright (c) 2021 Oracle and/or its affiliates.

FROM ruby:3.0.1-alpine3.13

COPY license_check.rb /license_check.rb

ENTRYPOINT ["ruby", "/license_check.rb"]