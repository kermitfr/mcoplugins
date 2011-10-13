metadata    :name => "Puppet Agent Test",
            :description => "puppet agent --test",
            :author => "Louis Coilliot",
            :license => "Apache License 2.0",
            :version => "0.1",
            :url => "http://www.kermit.fr/",
            :timeout => 120 

action "testing", :description => "puppet agent --test" do
    input :server,
          :prompt      => "Puppet master server",
          :description => "The server to query",
          :type        => :string,
          :validation  => '^[a-zA-Z\-_\d\.]+$',
          :optional    => true,
          :maxlength   => 30


    output :output,
           :description => "Output from puppet",
           :display_as => "Output"
end


