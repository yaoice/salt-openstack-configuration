{% from 'configuration/vars/map.jinja' import common with context %}

openstack-ceilometer:
  service.running:
    - names:
      - openstack-ceilometer-api
      - openstack-ceilometer-central
      - openstack-ceilometer-collector
      - openstack-ceilometer-notification
    - enable: True
    - watch:
      - file: /etc/ceilometer/ceilometer.conf

/etc/ceilometer/ceilometer.conf:
    file.managed:
        - source: salt://configuration/templates/controller/ceilometer.conf.jinja
        - mode: 644
        - user: ceilometer
        - group: ceilometer
        - template: jinja
        - context:
          hostname: {{ grains['host'] }}
          vip_hostname: {{ common.vip_hostname }}
          controller_1: {{ common.controllers[1] }}
          controller_2: {{ common.controllers[0] }}
