require 'socket'
module MCollective
    module Agent 
        # Inspired with the agent meta.rb of R.I.Pienaar
        class Nodeinfo<RPC::Agent

            action "basicinfo" do
                result = {:agentlist => [],
                          :facts => {},
                          :classes => []}

                cfile = Config.instance.classesfile
                if File.exist?(cfile)
                    result[:classes] = File.readlines(cfile).map {|i| i.chomp}
                end

                result[:agentlist] = Agents.agentlist

                #facts = PluginManager["facts_plugin"].get_facts()
                #selectedkeys=['architecture','lsbdistdescription','fqdn']
                #facts.delete_if{|k, v| !selectedkeys.include? k}  

                begin
                    distrel = File.open('/etc/redhat-release','r')
                    lsbdistdesc=distrel.gets.chomp
                rescue
                    #lsbdistdesc='Unknown'
                    lsbdistdesc=`uname -s -v`.chomp
                end

                facts = {'architecture' => RUBY_PLATFORM,
                         #'fqdn' => Socket.gethostbyname(Socket.gethostname).first,
                         'fqdn' => `hostname`.chomp,
                         'lsbdistdescription' => lsbdistdesc}
                result[:facts] = facts

                reply.data = result 
            end
        end
    end
end
# vi:tabstop=4:expandtab:ai
