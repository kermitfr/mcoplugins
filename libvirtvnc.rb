# Copyright (C) 2011 Louis Coilliot (<louis.coilliot@gmail.com>)
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


require 'xmlsimple'
require 'json'
module MCollective
    module Agent
        class Libvirtvnc<RPC::Agent
            metadata :name        => "Libvirt VNC",
                     :description => "Control VNC Part of Libvirt Virtual Machines",
                     :author      => "Marco Mornati",
                     :license     => "",
                     :version     => "0.1",
                     :url         => "",
                     :timeout     => 120


            action "get_vnc_port" do
                validate :domain, String

                domain = request[:domain]

                conn = connect
                has_domain?(request[:domain], conn)

                retrieved_domain = conn.lookup_domain_by_name(request[:domain])
                reply[:port] = extract_vnc_port(retrieved_domain.xml_desc)
            end

            action "start_proxy" do
                validate :domain, String

                domain = request[:domain]

                conn = connect
                has_domain?(request[:domain], conn)

                retrieved_domain = conn.lookup_domain_by_name(request[:domain])
                vnc_port = extract_vnc_port(retrieved_domain.xml_desc)

                cmd = "/usr/bin/websockify -D 6080 localhost:#{vnc_port}"
                %x[#{cmd}]
                pid_cmd = "ps -e -o pid,command | grep -v grep | grep websockify | awk '{print $1}'"
                result = %x[#{pid_cmd}]
                reply[:pid] = result.strip!
            end

            action "stop_proxy" do
                validate :port, String

                port = request[:port]

                pid_cmd = "ps -e -o pid,command | grep -v grep | grep #{port} | awk '{print $1}'"
                result = %x[#{pid_cmd}]
                kill_cmd = "kill -9 #{result.strip!}"
                result = %x[#{kill_cmd}]
                Log.debug "Kill Result: #{result}"

                reply[:result] = (result.strip!.nil? or result.strip!.empty?) ? "OK" : "#{result}"
            end

            private
            def connect
                url = @config.pluginconf["libvirt.url"] || "qemu:///system"

                conn = ::Libvirt::open(url)

                raise "Could not connect to hypervisor" if conn.closed?

                conn
            end

            def domains(conn)
                domains = []
                conn.list_domains.each do |id|
                    domain = conn.lookup_domain_by_id(id)
                    domains << domain.name
                    domain.free
                end

                domains << conn.list_defined_domains

                domains.flatten.sort
            end

            def has_domain?(domain, conn)
                raise "Unknown domain #{request[:domain]}" unless domains(conn).include?(request[:domain])
            end

            def extract_vnc_port(xml)
                data = XmlSimple.xml_in xml, { 'ForceArray' => false, 'AttrPrefix' => true }
                return data["devices"]["graphics"]["@port"] 
            end
    
        end
    end
end


