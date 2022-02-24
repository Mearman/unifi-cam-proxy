ARG VARIANT="3.8"
FROM mcr.microsoft.com/vscode/devcontainers/python:dev-${VARIANT}-buster

WORKDIR /app

RUN apt update 
RUN apt upgrade -y
RUN apt install -y ffmpeg 
RUN apt install -y netcat-openbsd

COPY . .
RUN pip install .