
/etc/hosts:
   file.managed:
      - source: salt://configuration/files/hosts
      - mode: 644

