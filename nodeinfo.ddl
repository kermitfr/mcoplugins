metadata     :name    => "Get basic informations on nodes",
             :description => "Get the agents, some facts and puppet classes of a node",
             :author      => "Louis Coilliot",
             :license     => "GPLv3",
             :version     => "1.0",
             :url         => "http://kermit.fr",
             :timeout     => 60


action "basicinfo", :description => "Get basic and light information" do
    display :always

    output :agentlist,
           :description => 'List of agents',
           :display_as  => "Agent list"
    output :classes,
           :description => 'List of classes',
           :display_as  => "Class list"
    output :facts,
           :description => 'Hash of facts',
           :display_as  => "Fact hash"
end

