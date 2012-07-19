module MCollective
    module Agent
        class Puppetagent<RPC::Agent
            metadata    :name => "Puppet Module",
                        :description => "Puppet Operations",
                        :author => "Marco Mornati",
                        :license => "Apache License 2.0",
                        :version => "0.1",
                        :url => "http://www.kermit.fr/",
                        :timeout => 120

	    action "classlist" do
		class_list
	    end

            private

	    def class_list
		require 'puppet'
		require 'puppet/face'
		require 'pp'

		classlist = Puppet::Face[:resource_type,:current].search('.*').find_all {|x| x.type==:hostclass}.collect{|x| x.name}.sort

		reply[:classlist] = classlist
	    end
        end
    end
end
