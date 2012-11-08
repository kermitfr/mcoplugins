# Copyright (C) 2012 Marco Mornati (<ilmorna@gmail.com>)
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

# /etc/kermit/kermit.cfg properties
#
# [oVirt]
# username=admin@internal
# password=password
# api_url=https://server/api
#

require 'inifile'
require 'fileutils'
require 'rbovirt'

module MCollective
    module Agent
        class Ovirt<RPC::Agent

        action "get_api_version" do
          Log.debug "Executing get_api_version action"
          client = ovirt_connection()
          reply['api_version'] = client.api_version
        end

        action "list_vms" do
          Log.debug "Executing list_vms Action"
          client = ovirt_connection()
          vmlist  = Array.new
          client.vms.each do |vm|
                 vmlist << {"name" => vm.name, "id" => vm.id}
          end
          reply['vms'] = vmlist
        end

        action "vm_details" do
          Log.debug "Executing vm_details Action"
          client = ovirt_connection()
          vm_id = "#{request[:vm_id]}"
          vm = client.vm(vm_id)
          vmdetails = {"name" => vm.name,
                   "id" => vm.id,
                   "memory" => vm.memory,
                   "os" => {"type" => vm.os[:type], "boot" => vm.os[:boot]},
                   "profile" => vm.profile,
                   "status" => vm.status.strip,
                   "vnc" => {"address" => vm.vnc[:address], "port" => vm.vnc[:port]} }
          reply['vm'] = vmdetails
        end

        action "get_clusters" do
          Log.debug "Executing get_clusters Action"
          client = ovirt_connection()
          clusters = Array.new
          client.clusters.each do |cluster|
                  clusters << {"name" => "#{cluster.name}",
                               "id" => "#{cluster.id}"}
          end
          reply["clusters"] = clusters
        end

        action "get_templates" do
           Log.debug "Executing get_templates Action"
           client = ovirt_connection()
           templates = Array.new
           client.templates.each do |template|
                   templates <<  {"name" => "#{template.name}",
                                  "id" => "#{template.id}"}
           end
           reply["templates"] = templates
        end

        action "get_storagedomains" do
          Log.debug "Executing get_storagedomains Action"
          client = ovirt_connection()
          storagedomains = Array.new
          client.storagedomains.each do |storage|
                  storagedomains <<  {"id" => "#{storage.id}",
                  "name" => "#{storage.name}",
                  "kind" => "#{storage.kind}",
                  "path" => "#{storage.path}",
                  "role" => "#{storage.role}",
                  "address" => "#{storage.address}",
                  "used" => "#{storage.used}",
                  "available" => "#{storage.available}"
           }
           end
          reply["storagedomains"] = storagedomains
        end

        action "start_vm" do
          Log.debug "Executing start_vm Action"
          client = ovirt_connection()
          vm_id = "#{request[:vm_id]}"
          response = client.vm_action(vm_id, "start")
          reply['status'] = response
        end

        action "stop_vm" do
          Log.debug "Executing stop_vm Action"
          client = ovirt_connection()
          vm_id = "#{request[:vm_id]}"
          response = client.vm_action(vm_id, "stop")
          reply['status'] = response
        end

        action "create_vm" do
          Log.debug "Executing create_vm Action"
          client = ovirt_connection()
          #VM Information
          vm_name = "#{request[:name]}"
          cluster_id = "#{request[:cluster_id]}"
          template_id = "#{request[:template_id]}"
          memory = "#{request[:memory]}"
          opts = {
              :name => vm_name,
              :cluster => cluster_id,
          }
          unless template_id.nil?
              opts.update({:template => template_id})
          end
          unless memory.nil? 
              opts.update({:memory => memory})
          end
          Log.info "Creating VM with the following options: #{opts}"
          new_vm = client.create_vm(opts)
          Log.info "New VM id: #{new_vm.id}"
          reply['vm_id'] = new_vm.id
        end

        action "add_storage" do
          Log.debug "Executing add_storage Action"
                  client = ovirt_connection()
          vm_id = "#{request[:vm_id]}"
          size = "#{request[:size]}" 
          type = "#{request[:type]}" 
          interface = "#{request[:interface]}"
          format = "#{request[:format]}" 
          bootable = "#{request[:bootable]}"
          opts = {
            :size => size,
            :type => type,
            :interface => interface,
            :format => format
          }
          unless bootable.nil? 
                opts.update({:bootable => bootable})
          end
          client.add_volume(vm_id, opts)
          #TODO: check to improve response
          reply['status'] = "OK" 
        end

        action "add_network" do
           Log.debug "Executing create_vm Action"
           client = ovirt_connection()
           vm_id = "#{request[:vm_id]}"
           interface = "#{request[:interface]}"
           name = "#{request[:name]}"
           network_name = "#{request[:network_name]}"
           opts = { :name => name }
           unless interface.nil?       
                   opts.update({:interface => interface})
           end
           unless network_name.nil?  
                   opts.update({:network_name => network_name})
           end
           client.add_interface(vm_id, opts)
           #TODO: check to improve response
           reply['status'] = "OK"
        end

        private

        def ovirt_connection()
          conffile = '/etc/kermit/kermit.cfg'
          section = 'oVirt'

          username = getkey(conffile, section, 'username')
          password = getkey(conffile, section, 'password')
          api_url = getkey(conffile, section, 'api_url')

          client = OVIRT::Client.new("#{username}", "#{password}", "#{api_url}", nil)
        end

        def getkey(conffile, section, key)
          ini=IniFile.load(conffile, :comment => '#')
          params = ini[section]
          params[key]
        end

        end
    end
end

