{% from 'configuration/vars/map.jinja' import common with context %}

openstack-cinder:
  service.running:
    - names:
      - openstack-cinder-api
      - openstack-cinder-scheduler
      - openstack-cinder-volume
    - enable: True
    - watch:
      - file: /etc/cinder/cinder.conf
      - file: /etc/cinder/glusterfs_shares

/etc/cinder/cinder.conf:
    file.managed:
        - source: salt://configuration/templates/controller/cinder.conf.jinja
        - mode: 644
        - user: cinder
        - group: cinder
        - template: jinja
        - context:
          hostname: {{ grains['host'] }}
          vip_hostname: {{ common.vip_hostname }}
          controller_1: {{ common.controllers[0] }}
          controller_2: {{ common.controllers[1] }}

/etc/cinder/glusterfs_shares:
    file.managed:
        - source: salt://configuration/templates/controller/glusterfs_shares.jinja
        - mode: 644
        - user: cinder
        - group: cinder
        - template: jinja
        - context:
          glusterfs_shares: {{ common.glusterfs_shares }}
