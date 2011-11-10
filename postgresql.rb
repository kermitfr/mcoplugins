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

module MCollective
    module Agent
        class Postgresql<RPC::Agent
            metadata    :name        => "postgresql",
                        :description => "PostgreSQL Agent", 
                        :author      => "Marco Mornati",
                        :license     => "GPLv3",
                        :version     => "1.0",
                        :url         => "http://www.kermit.fr",
                        :timeout     => 120

        action "execute_sql" do
               Log.debug "Executing execute_sql Action"
               conffile = '/etc/kermit/kermit.cfg'
               section = 'postgresql'

               baseurl = getkey(conffile, section, 'sqlrepo')
               db_user = getkey(conffile, section, 'dbuser')
               logmsg  = "Contacting repository using URL #{baseurl}"
               logmsg << " to request #{request[:sqlfile]}"
               Log.debug logmsg 
               fileout = download(baseurl, request[:sqlfile], '/tmp')

               unless File.exists?(fileout)
                   reply['status'] = "Error - Unable to get #{request[:sqlfile]}"
                   reply.fail! "Error - Unable to get #{request[:sqlfile]} "
               end

               cmd = "psql -U #{db_user} < #{fileout}"
               Log.debug "Executing command #{cmd}"
               result = %x[#{cmd}]
               file_name = "/tmp/sql.log.#{Time.now.to_i}"
               Log.debug "Creating log file #{file_name}"
	           File.open(file_name, 'w') {|f| f.write(result) }
               reply['logfile'] =file_name

        end

        action "get_databases" do
                Log.debug "Executing get_databases Action"
                databaselist = get_databases
                reply['databases'] = databaselist
        end

        action "get_database_size" do
                Log.debug "Executing get_databases Action"
                db_name = request[:dbname]
                result = get_database_size(db_name)
                reply['size'] = result
        end

        action "get_tables" do
                Log.debug "Executing get_tables Action"
                db_name = request[:dbname]
                tables = get_tables(db_name)
                reply['tables'] = tables
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
            query = 'SELECT pg_database.datname as "Database",pg_user.usename'
            query << ' as "Owner" FROM pg_database, pg_user'
            query << ' WHERE pg_database.datdba = pg_user.usesysid'
            query << ' UNION'
            query << ' SELECT pg_database.datname as "Database", NULL as "Owner"'
            query << ' FROM pg_database WHERE pg_database.datdba'
            query << ' NOT IN (SELECT usesysid FROM pg_user) ORDER BY "Database"'
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

        def execute_query(query, database=nil)
            conffile = '/etc/kermit/kermit.cfg'
            section = 'postgresql'

           db_user = getkey(conffile, section, 'dbuser')
           cmd = "psql -U #{db_user} -tc \"#{query}\""
           if not database.nil?
               cmd = "psql -U #{db_user} #{database} -tc \"#{query}\""
           end
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

