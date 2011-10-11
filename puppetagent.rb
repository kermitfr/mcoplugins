module MCollective
    module Agent
        class Puppetagent<RPC::Agent
            metadata    :name => "Puppet Agent Test",
                        :description => "puppet agent --test",
                        :author => "Louis Coilliot",
                        :license => "Apache License 2.0",
                        :version => "0.1",
                        :url => "http://www.kermit.fr/",
                        :timeout => 120

            action "testing" do
                testing
            end

            private

            def testing
                puppet = "/usr/bin/puppet"
                cmd = [puppet, "agent", "--color no", "--onetime", "--verbose",
                "--ignorecache", "--no-daemonize" , "--no-usecacheonfailure",
                "--no-splay" ]
                if request[:server]
                    cmd << "--server #{request[:server]}"
                end
                cmd = cmd.join(" ")
                reply[:output] = %x[#{cmd}].to_a.last.chomp
            end
        end
    end
end
