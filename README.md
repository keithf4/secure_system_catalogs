Secure System Catalogs
======================

Extension to provide functions/views that give non-superuser roles visibility on catalog objects that are normally only fully visible to a superuser role. Installing the extension alone does not automatically give any user this visibility. Each role must be given explicit privleges to EXECUTE or SELECT the objects installed by this extension. The main use-case for this is when you don't want to use a non-superuser role for monitoring the database with third-party tools (nagios, circonus, zabbix, etc).

INSTALLATION
------------
Requirement: PostgreSQL 9.2+

In the directory where you downloaded this extension, run

    make install

Log into PostgreSQL and run the following commands. Schema is optional (but recommended so it's not in public) and can be whatever you wish, but it cannot be changed after installation. 

    CREATE SCHEMA monitoring;
    CREATE EXTENSION secure_system_catalogs SCHEMA monitoring;

UPGRADE
-------

To upgrade this extension, run "make install" same as above to put the script files in place. Then run the following in PostgreSQL itself:

    ALTER EXTENSION secure_system_catalogs UPDATE TO '<latest version>';

If you are upgrading PostgreSQL itself to a new major version, you may need to DROP & CREATE the extension again. This is due to changes in the system catalogs themselves. The definitions for the views in this extension can only be set during initial creation and there's no easy way to make specific extension versions be tied to specific versions of PostgreSQL. Since this extension has no persistent configuration data, the easiest thing to do is:

    - DROP EXTENSION secure_system_catalogs;
    - Upgrade PostgreSQL to new major version
    - CREATE EXTENSION secure_system_catalogs SCHEMA <yourschema>;

Currently known upgrade paths that require reinstallation are:
    - 9.2 or 9.3 -> 9.4
    - all earlier versions -> 9.6



