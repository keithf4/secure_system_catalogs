EXTENSION = secure_system_catalogs
EXTVERSION = $(shell grep default_version $(EXTENSION).control | \
               sed -e "s/default_version[[:space:]]*=[[:space:]]*'\([^']*\)'/\1/")
               
DATA = $(filter-out $(wildcard sql/*--*.sql),$(wildcard sql/*.sql))
#DOCS = $(wildcard doc/*.md)
PG_CONFIG = pg_config
PG92 = $(shell $(PG_CONFIG) --version | egrep " 8\.| 9\.0|9\.1" > /dev/null && echo no || echo yes)

ifeq ($(PG92),yes)
all: sql/$(EXTENSION)--$(EXTVERSION).sql

sql/$(EXTENSION)--$(EXTVERSION).sql: sql/$(EXTENSION).sql
	cp $< $@

# Use this DATA when updates are available
#DATA = $(wildcard updates/*--*.sql) sql/$(EXTENSION)--$(EXTVERSION).sql
DATA = sql/$(EXTENSION)--$(EXTVERSION).sql
EXTRA_CLEAN = sql/$(EXTENSION)--$(EXTVERSION).sql
else
$(error Minimum version of PostgreSQL required is 9.2.0)
endif

PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
