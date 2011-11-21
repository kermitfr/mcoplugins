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

#require 'curb'
require 'inifile'
require 'socket'
require 'json'
require 'base64'

module MCollective
    module Agent
        class Oracledb<RPC::Agent
            metadata    :name        => "oracledb",
                        :description => "OracleDB Agent", 
                        :author      => "Marco Mornati",
                        :license     => "GPLv3",
                        :version     => "1.0",
                        :url         => "http://www.kermit.fr",
                        :timeout     => 60

        action "execute_sql" do
            reply.fail! "Error - No Oracle server found or started" unless check_oracle
            Log.debug "Executing execute_sql Action"
            conffile = '/etc/kermit/kermit.cfg'
            section = 'oracledb'

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
	    oracle_sys_user = Base64.decode64(getkey(conffile, section, 'oracle_sys_user'))
	    cmd = "su #{oracle_sys_user} <<- 'END'
export ORACLE_HOME=/u01/app/oracle/product/1120/db11g01;
export ORACLE_BASE=/u01/app/oracle; 
export ORACLE_SID=tetrix02;
export PATH=$ORACLE_HOME/bin:$PATH
sqlplus -s #{db_user}/#{db_password} @#{fileout}
END
"
            Log.debug "Executing command #{cmd}"
            result = %x[#{cmd}]
            file_name = "oracle.sql.log.#{Time.now.to_i}"
            Log.debug "Creating log file #{file_name}"
            File.open("/tmp/#{file_name}", 'w') {|f| f.write(result) }
            send_log("/tmp/#{file_name}")
            reply['logfile'] = file_name
        end

        action "inventory" do
            reply.fail! "Error - No Oracle server found or started" unless check_oracle
	    Log.debug "Check Oracle OK!!"
	    reply['result'] = inventory
        end

        private

        def check_oracle
            conffile = '/etc/kermit/kermit.cfg'
            section = 'oracledb'

            oracle_sys_user = Base64.decode64(getkey(conffile, section, 'oracle_sys_user'))
	    Log.debug "Oracle SysUser: #{oracle_sys_user}"
            cmd = "su #{oracle_sys_user} <<-'END'
export ORACLE_HOME=/u01/app/oracle/product/1120/db11g01
export ORACLE_BASE=/u01/app/oracle 
export ORACLE_SID=tetrix02
export PATH=$ORACLE_HOME/bin:$PATH
echo 'select sysdate from dual;' | sqlplus / as sysdba
END
"     
            Log.debug "Check Oracle Command: #{cmd}"
            result = %x[#{cmd}]
            return $? == 0
        end

        def inventory
            inventory = Hash.new
            instances = get_instances
            inventory[:instances] = instances
            query = "select OWNER, OBJECT_TYPE,count(*) from dba_objects "
            query << " where owner not in"
            query << " ('WMSYS','SYSTEM','SYS','OUTLN','ORAEXPLOIT','DBSNMP','APPQOSSYS','BATCH','ORACLE_OCM','PUBLIC')"
            query << " group by owner,object_type order by owner,object_type;"
            instances.each do |instance|
                result = execute_query(generate_query_file(query))
		instance_data = []
            	result.each_line do |resultline|
			if not resultline.nil?
				line_content = resultline.split(/;/)
				if line_content.length == 3
					data = {"user_name" => line_content[0].strip!,
						"obj_type" => line_content[1].strip!,
						"number" => line_content[2].strip! }
					Log.debug "Line content: #{data}"
					instance_data << data
				else
					Log.warn "Wrong response line size: #{line_content}"
				end
			end
		end
		instance[:data] = instance_data
	    end
            jsonfilename = send_inventory(dump_inventory('oracledb', inventory))
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

        def generate_query_file(query)
            file_name = "/tmp/query.#{rand(36**16).to_s(36)}.#{Time.now.to_i}.sql"
            the_file=File.open( file_name, "w" ) 
            the_file.puts "SET COLSEP \";\""
            the_file.puts "SET PAGESIZE 0"
            the_file.puts "SET TRIMSPOOL on"
            the_file.puts "SET HEADSEP off"
            the_file.puts "SET LINESIZE 32000"
            the_file.puts "#{query}"
            the_file.puts "EXIT 0"
            the_file.close
            file_name 
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

        def get_instances
            instances = []
            File.open("/etc/oratab").each do |line|
                if not /^#/.match( line ) and not /^\n/.match( line )
                    data = line.split(':')
                    if data.length == 3 and not data[0] == '*'
                        i_data = {
                            "instance_name" => data[0],
                            "instance_home" => data[1],
                            "run_at_startup" => data[2]
                        }
                        instances << i_data
                    end
                end
            end
            instances
        end 

        def execute_query(sql_file_name, database=nil)
            conffile = '/etc/kermit/kermit.cfg'
            section = 'oracledb'

            oracle_sys_user = Base64.decode64(getkey(conffile, section, 'oracle_sys_user'))
            cmd = "su #{oracle_sys_user} <<- 'END'
export ORACLE_HOME=/u01/app/oracle/product/1120/db11g01
export ORACLE_BASE=/u01/app/oracle; export ORACLE_SID=tetrix02
export PATH=$ORACLE_HOME/bin:$PATH
sqlplus -s / as sysdba @#{sql_file_name}
END
" 

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
            #Curl::Easy.download(url,filename=fileout)
            cmd="wget #{url} -O #{fileout}"
            %x[#{cmd}]
            fileout
        end

        end
    end
end

