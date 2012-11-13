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
require 'curb'
require 'inifile'
require 'fileutils'

module MCollective
    module Agent
        class Jboss7<RPC::Agent

            # JBoss inventory
            action "inventory" do
                jbosshome = guess_jboss_home(run_cmd)
                reply.fail! "Error - Unable to detect JBoss (not started ?)" \
                            unless jbosshome
                inventory
            end

            # List applications available on a repository
            action "applist" do
                result = {:applist => [], :apptype => ""}
                validate :apptype, String
                apptype = request[:apptype]
                c =  Curl::Easy.perform(repourl)
                pattern = /<a.*?href="(.*#{apptype}?)"/
                m=c.body_str.scan(pattern)
                result[:applist] = m.map{ |item| item.first }
                result[:apptype] = apptype
                reply.data = result
            end

            # List the deployed applications of the running instance 
            action "deploylist" do
                webdeployment
            end

            # Deploy an application in JBoss 
            action "deploy" do
                result = {:status => ""}

                validate :appfile, String
                validate :instancename, String

                appfile = request[:appfile]
                instancename = request[:instancename]

                jbosshome = guess_jboss_home(run_cmd)
                reply.fail! "Error - Unable to detect JBoss (not started ?)" \
                            unless jbosshome

                downloadfolder = "#{jbosshome}/server/#{instancename}/"
                deployfolder   = "#{jbosshome}/server/#{instancename}/deploy/"
                reply.fail! "Error - Unable to find #{deployfolder}" \
                            unless File.directory? deployfolder
                create_backup(appfile, deployfolder)
                result[:status] = download(repourl, appfile, downloadfolder)
                srcfile="#{downloadfolder}/#{appfile}"
                # You need to move the file after the download, otherwise
                # if the download takes time, the deployment will start before
                # the end of the download and fail.
                FileUtils.mv(srcfile, deployfolder, :force => true)
                reply.data = result
            end

            # Redeploy an application in JBoss 
            action "redeploy" do
                result = {:status => ""}

                validate :appfile, String
                validate :instancename, String

                appfile = request[:appfile]
                instancename = request[:instancename]

                jbosshome = guess_jboss_home(run_cmd)
                reply.fail! "Error - Unable to detect JBoss (not started ?)" \
                            unless jbosshome

                downloadfolder = "#{jbosshome}/server/#{instancename}/"
                deployfolder   = "#{jbosshome}/server/#{instancename}/deploy/"
                reply.fail! "Error - Unable to find #{deployfolder}" \
                            unless File.directory? deployfolder
        
                #Check presence of app to redeploy in deploy folder (app must exist)
                reply.fail! "Error - Application do redeploy does not exist in target path" \
                            unless check_app_existence(appfile, deployfolder)   
                #Redeploy
                create_backup(appfile, deployfolder)
                result[:status] = download(repourl, appfile, downloadfolder)
                srcfile="#{downloadfolder}/#{appfile}"
                # You need to move the file after the download, otherwise
                # if the download takes time, the deployment will start before
                # the end of the download and fail.
                FileUtils.mv(srcfile, deployfolder, :force => true)
                reply.data = result
            end

            action "undeploy" do
                result = {:status => ""}

                validate :appfile, String
                validate :instancename, String

                appfile = request[:appfile]
                instancename = request[:instancename]

                jbosshome = guess_jboss_home(run_cmd)
                reply.fail! "Error - Unable to detect JBoss (not started ?)" \
                            unless jbosshome

                deployfolder="#{jbosshome}/server/#{instancename}/deploy/"
                reply.fail! "Error - Unable to find #{deployfolder}" \
                            unless File.directory? deployfolder

                File.delete("#{deployfolder}#{appfile}")

                result[:status] = "#{deployfolder}#{appfile}"
                reply.data = result
            end

            action "get_log" do
                result = {:server_log => ""}

                validate :instancename, String

                instancename = request[:instancename]

                jbosshome = guess_jboss_home(run_cmd)
                reply.fail! "Error - Unable to detect JBoss (not started ?)" \
                            unless jbosshome

                logfile="#{jbosshome}/server/#{instancename}/log/server.log"
                reply.fail! "Error - Unable to find #{logfile}" \
                            unless File.exists? logfile

                shorthostname=`hostname -s`.chomp
                file_name = "server.log.#{shorthostname}.#{Time.now.to_i}"

                cmd="tail -n 1000 #{logfile}"
                result=%x[#{cmd}]

                File.open("/tmp/#{file_name}", 'w') {|f| f.write(result) }

                send_log("/tmp/#{file_name}")
                reply['logfile'] = file_name
            end

            action "get_app_backups" do
                validate :appname, String

                appname = request[:appname]
                reply['backups'] = get_app_backups(appname)
            end

            action "rollback" do
                result = {:status => ""}

                validate :backupfile, String
                validate :instancename, String

                backupfile = request[:backupfile]
                instancename = request[:instancename]

                jbosshome = guess_jboss_home(run_cmd)
                reply.fail! "Error - Unable to detect JBoss (not started ?)" \
                            unless jbosshome

                deployfolder="#{jbosshome}/server/#{instancename}/deploy/"
                reply.fail! "Error - Unable to find #{deployfolder}" \
                            unless File.directory? deployfolder
                result[:status] = rollback(backupfile, deployfolder)
                reply.data = result
            end

            private

            # Get the jboss run cmd from the system
            def run_cmd
                Log.info "Trying to identify JBoss using cmd"
                cmd="/bin/ps aux"
                cmdout = %x[#{cmd}]
                cmdout.each_line do |line|
                    next unless line =~ /jboss/
                    Log.debug line
                    if line =~ /\/bin\/java\s+/
                        Log.info "JBoss found: #{line}"
                        return line
                    end
                end
                Log.info "JBoss not found with this method"
                nil
            end

            def guess_jboss_home(cmdline)
                Log.debug "Trying to detect JBOSS_HOME using jboss.home.dir into jboss process"
                if cmdline =~ /\s*-Djboss.home.dir=(.*)/
                  Log.debug "JBoss home found with this method"
                  Log.debug $1
                  return $1
                end
                nil
            end


            # Give the first full path found of a shell command
            def which(program)
                ENV['PATH'].split(File::PATH_SEPARATOR).any? do |directory|
                    if File.executable?(File.join(directory, program.to_s))
                        return "#{directory}/#{program}"
                    end
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

            # Returns the url of the app repository from a ini file
            def repourl
                section = 'as'
                mainconf = '/etc/kermit/kermit.cfg'
                ini=IniFile.load(mainconf, :comment => '#')
                params = ini[section]
                params['apprepo']
            end

            # Download a file with Curl
            def download(repourl, file, targetfolder)
                url="#{repourl}/#{file}".gsub(/([^:])\/\//, '\1/')
                fileout = "#{targetfolder}/#{file}".gsub(/([^:])\/\//, '\1/')
                Curl::Easy.download(url,filename=fileout)
                fileout
            end

            # Main Jboss inventory
            def inventory 
                artypes = [ 'war', 'ear' ]

                dstypes = [
                'no-tx-datasource',
                'local-tx-datasource',
                'xa-datasource',
                'ha-local-tx-datasource',
                'ha-xa-datasource' ]

                inventory = Hash.new

                cmdline=run_cmd

                javacmd=java_cmd

                jbosshome = guess_jboss_home(cmdline)

                javabin   = ""

                inventory[:java_bin] = javabin

                inventory[:java_ver] = java_ver(javabin)

                inventory[:server_name] = active_instance(cmdline)

                inventory[:jboss_ver]  = jboss_ver(jbosshome)

                inventory[:jboss_home] = jbosshome

                instancelist=Array.new

                if jbosshome
                    Dir["#{jbosshome}/server/*/"].each do |folder|
                        if File.directory? "#{folder}/deploy"
                          instancehash = Hash.new
                          instancename = File.basename(folder)
                          instancehash[:name] = instancename
                          instancehash[:applilist] = app_list(folder, artypes)
                          instancehash[:datasources]  = ds_list(folder, dstypes)
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

                cmd  = "ruby /usr/local/bin/kermit/queue/send.rb "
                cmd << "#{jsoncompactfname}"

                %x[#{cmd}]

                reply.data = { :result => jsoncompactfname }
            end

            def send_log(logfile)
                cmd = "ruby /usr/local/bin/kermit/queue/sendlog.rb #{logfile}"

                %x[#{cmd}]

                logfile
            end

            def getkey(conffile, section, key)
                ini=IniFile.load(conffile, :comment => '#')
                params = ini[section]
                params[key]
            end

        end
    end
end

