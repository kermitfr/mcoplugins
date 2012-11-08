# Copyright (C) 2011  (<Marco Mornati>) 
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

metadata     :name        => "Libvirt VNC",
             :description => "Control VNC Part of Libvirt Virtual Machines",
             :author      => "Marco Mornati",
             :license     => "GPLv3",
             :version     => "0.1",
             :url         => "",
             :timeout     => 120



action "get_vnc_port", :description => "Get VNC Port for Running VirtualMachines" do
    display :always

    input   :domain,
            :prompt      => "Domain Name",
            :description => "Domain Name",
            :validation  => '^[a-zA-Z\-_\d]+$',
            :type        => :string,
            :optional    => false,
            :maxlength   => 20

    output  :port,
            :description => "Virtal Machine VNC Port",
            :display_as  => "Port"

end


action "start_proxy", :description => "Start WebSocket Proxy" do
    display :always

    input  :domain,
           :prompt      => "Domain Name",
           :description => "Domain Name",
           :validation  => '^[a-zA-Z\-_\d]+$',
           :type        => :string,
           :optional    => false,
           :maxlength   => 20

    output :pid,
           :description => "Proxy Process ID",
           :display_as  => "PID"

end

action "stop_proxy", :description => "Stop WebSocket Proxy" do
    display :always

    input  :port,
           :prompt      => "WebSocket Proxy Port",
           :description => "Proxy port",
           :validation  => '^[a-zA-Z\-_\d]+$',
           :type        => :string,
           :optional    => false,
           :maxlength   => 20

    output :result,
           :description => "Result",
           :display_as  => "Result"

end

