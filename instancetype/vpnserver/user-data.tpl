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
  - name: openvpncerts.service
    command: start
    content: |-
      [Unit]
      Description=Generate openvpn certificate during bootstrap
      Wants=network-online.target
      After=network-online.target docker.service confd.service caliconode.service

      [Service]
      RemainAfterExit=yes
      Type=oneshot
      ExecStart=-/usr/bin/docker pull busybox
      ExecStart=-/usr/bin/docker pull nixlike/openvpn
      ExecStart=-/usr/bin/docker run --name openvpn -v /etc/openvpn busybox
      ExecStart=-/usr/bin/docker run --volumes-from openvpn --rm nixlike/openvpn ovpn_genconfig -u udp://$public_ipv4
      ExecStart=-/usr/bin/docker run --volumes-from openvpn --rm nixlike/openvpn ovpn_initpki nopass
  - name: openvpn.service
    command: start
    content: |
      [Unit]
      Description=OpenVpn service
      After=docker.service openvpncerts.service
      Before=exhibitor.service

      [Service]
      Restart=always
      TimeoutStartSec=1m
      TimeoutStopSec=10s
      ExecStartPre=-/usr/bin/docker cp /home/core/openvpn.conf openvpn:/etc/openvpn/openvpn.conf
      ExecStart=/usr/bin/docker run --name openvpnd --rm --volumes-from openvpn -p 1194:1194/udp --cap-add=NET_ADMIN nixlike/openvpn
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
- path: "/opt/etc/confd/conf.d/openvpn.toml"
  permissions: '0644'
  owner: root
  content: |
    [template]
    src = "openvpn.conf.tmpl"
    dest = "/home/core/openvpn.conf"
    uid = 0
    gid = 0
    mode = "0644"
    keys = [
     "/mesos-master"
    ]
    reload_cmd = "docker cp /home/core/openvpn.conf openvpnd:/etc/openvpn/openvpn.conf&&docker stop openvpnd"
- path: "/opt/etc/confd/templates/openvpn.conf.tmpl"
  permissions: '0644'
  owner: root
  content: |
    server 192.168.255.0 255.255.255.0
    verb 3
    key /etc/openvpn/pki/private/$public_ipv4.key
    ca /etc/openvpn/pki/ca.crt
    cert /etc/openvpn/pki/issued/$public_ipv4.crt
    dh /etc/openvpn/pki/dh.pem
    tls-auth /etc/openvpn/pki/ta.key
    key-direction 0
    keepalive 10 60
    persist-key
    persist-tun

    proto udp
    # Rely on Docker to do port mapping, internally always 1194
    port 1194
    dev tun0
    status /tmp/openvpn-status.log

    user nobody
    group nogroup
    {{range getvs "/mesos-master/*"}}{{ $ip := split (.) ":" }}push "dhcp-option DNS {{index $ip 0}}"
    {{end}}
    push "route $private_ipv4 255.255.0.0"
    route 192.168.254.0 255.255.255.0
manage_etc_hosts: localhost
