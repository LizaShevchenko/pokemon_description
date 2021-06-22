# usage: 
#   build: docker build -t pokemon .
#   run: docker run -p 8080:8080 pokemon

FROM perl:5.34.0
COPY src/cpanfile cpanfile
RUN cpanm --installdeps --notest .
COPY ./src .
RUN prove t
CMD ["./pokemon.pl", "daemon", "-m",  "production", "-l", "http://*:8080"]
