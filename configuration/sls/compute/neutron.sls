{% from 'configuration/vars/map.jinja' import common with context %}
{% from 'configuration/vars/map.jinja' import data_ip with context %}

neutron-openvswitch-agent:
   service.running:
      - enable: True
      - watch:
        - file: /etc/neutron/neutron.conf
        - file: /etc/neutron/plugins/ml2/ml2_conf.ini

/etc/neutron/neutron.conf:
     file.managed:
        - source: salt://configuration/templates/compute/neutron.conf.jinja
        - mode: 644
        - user: neutron
        - group: neutron
        - template: jinja
        - context:
          hostname: {{ grains['host'] }}
          vip_hostname: {{ common.vip_hostname }}
          controller_1: {{ common.controllers[0] }}
          controller_2: {{ common.controllers[1] }}

/etc/neutron/plugins/ml2/ml2_conf.ini:
   file.managed:
      - source: salt://configuration/templates/compute/ml2_conf.ini.jinja
      - mode: 644
      - user: neutron
      - group: neutron
      - template: jinja
      - context:
        local_ip: {{ data_ip[0] }}
