{% from 'configuration/vars/map.jinja' import common with context %}

openstack-nova-compute:
   service.running:
      - enable: True
      - watch:
        - file: /etc/nova/nova.conf

/etc/nova/nova.conf:
   file.managed:
        - source: salt://configuration/templates/compute/nova.conf.jinja
        - mode: 644
        - user: nova
        - group: nova
        - template: jinja
        - context:
          hostname: {{ grains['host'] }}
          vip: {{ common.vip }}
          controller_1: {{ common.controllers[1] }}
          controller_2: {{ common.controllers[0] }}
