include:
  - python
  - systemd.reload

# add docker options to etc/default config, add http_proxy if set
{%- if grains['virtual']|upper in ['LXC', 'SYSTEMD-NSPAWN', 'NSPAWN'] %}
  # use vfs storage driver and systemd cgroup if running under same kernel virt
  {% set options='--bridge=docker0 --storage-driver=vfs --exec-opt native.cgroupdriver=systemd --log-driver=journald' %}
{% else %}
  {% set options='--bridge=docker0 --storage-driver=overlay2' %}
{% endif %}
/etc/default/docker:
  file.managed:
    - contents: |
        DOCKER_OPTIONS="{{ options }}"
{%- if salt['pillar.get']('http_proxy', '') != '' %}
  {%- for a in ['http_proxy', 'HTTP_PROXY'] %}
        {{ a }}="{{ salt['pillar.get']('http_proxy') }}"
  {%- endfor %}
{%- endif %}

# etc-network-interfaces:
#   file.touch:
#     - name: /etc/network/interfaces

# docker-network:
#   file.blockreplace:
#     - name: /etc/network/interfaces
#     - marker_start: |
#         auto docker0
#     - marker_end: |
#             bridge_stp off
#     - append_if_not_found: true
#     - content: |
#         iface docker0 inet static
#             address {{ salt['pillar.get']('docker:ip') }}
#             netmask {{ salt['pillar.get']('docker:netmask') }}
#             bridge_fd 0
#             bridge_maxwait 0
#             bridge_ports none
#     - require:
#       - file: etc-network-interfaces
#       - pkg: docker-requisites
#   cmd.run:
#     - name: ifup docker0
#     - onchanges:
#       - file: docker-network

docker:
  cmd.run:
    - name: sh -c "$(curl -fsSL https://get.docker.com)"
    - onlyif: if [[ -z "$(which docker)" ]]; then exit 0; else exit 1; fi

docker-compose:
  cmd.run:
    - name: |
        curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    - onlyif: if [[ -z "$(which docker-compose)" ]]; then exit 0; else exit 1; fi
