metadata    :name        => "Get inventory information from the OS",
            :description => "Inventory of packages, etc.", 
            :author      => "Louis Coilliot",
            :license     => "GPLv3",
            :version     => "0.1",
            :url         => "http://www.kermit.fr",
            :timeout     => 60

action "rpmlist", :description => "Gets the list of installed rpm packages" do
    display :always

    output "rpmlist",
          :description => "List of installed packages",
          :display_as  => "rpm list"
end
