# 目录结构

* configuration
* files 
* sls
* templates
* vars


		[root@controller-59 configuration]# tree
		.
		├── files              # 静态文件模板
		│   └── hosts
		├── LICENSE
		├── README.md          
		├── sls                # sls执行文件
		│   ├── common                # 公共部分
		│   │   └── sync_hosts.sls    # 更新hosts文件
		│   ├── compute               # compute部分 
		│   │   ├── all.sls           # all包括ceilometer.sls、neutron.sls、nova.sls
		│   │   ├── ceilometer.sls
		│   │   ├── neutron.sls
		│   │   └── nova.sls
		│   └── controller            # controller部分
		│       ├── all.sls           # all包括以下几个sls
		│       ├── ceilometer.sls
		│       ├── cinder.sls
		│       ├── glance.sls
		│       ├── keystone.sls
		│       ├── neutron.sls
		│       └── nova.sls
		├── templates                 # 配置文件模板（模板可能需要重新更新一下，变量部分保持一致即可）
		│   ├── compute
		│   │   ├── ceilometer.conf.jinja
		│   │   ├── ml2_conf.ini.jinja
		│   │   ├── neutron.conf.jinja
		│   │   └── nova.conf.jinja
		│   └── controller
		│       ├── ceilometer.conf.jinja
		│       ├── cinder.conf.jinja
		│       ├── glance-api.conf.jinja
		│       ├── glance-registry.conf.jinja
		│       ├── glusterfs_shares.jinja
		│       ├── keystone.conf.jinja
		│       ├── ml2_conf.ini.jinja
		│       ├── neutron.conf.jinja
		│       └── nova.conf.jinja
		└── vars                  # 变量
 			└── map.jinja
 						
 						
<br/>						
# 配置
	cp -r configuration /srv/openstack-deploy/salt/    # copy到这个目录下
	
	[root@pxe ~]#  cat /etc/salt/master  # salt master配置
	# interface: interface_ip
	auto_accept: True
	worker_threads: 10
	#max_event_size: 2097152
	file_roots:
 	  base:
  	  	  - /srv/openstack-deploy/salt/
 	  dev:
   		  - /srv/openstack-deploy/salt/dev

	pillar_roots:
 	  base:
    	 - /srv/openstack-deploy/pillar
  	  dev:
    	 - /srv/openstack-deploy/pillar/dev
	jinja_trim_blocks: True
	jinja_lstrip_blocks: True
	
	[root@controller-59 configuration]# cat vars/map.jinja
	{% set common = {
   		'manage_interface': 'eth0',                    # 管理网网卡名字
   		'data_interface': 'eth1',                      # 数据网网卡名字
   		'vip': '172.16.100.250',                       # vip
   		'vip_hostname': 'controller',                  # vip主机名
   		'controllers': ['controller1','controller2'],  # 控制节点列表
   		'glusterfs_shares': 'localhost:/glance',       # cinder-volume中glusterfs volume路径
   		}
	%}

	{% set data_ip = grains['ip_interfaces'].get(common.data_interface,'eth0') %}  # 数据网ip
	注：增加变量的话，直接在上面的字典中增加定义，跟Python dict一样，key-value结构。
	
	
	[root@controller-59 configuration]# cat sls/controller/nova.sls      # 说明一下sls文件，以controller中的nova为例
	{% from 'configuration/vars/map.jinja' import common with context %}  # 加载vars目录下的变量
	openstack-nova:
  		service.running:
   	 	- names:                           # openstack nova服务           
      		- openstack-nova-api
      		- openstack-nova-cert
      		- openstack-nova-conductor
      		- openstack-nova-consoleauth
      		- openstack-nova-scheduler
      		- openstack-nova-novncproxy
    	- enable: True
    	- watch:
      		- file: /etc/nova/nova.conf

	/etc/nova/nova.conf:   # 目的路径
   		file.managed:
        	- source: salt://configuration/templates/controller/nova.conf.jinja   # 模板源路径
        	- mode: 644
        	- user: nova
        	- group: nova
        	- template: jinja   # 模板引擎
        	- context:
          	hostname: {{ grains['host'] }}              # 服务器自己的主机名，就是这么写的
          	vip_hostname: {{ common.vip_hostname }}     # common是vars目录下定义的字典，点号引用
          	vip: {{ common.vip }}
          	controller_1: {{ common.controllers[1] }}
          	controller_2: {{ common.controllers[0] }}

<br/>	
# 使用
	# test=True表示模拟执行，不真正执行，最好每次执行之前先模拟执行一遍
	salt 'controller-59' state.sls configuration.sls.controller.keystone test=True
	
	controller节点配置下发
	salt 'controller-59' state.sls configuration.sls.controller.keystone  #  同步keystone配置
	salt 'controller-59' state.sls configuration.sls.controller.glance    #  同步glance配置
	salt 'controller-59' state.sls configuration.sls.controller.nova      #  同步nova配置
	salt 'controller-59' state.sls configuration.sls.controller.neutron   #  同步neutron配置 
	salt 'controller-59' state.sls configuration.sls.controller.cinder    #  同步cinder配置
	salt 'controller-59' state.sls configuration.sls.controller.ceilometer   # 同步ceilometer配置 	
	salt 'controller-59' state.sls configuration.sls.controller.all   # 同步keystone、glance、nova、neutron、cinder、ceilometer配置
	
	
	compute节点配置下发
	salt 'compute-1' state.sls configuration.sls.compute.nova  # 同步nova配置
	salt 'compute-1' state.sls configuration.sls.compute.neutron  # 同步neutron配置
	salt 'compute-1' state.sls configuration.sls.compute.ceilometer  # 同步ceilometer配置
	salt 'compute-1' state.sls configuration.sls.compute.all  # 同步nova、neutron、ceilometer配置
	
	
	salt '*' state.sls configuration.sls.common.sync_hosts  #  同步/etc/hosts配置
	
	
<br/>
# 如何添加一个组件
	# for example: 增加trove配置，这时候你的目录结构可能就变成这样：
	[root@controller-59 configuration]# tree
		.
		├── files              # 静态文件模板
		│   └── hosts
		├── LICENSE
		├── README.md          
		├── sls                # sls执行文件
		│   ├── common                # 公共部分
		│   │   └── sync_hosts.sls    # 更新hosts文件
		│   ├── compute               # compute部分 
		│   │   ├── all.sls           # all包括ceilometer.sls、neutron.sls、nova.sls
		│   │   ├── ceilometer.sls
		│   │   ├── neutron.sls
		│   │   └── nova.sls
		│   └── controller            # controller部分
		│       ├── all.sls           # all包括以下几个sls，all里面添加下trove.sls
		│       ├── ceilometer.sls
		│       ├── cinder.sls
		│       ├── glance.sls
		│       ├── keystone.sls
		│       ├── neutron.sls
		│       └── nova.sls
		│       └── trove.sls		 # 新增的trove.sls
		├── templates                 # 配置文件模板（模板可能需要重新更新一下，变量部分保持一致即可）
		│   ├── compute
		│   │   ├── ceilometer.conf.jinja
		│   │   ├── ml2_conf.ini.jinja
		│   │   ├── neutron.conf.jinja
		│   │   └── nova.conf.jinja
		│   └── controller
		│       ├── ceilometer.conf.jinja
		│       ├── cinder.conf.jinja
		│       ├── glance-api.conf.jinja
		│       ├── glance-registry.conf.jinja
		│       ├── glusterfs_shares.jinja
		│       ├── keystone.conf.jinja
		│       ├── ml2_conf.ini.jinja
		│       ├── neutron.conf.jinja
		│       └── nova.conf.jinja
		│       └── trove.conf.jinja     # 新增的trove.conf.jinja模板文件
		└── vars                  # 变量
 			└── map.jinja
	
		[root@controller-59 configuration]# cat sls/controller/trove.sls      # 模仿上面的nova.sls文件
	{% from 'configuration/vars/map.jinja' import common with context %}  # 加载vars目录下的变量
	openstack-trove:    # 这个是id号，随便定义，叫trove-xxxx都行
  		service.running:
   	 	- names:                           # 下面写跟trove相关的服务，启动服务名，不能乱写           
      	   - trove相关服务名
      	   - trove相关服务名
    	- enable: True
    	- watch:
      		- file: /etc/trove/trove.conf  # 下面定义的目的路径

	/etc/trove/trove.conf:   # 目的路径
   		file.managed:
        	- source: salt://configuration/templates/controller/trove.conf.jinja   # trove模板路径
        	- mode: 644
        	- user: trove
        	- group: trove
        	- template: jinja   # 模板引擎
        	- context:
           变量内容根据实际情况来

	