metadata    :name        => "Various checks",
            :description => "Various checks",
            :author      => "Louis Coilliot",
            :license     => "GPLv3",
            :version     => "",
            :url         => "",
            :timeout     => 10

action "timegap", :description => "Get the time gap from a ref." do
    display :always

    input   :reftime,
            :prompt      => "Number of seconds since epoch",
            :description => "ruby -r time -e 'puts Time.now.to_i'",
            :type        => :string,
            :validation  => '^\d*$',
            :optional    => false,
            :maxlength   => 10

    output  :output,
            :description => "Time gap between the ref. and the local time (s)",
            :display_as  => "Output"
end

action "fsstat", :description => "Get filesystem list and stats" do
    display :always

    output  :output,
            :description => "File system list with space usage",
            :display_as  => "Output"
end

action "pvs", :description => "Report information about LVM physical volumes" do
    display :always

    output  :output,
            :description => "List of physical volumes with size",
            :display_as  => "Output"
end

action "vgs", :description => "Report information about LVM volume groups" do
    display :always

    output  :output,
            :description => "List of volume groups with space usage",
            :display_as  => "Output"
end

action "lvs", :description => "Report information about LVM logical volumes" do
    display :always

    output  :output,
            :description => "List of logical volumes with size",
            :display_as  => "Output"
end
