module MCollective
    module Agent
        class Puppetagent<RPC::Agent

        action "classlist" do
          class_list
        end

        action "forceupdate" do
          force_update
        end

        private

        def force_update
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

        def class_list
          require 'puppet'
          require 'puppet/face'

          begin
              # for puppet 3 :
              ::Puppet.settings.initialize_global_settings(['--confdir=/etc/puppet'])
	  rescue ::Puppet::DevError
	      # Already initialized
	  end
	  begin
              # Works only on a puppet master
              classlist = ::Puppet::Face[:resource_type,:current].search('.*').find_all {|x| x.type==:hostclass}.collect{|x| x.name}.sort
          rescue RuntimeError, NoMethodError
              classlist = []
          end

          reply[:classlist] = classlist
        end

        end
    end
end
