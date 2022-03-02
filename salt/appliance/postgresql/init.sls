include:
  - docker
  - systemd.reload
  - appliance.directories

/usr/local/share/appliance/prepare-postgresql.sh:
  file.managed:
    - source: salt://appliance/postgresql/prepare-postgresql.sh
    - require:
      - sls: appliance.directories

postgresql:
  pkg.installed:
    - pkgs:
      - postgresql
      - postgresql-contrib
  service.running:
    - enable: true
    - require:
      - pkg: postgresql
      - sls: docker
      - file: /etc/postgresql/12/main/pg_hba.conf
    - watch:
      - file: /etc/postgresql/12/main/pg_hba.conf

/etc/systemd/system/postgresql@12-main.service.d/override.conf:
  file.managed:
    - source: salt://appliance/postgresql/postgresql-override.conf

/etc/postgresql/12/main/pg_hba.conf:
  file.replace:
    - pattern: |
        ^host.*{{ salt['pillar.get']('docker:net') }}.*
    - repl: |
        host     all             app             {{ salt['pillar.get']('docker:net') }}           md5
    - append_if_not_found: true
    - require:
      - pkg: postgresql

/etc/postgresql/12/main/ecs.conf.template:
  file.managed:
    - source: salt://appliance/postgresql/ecs.conf.template

{% for p,r in [
  ("listen_addresses", "listen_addresses = '" + salt['pillar.get']('docker:ip') + "'"),
  ("shared_preload_libraries", "shared_preload_libraries = 'pg_stat_statements'"),
  ("pg_stat_statements.track", "pg_stat_statements.track = all")
  ] %}

/etc/postgresql/12/main/postgresql.conf_{{ p }}:
  file.replace:
    - name: /etc/postgresql/12/main/postgresql.conf
    - pattern: |
        ^.*{{ p }}.*
    - repl: |
        {{ r }}
    - append_if_not_found: true
    - require:
      - pkg: postgresql
    - watch_in:
      - service: postgresql
    - require_in:
      - service: postgresql
{% endfor %}
