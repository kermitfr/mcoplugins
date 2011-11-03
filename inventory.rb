# Copyright (C) 2011 Louis Coilliot (<louis.coilliot@gmail.com>)
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


require 'xmlsimple'
require 'json'
require 'socket'

module MCollective
    module Agent
        class Inventory<RPC::Agent
            metadata :name        => "Inventory information for apps and sys",
                     :description => "Inventory for apps and sys",
                     :author      => "Louis Coilliot",
                     :license     => "",
                     :version     => "0.1",
                     :url         => "",
                     :timeout     => 60

            action "jboss" do
                jbossinv        
            end

            private

            # Get the jboss run cmd from the system
            def run_cmd
                cmd="/bin/ps aux"
                cmdout = %x[#{cmd}]
                cmdout.each_line do |line|
                    next unless line =~ /jboss/
                    if line =~ /\/bin\/run.sh\s+/
                        return line
                    end
                end
                nil
            end
            
            # Get the java run cmd from the system
            def java_cmd
                cmd="/bin/ps aux"
                cmdout = %x[#{cmd}]
                cmdout.each_line do |line|
                    next unless line =~ /jboss/
                    if line =~ /\/bin\/java\s+/
                        return line
                    end
                end
                nil
            end
            
            
            # 1st attempt to guess JBoss home
            def guess_jboss_home1(cmdline)
                if cmdline =~ /\s(\/[^\s]*)\/bin\/run.sh\s+/
                    return $1 
                end
                nil
            end
            
            
            # 2d attempt to guess JBoss home
            def guess_jboss_home2(jbinit)
                return nil unless FileTest.readable? jbinit
                File.open(jbinit).each do |line|
                    next unless line =~ /^\s*JBOSS_HOME=.*["'](.*)["']/ 
                    return $1
                end
                nil
            end
            
            # 1st attempt to guess java bin 
            def guess_java_bin1(javacmd)
                if javacmd =~ /\s(\/[^\s]*\/bin\/java)\s+/
                    return $1 
                end
                nil
            end
            
            # 2d attempt to guess java bin
            def guess_java_bin2(jbinit)
                return nil unless FileTest.readable? jbinit
                File.open(jbinit).each do |line|
                    next unless line =~ /^\s*JAVAPTH=.*["'](.*)["']/ 
                    puts $1
                    return $1
                end
                nil
            end
            
            # Get the jboss version using jmx and twiddle.sh
            # jmx = Java Management eXtensions
            def jboss_ver(jbosshome)
                twiddlecmd = "#{jbosshome}/bin/twiddle.sh -q get "
                twiddlecmd << "'jboss.system:type=Server' VersionNumber"
                jbossver = %x[#{twiddlecmd}].split('=')[1]
                jbossver = nil unless $? == 0
                jbossver.chomp! if jbossver
                File.delete('twiddle.log') if File.exists?('twiddle.log') 
                jbossver
            end
            
            # Get the active jboss instance from the running command line
            def active_instance(cmdline)
                if cmdline =~ /\-c\s+(.*?)\s+/
                    return $1 
                end
                nil
            end
            
            # Get the java version by running the java binary
            def java_ver(javabin)
                javaverline = javabin ? %x[#{javabin} -version 2>&1] : nil 
                if javaverline =~ /java version "(.*)"/
                    return $1
                end
                nil
            end
            
            # List the data sources in an instance
            def ds_list(folder, dstypes)
                dslist  = Array.new
                Dir.glob("#{folder}deploy/**/*-ds.xml").each do|f| 
                    data = XmlSimple.xml_in(f)
                    dstypes.each do |type|
                       if data[type]
                           data[type].each do |ds|
                               dslist << ds["jndi-name"][0] if ds["jndi-name"][0]
                           end
                       end
                    end
                end
                dslist
            end
            
            # List the applications in an instance
            def app_list(folder, archivetypes)
                applist = Array.new    
                archivetypes.each do |atype|
                    Dir.glob("#{folder}deploy/**/*.#{atype}").each do|f| 
                        applist << File.basename(f)
                    end
                end
                applist
            end

            def jbossinv
                jbinit  = '/etc/init.d/jboss'
                
                archivetypes = [ 'war' , 'ear' ] 
                
                dstypes = [
                'no-tx-datasource',
                'local-tx-datasource',
                'xa-datasource',
                'ha-local-tx-datasource',
                'ha-xa-datasource' ]
                
                inventory = Hash.new

                cmdline=run_cmd
                
                javacmd=java_cmd
                
                jbosshome = guess_jboss_home1(cmdline) || guess_jboss_home2(jbinit)
                
                javabin = guess_java_bin1(javacmd) || guess_java_bin2(jbinit)
                
                inventory[:java_bin] = javabin
                
                inventory[:java_ver] = java_ver(javabin)
                
                inventory[:server_name] = active_instance(cmdline)
                
                inventory[:jboss_ver] = jboss_ver(jbosshome)
                
                inventory[:jboss_home] = jbosshome
                
                instancelist=Array.new
                
                if jbosshome
                    Dir["#{jbosshome}/server/*/"].each do |folder|
                        if File.directory? "#{folder}/deploy"
                            instancehash = Hash.new
                            instancename = File.basename(folder)
                            instancehash[:name] = instancename
                            instancehash[:applilist] = app_list(folder, archivetypes)
                            instancehash[:datasources]  = ds_list(folder,  dstypes) 
                            instancelist << instancehash
                        end
                    end
                end
                
                inventory[:instances] = instancelist
                
                hostname = Socket.gethostname
                
                jsoncompactfname="/tmp/jbossinventory-#{hostname}-compact.json"
                jsoncompactout = File.open(jsoncompactfname,'w')
                jsoncompactout.write(JSON.generate(inventory))
                jsoncompactout.close
                
                jsonprettyfname="/tmp/jbossinventory-#{hostname}-pretty.json"
                jsonprettyout = File.open(jsonprettyfname,'w')
                jsonprettyout.write(JSON.pretty_generate(inventory))
                jsonprettyout.close
                
                cmd1 = "ruby /usr/local/bin/kermit/queue/send.rb #{jsoncompactfname}"
                cmd2 = "ruby /usr/local/bin/kermit/queue/send.rb #{jsonprettyfname}"
                
                %x[#{cmd1}]
                %x[#{cmd2}]
                
                reply['result'] = jsoncompactfname
            end
        end
    end
end


