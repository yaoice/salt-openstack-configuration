{% from 'configuration/vars/map.jinja' import common with context %}

openstack-ceilometer-compute:
   service.running:
     - enable: True
     - watch:
       - file: /etc/ceilometer/ceilometer.conf

/etc/ceilometer/ceilometer.conf:
    file.managed:
        - source: salt://configuration/templates/compute/ceilometer.conf.jinja
        - mode: 644
        - user: ceilometer
        - group: ceilometer
        - template: jinja
        - context:
          hostname: {{ grains['host'] }}
          vip_hostname: {{ common.vip_hostname }}
          controller_1: {{ common.controllers[1] }}
          controller_2: {{ common.controllers[0] }}
