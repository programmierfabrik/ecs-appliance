ecs:
  absolute_url_prefix: https://localhost
  authorative_domain: localhost
  allowed_hosts: "['localhost',]"
  secure_proxy_ssl: true
  client_certs_required: true

  debug: false
  debugtoolbar: false

  sentry_dsn: # empty
  prometheus:
    enabled: true
  logo_border_color: green
  userswitcher:
    enabled: true
    parameter: -it

  database:
    migrate_auto: true

  email:
    filter_outgoing_mail: true
    backend: django.core.mail.backends.console.emailbackend
    limited_backend: django.core.mail.backends.console.emailbackend

  recover:
    from_backup: false
    from_dump: false
    dump_filename: "" # if not empty, this file will be picked first

  local_settings: |
      # imported from env.yml
      x=0
      z="jo"

  secrets:
    common: 'ptn5xj+85fvd=d4u@i1-($z*otufbvlk%x1vflb&!5k94f$i3w'
    registration: '!brihi7#cxrd^twvj$r=398mdp4neo$xa-rm7b!8w1jfa@7zu_'
    password_reset: 'j2obdvrb-hm$$x949k*f5gk_2$1x%2etxhd!$+*^qs8$4ra3=a'

  authorized_keys: |
      # insert your ssh keys here
  storage:
    volatile:
      device: xvda
    permanent:
      device: xvdb
      snapshot_type: lvm
    backup:
      url: ftp://username:password@your-backup-data.host/backups/mydata
      encrypt: |
          PGP PRIVATE KEY BLOCK OF BACKUP HERE

    vault:
      encrypt:
        sec: |
            -----BEGIN PGP PRIVATE KEY BLOCK-----
            Version: GnuPG v1.4.10 (MingW32)

            lQOYBE3kIS0BCADHNBytxcTEasGbcT0ybEtCjbgUy8ePRaoDXaSo7W6/val+Gl3X
            AwbHAbAYNOO3Kr/4zvaX2qc3n8+AnsNNKnZDvYFEGsMzE80oVEwJMpoqH18mtnav
            Px63pFLyHeyUtYagmh+L0795zZxBe+a2Zl7K17klcx350iAai1Y4pHoJSUZ6X8/i
            VuKvNyfLh2DRb4JYYHM/bCGuu6z767gwDYkzJkk1n/u1Brr+LC3uwKSI1lvy3Tlx
            RSpurirTZN8av4RaLl+7A2EbxQQA+/kTXQZAdRmytMyAi2GceB+qFgvK4JFrl2DH
            /ElfMRJnKNguYCt0cW5GdGFqqykRVqwLak8jABEBAAEAB/4rQFvXuSCLexh1XSVp
            7Mx8c1PcJBC8wWX0HCFz0jWhKReDe0sTs6MFk469+sHUk9IhviIZf46eC7NcnFwQ
            RZ9u/tbxyBPI48xALOljd9q0OaKJv8VOMJjFS8b8rdWfxjgoZ75guEWTNzrtlu7V
            fK2pQiR/hpqkEuUIjmdWnhOnLyEGI4T7appy41fE1WApZRrzLr9xG3JZecXfPdGr
            S908BfStVaYPjg6i+vhxPeUaI51V1ARRkw6LiTw/A5rHGO+8SPZ4ZL/dI2AKlgcY
            kjfzKF728StCBRos65l4KF5HIGAfsWsOsbN2OEyoPQzXKl6my4sV74P6+TJlMQvg
            qTN9BADVOYB7JE4hRIiSp+gkuWlh6OiioRjAbxX67TfNoOzRW1MieGlhDAEGhsBI
            fEcpH9N89dCS162S7CRRaRf7XQmWqp3j1oM4AaW1eKmP7vr3vJW+FSMV0sDHEiOU
            Mk3sRJh16EF1PB1HK7lL8o+x+kvn61etdd+Q4TKAGIT+bpyCzwQA7yqJOZPO6uUI
            OAibMiYo7sRDmngB35TU2iZP8WlYtsQBKL+1ScdqZV6JzGHWAvPFMvYnEU+LVoQ5
            fQKRcDNW8KjHPktwo4yluxJYllebLVXow821zK2ffoTv42b7Mz4XQgoBRNd2uyzA
            qsjxwKHtWl80nZbUO9D4+QYkbPMq020D/3gcE98vgnu0FYJB/7GtizybpG97/Xsw
            1iAuBl+A9rQM0m+L6vNPyb1TIj3qeYi6vSG8C65NMV/qXfb8kuryephpClRSg8ev
            l3I/mMZ8FA19NktA0QKizKU3Ort6tXmNn8/EihOSPZjILg7ZEjY0KsFWRERk2fh7
            XkJrRIJfbbQoPfW0D2Vjc19tZWRpYXNlcnZlcokBOAQTAQIAIgUCTeQhLQIbLwYL
            CQgHAwIGFQgCCQoLBBYCAwECHgECF4AACgkQMU/68+TVSpxkVAf/baQ8afYMdua/
            s7UNj/d8ugOW/TpksaA7LCvcV7MYFEYStIot9juvcBkuQNIFTiBo69GUnl63WBT5
            D4jyychLtnIKBiWbAvRLE4Tcb6/Zluu4XsrjXmZZlQoz1fo7SGveFabJ1D72LxXe
            789Du7TnFDAMTSQil/nLeShogfQLdWRpdNajHCIgJeB3+NByjeJpNHTFJTI6JcKN
            MSJ8UXoRy47bbodzUmaEgl2sCBdXEsTfm3eK34IdCzR7fj64/7S7U7y2KL2NFaFY
            XcgsooRQ7FAwIYeZWxruQPaypgWnuR2f0iTbAzfZ7i68WjZjMUpD9EfJIc/eKYvL
            iEeHU7SxQA==
            =qL2O
            -----END PGP PRIVATE KEY BLOCK-----
      sign:
        sec: |
            -----BEGIN PGP PRIVATE KEY BLOCK-----
            Version: GnuPG v1.4.10 (MingW32)

            lQOYBE3kIQABCACsH2oUgCb8SHIqPx3aEn2pS+DStTMO01eZkoUH+NdY+h7egYN1
            SCebY4fYMwqayf9dP/eRBm+QI3/lJeuaxxa3uIjkO+4ENsgj4CH5ZeVR605U8CAo
            ZhI01ezv/AwWB5ZvljgTOeNA/BlUQSyATrBVITk1yIXH6izBA6T1mD0Or/NtBYVE
            vo42MSiPBQMBkMSM9aWZKNl6gJqy0j8tI3VWgnCoGNeAJL3RH7y8I4V1x5XRCZna
            N1CQc2bMvaaBsz0w6HUJ6ETEJEQmWSCqJsN76VG8UhkQ/leN7tPydGozTPMGIT7x
            ebtoEyvd3A4D+FFAoEiW/bUSgKRa70qzchzPABEBAAEAB/wLNORoP0vKg0EDpSZh
            a3DJFAqoTWnsnjAG7LZCpZ4Hygk2fYI8oZ0KjflrRy96kopQ3PhWde/Pl7AdEFH9
            utas0ZQAIDLIDXUMeOxdW5gJtGNePmApoTOwQvlxSpzS1l2iGErAXbWBJqjThobK
            N9VdRZN+//ZN5N5TFtSntOjMyuaU1pCqOiVsNMGSqYjYAdl+a91s4ZvtCwDTKrob
            UQ4jbcS7UjSbcfMqmqr8kjJMZ7btQ4znfIT1FNMeoWXSXBQW+2siWPbe09wcnAvD
            +vGImWVe2+b66bHV6nVo2JTsMANe4MQckAQGBZ25tRZWpNFMH5UqHLDVX+pKsc/K
            dzCxBADHg6tuPMPrEOAe1eiIglq4V8YxajSTGxxXDQzFQqKAuHDUhslEHFsEAqFO
            uN7ciGahCTzPOaA6c0QJJeYklqAZ5qILcMiN763wXOXtKAn+eCdj104G5FLkkVvH
            YoHyOZw7XjrSSpffXOGKS7sKa8gHIX8AHdrJUaFYu/m/mZMV5wQA3Np224c9jZYY
            1ewKcxXB/Je8c7f7PvQ+iP3ub8YyZPWq42YwcUX/NHa7DK+frjsSZwNJZEXpbu5X
            fZoXftAkkcxBIDznubjhbC1F0n6Htd0BOeSzFkPoTKxIdJNtabXW5qODIf982i5+
            I+vVTBW/3KI6GphXuFVgL3JRAdCtlNkD/2VONaONrbondrMPNn3KVeHt/jXxhzvb
            /dWxkEcgbOvs57VXFKhrr744LtQ4D5p0SrlkloidKDNByR+EoglCFbwD8JQa0mz3
            qgxsnyqBzgycd3KyNi5qUfVx9QCwNe0H7pGP40/Wr6ZzK2ZEc0qVI8tzrKhZ52rn
            xwlSz5PCmkLRRq+0DWVjc19hdXRob3JpdHmJATgEEwECACIFAk3kIQACGy8GCwkI
            BwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJELMEqSzEuXwj2bQH/2R/Cos4s12D7Iq5
            xmFXWJyAqF0nX79LrQ7nJqATx79qEAY3eMuqgGHFGRLUUcuZ+wMaW+1U4TXX5EEV
            R543QAmvwVHDtsZGSIm57Gu0bqHtSJUUWycfkkHmX/e7RS+tIUCtooNS+QvAPug5
            MnwcqLJIFXnjRbBUJBN9Ke0Tymi0PjgXuwUunf1pAPH2qcvLgP0q88613RQwx5UI
            SH1GkLHNQZAVwXqHhwL/ZX7hdnKqoOb6RMxsa6b4ynS/xbIqy/KTUmChZMEM9cJF
            fDEUuq+he1teTnpoAGhrlGnQCRcEvbXZ2jwOz8a7y++4xl8fOiH0XZwCi38QxVRs
            fUJ7VCc=
            =KKoR
            -----END PGP PRIVATE KEY BLOCK-----