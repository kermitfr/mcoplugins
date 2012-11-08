metadata    :name => "Operations on the operating system",
            :description => "Agent to manage the operating system",
            :author => "Louis Coilliot",
            :license => "Apache License 2.0",
            :version => "0.1",
            :url => "http://www.kermit.fr/",
            :timeout => 10

action "halt", :description => "halt -p" do
    input  :areyousure,
           :prompt      => "Are you sure",
           :description => "Are you sure ?",
           :type        => :string,
           :validation  => '^(yes|no)$',
           :optional    => false,
           :maxlength   => 3

    output :output,
           :description => "Exit code from system shutdown",
           :display_as => "Output"
end


action "reboot", :description => "reboot" do
    input  :areyousure,
           :prompt      => "Are you sure",
           :description => "Are you sure ?",
           :type        => :string,
           :validation  => '^(yes|no)$',
           :optional    => false,
           :maxlength   => 3

    output :output,
           :description => "Exit code from system reboot",
           :display_as => "output"
end

action "ntpdate", :description => "ntpdate" do
    input  :ntpserver,
           :prompt      => "NTP server",
           :description => "The NTP server to synchronize with",
           :type        => :string,
           :validation  => '^[a-zA-Z\-_\d\.]+$',
           :optional    => true,
           :maxlength   => 30

    output :output,
           :description => "Status for ntpdate",
           :display_as => "output"

    output :exitcode,
           :description => "Exit code for ntpdate",
           :display_as => "exitcode"
end



