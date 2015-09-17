{% from 'configuration/vars/map.jinja' import common with context %}

openstack-nova:
  service.running:
    - names:
      - openstack-nova-api
      - openstack-nova-cert
      - openstack-nova-conductor
      - openstack-nova-consoleauth
      - openstack-nova-scheduler
      - openstack-nova-novncproxy
    - enable: True
    - watch:
      - file: /etc/nova/nova.conf

/etc/nova/nova.conf:
   file.managed:
        - source: salt://configuration/templates/controller/nova.conf.jinja
        - mode: 644
        - user: nova
        - group: nova
        - template: jinja
        - context:
          hostname: {{ grains['host'] }}
          vip_hostname: {{ common.vip_hostname }}
          vip: {{ common.vip }}
          controller_1: {{ common.controllers[1] }}
          controller_2: {{ common.controllers[0] }}
