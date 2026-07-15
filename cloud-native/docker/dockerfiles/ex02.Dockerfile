# syntax=docker/dockerfile:1
FROM alpine AS base

ARG NUMBER="2"


FROM base AS build
RUN echo $NUMBER