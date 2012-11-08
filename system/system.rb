module MCollective
    module Agent
        class System<RPC::Agent

            action "halt" do
                halt
            end

            action "reboot" do
                reboot
            end

            action "ntpdate" do
                ntpdate
            end
            
            private

            def halt
                validate :areyousure, String
                if request[:areyousure] == 'yes'
                    cmd = "/sbin/halt -p" 
                    %x[#{cmd}]
                    reply[:output] = "Return code : #{$?}"
                else
                    reply.fail! "Cancelled"
                end
            end

            def reboot
                validate :areyousure, String
                if request[:areyousure] == 'yes'
                    cmd = "/sbin/reboot" 
                    %x[#{cmd}]
                    reply[:output] = "Return code : #{$?}"
                else
                    reply.fail! "Cancelled"
                end
            end

            def ntpdate
                if request[:ntpserver]
                    validate :ntpserver, String
                    ntpsrv = request[:ntpserver]
                else
                    ntpsrv = 'pool.ntp.org'
                end
                cmd = "/usr/sbin/ntpdate"
                cmd << " #{ntpsrv} 2>&1" 
                cmdout = %x[#{cmd}]
                if !cmdout.empty?
                    reply[:output] = cmdout.to_a.last.chomp
                else
                    reply[:output] = ""
                end
                reply[:exitcode] = $?.exitstatus
                reply.fail! "#{reply[:output]}" unless reply[:exitcode] == 0
            end

        end
    end
end
