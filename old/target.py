#
    def backup_config(self):
        if not self.config.get('backup', default=False):
            warn('no backup configuration, skipping backup config')
        else:
            with settings(warn_only=True):
                local('sudo bash -c "if test -e /root/.gnupg; then rm -r /root/.gnupg; fi"')
            local('sudo gpg --homedir /root/.gnupg --rebuild-keydb-caches')
            local('sudo gpg --homedir /root/.gnupg --batch --yes --import {0}'.format(self.config.get_path('backup.encrypt_gpg_sec')))
            local('sudo gpg --homedir /root/.gnupg --batch --yes --import {0}'.format(self.config.get_path('backup.encrypt_gpg_pub')))

            with settings(warn_only=True):
                local('sudo mkdir -m 0600 -p /root/.duply/root')
                local('sudo mkdir -m 0600 -p /root/.duply/opt')

            self.config['duplicity.duply_path'] = self.pythonexedir

            self.config['duplicity.root'] = os.path.join(self.config['backup.hostdir'], 'root')
            self.config['duplicity.include'] = "SOURCE='/'"
            self.write_config_template('duply.template',
                '/root/.duply/root/conf', context=self.config, use_sudo=True, filemode= '0600')
            self.write_config_template('duplicity.root.files', '/root/.duply/root/exclude', use_sudo=True)

            self.config['duplicity.root'] = os.path.join(self.config['backup.hostdir'], 'opt')
            self.config['duplicity.include'] = "SOURCE='/opt'"
            self.write_config_template('duply.template',
                '/root/.duply/opt/conf', context=self.config, use_sudo=True, filemode= '0600')
            self.write_config_template('duplicity.opt.files', '/root/.duply/opt/exclude', use_sudo=True)

            self.config['duplicity.duply_conf'] = "root"
            with settings(warn_only=True): # remove legacy duply script, before it was renamed
                local('sudo bash -c "if test -f /etc/backup.d/90duply.sh; then rm /etc/backup.d/90duply.sh; fi"')
            self.write_config_template('duply-backupninja.sh',
                '/etc/backup.d/90duply-root.sh', backup=False, use_sudo=True, filemode= '0600')

            self.config['duplicity.duply_conf'] = "opt"
            with settings(warn_only=True): # remove legacy duply script, before it was renamed
                local('sudo bash -c "if test -f /etc/backup.d/91duply.sh; then rm /etc/backup.d/91duply.sh; fi"')
            self.write_config_template('duply-backupninja.sh',
                '/etc/backup.d/91duply-opt.sh', backup=False, use_sudo=True, filemode= '0600')

            self.write_config_template('10.sys',
                '/etc/backup.d/10.sys', backup=False, use_sudo=True, filemode= '0600')

            self.write_config_template('20.pgsql',
                '/etc/backup.d/20.pgsql', backup=False, use_sudo=True, filemode= '0600')


    def mail_config(self):
        '''
        with tempfile.NamedTemporaryFile() as h:
            h.write(self.config['host'])
            h.flush()
            local('sudo cp {0} /etc/mailname'.format(h.name))

        self.config['postfix.cert'] = '/etc/ssl/private/{0}.pem'.format(self.host)
        self.config['postfix.key'] = '/etc/ssl/private/{0}.key'.format(self.host)
        self.write_config_template('postfix.main.cf', '/etc/postfix/main.cf', use_sudo=True)
        self.write_config_template('postfix.master.cf', '/etc/postfix/master.cf', use_sudo=True)
        self.write_config_template('aliases', '/etc/aliases', use_sudo=True)

smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
myhostname = ecsdev.ep3.at
mydestination = ecsdev.ep3.at, localhost.ep3.at, , localhost
myorigin = /etc/mailname # $myhostname
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 %(ip)s/32
[localhost:8823]

mydestination =
local_recipient_maps =
local_transport = error:local mail delivery is disabled
myorigin = /etc/mailname # $myhostname
relay_domains = $myhostname

  myorigin = example.com
  mydestination =
  local_recipient_maps =
  local_transport = error:local mail delivery is disabled
  relay_domains = example.com
  parent_domain_matches_subdomains =
      debug_peer_list smtpd_access_maps
  smtpd_recipient_restrictions =
      permit_mynetworks reject_unauth_destination

  relay_recipient_maps = hash:/etc/postfix/relay_recipients
  transport_maps = hash:/etc/postfix/transport

/etc/postfix/transport:
$myhostname   smtp:[localhost:8823]
        '''
        pass

    def gpg_config(self):
        for key, filename in (('encrypt_key', 'ecs_mediaserver.pub'), ('signing_key', 'ecs_authority.sec'), ('decrypt_key', 'ecs_mediaserver.sec'), ('verify_key', 'ecs_authority.pub')):
            try:
                path = self.config.get_path('mediaserver.storage.%s' % key)
                shutil.copy(path, os.path.join(self.configdir, filename))
            except KeyError:
                pass


    def sysctl_config(self):
        sysctl_conf = '/etc/sysctl.d/30-ECS.conf'
        params = {
            'kernel.shmmax': '2147483648',       # 2 GB
        }
        conf = ''
        for k, v in params.iteritems():
            self.local(['sysctl', '-w', '{0}={1}'.format(k, v)])
            conf += '{0} = {1}'.format(k, v)
        conf += '\n'
        tmp_fd, tmp_name = tempfile.mkstemp()
        os.write(tmp_fd, conf)
        os.close(tmp_fd)
        cat = subprocess.list2cmdline(['cat', tmp_name])
        tee = subprocess.list2cmdline((['sudo'] if self.use_sudo else []) + ['tee', sysctl_conf])
        local('{0} | {1} > /dev/null'.format(cat, tee))
        os.remove(tmp_name)


    def postgresql_config(self):
        postgresql_conf = '/etc/postgresql/{0}/main/postgresql.conf'.format(self.postgresql_version())
        _marker = '# === ECS config below: do not edit, autogenerated ==='
        conf = ''
        self.local(['cp', postgresql_conf, postgresql_conf + '.bak'])
        with open(postgresql_conf, 'r') as f:
            for line in f:
                if line.strip('\n') == _marker:
                    break
                conf += line
        conf += '\n'.join([
            _marker,
            '# manual tuned settings: 1.10.2014 (similar to pgtune -i postgresql.conf -M 4294967296 -c 40 -T Web)',
            'wal_sync_method = fdatasync',
            'max_connections = 40',
            'maintenance_work_mem = 192MB',
            'effective_cache_size = 2304MB',
            'work_mem = 64MB',
            'wal_buffers = 4MB',
            'shared_buffers = 768MB',
            'checkpoint_segments = 8',
            'checkpoint_completion_target = 0.7',
            '# track long running queries',
            'track_activity_query_size = 4096',
            'log_min_duration_statement = 4000',
            "log_line_prefix = 'user=%u,db=%d '",
            "statement_timeout = 10min",
        ]) + '\n'
        tmp_fd, tmp_name = tempfile.mkstemp()
        os.write(tmp_fd, conf)
        os.close(tmp_fd)
        cat = subprocess.list2cmdline(['cat', tmp_name])
        tee = subprocess.list2cmdline((['sudo'] if self.use_sudo else []) + ['tee', postgresql_conf])
        local('{0} | {1} > /dev/null'.format(cat, tee))
        os.remove(tmp_name)
