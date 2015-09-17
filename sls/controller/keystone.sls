{% from 'configuration/vars/map.jinja' import common with context %}

openstack-keystone:
  service.running:
    - enable: True
    - watch:
      - file: /etc/keystone/keystone.conf

/etc/keystone/keystone.conf:
   file.managed:
      - source: salt://configuration/templates/controller/keystone.conf.jinja
      - mode: 640
      - user: keystone
      - group: keystone
      - template: jinja
      - context:
        hostname: {{ grains['host'] }}
        vip_hostname: {{ common.vip_hostname }}
         
