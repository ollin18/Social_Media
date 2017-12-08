from ollin18/senate_base

MAINTAINER Ollin Demian Langle Chimal <ollin.langle@ciencias.unam.mx>

ENV REFRESHED_AT 2017-12-05

RUN julia -E 'Pkg.add("ArgParse")'
RUN julia -E "using ArgParse"

COPY src/ src/

WORKDIR src

CMD ["./scrap_all.sh"]
