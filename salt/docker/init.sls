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

docker-gpg-key:
  cmd.run:
    - name:  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    - onlyif: if [ ! -f /usr/share/keyrings/docker-archive-keyring.gpg ]; then exit 0; else exit 1; fi

docker-repository:
  cmd.run:
    - name: |
        echo \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        focal stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    - onlyif: if [ ! -f /etc/apt/sources.list.d/docker.list ]; then exit 0; else exit 1; fi
    - require:
      - cmd: docker-gpg-key

docker:
  pkg.installed:
    - refresh: True
    - pkgs:
      - docker-ce
      - docker-ce-cli
      - containerd.io
    - require:
      - cmd: docker-repository

docker-compose:
  cmd.run:
    - name: |
        curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    - onlyif: if [[ -z "$(which docker-compose)" ]]; then exit 0; else exit 1; fi
