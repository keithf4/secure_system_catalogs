/*
 * Check PostgreSQL version number. 
 * Parameter must be full 3 point version if prior to 10.0. Otherwise 2 point version.
 * Returns true if current version is greater than or equal to the parameter given.
 */
CREATE OR REPLACE FUNCTION check_version(p_check_version text) RETURNS boolean
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE

v_check_version     text[];
v_current_version   text[] := string_to_array(current_setting('server_version'), '.');
 
BEGIN

v_check_version := string_to_array(p_check_version, '.');

IF substring(v_current_version[1] from 'devel') IS NOT NULL THEN
    -- You're running a test version. You're on your own if things fail.
    RETURN true;
END IF;
IF v_current_version[1]::int > v_check_version[1]::int THEN
    RETURN true;
END IF;
IF v_current_version[1]::int = v_check_version[1]::int THEN
    IF substring(v_current_version[2] from 'beta') IS NOT NULL 
        OR substring(v_current_version[2] from 'alpha') IS NOT NULL 
        OR substring(v_current_version[2] from 'rc') IS NOT NULL 
    THEN
        -- You're running a test version. You're on your own if things fail.
        RETURN true;
    END IF;
    IF v_current_version[2]::int > v_check_version[2]::int THEN
        RETURN true;
    END IF;
    IF v_current_version[2]::int = v_check_version[2]::int THEN
        IF array_length(v_current_version, 1) <= 2 THEN
            -- Account for reduction to 2 number version in 10.0
            RETURN true;
        END IF; 
        IF v_current_version[3]::int >= v_check_version[3]::int THEN
            RETURN true;
        END IF; -- 0.0.x
    END IF; -- 0.x.0
END IF; -- x.0.0

RETURN false;

END
$$;


/*
 * Run pg_ls_dir for given path
 */
CREATE FUNCTION pg_ls_dir(text) RETURNS SETOF text 
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN 
    RETURN query(SELECT pg_catalog.pg_ls_dir($1)); 
END
$$;

REVOKE ALL ON FUNCTION @extschema@.pg_ls_dir(text) FROM PUBLIC;


/*
 * Returns all values from pg_settings system catalog
 */
CREATE FUNCTION pg_settings() RETURNS SETOF pg_catalog.pg_settings 
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN 
    RETURN query(SELECT * FROM pg_catalog.pg_settings); 
END
$$;

REVOKE ALL ON FUNCTION @extschema@.pg_settings() FROM PUBLIC;

CREATE VIEW @extschema@.pg_settings AS SELECT * FROM @extschema@.pg_settings(); 

REVOKE ALL ON @extschema@.pg_settings FROM PUBLIC;


/*
 * Return all sessions from pg_stat_activity with all columns visible
 * Also includes extra columns to provide runtime intervals
 */
CREATE FUNCTION pg_stat_activity() returns SETOF pg_catalog.pg_stat_activity 
LANGUAGE PLPGSQL SECURITY DEFINER
AS $$
BEGIN 
    RETURN query(SELECT * FROM pg_catalog.pg_stat_activity); 
END
$$ ; 

REVOKE ALL ON FUNCTION @extschema@.pg_stat_activity() FROM PUBLIC;

DO $$
BEGIN
IF @extschema@.check_version('9.6.0') THEN

    CREATE VIEW @extschema@.pg_stat_activity AS 
        SELECT datid
                , datname
                , pid
                , usesysid
                , usename
                , application_name
                , client_addr
                , client_hostname
                , client_port
                , backend_start
                , xact_start
                , query_start
                , state_change
                , wait_event_type
                , wait_event
                , state
                , backend_xid
                , backend_xmin
                , query 
                , now() - xact_start AS xact_runtime
                , now() - query_start AS query_runtime
                , now() - backend_start AS session_runtime
        FROM @extschema@.pg_stat_activity();

ELSIF @extschema@.check_version('9.4.0') THEN

    CREATE VIEW @extschema@.pg_stat_activity AS
        SELECT datid
                , datname
                , pid
                , usesysid
                , usename
                , application_name
                , client_addr
                , client_hostname
                , client_port
                , backend_start
                , xact_start
                , query_start
                , state_change
                , waiting
                , state
                , backend_xid
                , backend_xmin
                , query
                , now() - xact_start AS xact_runtime
                , now() - query_start AS query_runtime
                , now() - backend_start AS session_runtime
        FROM @extschema@.pg_stat_activity();

ELSE
 
    CREATE VIEW @extschema@.pg_stat_activity AS
        SELECT datid
                , datname
                , pid
                , usesysid
                , usename
                , application_name
                , client_addr
                , client_hostname
                , client_port
                , backend_start
                , xact_start
                , query_start
                , state_change
                , waiting
                , state
                , query
                , now() - xact_start AS xact_runtime
                , now() - query_start AS query_runtime
                , now() - backend_start AS session_runtime
        FROM @extschema@.pg_stat_activity();

END IF;

END
$$;

REVOKE ALL ON pg_stat_activity FROM PUBLIC;

-- pg_tablespace() requires data type as return set because you can't 
-- have a RETURNS TABLE function with the same column names as the query() columns
CREATE TYPE tblspc_result AS (spcoid oid, spcname name, spcowner oid, spcacl aclitem[], spcoptions text[], spclocation text);
/*
 * Return all data from pg_tablespace system catalog
 */
CREATE FUNCTION pg_tablespace() RETURNS SETOF tblspc_result
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN 
    RETURN query(SELECT oid
                    , spcname
                    , spcowner
                    , spcacl
                    , spcoptions
                    , pg_tablespace_location(oid) AS spclocation
                 FROM pg_catalog.pg_tablespace); 
END
$$; 
    -- Not sure why this is returning null values for most columns
--    RETURN query(SELECT spcname, null::oid, spclocation, null::aclitem[], null::text[]  
--                 FROM pg_catalog.pg_tablespace WHERE spclocation <> ''); end$$ language plpgsql security definer; 
REVOKE ALL ON FUNCTION @extschema@.pg_tablespace() FROM PUBLIC;

CREATE VIEW @extschema@.pg_tablespace AS 
    SELECT spcoid
        , spcname
        , spcowner
        , spcacl
        , spcoptions
        , spclocation
    FROM @extschema@.pg_tablespace(); 

REVOKE ALL ON @extschema@.pg_tablespace FROM PUBLIC;


