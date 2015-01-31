CREATE VIEW 'vw_vm_trace' AS 
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
    
    ORDER BY 1,4