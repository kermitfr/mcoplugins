module MCollective
    module Agent
        class System<RPC::Agent
            metadata    :name => "Operations on the operating system",
                        :description => "Agent to manage the operating system",
                        :author => "Louis Coilliot",
                        :license => "Apache License 2.0",
                        :version => "0.1",
                        :url => "http://www.kermit.fr/",
                        :timeout => 10 

            action "halt" do
                halt 
            end

            private

            def halt 
                cmd = "/sbin/halt -p" 
                %x[#{cmd}]
                reply[:output] = "Return code : #{$?}"
            end
        end
    end
end
