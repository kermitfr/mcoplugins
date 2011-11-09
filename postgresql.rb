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
               Log.debug "Contacting repository using URL #{baseurl} to request #{request[:sqlfile]}"
               fileout = download(baseurl, request[:sqlfile], '/tmp')

               unless File.exists?(fileout)
                       reply['status'] = "Error - Unable to get #{request[:sqlfile]}"
                       reply.fail! "Error - Unable to get #{request[:sqlfile]} "
               end

               cmd = "psql -U #{db_user} < #{fileout}"
	       Log.debug "Executing command #{cmd}"
               result = %x[#{cmd}]
               reply['status'] = result

	    end

	    action "get_databases" do
		Log.debug "Executing get_databases Action"
		conffile = '/etc/kermit/kermit.cfg'
                section = 'postgresql'

                db_user = getkey(conffile, section, 'dbuser')
                databaselist = get_databases(db_user)
		reply['status'] = {"databases" => databaselist}
	    end

	    def get_databases(db_user) 
	    	query = "SELECT pg_database.datname as \\\"Database\\\",pg_user.usename as \\\"Owner\\\"FROM pg_database, pg_user WHERE pg_database.datdba = pg_user.usesysid UNION SELECT pg_database.datname as \\\"Database\\\", NULL as \\\"Owner\\\"FROM pg_database WHERE pg_database.datdba NOT IN (SELECT usesysid FROM pg_user) ORDER BY \\\"Database\\\""
                cmd = "psql -U #{db_user} -tc \"#{query}\""
                Log.debug "Command RUN: #{cmd}"
                result = %x[#{cmd}]
                databaselist  = Array.new
		if not result.nil? and not result.empty?
                  result.each {|row|
                        content = row.split('|')
			if not content.nil? and not content.empty? and not content[0].nil? and not content[0].empty? and not content[1].nil? and not content[1].empty?
                          dbname = content[0].strip
                          owner = content[1].strip
                          #owner = owner.gsub!('\n',' ')
                          data = {
                            "name" => dbname,
                            "owner" => owner
                          }
                          databaselist << data
                       end
                  }
                end
		databaselist
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

