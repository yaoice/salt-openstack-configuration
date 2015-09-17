{% from 'configuration/vars/map.jinja' import common with context %}

openstack-glance:
  service.running:
    - names:
      - openstack-glance-api
      - openstack-glance-registry
    - enable: True
    - watch:
      - file: /etc/glance/glance-api.conf
      - file: /etc/glance/glance-registry.conf

{% for srv in ['api','registry'] %}
/etc/glance/glance-{{ srv }}.conf:
    file.managed:
        - source: salt://configuration/templates/controller/glance-{{ srv }}.conf.jinja
        - mode: 644
        - user: glance
        - group: glance
        - template: jinja
        - context:
          hostname: {{ grains['host'] }}
          vip_hostname: {{ common.vip_hostname }}
          controller_1: {{ common.controllers[0] }}
          controller_2: {{ common.controllers[1] }}
{% endfor %}
