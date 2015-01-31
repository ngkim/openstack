###############################################################################
    하나의 서버에 cnode를 설치하기 위한 스크립트임
###############################################################################


- 설치를 위해 원격접속을 위한 준비사항         
    - 가능하면 IPMI 설정하여 웹콘솔로 접속
        HP의 경우 컴퓨터 부팅때 F8로 ILO 화면에서 설정
        사용예) https://221.145.180.108/ -> 신규 서버 ILO 웹콘솔
                웹콘솔에 로그인하여 리모트콘솔로 접속하여 설치가능
    - 리모트 콘솔이나 KVM 콘솔에서 수행해야 할 작업
        - root 패스워드 설정
            ubuntu@ubuntu:~$ sudo passwd root
            Enter New UNIX Password :  ohhberry3333  
            Reype New Nunix password : ohhberry3333
        - 우분투 Firewall 해제(이건 나중에 보안심의 이슈가 될 수 있슴)
            sudo ufw disable
        - 우분투 12.04인 경우 리포지터리 추가
            vi /etc/apt/sources.list 변경
            서버를 모두 ftp.daum.net으로 변경
            ex) vi에서 ":%s/us.archive.ubuntu.com/ftp.daum.net/g" 실행
            apt-get update
            apt-get -y install python-software-properties
            add-apt-repositiory -y cloud-archive:icehouse
        - openssh 서버 설치
            sudo apt-get install -y openssh-server
        - root 권한으로 외부에서 ssh 접속 허용 설정(우분투 12.04인 경우 불필요)
            /etc/ssh/sshd_config 파일의 PermitRootLogin 설정값을? no -> yes로 변경한다.
            service ssh restart 로 sshd를 새로운 설정이 적용되도록 restart한다.
    
    - 우분투 버전(12.04/14.04)에 따라 신경써야할 내용들
        - 12.04 서버의 레포지토리 사이트 수정 필요
            /etc/apt/sources.lists 에서 서버를 모두 ftp.daum.net으로 변경
            ex) vi에서 ":%s/us.archive.ubuntu.com/ftp.daum.net/g" 실행
    
        - 12.04 서버에 설치할 때는 cloud-archive:icehouse 레포지토리 추가 필요
            apt-get update
            apt-get -y install python-software-properties
            add-apt-repositiory -y cloud-archive:icehouse
                    
        - 12.04는 NIC 식별이 eth0, eth1, eth2 ....순서
             10G NIC도 eth로 식별됨    
        - 14.04는 NIC 식별이 em1, em2, em3, em4 ....순서
             10G NIC은 p1p1, p1p2로 식별됨            

- 설치 자동화를 위해 대부분 함수형태로 스크립트를 제작
- 각 함수는 반드시 수행한 내역에 대한 확인 내용 포함시킴
    -> 아직 성공/실패로 나오는 형태는 아니므로 눈으로 확인해야 함.
    
- LJG: 구성파일은 모두 라인시작에 공백이 없어야 한다.
       파이썬에서 파싱에러 발생할 수 있슴

- LJG: 모든 구성파일에 로그를 감시하기 위해 다음과 같은 항목은 필수
    verbose = True
    debug = True
    
    use_syslog = True
    syslog_log_facility = LOG_LOCAL0
    

###############################################################################    
- 프로그램 설명
###############################################################################

compute.sh
    :: cnode 설치 메인 스크립트

cnode_network_setting.sh
    :: cnode 서버 네트워크 환경 설정
        cnode_hosts_info_setting
        cnode_NIC_setting        

host_base_setting.sh
    :: cnode 서버 환경 설정
        server_syscontrol_change
        timezone_setting
        repository_setting
        install_base_utils

cnode에 cli 실행을 위한 openstack_rc 설정    
    
cnode_ovs_install.sh
    :: compute 서버에 openvswitch 설치 및 실행
        compute_openvswitch_install
        compute_openvswitch_execute
        
cnode_nova_install.sh
    :: compute 서버에 nova 설치 및 구성
        compute_nova_install
        compute_nova_configure
        compute_nova_compute_configure
        compute_nova_restart
        
cnode_neutron_install.sh
    :: compute 서버에 neutron 설치 및 구성
        compute_neutron_install
        compute_neutron_config
        compute_neutron_plugin_ml2_config
        compute_neutron_sudoers_append
        compute_neutron_plugin_openvswitch_agent_restart
        
cnode 서버 rsyslog 설정 & 재시작

