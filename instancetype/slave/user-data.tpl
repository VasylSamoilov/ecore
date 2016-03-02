#cloud-config

---
coreos:
  etcd2:
    advertise-client-urls: http://$private_ipv4:2379
    initial-advertise-peer-urls: http://$private_ipv4:2380
    listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
    listen-peer-urls: http://$private_ipv4:2380,http://$private_ipv4:7001
    discovery: ${etcd_cluster_token}
  units:
  - name: update-engine.service
    command: stop
  - name: etcd2.service
    drop-ins:
    - name: 50-timeout.conf
      content: |
        [Service]
        TimeoutSec=5min
    command: start
  - name: docker.service
    command: restart
    content: |-
      [Unit]
      Description=Docker Application Container Engine
      After=docker.socket early-docker.target network.target etcd2.service
      Requires=docker.socket early-docker.target

      [Service]
      Environment=TMPDIR=/var/tmp
      MountFlags=slave
      LimitNOFILE=1048576
      LimitNPROC=1048576
      ExecStart=/usr/bin/docker daemon --cluster-store=etcd://$private_ipv4:2379 --host=fd:// $DOCKER_OPTS $DOCKER_OPT_BIP $DOCKER_OPT_MTU $DOCKER_OPT_IPMASQ
      RestartSec=10
      Restart=always
      [Install]
      WantedBy=multi-user.target
  - name: registrator.service
    command: start
    content: |
      [Unit]
      Description=Registrator service http://gliderlabs.com/registrator
      After=docker.service
      Before=exhibitor.service

      [Service]
      Restart=always
      TimeoutStartSec=30s
      TimeoutStopSec=3s
      ExecStart=/usr/bin/docker run --rm=true --name=registrator --net=host --volume=/var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator:latest -tags master -ip $private_ipv4 etcd://127.0.0.1:2379
  - name: caliconode.service
    command: start
    content: |-
      [Unit]
      Description=Calico node service
      Wants=network-online.target
      After=network-online.target docker.service
      Before=exhibitor.service

      [Service]
      RemainAfterExit=yes
      Type=oneshot
      ExecStart=/opt/bin/calicoctl node --libnetwork
  - name: confd.service
    command: start
    content: |-
      [Unit]
      Description=Confd service
      Wants=network-online.target
      After=network-online.target docker.service registrator.service

      [Service]
      Restart=always
      TimeoutStartSec=3m
      TimeoutStopSec=3s
      ExecStartPre=-/bin/sh -c '/usr/bin/grep nameserver /run/systemd/resolve/resolv.conf >>/opt/etc/confd/templates/resolv.conf.tmpl'
      ExecStart=/opt/bin/confd -confdir=/opt/etc/confd -interval=2
      ExecStopPost=-/bin/sh -c '/usr/bin/grep nameserver /run/systemd/resolve/resolv.conf >/etc/resolv.conf'
  - name: mesos-slave.service
    command: start
    content: |
      [Unit]
      Description=Mesos slave service
      Author=Oleksii Dzhulai
      After=exhibitor.service mesos-master.service

      [Service]
      Restart=always
      TimeoutStartSec=20m
      TimeoutStopSec=3s
      ExecStartPre=-/usr/bin/docker rm mesos-slave
      ExecStartPre=-/bin/docker pull nixlike/mesos-slave:mesos-0.24.1_docker-1.10.0
      ExecStart=/usr/bin/docker run --privileged --net=host -e LIBPROCESS_IP=$private_ipv4 -e MESOS_HOSTNAME=$private_ipv4 -e MESOS_IP=$private_ipv4 -e MESOS_MASTER=zk://leader.mesos:2181/mesos -v /sys/fs/cgroup:/sys/fs/cgroup -v /var/run/docker.sock:/var/run/docker.sock --rm=true --name mesos-slave -p 5050:5050 nixlike/mesos-slave:mesos-0.24.1_docker-1.10.0
  - name: instance-test.service
    command: start
    content: |
      [Unit]
      Description=Health check during instance provision
      After=mesos-master.service

      [Service]
      RemainAfterExit=yes
      Type=oneshot
      ExecStart=-/bin/docker pull nixlike/buildcont:ubuntu-15.10
      ExecStart=/usr/bin/bash -c 'while [ ! "$(docker run --entrypoint bash nixlike/buildcont:ubuntu-15.10 -c "cd ecore/envtype/CI && rake")" ]; do sleep 2;done'
      ExecStartPost=/usr/bin/touch /tmp/signal
write_files:
- path: "/etc/systemd/coredump.conf"
  permissions: '0644'
  owner: root
  content: |
    [Coredump]
    Storage=none
- path: "/etc/profile.d/01.calico.sh"
  permissions: '0644'
  owner: root
  content: |
    #!/usr/bin/bash
    export PATH=/opt/bin:$PATH
    export ETCD_AUTHORITY="$private_ipv4:2379"
- path: "/etc/sudoers.d/etcd"
  permissions: '0644'
  owner: root
  content: |
    Defaults env_keep +="ETCD_AUTHORITY"
- path: "/opt/etc/confd/conf.d/resolv.toml"
  permissions: '0644'
  owner: root
  content: |
    [template]
    src = "resolv.conf.tmpl"
    dest = "/etc/resolv.conf"
    uid = 0
    gid = 0
    mode = "0644"
    keys = [
     "/mesos-master"
    ]
- path: "/opt/etc/confd/templates/resolv.conf.tmpl"
  permissions: '0644'
  owner: root
  content: |
    {{range getvs "/mesos-master/*"}}{{ $ip := split (.) ":" }}nameserver {{index $ip 0}}
    {{end}}
manage_etc_hosts: localhost
