# Copyright (C) 2011 Marco Mornati (<ilmorna@gmail.com>) 
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'curb'
require 'inifile'
require 'socket'
require 'json'
require 'base64'

module MCollective
    module Agent
        class Postgresql<RPC::Agent

        action "execute_sql" do
            reply.fail! "Error - No pgsql server found or started" unless check_pg
            Log.debug "Executing execute_sql Action"
            conffile = '/etc/kermit/kermit.cfg'
            section = 'postgresql'

            baseurl = getkey(conffile, section, 'sqlrepo')
            logmsg  = "Contacting repository using URL #{baseurl}"
            logmsg << " to request #{request[:sqlfile]}"
            Log.debug logmsg 
            fileout = download(baseurl, request[:sqlfile], '/tmp')

            unless File.exists?(fileout)
                reply['status'] = "Error - Unable to get #{request[:sqlfile]}"
                reply.fail! "Error - Unable to get #{request[:sqlfile]} "
            end
            db_user = Base64.decode64(getkey(conffile, section, 'dbuser'))
            db_password = Base64.decode64(getkey(conffile, section, 'dbpassword'))
            cmd = "su - postgres -c '"
            if db_password
                cmd << "export PGPASSWORD=\"#{db_password}\";"
            end
            if request[:dbname].nil?
                Log.debug "Executing SQL script without DBName specfied. Need to be present in SQL file"
                cmd << "psql -U #{db_user} < #{fileout}"
            else
                db_name = request[:dbname]
                Log.debug "Executing SQL script with provided DBName: #{db_name}"
                cmd << "psql -U #{db_user} #{db_name} < #{fileout}"
            end
            cmd << "'"
            Log.debug "Executing command #{cmd}"
            result = %x[#{cmd}]
            shorthostname=`hostname -s`.chomp
            file_name = "sql.log.#{shorthostname}.#{Time.now.to_i}"
            Log.debug "Creating log file #{file_name}"
	        File.open("/tmp/#{file_name}", 'w') {|f| f.write(result) }
            send_log("/tmp/#{file_name}")
            reply['logfile'] = file_name
        end

        action "inventory" do
            reply.fail! "Error - No pgsql server found or started" unless check_pg
            reply[:result] = inventory
        end

        action "get_databases" do
            reply.fail! "Error - No pgsql server found or started" unless check_pg
            Log.debug "Executing get_databases Action"
            databaselist = get_databases
            reply['databases'] = databaselist
        end

        action "get_database_size" do
            reply.fail! "Error - No pgsql server found or started" unless check_pg
            Log.debug "Executing get_databases Action"
            db_name = request[:dbname]
            result = get_database_size(db_name)
            reply['size'] = result
        end

        action "get_tables" do
            reply.fail! "Error - No pgsql server found or started" unless check_pg
            Log.debug "Executing get_tables Action"
            db_name = request[:dbname]
            tables = get_tables(db_name)
            reply['tables'] = tables
        end 

        action "get_data_dir" do
            reply.fail! "Error - No pgsql server found or started" unless check_pg
            Log.debug "Executing get_data_dir Action"
            data_dir = get_data_dir
            reply['data_dir'] = data_dir
        end

        action "get_version" do
            reply.fail! "Error - No pgsql server found or started" unless check_pg
            Log.debug "Executing get_version Action"
            version = get_version
            reply['version'] = version
        end

        action "sql_list" do
            filetype = 'sql'
            result = { :sqllist => [] }
            SECTION = 'postgresql'
            MAINCONF = '/etc/kermit/kermit.cfg'
            ini=IniFile.load(MAINCONF, :comment => '#')
            params = ini[SECTION]
            repourl = params['sqlrepo']
            c =  Curl::Easy.perform(repourl)
            pattern = /<a.*?href="(.*#{filetype}?)"/
            m=c.body_str.scan(pattern)
            result[:sqllist] = m.map{ |item| item.first }
            reply.data = result
        end

        private

        def get_tables(database)
            query = "SELECT table_name FROM information_schema.tables"
            query << " WHERE table_type = 'BASE TABLE'"
            query << " and table_schema != 'pg_catalog'"
            query << " and table_schema != 'information_schema';"
            result = execute_query(query, database)     
            tablelist  = Array.new
            return tablelist unless result
            result.each_line do |row|
                 row.strip!
                 tablelist << row unless row.empty?
            end
            tablelist
        end

        def get_database_size(db_name)
            query = "SELECT pg_size_pretty(pg_database_size('#{db_name}'))"
            query << " as database_size"
            result = execute_query(query)
            if not result.nil?
               result = result.strip
               result = result.gsub('\n', '')
            end
            result
        end

        def get_databases 
            query = 'SELECT pg_database.datname as \"Database\",pg_user.usename'
            query << ' as \"Owner\" FROM pg_database, pg_user'
            query << ' WHERE pg_database.datdba = pg_user.usesysid'
            query << ' UNION'
            query << ' SELECT pg_database.datname as \"Database\", NULL as "Owner"'
            query << ' FROM pg_database WHERE pg_database.datdba'
            query << ' NOT IN (SELECT usesysid FROM pg_user) ORDER BY \"Database\"'
            result = execute_query(query)
            databaselist  = Array.new

            return databaselist unless result
            
            result.each_line do |row|
                content = row.split('|')
                if content.length == 2
                    dbname = content[0].strip
                    owner = content[1].strip
                    data = { "name" => dbname, "owner" => owner }
                    databaselist << data
                end
            end
            databaselist
        end

        def get_data_dir
            query = 'SHOW data_directory;'
            result = execute_query(query)
            if not result.nil?
               result = result.strip
               result = result.gsub('\n', '')
            end
            result
        end

        def check_pg
            conffile = '/etc/kermit/kermit.cfg'
            section = 'postgresql'

            db_user = Base64.decode64(getkey(conffile, section, 'dbuser'))
            db_password = Base64.decode64(getkey(conffile, section, 'dbpassword'))
            query = 'select version();'
            cmd = "su - postgres -c '"
            if db_password
                cmd << "export PGPASSWORD=\"#{db_password}\";"
            end
 
            cmd << "psql -U #{db_user} -d postgres -tc \"#{query}\""
            cmd << "'"
            Log.debug "Check Postgres Command: #{cmd}"
            %x[#{cmd}]
            return $? == 0
        end

        def get_version
            query = 'select version();'
            result = execute_query(query)
            if not result.nil?
               result = result.strip
               result = result.gsub('\n', '')
            end
            result 
        end

        def get_users
            query = 'SELECT u.usename AS \"User name\",  u.usesysid AS \"User ID\",  '
            query << 'CASE WHEN u.usesuper AND u.usecreatedb THEN CAST(\'superuser, create database\' AS pg_catalog.text)'
            query << ' WHEN u.usesuper THEN CAST(\'superuser\' AS pg_catalog.text) WHEN u.usecreatedb '
            query << 'THEN CAST(\'create database\' AS pg_catalog.text) ELSE CAST(\'\' AS pg_catalog.text) '
            query << 'END AS \"Attributes\" FROM pg_catalog.pg_user u ORDER BY 1; '
            result = execute_query(query)
            userlist  = Array.new

            return userlist unless result

            result.each_line do |row|
                content = row.split('|')
                if content.length == 3
                    uname = content[0].strip
                    uid = content[1].strip
                    attributes = content[2].strip
                    data = { "username" => uname, "uid" => uid, "attributes" => attributes }
                    userlist << data
                end
            end
            userlist
        end

        def inventory
            inventory = Hash.new

            inventory[:databases] = []
            inventory[:version] = get_version
            
            inventory[:data_dir] = get_data_dir
            inventory[:users] = get_users
            databases = get_databases
            databases.each do |db|
                tables = get_tables(db['name'])
                db_size = get_database_size(db['name'])
                database = {"name" => db['name'], "size" => db_size, "tables" => tables}
                inventory[:databases] << database 
            end
            jsonfilename = send_inventory(dump_inventory('postgresql', inventory))
            jsonfilename
        end

        def dump_inventory(dump_name, inventory)
            hostname = Socket.gethostname

            jsoncompactfname="/tmp/#{dump_name}inventory-#{hostname}-compact.json"
            jsoncompactout = File.open(jsoncompactfname,'w')
            jsoncompactout.write(JSON.generate(inventory))
            jsoncompactout.close

            jsonprettyfname="/tmp/#{dump_name}inventory-#{hostname}-pretty.json"
            jsonprettyout = File.open(jsonprettyfname,'w')
            jsonprettyout.write(JSON.pretty_generate(inventory))
            jsonprettyout.close
            jsoncompactfname 
        end

        def send_log(logfile)
            cmd = "ruby /usr/local/bin/kermit/queue/sendlog.rb #{logfile}"

            %x[#{cmd}]

            logfile
        end

        def send_inventory(jsoncompactfname)
            cmd = "ruby /usr/local/bin/kermit/queue/send.rb #{jsoncompactfname}"

            %x[#{cmd}]

            jsoncompactfname
        end
        
        def execute_query(query, database='postgres')
            conffile = '/etc/kermit/kermit.cfg'
            section = 'postgresql'

            db_user = Base64.decode64(getkey(conffile, section, 'dbuser'))
            db_password = Base64.decode64(getkey(conffile, section, 'dbpassword'))
            cmd = "echo \"#{query}\""
            cmd << " | su - postgres -c '"
            if db_password
                cmd << "export PGPASSWORD=\"#{db_password}\";"
            end
            cmd << "psql -U #{db_user} #{database} -t"
            cmd << "'"
            Log.debug "Command RUN: #{cmd}"

            result = %x[#{cmd}]
            result
        end

        def getkey(conffile, section, key)
            ini=IniFile.load(conffile, :comment => '#')
            params = ini[section]
            params[key]
        end

        # Download a file with Curl
        def download(repourl, file, targetfolder)
            url="#{repourl}/#{file}".gsub(/([^:])\/\//, '\1/')
            fileout = "#{targetfolder}/#{file}".gsub(/([^:])\/\//, '\1/')
            Curl::Easy.download(url,filename=fileout)
            fileout
        end

        end
    end
end

