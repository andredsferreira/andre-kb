# syntax=docker/dockerfile:1
ARG NUMBER="2"        # global default

FROM alpine AS base

FROM base AS build
ARG NUMBER            # ← inherit from global, no need to repeat the value
RUN echo $NUMBER5
