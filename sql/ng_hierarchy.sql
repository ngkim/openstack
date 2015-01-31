SELECT 
    aggregate_metadata.created_at AS aggregate_metadata_created_at,     
    aggregate_metadata.`key` AS aggregate_metadata_key, 
    aggregate_metadata.value AS aggregate_metadata_value, 
    aggregates.name AS aggregates_name, 
    aggregate_hosts_1.created_at AS aggregate_hosts_1_created_at, 
    aggregate_hosts_1.host AS aggregate_hosts_1_host

FROM aggregates INNER JOIN aggregate_metadata 
    ON aggregates.id = aggregate_metadata.aggregate_id AND aggregate_metadata.deleted = 0 AND aggregates.deleted = 0 
    LEFT OUTER JOIN aggregate_hosts AS aggregate_hosts_1 
    ON aggregates.id = aggregate_hosts_1.aggregate_id AND aggregate_hosts_1.deleted = 0 AND aggregates.deleted = 0