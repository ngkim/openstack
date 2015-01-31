
-- ip에 설정된 security group을 파악한다.

SELECT 
	qi.ip_address,
	'',
	qp.network_id ,
	qp.mac_address,
	qp.device_owner,	
	qsgpb.*,
	'',
	qsg.name	 
FROM 
	neutron.securitygroupportbindings qsgpb,
	neutron.securitygroups qsg,
	neutron.ports qp,
	neutron.ipallocations AS qi
		
WHERE 
	qsgpb.security_group_id = qsg.id
	AND qsgpb.port_id = qp.id
	AND qp.id = qi.port_id
	
-- host 별 할당된 port list
SELECT 
	qpbp.host,
	'',
	qi.ip_address,
	qp.tenant_id,
	qp.network_id,
	qp.mac_address,
	qp.status,
	qp.device_owner
FROM 
	neutron.portbindingports qpbp,
	neutron.ports qp,	
	neutron.ipallocations AS qi

WHERE
	qpbp.port_id = qp.id
	
	AND qp.id = qi.port_id

ORDER BY 1