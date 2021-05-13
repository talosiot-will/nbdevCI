# syntax=docker/dockerfile:1.2

FROM python:3.8.10-buster

ADD install_requirements /install_requirements
RUN ["chmod", "+x", "/install_requirements"]
RUN /install_requirements

ADD entrypoint.sh /entrypoint.sh
RUN ["chmod", "+x", "/entrypoint.sh"]

ENTRYPOINT ["/entrypoint.sh"]
