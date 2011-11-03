metadata     :name        => "Inventory information for apps and sys",
             :description => "Inventory for apps and sys",
             :author      => "Louis Coilliot",
             :license     => "",
             :version     => "0.1",
             :url         => "",
             :timeout     => 60



action "jboss", :description => "Get inventory information about JBoss" do
    display :always

    output :result,
           :description => 'The filename of the inventory in json format',
           :display_as  => "Output"
end
