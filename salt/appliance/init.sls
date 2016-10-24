include:
  - docker
  - .dehydrated
  - .nginx
  - .backup
  # - .postgresql
  # - .postfix

{% for i in ['prepare_appliance.sh', 'prepare_ecs.sh', 'appliance_update.sh', 'ecs_update.sh'] %}
/usr/local/bin/{{ i }}:
  file.managed:
    - source: salt://appliance/{{ i }}
    - mode: "0755"
{% endfor %}

/usr/local/etc/appliance.include:
  file.managed:
    - source: salt://appliance/appliance.include

/etc/systemd/system/appliance.service:
  file.managed:
    - source: salt://appliance/appliance.service

/etc/appliance/compose:
  file.recurse:
    - source: salt://appliance/compose
    - keep_symlinks: true
