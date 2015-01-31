# -*- coding: utf-8 -*-

##########################################################################
# CDP Master에서 사용하는 SQL 모음
##########################################################################

ng_sql = {}


#
# for openstack inventory

"""
-- 내용 : Project별 Quator 사용량 확인
-- 사용법 : 아래 쿼리 실행, 사용율이 일정 %이상인 걸 확인 하고 싶을 땐 조건을 수정하여 확인 
    SELECT 
        q.project_id,kp.name, q.resource,q.hard_limit, u.in_use, u.in_use/q.hard_limit*100 AS "usages(%)" 
    FROM 
        nova.quotas q, nova.quota_usages u, keystone.project kp
    WHERE 
        u.project_id = q.project_id AND q.resource = u.resource 
          AND q.project_id=kp.id
        -- and u.in_use/q.hard_limit *100 >50
    ORDER BY q.project_id;


-- vm별 ip정보를 neutron과 nova를 join하여  가져올 수 있음

    SELECT 
        ni.hostname, qi.ip_address
    FROM 
        neutron.ports qp, neutron.ipallocations qi, nova.instances ni
    WHERE 
        qp.device_id=ni.uuid
        AND qi.port_id = qp.id
    ORDER BY hostname;


-- instacne event 추적 관리
-- 조건절을 추가 하면 error 상태 및 처리완료가 되지 않은 값을 볼 수 있음

    SELECT 
        created_at,event, start_time, finish_time, result
    FROM 
        nova.instance_actions_events
    -- where result ='Error' -- 상태가 Error
    -- where result is null  -- 처리 완료가 되지 않은 상태
    ORDER BY start_time DESC;

    SELECT
        a.display_name AS vm_name,
        b.action       AS ACTION,
        c.event        AS event,
        c.start_time   AS start_time,
        c.finish_time  AS finish_time,
        c.result       AS result,
        c.traceback    AS traceback
    FROM 
        instances a,
        instance_actions b,
        instance_actions_events c
    WHERE a.uuid = b.instance_uuid
        AND b.id = c.action_id

    UNION 

    SELECT
        a.display_name  AS vm_name,
        b.host          AS HOST,
        '#instance fault',
        b.created_at    AS created_at,
        b.deleted_at    AS deleted_at,
        b.message       AS message,
        b.details       AS details
    FROM 
        instances a,
        instance_faults b
    WHERE a.uuid = b.instance_uuid
    
-- Cnode별 자원 사용율 확인 Query(VCPU, MEMORY), 가상화율 적용
-- where 조건에 hostOS이름을 넣어주면 지정한 cnode별로 조회가능

    SELECT 
        hypervisor_hostname,
        vcpus*5 AS total_vcpu,
        vcpus_used AS used_vcpu,
        vcpus_used/(vcpus*5) *100 AS "percent_vcpu(%)",
        memory_mb AS "total_mm(MB)", 
        memory_mb_used AS "used_mm(MB)", 
        memory_mb_used/memory_mb*100 AS "percent_mm(%)"
    FROM 
        nova.compute_nodes
    -- where hypervisor_hostname=''
    ORDER BY memory_mb_used/memory_mb*100 DESC, vcpus_used/(vcpus*5) *100 DESC;

-- Cnode 별 cinder volume 정보
-- 특정 Cnode만 보고 싶을땐 주석을 없애고 Cnode 이름을 넣어준다

    SELECT 
        ni.host, ni.uuid AS instance_uuid, cv.id AS volume_uuid, cv.status, cv.attach_status, cv.mountpoint, cv.display_name 
    FROM 
        cinder.volumes cv
        INNER JOIN nova.instances ni ON cv.instance_uuid=ni.uuid
    -- where ni.host ='cnode name'
    ORDER BY ni.host;

-- volume의 상세 정보를 볼 수 있다
-- volume 이름을 주면 볼륨별로 확인 가능
    
    SELECT 
        v.display_name, vgm.key, vgm.value, 
        DATE_ADD(vgm.created_at, INTERVAL 9 HOUR) AS created_at,
        DATE_ADD(vgm.deleted_at, INTERVAL 9 HOUR) AS deleted_at
    FROM 
        cinder.volume_glance_metadata vgm, cinder.volumes v
    WHERE vgm.volume_id=v.id
        -- and v.display_name='' 
        AND vgm.deleted_at IS NULL;

-- vm 상세 정보를 조회
-- vm의 volume정보가 모두 포함(예, vm에 volume이 5개일경우 5line 표시)

    SELECT 
        kp.name AS project_name,
        ni.hostname AS Cnode_Name,
        ni.host AS VM_Name,
        ni.vcpus AS VCPU,
        ni.memory_mb AS MEMORY,
        SUBSTRING(SUBSTRING_INDEX(iic.pub_ip, ',', -1),14,12) AS Pub_ip,
        SUBSTRING(SUBSTRING_INDEX(iicc.priv_ip, ',', -1),14,12) AS Priv_ip,
        SUBSTRING_INDEX(gi.name,'_',2) AS Image_Name,
        vm_state,
        UUID AS Instance_UUID,
        ni.availability_zone,
        ni.created_at,
        cv.provider_location AS Snode_Location,
        cv.display_name AS volume_name,
        cv.id AS volume_id
    FROM 
        nova.instances ni, 
        cinder.volumes AS cv, 
        keystone.project kp , 
        glance.images gi,
        (SELECT SUBSTRING_INDEX(network_info, ',', 7) pub_ip,instance_uuid  FROM nova.instance_info_caches) iic,
        (SELECT SUBSTRING_INDEX(network_info, ',', 38) priv_ip,instance_uuid  FROM nova.instance_info_caches) iicc
    WHERE 
        ni.project_id=kp.id
        AND ni.uuid=iic.instance_uuid
        AND ni.uuid=iicc.instance_uuid
        AND ni.uuid=cv.instance_uuid
        AND gi.id=ni.image_ref
        -- and kp.name='' ?- project 별로 조회 가능
        -- and hostname='' -? vm별 조회 가능
        -- and host=''   -? Cnode단위 조회 가능
        -- gi.name=''    -? image별 조회 가능
        -- and vm_state ='active'
    ORDER BY hostname DESC;

-- vm 상세 정보를 조회

-- vm별 resource 사용 정보 확인 가능
-- hostname이 겹칠 수 있으니 project name이나, hostname을 조건 추가

    SELECT 
        kp.name AS project_name,i.hostname,ism.key,ism.value  
    FROM 
        nova.instances i, nova.instance_system_metadata ism,keystone.project kp 
    WHERE 
        i.uuid=ism.instance_uuid
        AND i.project_id=kp.id
        -- and i.hostname='test1'
        -- and kp.name='';


-- Storage pool별 할당량 보는 쿼리
-- used는 DB에서 가져 올 수 없음(nexcenta에서 가져와야 함)

    SELECT 
        provider_location, 
        SUM(size/1024) AS "allocate_size(TB)"
    FROM cinder.volumes
    WHERE STATUS='in-use'
    GROUP BY provider_location;

"""

ng_sql['openstack_hierarchy'] = """
    -- openstack 의 계층구조를 보여준다.
    /*
    aggr_id  aggr_name          aggr_key           aggr_host         
    -------  -----------------  -----------------  ------------------
      3  mokdong.dev.ktis   availability_zone  cnode01.mkd-stag  
      3  mokdong.dev.ktis   availability_zone  cnode02.mkd-stag  
      6  mokdong.dev.dmz    availability_zone  cnode03.mkd-stag  
      6  mokdong.dev.dmz    availability_zone  cnode04.mkd-stag  
      9  mokdong.prod.dmz   availability_zone  cnode08.mkd-stag  
      9  mokdong.prod.dmz   availability_zone  cnode07.mkd-stag  
     12  mokdong.prod.ktis  availability_zone  cnode05.mkd-stag  
     12  mokdong.prod.ktis  availability_zone  cnode06.mkd-stag
    */
    SELECT 
        a.id     AS aggr_id,
        a.name   AS aggr_name, 
        b.key    AS aggr_key,     
        c.host   AS aggr_host
    FROM 
        nova.aggregates         a, 
        nova.aggregate_metadata b, 
        nova.aggregate_hosts    c
    WHERE 
        a.id     = b.aggregate_id
        AND a.id = c.aggregate_id
        AND b.key= 'availability_zone' -- 나중에 pod가 추가되면 계층구조를 만들어 줘야함.
"""

ng_sql['vm_inventory'] = """

CREATE VIEW vw_vm_inventory AS    
    /*
     openstack detail inventory 구하기
    
        기본적으로 vm을 중심으로 관련된 데이터를 최대로 구해 이 질의문 하나에 대부분의 관계를 파악할 수 있도록 한다.
    
        volume, network등과 같은 레코드들은 하나의 vm에 여러개의 레코드가 나올수 있어 깔끔하게 표시하기 어렵지만
        group 함수들을 이용하여 최대한 표현하도록 한다. (예, 볼류갯수, 볼륨 정보 리스트 등)
        
        그리고 project와 관련된 정보도 상당히 다양하지만 기본적으로 힌트를 얻기위해 securitygroup과 같은 정보를 보여줌으로서
        이 질의문을 보는 사람이 관련성을 파악할 수 있는 힌트를 제공하자.
    
    주의 사항(LJG):
        1. group 함수를 잘 사용해야 한다. vm과 1:n의 관계인데 1:1인줄 알고 join을 하면 더 많은 열이 구해지므로
           항상 instances 테이블과 갯수를 비교하면 질의를 수행하는 습관이 필요, 나중에 디버깅하려면 골치아프다....
        2. group_concat, concat 함수내의 필드중에 하나라도 null이 있으면 전체가 null이 나온다.
        3. group_concat는 from 절에 outer join을 만들고 그 테이블을 사용하면 결과레코드가 하나만 나온다. 
           즉, select 절에서 개별 row에 적용해야 한다는 얘기
    */
    
    SELECT
        ni.availability_zone                                                        AS vm_zone,
        ni.host                                                                     AS vm_host,
        -- ni.hostname                                                              AS vm_name, 
            -- instances 테이블의 hostname 컬럼은 jingoo_server라면 Vm 이름을 넣으면 
            -- jingoo-server라고 표시됨 윈인은 몰라.. 따라서 display_name을 사용해야 함.
        ni.display_name                                                             AS vm_name,
        ni.uuid                                                                     AS vm_uuid,
        
        ni.created_at                                                               AS vm_create_dt,
        -- DATE_ADD(ni.created_at, INTERVAL 9 HOUR) as vm_create_dt2,
        -- vm_host info 
        /*
            SELECT 
                hypervisor_hostname,
                vcpus*5 AS total_vcpu,
                vcpus_used AS used_vcpu,
                vcpus_used/(vcpus*5) *100 AS 'percent_vcpu(%)',
                memory_mb AS 'total_mm(MB)', 
                memory_mb_used AS 'used_mm(MB)', 
                memory_mb_used/memory_mb*100 AS 'percent_mm(%)'
            FROM 
                nova.compute_nodes
            -- where hypervisor_hostname=''
            ORDER BY memory_mb_used/memory_mb*100 DESC, vcpus_used/(vcpus*5) *100 DESC;
        */
             -- json형식으로 포맷팅
            (SELECT
                CONCAT( '[',     
                    GROUP_CONCAT( CONCAT('{ host total_vcpu(x5): ',ncn.vcpus*5,'}'
                        -- ,' host total_base_vcpu: ',ncn.vcpus
                        ,', { host used_vcpu: ',ncn.vcpus_used,'}'
                        ,', { percent_vcpu(%): ', FORMAT(ncn.vcpus_used/(vcpus*5) * 100, 1),'}'
                        ,', { total_mm_MB: ',ncn.memory_mb,'}'
                        ,', { used_mm_MB: ',ncn.memory_mb_used,'}'
                        ,', { percent_mm(%): ',FORMAT((ncn.memory_mb_used/ncn.memory_mb)*100,1),'}'
                        ) SEPARATOR ',')
                ,']' )
             FROM
                 nova.compute_nodes    AS ncn
             WHERE 
                 ni.host = ncn.hypervisor_hostname)                                AS vm_host_info,
                    
        kp.name                                                                    AS vm_project_name,
        
        -- project 관련 compute quota & quota usages
        (SELECT
                CONCAT( '[',
                    GROUP_CONCAT( CONCAT('{', nq.resource,': ', nq.hard_limit, '}') SEPARATOR ', ')
                ,']' )
             FROM
                nova.quotas AS nq
             WHERE
                ni.project_id = nq.project_id
                AND nq.resource IN ('instances','cores','ram') )                   AS vm_project_compute_quotas,

        (SELECT
                CONCAT( '[',
                GROUP_CONCAT( CONCAT('{', nqu.resource,': ', nqu.in_use, '}') SEPARATOR ', ')
                ,']' )
             FROM
                nova.quota_usages AS nqu
             WHERE
                ni.project_id = nqu.project_id
                AND nqu.resource IN ('instances','cores','ram') )                  AS vm_project_compute_quota_usage,
    
        -- project 관련 storage quota & quota usages
        (SELECT
                CONCAT( '[',
                GROUP_CONCAT( CONCAT('{', cq.resource,': ', cq.hard_limit, '}') SEPARATOR ', ')
                ,']' )
             FROM
                cinder.quotas AS cq
             WHERE
                ni.project_id = cq.project_id )                                    AS vm_project_volume_quotas,

        (SELECT
                CONCAT( '[',
                GROUP_CONCAT( CONCAT('{', cqu.resource,' -> ', cqu.in_use, '}') SEPARATOR ', ')
                ,']' )
             FROM
                cinder.quota_usages AS cqu
             WHERE
                ni.project_id = cqu.project_id )                                   AS vm_project_volume_quotas_usage,
        
        -- project 관련 network quota & quota usages
        (SELECT
            CONCAT( '[',
                GROUP_CONCAT( CONCAT('{', nq.resource,': ', nq.limit, '}') SEPARATOR ', ')
            ,']' )
             FROM
                neutron.quotas AS nq
             WHERE
                ni.project_id = nq.tenant_id )                                    AS vm_project_network_quotas,
        /*
        (SELECT
                GROUP_CONCAT( CONCAT(nqu.resource,': ', nqu.in_use) SEPARATOR ', ')
             FROM
                neutron.quota_usages AS nqu
             WHERE
                ni.project_id = qqu.project_id )                                   AS vm_project_network_quotas_usage,
        */
        
        -- tennant(project)관련 security group info
        (SELECT
                GROUP_CONCAT( qsg.name SEPARATOR ', ')
             FROM
                neutron.securitygroups AS qsg
             WHERE
                ni.project_id = qsg.tenant_id )                                    AS vm_sequrity_group_info,
    
        ku.name                                                                    AS vm_user_name,
        
        -- user key pair info
        -- LJG: 조심 ! 하나의 user가 여러개의 key pair를 가지는 경우가 있슴
        
        (SELECT
            GROUP_CONCAT( nkp.fingerprint SEPARATOR ', ')
         FROM
            nova.key_pairs AS nkp
         WHERE
            ni.user_id = nkp.user_id )                                             AS vm_user_keypair_fingerprints,
            
        (SELECT
                GROUP_CONCAT( nkp.public_key SEPARATOR ', ')
             FROM
                nova.key_pairs AS nkp
             WHERE
                ni.user_id = nkp.user_id )                                         AS vm_user_keypair_public_key,
                
        -- ku.password as user_password,
        -- ku.extra as user_info,
    
        ni.display_description                                                     AS vm_desc,    
        -- ni.power_state AS vm_power_state_code,
        CASE ni.power_state
            WHEN '0' THEN 'inactive'
            WHEN '1' THEN 'active'
            ELSE '-'
        END                                                                        AS vm_power_state,
        
        ni.vm_state                                                                AS vm_state,
        nit.name                                                                   AS vm_instance_type,
        -- nit.vcpus,
        -- nit.memory_mb,
        -- nit.swap,        
        -- nit.vcpu_weight, -- 이건 뭘까??
        -- nit.rxtx_factor,
        -- nit.root_gb,
        
        ni.vcpus                                                                   AS vm_vcpus,    
        ni.memory_mb                                                               AS vm_memory_MB,    
    
        -- vm's volume info
        
        (SELECT
            -- concat(count(*), '-', sum(vol.size))
            COUNT(*)
         FROM
            cinder.volumes AS vol
         WHERE
            vol.deleted_at IS NULL AND
            ni.uuid = vol.instance_uuid) AS vm_vol_count,
    
        (SELECT
            SUM(vol.size)
         FROM
            cinder.volumes AS vol
         WHERE
            vol.deleted_at IS NULL AND
            ni.uuid = vol.instance_uuid)                                           AS vm_vol_size_sum_GB,
    
        (SELECT
            CONCAT( '[',
            GROUP_CONCAT( CONCAT( '{ vol_name: ', cv.display_name, '}, {size(GB): ', cv.size, '}, {Loc: ', cv.provider_location,'}') SEPARATOR ', ') 
            ,']' )
         FROM
            cinder.volumes AS cv
         WHERE
            cv.deleted_at IS NULL 
            AND ni.uuid = cv.instance_uuid)                                        AS vm_vol_infos,

        /*
        (SELECT
                GROUP_CONCAT(vol.display_name SEPARATOR '-')
             FROM
                cinder.volumes AS vol
             WHERE
                vol.deleted_at IS NULL AND
                ni.uuid = vol.instance_uuid) AS vm_vol_names,
        
        (SELECT
                GROUP_CONCAT(vol.size SEPARATOR '-')
             FROM
                cinder.volumes AS vol
             WHERE
                vol.deleted_at IS NULL AND
                ni.uuid = vol.instance_uuid) AS 'vm_vol_sizes(GB)',
        
        (SELECT
                GROUP_CONCAT(vol.provider_location SEPARATOR '-')
             FROM
                cinder.volumes AS vol
             WHERE
                vol.deleted_at IS NULL AND
                ni.uuid = vol.instance_uuid) AS 'vm_vol_locs',
        */
        
        -- vm system_meta info -> json formatting
        (SELECT    
            CONCAT( '[',
            GROUP_CONCAT( CONCAT('{\"', nism.key,'\": \"', nism.value, '\"}') SEPARATOR ', ')            
            ,']' )
        FROM             
            nova.instance_system_metadata AS nism
        WHERE
            ni.uuid = nism.instance_uuid)                                          AS vm_system_meta_infos,
        
        -- vm's network info
        niic.network_info                                                          AS vm_network_info,
        
        (SELECT
            COUNT(*)
         FROM
            neutron.ports AS qp
         WHERE            
            ni.uuid = qp.device_id)                                                AS vm_nic_count,

        (SELECT
            GROUP_CONCAT(qp.mac_address SEPARATOR ' ')
         FROM
            neutron.ports AS qp
         WHERE            
            ni.uuid = qp.device_id)                                                AS vm_macs,
             
        (SELECT            
            GROUP_CONCAT(qn.name SEPARATOR ' ')
         FROM
            neutron.ports AS qp,
            neutron.networks AS qn
         WHERE            
            ni.uuid = qp.device_id
            AND qp.network_id = qn.id)                                             AS vm_networks,
                
        (SELECT
            GROUP_CONCAT(qp.device_owner SEPARATOR ' ')
         FROM
            neutron.ports AS qp
         WHERE            
            ni.uuid = qp.device_id)                                                AS vm_devices_owners,
   
        (SELECT
            GROUP_CONCAT(qi.ip_address SEPARATOR ' ')
         FROM
            neutron.ports AS qp,
            neutron.ipallocations AS qi
         WHERE            
            ni.uuid = qp.device_id        
            AND qp.id = qi.port_id )                                               AS vm_net_ips,
        
        (SELECT
            GROUP_CONCAT(qs.cidr SEPARATOR ' ')
         FROM
            neutron.ports AS qp,
            neutron.ipallocations AS qi,
            neutron.subnets AS qs
         WHERE            
            ni.uuid = qp.device_id        
            AND qp.id = qi.port_id
            AND qi.subnet_id = qs.id
        )                                                                          AS vm_net_cidrs,
        
        (SELECT
            -- GROUP_CONCAT(IFNULL(qs.gateway_ip,'null') SEPARATOR '-')
            GROUP_CONCAT(qs.gateway_ip SEPARATOR ' ')
         FROM
            neutron.ports AS qp,
            neutron.ipallocations AS qi,
            neutron.subnets AS qs
         WHERE            
            ni.uuid = qp.device_id        
            AND qp.id = qi.port_id
            AND qi.subnet_id = qs.id
        )                                                                          AS vm_net_gw_ips,
        
        ni.hostname                                                                AS vm_hostname,    
        ni.launched_at                                                                AS vm_start_dt,
        ni.root_device_name                                                        AS vm_root,
        
        -- ni.task_state as vm_task_state,
        -- ni.node as vm_node,
        
        gi.name                                                                    AS image_name,
        gi.size/1000000000                                                         AS image_size_GB
        
    FROM 
        nova.instances AS ni
        LEFT OUTER JOIN keystone.project AS kp
            ON ni.project_id = kp.id
    
        LEFT OUTER JOIN keystone.user AS ku
            ON ni.user_id = ku.id
    
        LEFT OUTER JOIN glance.images AS gi
            ON ni.image_ref = gi.id
    
        LEFT OUTER JOIN nova.instance_info_caches AS niic
            ON (ni.uuid = niic.instance_uuid AND niic.deleted_at IS NULL)
        
        LEFT OUTER JOIN nova.instance_types AS nit
            ON ni.instance_type_id = nit.id
                        
    WHERE 
        ni.deleted_at IS NULL
        -- AND ni.hostname = 'pos-dev-ktis'
        
    ORDER BY vm_zone, vm_host, vm_name, vm_create_dt
"""

ng_sql['openstack_inventory'] = """
    -- openstack zone, host, vm 계층으로 vm의 상세 인벤토리를 보여준다.
    /*
    vm_zone            vm_host           vm_name                   project_name    user_name       blank1  vm_desc                   vm_power_state  vm_state  vm_vcpus  vm_memory(MB)  vm_vol_count  vm_vol_size_sum(GB)  vm_vol_names                                    vm_vol_sizes(GB)  vm_vol_locs                                                                      blank2  vm_system_meta_infos                                                                                                                                                                                                                                                                                                                                   vm_nic_count  vm_macs                              vm_ips                     vm_networks                                  vm_devices_owners                                    network_info                                                                                                                                                                                                                                                                                                                                                                                      blank3  vm_hostname               vm_start_dt          vm_root   image_name                               image_size(GB)  
    -----------------  ----------------  ------------------------  --------------  --------------  ------  ------------------------  --------------  --------  --------  -------------  ------------  -------------------  ----------------------------------------------  ----------------  -------------------------------------------------------------------------------  ------  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  ------------  -----------------------------------  -------------------------  -------------------------------------------  ---------------------------------------------------  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  ------  ------------------------  -------------------  --------  ---------------------------------------  ----------------
    mokdong.dev.dmz    cnode03.mkd-stag  centos-package            admin           (NULL)                  centos_package            active          active           1           1024             1                   10  centos_package                                  10                14.63.250.228:3260,iqn.1994-04.jp.co.hitachi:cnode03.mkd-stag,93012311.3005,1,4          instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref ->                                                       1  fa:16:3e:1b:c9:2f                    14.63.205.39               mokdong.dev.dmz                              compute:mokdong.dev.dmz                              [{"ovs_interfaceid": null, "network": {"bridge": "brq5829fbee-ee", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "14.63.205.39"}], "version": 4, "meta": {"dhcp_server": "14.63.205.34"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "8.8.8.8"}], "routes": [], "cidr": "14.63.205.32/27", "gateway": {"meta": {}, "version": null, "tcentos-package", "address"2014-04-23 00:49:31{"/dev/vda":(NULL), "tenant_id": "00ca37df388445fe9f5          (NULL)
    mokdong.dev.dmz    cnode03.mkd-stag  instcos63                 admin           (NULL)                  instCOS63                 active          active           1           1024             0               (NULL)  (NULL)                                          (NULL)            (NULL)                                                                                   instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref -> 1bf59a10-193b-46c5-b47a-5a65be2da026                  1  fa:16:3e:54:64:19                    14.63.205.35               mokdong.dev.dmz                              compute:mokdong.dev.dmz                              [{"ovs_interfaceid": null, "network": {"bridge": "brq5829fbee-ee", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "14.63.205.35"}], "version": 4, "meta": {"dhcp_server": "14.63.205.34"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "8.8.8.8"}], "routes": [], "cidr": "14.63.205.32/27", "gateway": {"meta": {}, "version": null, "tinstcos63teway", "address"2014-04-16 07:31:31{"/dev/vda":CentOS6.3_64bit_140327-multinic-10Gtestf5          1.3215
    mokdong.dev.dmz    cnode03.mkd-stag  leeseul-sttest            admin           (NULL)                  leeseul_sttest            active          active           1           1024             0               (NULL)  (NULL)                                          (NULL)            (NULL)                                                                                   instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref -> 22f2c82b-e194-496e-a7e3-5eeb92bc8240 || p             1  fa:16:3e:0f:cf:79                    14.63.205.44               mokdong.dev.dmz                              compute:mokdong.dev.dmz                              [{"ovs_interfaceid": null, "network": {"bridge": "brq5829fbee-ee", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "14.63.205.44"}], "version": 4, "meta": {"dhcp_server": "14.63.205.34"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "8.8.8.8"}], "routes": [], "cidr": "14.63.205.32/27", "gateway": {"meta": {}, "version": null, "tleeseul-sttest", "address"2014-04-29 02:24:14{"/dev/vda":Windows2008StdR2_64bit_140429f388445fe9f5          8.3961
    mokdong.dev.dmz    cnode03.mkd-stag  p-ngone-dd90-w02          ipcid_00003866  ipcid_00003866          p-ngone-dd90-w02          inactive        building         1           1024             0               (NULL)  (NULL)                                          (NULL)            (NULL)                                                                                   instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref -> aca7f4fd-7a86-43db-8edb-062ac73b1e02                  0  (NULL)                               (NULL)                     (NULL)                                       (NULL)                                               []                                                                                                                                                                                                                                                                                                                                                                                                        p-ngone-dd90-w02          (NULL)               (NULL)    CentOS6.4_64bit_140404-multinic-10Gtest            2.6682
    mokdong.dev.dmz    cnode03.mkd-stag  p-ngone-dd90-w03          ipcid_00003866  ipcid_00003866          p-ngone-dd90-w03          inactive        building         1           1024             0               (NULL)  (NULL)                                          (NULL)            (NULL)                                                                                   instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref -> f64e25fd-99f7-4963-90c7-a2775895e2f8                  0  (NULL)                               (NULL)                     (NULL)                                       (NULL)                                               []                                                                                                                                                                                                                                                                                                                                                                                                        p-ngone-dd90-w03          (NULL)               (NULL)    CentOS6.3_64bit_140327                             5.4936
    mokdong.dev.dmz    cnode04.mkd-stag  5401                      leeseul         leeseul                 5401                      active          active           1           1024             0               (NULL)  (NULL)                                          (NULL)            (NULL)                                                                                   instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref -> 4abcd60a-411f-4049-ba0a-e339ef215890                  1  fa:16:3e:3c:b6:4b                    14.63.205.45               mokdong.dev.dmz                              compute:mokdong.dev.dmz                              [{"ovs_interfaceid": null, "network": {"bridge": "brq5829fbee-ee", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "14.63.205.45"}], "version": 4, "meta": {"dhcp_server": "14.63.205.34"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "8.8.8.8"}], "routes": [], "cidr": "14.63.205.32/27", "gateway": {"meta": {}, "version": null, "t5401: "gateway", "address"2014-05-13 07:08:28{"/dev/vda":CentOS5.8_64bit_14042400ca37df388445fe9f5          5.8338
    mokdong.dev.dmz    cnode04.mkd-stag  dfefse64                  leeseul         leeseul                 dfefse64                  active          active           1           1024             0               (NULL)  (NULL)                                          (NULL)            (NULL)                                                                                   instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref -> 4558f733-cb26-4c4e-bb6a-23de0d4218ad                  1  fa:16:3e:26:a0:b9                    14.63.205.42               mokdong.dev.dmz                              compute:mokdong.dev.dmz                              [{"ovs_interfaceid": null, "network": {"bridge": "brq5829fbee-ee", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "14.63.205.42"}], "version": 4, "meta": {"dhcp_server": "14.63.205.34"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "8.8.8.8"}], "routes": [], "cidr": "14.63.205.32/27", "gateway": {"meta": {}, "version": null, "tdfefse64ateway", "address"2014-05-13 02:10:09{"/dev/vda":CentOS6.4_64bit_14051200ca37df388445fe9f5          4.6224
    mokdong.dev.dmz    cnode04.mkd-stag  vm1ubuntu                 boram           boram                   vm1(ubuntu)               active          active           1           1024             0               (NULL)  (NULL)                                          (NULL)            (NULL)                                                                                   instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref -> 096e1e7b-792d-45f1-8be6-2ab3b88a9a96                  1  fa:16:3e:2d:82:46                    14.63.205.41               mokdong.dev.dmz                              compute:mokdong.dev.dmz                              [{"ovs_interfaceid": null, "network": {"bridge": "brq5829fbee-ee", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "14.63.205.41"}], "version": 4, "meta": {"dhcp_server": "14.63.205.34"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "8.8.8.8"}], "routes": [], "cidr": "14.63.205.32/27", "gateway": {"meta": {}, "version": null, "tvm1ubuntuteway", "address"2014-05-12 06:02:41{"/dev/vda":Ubuntu12.04_64bit_140512ca37df388445fe9f5          3.8097
    mokdong.dev.dmz    cnode04.mkd-stag  vm2centos                 boram           boram                   vm2(centos)               active          active           1           2048             0               (NULL)  (NULL)                                          (NULL)            (NULL)                                                                                   instance_type_memory_mb -> 2048 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 57 || instance_type_name -> 1c2g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 2 || instance_type_vcpus -> 1 || image_base_image_ref -> 4558f733-cb26-4c4e-bb6a-23de0d4218ad                  1  fa:16:3e:0b:1d:05                    14.63.205.40               mokdong.dev.dmz                              compute:mokdong.dev.dmz                              [{"ovs_interfaceid": null, "network": {"bridge": "brq5829fbee-ee", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "14.63.205.40"}], "version": 4, "meta": {"dhcp_server": "14.63.205.34"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "8.8.8.8"}], "routes": [], "cidr": "14.63.205.32/27", "gateway": {"meta": {}, "version": null, "tvm2centosteway", "address"2014-05-12 05:38:21{"/dev/vda":CentOS6.4_64bit_14051200ca37df388445fe9f5          4.6224
    mokdong.dev.ktis   cnode01.mkd-stag  58test01                  leeseul         leeseul                 58test01                  active          active           1           1024             0               (NULL)  (NULL)                                          (NULL)            (NULL)                                                                                   instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref -> 39039d3a-f835-4eb9-b6d7-d1b6bd10701d                  1  fa:16:3e:62:c4:42                    10.180.10.18               mokdong.dev.ktis                             compute:mokdong.dev.ktis                             [{"ovs_interfaceid": null, "network": {"bridge": "brq117871a7-0a", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "10.180.10.18"}], "version": 4, "meta": {"dhcp_server": "10.180.10.11"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "8.8.8.8"}], "routes": [], "cidr": "10.180.10.0/24", "gateway": {"meta": {}, "version": null, "ty58test01teway", "address":2014-05-13 07:07:16"i/dev/vda: CentOS5.8_64bit_140327-multinic-10Gtest50          2.1269
    mokdong.dev.ktis   cnode01.mkd-stag  ubuntu                    leeseul         leeseul                 ubuntu                    active          active           1           1024             0               (NULL)  (NULL)                                          (NULL)            (NULL)                                                                                   instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref -> 1fe9d087-25c0-43c3-949c-838aee909141                  1  fa:16:3e:b3:27:cc                    10.180.10.12               mokdong.dev.ktis                             compute:mokdong.dev.ktis                             [{"ovs_interfaceid": null, "network": {"bridge": "brq117871a7-0a", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "10.180.10.12"}], "version": 4, "meta": {"dhcp_server": "10.180.10.11"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "8.8.8.8"}], "routes": [], "cidr": "10.180.10.0/24", "gateway": {"meta": {}, "version": null, "tyubuntugateway", "address":2014-05-12 04:23:33"i/dev/vda: Ubuntu12.04_64bit_140429a37df388445fe9f50          3.7890
    mokdong.dev.ktis   cnode02.mkd-stag  boan-dev-ktis-01          CloudBoan       cloudboan               boan_dev_ktis_01          active          active           1           1024             1                   10  boan_dev_ktis_01                                10                snode02-disk:/volumes/mkd-stag-snode2-zpool1/cinder1                                     instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref ->                                                       1  fa:16:3e:75:83:2b                    10.180.10.13               mokdong.dev.ktis                             compute:mokdong.dev.ktis                             [{"ovs_interfaceid": null, "network": {"bridge": "brq117871a7-0a", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "10.180.10.13"}], "version": 4, "meta": {"dhcp_server": "10.180.10.11"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "8.8.8.8"}], "routes": [], "cidr": "10.180.10.0/24", "gateway": {"meta": {}, "version": null, "tyboan-dev-ktis-01"address":2014-04-25 07:46:48"i/dev/vda: (NULL) "tenant_id": "00ca37df388445fe9f50          (NULL)
    mokdong.dev.ktis   cnode02.mkd-stag  boan-dev-ktis-02          CloudBoan       cloudboan               boan_dev_ktis_02          active          active           1           1024             1                   10  boan_dev_ktis_02                                10                snode02-disk:/volumes/mkd-stag-snode2-zpool1/cinder1                                     instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref ->                                                       1  fa:16:3e:c5:ea:27                    10.180.10.15               mokdong.dev.ktis                             compute:mokdong.dev.ktis                             [{"ovs_interfaceid": null, "network": {"bridge": "brq117871a7-0a", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "10.180.10.15"}], "version": 4, "meta": {"dhcp_server": "10.180.10.11"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "8.8.8.8"}], "routes": [], "cidr": "10.180.10.0/24", "gateway": {"meta": {}, "version": null, "tyboan-dev-ktis-02"address":2014-04-25 07:46:46"i/dev/vda: (NULL) "tenant_id": "00ca37df388445fe9f50          (NULL)
    mokdong.dev.ktis   cnode02.mkd-stag  boan-dev-ktis-03          CloudBoan       cloudboan               boan_dev_ktis_03          active          active           1           1024             1                   10  boan_dev_ktis_03                                10                snode02-disk:/volumes/mkd-stag-snode2-zpool1/cinder1                                     instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref ->                                                       1  fa:16:3e:a3:cd:9a                    10.180.10.16               mokdong.dev.ktis                             compute:mokdong.dev.ktis                             [{"ovs_interfaceid": null, "network": {"bridge": "brq117871a7-0a", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "10.180.10.16"}], "version": 4, "meta": {"dhcp_server": "10.180.10.11"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "8.8.8.8"}], "routes": [], "cidr": "10.180.10.0/24", "gateway": {"meta": {}, "version": null, "tyboan-dev-ktis-03"address":2014-04-25 07:46:48"i/dev/vda: (NULL) "tenant_id": "00ca37df388445fe9f50          (NULL)
    mokdong.dev.ktis   cnode02.mkd-stag  pos-dev-ktis              positive        positive                pos_dev_ktis              active          active           1           1024             1                  100  pos_vol2                                        100               snode02-disk:/volumes/mkd-stag-snode2-zpool1/cinder1                                     instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref ->                                                       2  fa:16:3e:11:58:7a-fa:16:3e:f0:d1:66  10.180.10.17-10.180.14.17  mokdong.dev.ktis-mokdong.prod.ktis           compute:mokdong.dev.ktis-compute:mokdong.dev.ktis    [{"ovs_interfaceid": null, "network": {"bridge": "brq117871a7-0a", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "10.180.10.17"}], "version": 4, "meta": {"dhcp_server": "10.180.10.11"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "8.8.8.8"}], "routes": [], "cidr": "10.180.10.0/24", "gateway": {"meta": {}, "version": null, "typos-dev-ktisy", "address":2014-05-15 00:40:24"i/dev/vda: (NULL) "tenant_id": "00ca37df388445fe9f50          (NULL)
    mokdong.dev.ktis   cnode02.mkd-stag  test03                    leeseul         leeseul                 test03                    active          active           1           1024             0               (NULL)  (NULL)                                          (NULL)            (NULL)                                                                                   instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref -> b9821d7f-804f-4f78-bf10-424b148e8938                  1  fa:16:3e:89:3b:72                    10.180.10.21               mokdong.dev.ktis                             compute:mokdong.dev.ktis                             [{"ovs_interfaceid": null, "network": {"bridge": "brq117871a7-0a", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "10.180.10.21"}], "version": 4, "meta": {"dhcp_server": "10.180.10.11"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "8.8.8.8"}], "routes": [], "cidr": "10.180.10.0/24", "gateway": {"meta": {}, "version": null, "tytest03gateway", "address":2014-05-15 14:37:18"i/dev/vda: test03 "tenant_id": "00ca37df388445fe9f50          7.8146
    mokdong.prod.dmz   cnode07.mkd-stag  0423-1-cent64mproddmz     QA_TEST         qatadmin                0423_1_cent64mproddmz     inactive        error            8           8192             1                  100  bfv1_cent64m_proddmz                            100               snode01-disk:/volumes/mkd-stag-snode1-zpool1/cinder2                                     instance_type_memory_mb -> 8192 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 84 || instance_type_name -> 8c8g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 11 || instance_type_vcpus -> 8 || image_base_image_ref ->                                                      0  (NULL)                               (NULL)                     (NULL)                                       (NULL)                                               (NULL)                                                                                                                                                                                                                                                                                                                                                                                                    0423-1-cent64mproddmz     (NULL)               /dev/vda  (NULL)                                             (NULL)
    mokdong.prod.dmz   cnode07.mkd-stag  0423-2-centos64m-proddmz  QA_TEST         qatadmin                0423_2_centos64m_proddmz  inactive        error            2           2048             1                  100  bfv2_cent64m_proddmz                            100               snode01-disk:/volumes/mkd-stag-snode1-zpool1/cinder2                                     instance_type_memory_mb -> 2048 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 60 || instance_type_name -> 2c2g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 3 || instance_type_vcpus -> 2 || image_base_image_ref ->                                                       0  (NULL)                               (NULL)                     (NULL)                                       (NULL)                                               (NULL)                                                                                                                                                                                                                                                                                                                                                                                                    0423-2-centos64m-proddmz  (NULL)               /dev/vda  (NULL)                                             (NULL)
    mokdong.prod.dmz   cnode07.mkd-stag  cloudboan01-centos-10g    CloudBoan       cloudboan               cloudboan01_centos_10G    active          active           1           1024             1                   10  vol-CentOS6.4_64bit_140404-multinic-10Gtest-01  10                snode01-disk:/volumes/mkd-stag-snode1-zpool1/cinder2                                     instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref ->                                                       1  fa:16:3e:bd:65:cf                    14.63.205.227              mokdong.prod.dmz                             compute:mokdong.prod.dmz                             [{"ovs_interfaceid": null, "network": {"bridge": "brq5e32244b-36", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "14.63.205.227"}], "version": 4, "meta": {"dhcp_server": "14.63.205.226"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "147.6.44.44"}], "routes": [], "cidr": "14.63.205.224/28", "gateway": {"meta": {}, "version": ncloudboan01-centos-10g, "a2014-04-18 01:54:55me/dev/vdanj(NULL): false, "tenant_id": "00ca37df3884          (NULL)
    mokdong.prod.dmz   cnode07.mkd-stag  cloudboan02-centos-10g    CloudBoan       cloudboan               cloudboan02_centos_10G    active          active           1           1024             1                   10  vol-CentOS6.4_64bit_140404-multinic-10Gtest-02  10                snode01-disk:/volumes/mkd-stag-snode1-zpool1/cinder2                                     instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref ->                                                       1  fa:16:3e:40:6c:f5                    14.63.205.228              mokdong.prod.dmz                             compute:mokdong.prod.dmz                             [{"ovs_interfaceid": null, "network": {"bridge": "brq5e32244b-36", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "14.63.205.228"}], "version": 4, "meta": {"dhcp_server": "14.63.205.226"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "147.6.44.44"}], "routes": [], "cidr": "14.63.205.224/28", "gateway": {"meta": {}, "version": ncloudboan02-centos-10g, "a2014-04-18 01:55:19me/dev/vdanj(NULL): false, "tenant_id": "00ca37df3884          (NULL)
    mokdong.prod.dmz   cnode07.mkd-stag  cloudboan03-centos-10g    CloudBoan       cloudboan               cloudboan03_centos_10G    active          active           1           1024             1                   10  vol-CentOS6.4_64bit_140404-multinic-10Gtest-03  10                snode01-disk:/volumes/mkd-stag-snode1-zpool1/cinder2                                     instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref ->                                                       1  fa:16:3e:3b:ad:d4                    14.63.205.229              mokdong.prod.dmz                             compute:mokdong.prod.dmz                             [{"ovs_interfaceid": null, "network": {"bridge": "brq5e32244b-36", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "14.63.205.229"}], "version": 4, "meta": {"dhcp_server": "14.63.205.226"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "147.6.44.44"}], "routes": [], "cidr": "14.63.205.224/28", "gateway": {"meta": {}, "version": ncloudboan03-centos-10g, "a2014-04-18 01:56:35me/dev/vdanj(NULL): false, "tenant_id": "00ca37df3884          (NULL)
    mokdong.prod.dmz   cnode07.mkd-stag  cloudboan04-centos-10g    CloudBoan       cloudboan               cloudboan04_centos_10G    active          active           1           1024             1                   10  vol-CentOS6.4_64bit_140404-multinic-10Gtest-04  10                snode01-disk:/volumes/mkd-stag-snode1-zpool1/cinder2                                     instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref ->                                                       1  fa:16:3e:12:54:86                    14.63.205.230              mokdong.prod.dmz                             compute:mokdong.prod.dmz                             [{"ovs_interfaceid": null, "network": {"bridge": "brq5e32244b-36", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "14.63.205.230"}], "version": 4, "meta": {"dhcp_server": "14.63.205.226"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "147.6.44.44"}], "routes": [], "cidr": "14.63.205.224/28", "gateway": {"meta": {}, "version": ncloudboan04-centos-10g, "a2014-04-18 01:57:49me/dev/vdanj(NULL): false, "tenant_id": "00ca37df3884          (NULL)
    mokdong.prod.dmz   cnode07.mkd-stag  cloudboan05-centos-10g    CloudBoan       cloudboan               cloudboan05_centos_10G    active          active           1           1024             1                   10  vol-CentOS6.4_64bit_140404-multinic-10Gtest-05  10                snode01-disk:/volumes/mkd-stag-snode1-zpool1/cinder2                                     instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref ->                                                       1  fa:16:3e:aa:ef:e0                    14.63.205.231              mokdong.prod.dmz                             compute:mokdong.prod.dmz                             [{"ovs_interfaceid": null, "network": {"bridge": "brq5e32244b-36", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "14.63.205.231"}], "version": 4, "meta": {"dhcp_server": "14.63.205.226"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "147.6.44.44"}], "routes": [], "cidr": "14.63.205.224/28", "gateway": {"meta": {}, "version": ncloudboan05-centos-10g, "a2014-04-18 01:58:12me/dev/vdanj(NULL): false, "tenant_id": "00ca37df3884          (NULL)
    mokdong.prod.dmz   cnode07.mkd-stag  cloudboan06-centos-10g    CloudBoan       cloudboan               cloudboan06_centos_10G    active          active           1           1024             1                   10  vol-CentOS6.4_64bit_140404-multinic-10Gtest-06  10                snode01-disk:/volumes/mkd-stag-snode1-zpool1/cinder2                                     instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref ->                                                       1  fa:16:3e:5e:42:cb                    14.63.205.232              mokdong.prod.dmz                             compute:mokdong.prod.dmz                             [{"ovs_interfaceid": null, "network": {"bridge": "brq5e32244b-36", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "14.63.205.232"}], "version": 4, "meta": {"dhcp_server": "14.63.205.226"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "147.6.44.44"}], "routes": [], "cidr": "14.63.205.224/28", "gateway": {"meta": {}, "version": ncloudboan06-centos-10g, "a2014-04-18 01:59:03me/dev/vdanj(NULL): false, "tenant_id": "00ca37df3884          (NULL)
    mokdong.prod.dmz   cnode07.mkd-stag  cloudboan07-centos-10g    CloudBoan       cloudboan               cloudboan07_centos_10G    active          active           1           1024             1                   10  vol-CentOS6.4_64bit_140404-multinic-10Gtest-07  10                snode01-disk:/volumes/mkd-stag-snode1-zpool1/cinder2                                     instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref ->                                                       1  fa:16:3e:d8:ec:6a                    14.63.205.233              mokdong.prod.dmz                             compute:mokdong.prod.dmz                             [{"ovs_interfaceid": null, "network": {"bridge": "brq5e32244b-36", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "14.63.205.233"}], "version": 4, "meta": {"dhcp_server": "14.63.205.226"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "147.6.44.44"}], "routes": [], "cidr": "14.63.205.224/28", "gateway": {"meta": {}, "version": ncloudboan07-centos-10g, "a2014-04-18 02:07:26me/dev/vdanj(NULL): false, "tenant_id": "00ca37df3884          (NULL)
    mokdong.prod.dmz   cnode07.mkd-stag  cloudboan08-centos-10g    CloudBoan       cloudboan               cloudboan08_centos_10G    active          active           1           1024             1                   10  vol-CentOS6.4_64bit_140404-multinic-10Gtest-08  10                snode01-disk:/volumes/mkd-stag-snode1-zpool1/cinder2                                     instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref ->                                                       1  fa:16:3e:d9:8f:14                    14.63.205.234              mokdong.prod.dmz                             compute:mokdong.prod.dmz                             [{"ovs_interfaceid": null, "network": {"bridge": "brq5e32244b-36", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "14.63.205.234"}], "version": 4, "meta": {"dhcp_server": "14.63.205.226"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "147.6.44.44"}], "routes": [], "cidr": "14.63.205.224/28", "gateway": {"meta": {}, "version": ncloudboan08-centos-10g, "a2014-04-18 02:07:25me/dev/vdanj(NULL): false, "tenant_id": "00ca37df3884          (NULL)
    mokdong.prod.dmz   cnode07.mkd-stag  cloudboan09-centos-10g    CloudBoan       cloudboan               cloudboan09_centos_10G    active          active           1           1024             1                   10  vol-CentOS6.4_64bit_140404-multinic-10Gtest-09  10                snode01-disk:/volumes/mkd-stag-snode1-zpool1/cinder2                                     instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref ->                                                       1  fa:16:3e:1f:77:ab                    14.63.205.235              mokdong.prod.dmz                             compute:mokdong.prod.dmz                             [{"ovs_interfaceid": null, "network": {"bridge": "brq5e32244b-36", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "14.63.205.235"}], "version": 4, "meta": {"dhcp_server": "14.63.205.226"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "147.6.44.44"}], "routes": [], "cidr": "14.63.205.224/28", "gateway": {"meta": {}, "version": ncloudboan09-centos-10g, "a2014-04-18 02:37:47me/dev/vdanj(NULL): false, "tenant_id": "00ca37df3884          (NULL)
    mokdong.prod.dmz   cnode07.mkd-stag  test                      hs-test         hs-test                 test                      active          active           1           1024             0               (NULL)  (NULL)                                          (NULL)            (NULL)                                                                                   instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref -> 30431cbb-a613-4fee-b04d-92850ff2e086                  1  fa:16:3e:d4:ca:d1                    14.63.205.237              mokdong.prod.dmz                             compute:mokdong.prod.dmz                             [{"ovs_interfaceid": null, "network": {"bridge": "brq5e32244b-36", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "14.63.205.237"}], "version": 4, "meta": {"dhcp_server": "14.63.205.226"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "147.6.44.44"}], "routes": [], "cidr": "14.63.205.224/28", "gateway": {"meta": {}, "version": ntest "type": "gateway", "a2014-04-28 07:36:38me/dev/vdanjUbuntu12.04_64bit_140330d": "00ca37df3884          4.2694
    mokdong.prod.dmz   cnode07.mkd-stag  windows                   hs-test         hs-test                 windows                   active          active           1           1024             0               (NULL)  (NULL)                                          (NULL)            (NULL)                                                                                   instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref -> 60e9c529-8139-4761-beea-a6afaa141df1 || p             1  fa:16:3e:d6:73:ef                    14.63.205.236              mokdong.prod.dmz                             compute:mokdong.prod.dmz                             [{"ovs_interfaceid": null, "network": {"bridge": "brq5e32244b-36", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "14.63.205.236"}], "version": 4, "meta": {"dhcp_server": "14.63.205.226"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "147.6.44.44"}], "routes": [], "cidr": "14.63.205.224/28", "gateway": {"meta": {}, "version": nwindowsype": "gateway", "a2014-05-08 09:02:09me/dev/vdanjWindows2008EntR2_64bit_14042400ca37df3884         14.1128
    mokdong.prod.dmz   cnode07.mkd-stag  windows-02                hs-test         hs-test                 windows-02                active          active           1           1024             0               (NULL)  (NULL)                                          (NULL)            (NULL)                                                                                   instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref -> 60e9c529-8139-4761-beea-a6afaa141df1 || p             1  fa:16:3e:92:43:78                    14.63.205.238              mokdong.prod.dmz                             compute:mokdong.prod.dmz                             [{"ovs_interfaceid": null, "network": {"bridge": "brq5e32244b-36", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "14.63.205.238"}], "version": 4, "meta": {"dhcp_server": "14.63.205.226"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "147.6.44.44"}], "routes": [], "cidr": "14.63.205.224/28", "gateway": {"meta": {}, "version": nwindows-02": "gateway", "a2014-05-16 04:28:21me/dev/vdanjWindows2008EntR2_64bit_14042400ca37df3884         14.1128
    mokdong.prod.ktis  cnode05.mkd-stag  instharrytestpw01         admin           (NULL)                  instHarryTestPW01         active          active           1           2048             0               (NULL)  (NULL)                                          (NULL)            (NULL)                                                                                   instance_type_memory_mb -> 2048 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 57 || instance_type_name -> 1c2g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 2 || instance_type_vcpus -> 1 || image_base_image_ref -> aca7f4fd-7a86-43db-8edb-062ac73b1e02                  2  fa:16:3e:9c:81:fa-fa:16:3e:5f:c7:6c  10.180.14.13-10.180.15.13  mokdong.prod.ktis-mokdong.prod.ktis.private  compute:mokdong.prod.ktis-compute:mokdong.prod.ktis  [{"ovs_interfaceid": null, "network": {"bridge": "brq372ac458-0d", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "10.180.14.13"}], "version": 4, "meta": {"dhcp_server": "10.180.14.11"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "8.8.8.8"}], "routes": [], "cidr": "10.180.14.0/24", "gateway": {"meta": {}, "version": null, "tyinstharrytestpw01address":2014-04-25 06:35:00"i/dev/vda: CentOS6.4_64bit_140404-multinic-10Gtest50          2.6682
    mokdong.prod.ktis  cnode05.mkd-stag  kth-test-02               taeho           taeho                   kth-test-02               active          active           1           1024             0               (NULL)  (NULL)                                          (NULL)            (NULL)                                                                                   instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref -> f7e27b63-6446-4c38-9a63-be2aa57fadc2                  1  fa:16:3e:8e:83:4c                    10.180.14.12               mokdong.prod.ktis                            compute:mokdong.prod.ktis                            [{"ovs_interfaceid": null, "network": {"bridge": "brq372ac458-0d", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "10.180.14.12"}], "version": 4, "meta": {"dhcp_server": "10.180.14.11"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "8.8.8.8"}], "routes": [], "cidr": "10.180.14.0/24", "gateway": {"meta": {}, "version": null, "tykth-test-02ay", "address":2014-04-28 05:07:02"i/dev/vda: CentOS6.4_64bit_1404040ca37df388445fe9f50          4.5419
    mokdong.prod.ktis  cnode05.mkd-stag  kth-test-03               taeho           taeho                   kth-test-03               active          active           8           8192             0               (NULL)  (NULL)                                          (NULL)            (NULL)                                                                                   instance_type_memory_mb -> 8192 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 84 || instance_type_name -> 8c8g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 11 || instance_type_vcpus -> 8 || image_base_image_ref -> f7e27b63-6446-4c38-9a63-be2aa57fadc2                 1  fa:16:3e:b8:8b:c9                    10.180.14.14               mokdong.prod.ktis                            compute:mokdong.prod.ktis                            [{"ovs_interfaceid": null, "network": {"bridge": "brq372ac458-0d", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "10.180.14.14"}], "version": 4, "meta": {"dhcp_server": "10.180.14.11"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "8.8.8.8"}], "routes": [], "cidr": "10.180.14.0/24", "gateway": {"meta": {}, "version": null, "tykth-test-03ay", "address":2014-04-28 05:10:21"i/dev/vda: CentOS6.4_64bit_1404040ca37df388445fe9f50          4.5419
    mokdong.prod.ktis  cnode06.mkd-stag  0429-1-ubuntu-prodktis    QA_TEST         qatadmin                0429_1_ubuntu_prodktis    active          active           2           4096             1                  100  bfv_291_Ubuntu1204_140429                       100               snode01-disk:/volumes/mkd-stag-snode1-zpool1/cinder1                                     instance_type_memory_mb -> 4096 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 63 || instance_type_name -> 2c4g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 4 || instance_type_vcpus -> 2 || image_base_image_ref ->                                                       1  fa:16:3e:34:4c:e7                    10.180.14.15               mokdong.prod.ktis                            compute:mokdong.prod.ktis                            [{"ovs_interfaceid": null, "network": {"bridge": "brq372ac458-0d", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "10.180.14.15"}], "version": 4, "meta": {"dhcp_server": "10.180.14.11"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "8.8.8.8"}], "routes": [], "cidr": "10.180.14.0/24", "gateway": {"meta": {}, "version": null, "ty0429-1-ubuntu-prodktisss":2014-04-29 05:34:11"i/dev/vda: (NULL) "tenant_id": "00ca37df388445fe9f50          (NULL)
    mokdong.prod.ktis  cnode06.mkd-stag  0429-2-ubuntum-prodktis   QA_TEST         qatadmin                0429_2_ubuntum_prodktis   active          active           8          16384             1                  100  bfv_292_Ubuntu1204m_140429_prodktis             100               snode01-disk:/volumes/mkd-stag-snode1-zpool1/cinder1                                     instance_type_memory_mb -> 16384 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 87 || instance_type_name -> 8c16g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 12 || instance_type_vcpus -> 8 || image_base_image_ref ->                                                    2  fa:16:3e:e0:a1:10-fa:16:3e:17:dd:b7  10.180.15.12-10.180.14.16  mokdong.prod.ktis-mokdong.prod.ktis.private  compute:mokdong.prod.ktis-compute:mokdong.prod.ktis  [{"ovs_interfaceid": null, "network": {"bridge": "brq372ac458-0d", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "10.180.14.16"}], "version": 4, "meta": {"dhcp_server": "10.180.14.11"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "8.8.8.8"}], "routes": [], "cidr": "10.180.14.0/24", "gateway": {"meta": {}, "version": null, "ty0429-2-ubuntum-prodktiss":2014-04-29 05:35:07"i/dev/vda: (NULL) "tenant_id": "00ca37df388445fe9f50          (NULL)
    mokdong.prod.ktis  cnode06.mkd-stag  p-april-pd93-w01          ipcid_00003489  ipcid_00003489          p-april-pd93-w01          inactive        error            1           1024             0               (NULL)  (NULL)                                          (NULL)            (NULL)                                                                                   instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref -> 35ec94a8-dd4e-4f8b-a7ec-6b5074de5b04                  0  (NULL)                               (NULL)                     (NULL)                                       (NULL)                                               (NULL)                                                                                                                                                                                                                                                                                                                                                                                                    p-april-pd93-w01          (NULL)               /dev/vda  CentOS6.3_64bit_10G_0401                           1.6815
    mokdong.prod.ktis  cnode06.mkd-stag  p-april-pd93-w02          ipcid_00003489  ipcid_00003489          p-april-pd93-w02          inactive        building         1           1024             0               (NULL)  (NULL)                                          (NULL)            (NULL)                                                                                   instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref -> 35ec94a8-dd4e-4f8b-a7ec-6b5074de5b04                  0  (NULL)                               (NULL)                     (NULL)                                       (NULL)                                               (NULL)                                                                                                                                                                                                                                                                                                                                                                                                    p-april-pd93-w02          (NULL)               /dev/vda  CentOS6.3_64bit_10G_0401                           1.6815
    mokdong.prod.ktis  cnode06.mkd-stag  p-cloud-pd93-w02          ipcid_00003632  ipcid_00003632          p-cloud-pd93-w02          inactive        building         1           1024             0               (NULL)  (NULL)                                          (NULL)            (NULL)                                                                                   instance_type_memory_mb -> 1024 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 54 || instance_type_name -> 1c1g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 1 || instance_type_vcpus -> 1 || image_base_image_ref -> 35ec94a8-dd4e-4f8b-a7ec-6b5074de5b04                  0  (NULL)                               (NULL)                     (NULL)                                       (NULL)                                               (NULL)                                                                                                                                                                                                                                                                                                                                                                                                    p-cloud-pd93-w02          (NULL)               /dev/vda  CentOS6.3_64bit_10G_0401                           1.6815
    nova               cnode03.mkd-stag  ubuntu-vm-hd-test1        admin           (NULL)                  ubuntu-vm-hd-test1        active          active           1           2048             1                   10  hd_test02                                       10                14.63.250.228:3260,iqn.1994-04.jp.co.hitachi:cnode03.mkd-stag,93012311.3002,1,4          instance_type_memory_mb -> 2048 || instance_type_swap -> 0 || instance_type_root_gb -> 0 || instance_type_id -> 57 || instance_type_name -> 1c2g || instance_type_ephemeral_gb -> 0 || instance_type_rxtx_factor -> 1 || instance_type_flavorid -> 2 || instance_type_vcpus -> 1 || image_base_image_ref -> 1bf59a10-193b-46c5-b47a-5a65be2da026                  1  fa:16:3e:9e:91:ba                    14.63.205.37               mokdong.dev.dmz                              compute:nova                                         [{"ovs_interfaceid": null, "network": {"bridge": "brq5829fbee-ee", "subnets": [{"ips": [{"meta": {}, "version": 4, "type": "fixed", "floating_ips": [], "address": "14.63.205.37"}], "version": 4, "meta": {"dhcp_server": "14.63.205.34"}, "dns": [{"meta": {}, "version": 4, "type": "dns", "address": "8.8.8.8"}], "routes": [], "cidr": "14.63.205.32/27", "gateway": {"meta": {}, "version": null, "tubuntu-vm-hd-test1address"2014-04-22 02:40:56{"/dev/vda":CentOS6.3_64bit_140327-multinic-10Gtestf5          1.3215
    */
    SELECT    
        ni.availability_zone     AS vm_zone,
        ni.host                 AS vm_host,
        ni.hostname             AS vm_name,
        
        kp.name                 AS project_name,
        ku.name                 AS user_name,
        -- ku.password as user_password,
        -- ku.extra as user_info,
    
        '' as blank1,
    
        ni.display_description    AS vm_desc,    
        -- ni.power_state         AS vm_power_state_code,
        CASE ni.power_state
            WHEN '0' THEN 'inactive'
            WHEN '1' THEN 'active'
            ELSE '-'
        END                        AS vm_power_state,
        
        ni.vm_state                AS vm_state,
        ni.vcpus                   AS vm_vcpus,    
        ni.memory_mb               AS "vm_memory(MB)",    
    
        -- vm's volume info
        (SELECT COUNT(*) FROM cinder.volumes AS vol
         WHERE  vol.deleted_at IS NULL 
         AND    ni.uuid = vol.instance_uuid)     AS vm_vol_count,
    
        (SELECT SUM(vol.size) FROM cinder.volumes AS vol
         WHERE  vol.deleted_at IS NULL 
         AND    ni.uuid = vol.instance_uuid)     AS "vm_vol_size_sum(GB)",

        (SELECT GROUP_CONCAT(vol.display_name SEPARATOR ' ')
         FROM   cinder.volumes AS vol
         WHERE  vol.deleted_at IS NULL 
         AND    ni.uuid = vol.instance_uuid)     AS vm_vol_names,
    
        (SELECT GROUP_CONCAT(vol.size SEPARATOR '-')
         FROM   cinder.volumes AS vol
         WHERE  vol.deleted_at IS NULL 
         AND    ni.uuid = vol.instance_uuid)        AS "vm_vol_sizes(GB)",
    
        (SELECT GROUP_CONCAT(vol.provider_location SEPARATOR ' ')
         FROM   cinder.volumes AS vol
         WHERE  vol.deleted_at IS NULL 
         AND    ni.uuid = vol.instance_uuid)    AS "vm_vol_locs",
        
        '' as blank2,
        
        -- vm system_meta info
        (SELECT GROUP_CONCAT( CONCAT(nism.key,' -> ', nism.value) SEPARATOR ' || ') AS meta_kv
         FROM   nova.instance_system_metadata AS nism
         WHERE  ni.uuid = nism.instance_uuid)   AS vm_system_meta_infos,
    
        -- vm's network info
        (SELECT COUNT(*)
         FROM   neutron.ports AS qp
         WHERE  ni.uuid = qp.device_id)         AS vm_nic_count,
    
        (SELECT GROUP_CONCAT(qp.mac_address SEPARATOR ' ')
         FROM   neutron.ports AS qp
         WHERE  ni.uuid = qp.device_id)         AS vm_macs,

         (SELECT GROUP_CONCAT(qi.ip_address SEPARATOR ' ')
          FROM   neutron.ports AS qp, neutron.ipallocations AS qi
          WHERE  ni.uuid = qp.device_id
            AND qp.id = qi.port_id)             AS vm_ips,
        
        (SELECT GROUP_CONCAT(qn.name SEPARATOR ' ')
         FROM   neutron.ports AS qp, neutron.networks AS qn
         WHERE  ni.uuid = qp.device_id
           AND  qp.network_id = qn.id)         AS vm_networks,
                
        (SELECT GROUP_CONCAT(qp.device_owner SEPARATOR ' ')
         FROM   neutron.ports AS qp
         WHERE  ni.uuid = qp.device_id)         AS vm_devices_owners,
    
        niic.network_info AS network_info,                
        '' blank3,     
        
        ni.hostname                             AS vm_hostname,    
        ni.launched_at                          AS vm_start_dt,
        ni.root_device_name                     AS vm_root,
        
        -- ni.task_state as vm_task_state,
        -- ni.node as vm_node,
                
        gi.name                                 AS image_name,
        gi.size/1000000000                      AS 'image_size(GB)'
        
    FROM 
        nova.instances AS ni
        LEFT OUTER JOIN keystone.project AS kp
            ON ni.project_id = kp.id
    
        LEFT OUTER JOIN keystone.user AS ku
            ON ni.user_id = ku.id
    
        LEFT OUTER JOIN glance.images AS gi
            ON ni.image_ref = gi.id
    
        LEFT OUTER JOIN nova.instance_info_caches AS niic
            ON (ni.uuid = niic.instance_uuid AND niic.deleted_at IS NULL)
            
    WHERE 
        ni.deleted_at IS NULL
        -- and ni.hostname = 'pos-dev-ktis'
        
    ORDER BY 1,2,3
"""

ng_sql['openstack_host_usage'] = """
    -- openstack host의 사용현황 정보를 보여준다
    /*
    zone               host              total_vcpu(x5)  used_vcpu  percent_vcpu(%)  total_mm(MB)  used_mm(MB)  percent_mm(%)          service_id   vcpus  memory_mb  local_gb  vcpus_used  memory_mb_used  local_gb_used  hypervisor_type  hypervisor_version  cpu_info                                                                                                                                                                                                                                                                                                 disk_available_least  free_ram_mb  free_disk_gb  current_workload  running_vms  
    -----------------  ----------------  --------------  ---------  ---------------  ------------  -----------  -------------  ------  ----------  ------  ---------  --------  ----------  --------------  -------------  ---------------  ------------------  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  --------------------  -----------  ------------  ----------------  -------------
    mokdong.dev.ktis   cnode01.mkd-stag              80          2           2.5000         48167         2560         5.3148                  27      16      48167       458           2            2560              0  QEMU                        1000000  {"vendor": "Intel", "model": "Westmere", "arch": "x86_64", "features": ["rdtscp", "pdpe1gb", "dca", "pcid", "pdcm", "xtpr", "tm2", "est", "smx", "vmx", "ds_cpl", "monitor", "dtes64", "pclmuldq", "pbe", "tm", "ht", "ss", "acpi", "ds", "vme"], "topology": {"cores": 4, "threads": 2, "sockets": 2}}                   313        45607           458                 0              2
    mokdong.dev.ktis   cnode02.mkd-stag              80          2           2.5000         48167         2560         5.3148                  42      16      48167       458           2            2560              0  QEMU                        1000000  {"vendor": "Intel", "model": "Westmere", "arch": "x86_64", "features": ["rdtscp", "pdpe1gb", "dca", "pcid", "pdcm", "xtpr", "tm2", "est", "smx", "vmx", "ds_cpl", "monitor", "dtes64", "pclmuldq", "pbe", "tm", "ht", "ss", "acpi", "ds", "vme"], "topology": {"cores": 4, "threads": 2, "sockets": 2}}                   402        45607           458                 0              2
    mokdong.dev.dmz    cnode03.mkd-stag              80          6           7.5000         48167         7680        15.9445                  30      16      48167       458           6            7680              0  QEMU                        1000000  {"vendor": "Intel", "model": "Westmere", "arch": "x86_64", "features": ["rdtscp", "pdpe1gb", "dca", "pcid", "pdcm", "xtpr", "tm2", "est", "smx", "vmx", "ds_cpl", "monitor", "dtes64", "pclmuldq", "pbe", "tm", "ht", "ss", "acpi", "ds", "vme"], "topology": {"cores": 4, "threads": 2, "sockets": 2}}                   195        40487           458                 2              6
    mokdong.dev.dmz    cnode04.mkd-stag              80          4           5.0000         15911         5632        35.3969                  48      16      15911       916           4            5632              0  QEMU                        1000000  {"vendor": "Intel", "model": "Westmere", "arch": "x86_64", "features": ["rdtscp", "pdpe1gb", "dca", "pcid", "pdcm", "xtpr", "tm2", "est", "smx", "vmx", "ds_cpl", "monitor", "dtes64", "pclmuldq", "pbe", "tm", "ht", "ss", "acpi", "ds", "vme"], "topology": {"cores": 4, "threads": 2, "sockets": 2}}                   450        10279           916                 0              4
    mokdong.prod.ktis  cnode05.mkd-stag              80         10          12.5000         48167        11776        24.4483                  33      16      48167       458          10           11776              0  QEMU                        1000000  {"vendor": "Intel", "model": "Westmere", "arch": "x86_64", "features": ["rdtscp", "pdpe1gb", "dca", "pcid", "pdcm", "xtpr", "tm2", "est", "smx", "vmx", "ds_cpl", "monitor", "dtes64", "pclmuldq", "pbe", "tm", "ht", "ss", "acpi", "ds", "vme"], "topology": {"cores": 4, "threads": 2, "sockets": 2}}                   212        36391           458                 0              3
    mokdong.prod.ktis  cnode06.mkd-stag              80         13          16.2500         48167        24064        49.9595                  36      16      48167       458          13           24064              0  QEMU                        1000000  {"vendor": "Intel", "model": "Westmere", "arch": "x86_64", "features": ["rdtscp", "pdpe1gb", "dca", "pcid", "pdcm", "xtpr", "tm2", "est", "smx", "vmx", "ds_cpl", "monitor", "dtes64", "pclmuldq", "pbe", "tm", "ht", "ss", "acpi", "ds", "vme"], "topology": {"cores": 4, "threads": 2, "sockets": 2}}                   429        24103           458                 3              5
    mokdong.prod.dmz   cnode07.mkd-stag              80         22          27.5000         48167        23040        47.8336                  45      16      48167       458          22           23040              0  QEMU                        1000000  {"vendor": "Intel", "model": "Westmere", "arch": "x86_64", "features": ["rdtscp", "pdpe1gb", "dca", "pcid", "pdcm", "xtpr", "tm2", "est", "smx", "vmx", "ds_cpl", "monitor", "dtes64", "pclmuldq", "pbe", "tm", "ht", "ss", "acpi", "ds", "vme"], "topology": {"cores": 4, "threads": 2, "sockets": 1}}                   112        25127           458                 2             14
    mokdong.prod.dmz   cnode08.mkd-stag              80          0           0.0000         48167          512         1.0630                  39      16      48167       458           0             512              0  QEMU                        1000000  {"vendor": "Intel", "model": "Westmere", "arch": "x86_64", "features": ["rdtscp", "pdpe1gb", "dca", "pcid", "pdcm", "xtpr", "tm2", "est", "smx", "vmx", "ds_cpl", "monitor", "dtes64", "pclmuldq", "pbe", "tm", "ht", "ss", "acpi", "ds", "vme"], "topology": {"cores": 4, "threads": 2, "sockets": 2}}                   429        47655           458                 0              0
    */
    SELECT 
        na.name                           AS zone,
        ncn.hypervisor_hostname           AS HOST,
        
        ncn.vcpus*5                        AS 'total_vcpu(x5)',
        ncn.vcpus_used                     AS used_vcpu,
        ncn.vcpus_used/(vcpus*5) *100     AS 'percent_vcpu(%)',
        ncn.memory_mb                     AS 'total_mm(MB)', 
        ncn.memory_mb_used                 AS 'used_mm(MB)', 
        ncn.memory_mb_used/memory_mb*100 AS 'percent_mm(%)',
        '',
        ncn.service_id,
        ncn.vcpus,
        ncn.memory_mb,
        ncn.local_gb,
        ncn.vcpus_used,
        ncn.memory_mb_used,
        ncn.local_gb_used,
        ncn.hypervisor_type,
        ncn.hypervisor_version,
        ncn.cpu_info,
        ncn.disk_available_least,
        ncn.free_ram_mb,
        ncn.free_disk_gb,
        ncn.current_workload,
        ncn.running_vms
        
    FROM 
        nova.compute_nodes AS ncn,
        nova.aggregates       AS na,
        nova.aggregate_metadata AS nam, 
        nova.aggregate_hosts    AS nah
    WHERE 
        ncn.deleted_at IS NULL    
        AND na.id   = nam.aggregate_id
        AND na.id     = nah.aggregate_id
        -- AND b.key= 'availability_zone' -- 나중에 pod가 추가되면 계층구조를 만들어 줘야함.
        AND ncn.hypervisor_hostname = nah.host
        
    ORDER BY memory_mb_used/memory_mb*100 DESC, vcpus_used/(vcpus*5) *100 DESC;

"""

# 여기는 과거 내용

#
# for agent status collect

ng_sql['replace_agent_status'] = """
    REPLACE INTO cdp_urc_status 
        (id, col_datetime, resource_type, hostname, module, 
         sw_version, start_datetime, end_datetime, elapsed_time, 
         processed_rec_num, error_num, error_msg)
    VALUES (
      0, now(), %s, %s, %s, %s, %s, 
      %s, %s, %s, %s, %s
    )
"""   


#
# for manager status collect(only collect errors now)

ng_sql['insert_cdp_urc_manager_error'] = """
    INSERT INTO cdp_urc_manager_error 
        (id, col_datetime, hostname, module, error_msg)
    VALUES (
      0, now(), %s, %s, %s
    )
"""   