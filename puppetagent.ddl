metadata    :name => "Puppet Module",
            :description => "Puppet Operations",
            :author => "Marco Mornati",
            :license => "Apache License 2.0",
            :version => "0.1",
            :url => "http://www.kermit.fr/",
            :timeout => 120 

action "classlist", :description => "Get Puppet Classes List" do

    output :classlist,
           :description => "Defined Classlist",
           :display_as => "Classlist"
end

