-- quantum security group info

SELECT
	-- GROUP_CONCAT( qsg.name SEPARATOR ', ')
	qsg.name AS security_group_name, 
	qsg.description  AS security_group_desc,
	'',
	-- qsgr.remote_group_id  AS rule_remote_group_id, 
	qsgr.direction   AS rule_direction, 
	qsgr.ethertype  AS rule_ethertype, 
	qsgr.protocol  AS rule_protocol, 
	qsgr.port_range_min  AS rule_port_range_min, 
	qsgr.port_range_max  AS rule_port_range_max, 
	qsgr.remote_ip_prefix   AS rule_remote_ip_prefix 
FROM
	neutron.securitygroups AS qsg,
	neutron.securitygrouprules AS qsgr
WHERE
	-- ni.project_id = qsg.tenant_id
	qsg.id = qsgr.security_group_id
