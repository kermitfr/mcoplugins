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
               Log.debug "Contacting repository using URL #{baseurl} to request #{request[:sqlfile]}"
               fileout = download(baseurl, request[:sqlfile], '/tmp')

               unless File.exists?(fileout)
                       reply['status'] = "Error - Unable to get #{request[:sqlfile]}"
                       reply.fail! "Error - Unable to get #{request[:sqlfile]} "
               end

               cmd = "su - postgres -c 'psql < #{fileout}'"
               result = %x[#{cmd}]
               reply['status'] = result

	    end

	    action "get_databases" do
		Log.debug "Executing get_databases Action"
	        query = "SELECT pg_database.datname as \\\"Database\\\",pg_user.usename as \\\"Owner\\\"FROM pg_database, pg_user WHERE pg_database.datdba = pg_user.usesysid UNION SELECT pg_database.datname as \\\"Database\\\", NULL as \\\"Owner\\\"FROM pg_database WHERE pg_database.datdba NOT IN (SELECT usesysid FROM pg_user) ORDER BY \\\"Database\\\""
		cmd = "su - postgres -c 'psql -tc \"#{query}\"'"
		Log.debug "Command RUN: #{cmd}"
                result = %x[#{cmd}]
		databaselist  = Array.new
		result.each {|row| 
			content = row.split('|')
			dbname = content[0]
			owner = content[1]
			#owner = owner.gsub!('\n','')
			data = {
  			  "name" => dbname,
  			  "owner" => owner
			}
			databaselist << data
		}
                reply['status'] = {"databases" => databaselist}
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

