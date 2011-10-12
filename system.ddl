metadata    :name => "Operations on the operating system",
             :description => "Agent to manage the operating system",
             :author => "Louis Coilliot",
             :license => "Apache License 2.0",
             :version => "0.1",
             :url => "http://www.kermit.fr/",
             :timeout => 10

action "halt", :description => "halt -p" do
    output :output,
           :description => "Return code from system shutdown",
           :display_as => "Output"
end


