metadata     :name    => "Get informations on agents",
             :description => "Get actions, inputs, outputs of agents from the DDL",
             :author      => "Louis Coilliot",
             :license     => "GPLv3",
             :version     => "1.0",
             :url         => "http://kermit.fr",
             :timeout     => 60


action "desc", :description => "Get actions, inputs, outputs of agents" do
    display :always

    input   :agentname,
            :prompt      => "Agent Name",
            :description => "The agent to retrieve the information of",
            :type        => :string,
            :validation  => '.',
            :optional    => false,
            :maxlength   => 20

    output  :actionhash,
            :description => 'A hash with { action_name => { hash with action_interface details } }',
            :display_as  => "Actions"
end

