#Dockerfile for RHQ-ready Postgresql service
#See also https://index.docker.io/u/gkhachik/rhq-fedora.20/

FROM fedora:20

MAINTAINER Viet Nguyen <vnguyen@redhat.com>

RUN yum -y install postgresql-server

# Init postgres service; Start postgres service, create rhqadmin role and rhq db
RUN \
  su -l postgres -c "/usr/bin/initdb -D '/var/lib/pgsql/data' --auth='ident'" >> /var/lib/pgsql/initdb.log 2>&1 < /dev/null;\
  sed -i 's/ident/trust/g'  /var/lib/pgsql/data/pg_hba.conf;\
  su -l postgres -c "pg_ctl -l server.log -w -D /var/lib/pgsql/data start";\
  psql -h 127.0.0.1 -p 5432 -U postgres --command="CREATE USER rhqadmin WITH password 'rhqadmin'";\
  createdb -h 127.0.0.1 -p 5432 -U postgres -O rhqadmin rhq;\
  echo "listen_addresses='*'" >> /var/lib/pgsql/data/postgresql.conf;\
  su -l postgres -c "pg_ctl -l server.log -w -D /var/lib/pgsql/data stop"

EXPOSE 5432

ENTRYPOINT su -l postgres -c "pg_ctl -l server.log -w -D /var/lib/pgsql/data start; tail -F server.log"
