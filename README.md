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


LICENSE AND COPYRIGHT
---------------------

secure_system_catalogs is released under the PostgreSQL License, a liberal Open Source license, similar to the BSD or MIT licenses.

Copyright (c) 2017 OmniTI, Inc.

Permission to use, copy, modify, and distribute this software and its documentation for any purpose, without fee, and without a written agreement is hereby granted, provided that the above copyright notice and this paragraph and the following two paragraphs appear in all copies.

IN NO EVENT SHALL THE AUTHOR BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE AUTHOR HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

THE AUTHOR SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND THE AUTHOR HAS NO OBLIGATIONS TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
