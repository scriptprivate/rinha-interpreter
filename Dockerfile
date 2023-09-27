FROM perl:5.39

WORKDIR /app

COPY . /app

RUN cpan Exporter
RUN cpan JSON
RUN cpan Data::Dumper


CMD ["perl", "main.pl"]
