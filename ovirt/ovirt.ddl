# Copyright (C) 2012  (<Marco Mornati>) 
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

metadata     :name        => "oVirt Agent",
             :description => "Virtual machine management using oVirt API",
             :author      => "Marco Mornati",
             :license     => "GPLv3",
             :version     => "0.1",
             :url         => "",
             :timeout     => 120

action "get_api_version", :description => "Get the version of oVirt API in use on the server" do
    display :always

    output :api_version,
           :description => 'The version of oVirt API',
           :display_as  => "Api Version"
end

action "list_vms", :description => "Get list of defined virtual machine in the configured oVirt hypervisor" do
    display :always

    output :vms,
           :description => 'The list of defined Virtual Machines',
           :display_as  => "VMs List"
end

action "vm_details", :description => "Get details of provided Virtual Machine" do
    display :always

    input  :vm_id,
           :prompt      => "Virtual Machine ID",
           :description => "Virtual Machine Unique Identification",
           :validation  => '^[a-zA-Z\-_\d]+$',
           :type        => :string,
           :optional    => false,
           :maxlength   => 37

    output :vm,
           :description => 'Details of selected Virtual Machine',
           :display_as  => "VM Details"
end

action "get_clusters", :description => "Get list of defined clusters" do
    display :always

    output  :clusters,
            :description => 'The list of defined Clusters',
            :display_as  => "Clusters"
end

action "get_templates", :description => "Get list of defined Templates" do
    display :always

    output  :templates,
            :description => 'The list of defined Templates',
            :display_as  => "Templates"
end

action "get_storagedomains", :description => "Get list of defined Storage Domains" do
    display :always

    output  :storagedomains,
            :description => 'The list of defined Storage Domains',
            :display_as  => "Storage Domains"
end

action "start_vm", :description => "Start provided Virtual Machine" do
    display :always

    input  :vm_id,
           :prompt      => "Virtual Machine ID",
           :description => "Virtual Machine Unique Identification",
           :validation  => '^[a-zA-Z\-_\d]+$',
           :type        => :string,
           :optional    => false,
           :maxlength   => 37

    output :status,
           :description => 'Status of VM action',
           :display_as  => "Status"
end

action "stop_vm", :description => "Stop provided Virtual Machine" do
    display :always

    input  :vm_id,
           :prompt      => "Virtual Machine ID",
           :description => "Virtual Machine Unique Identification",
           :validation  => '^[a-zA-Z\-_\d]+$',
           :type        => :string,
           :optional    => false,
           :maxlength   => 37

    output :status,
           :description => 'Status of VM action',
           :display_as  => "Status"
end

action "create_vm", :description => "Create a new virtual machine" do
    display :always

    input  :name,
           :prompt      => "Virtual Machine Name",
           :description => "Virtual Machine Name",
           :validation  => '^[a-zA-Z\-_\d]+$',
           :type        => :string,
           :optional    => false,
           :maxlength   => 20

    input  :cluster_id,
           :prompt      => "Cluster ID",
           :description => "Cluster ID",
           :validation  => '^[a-zA-Z\-_\d]+$',
           :type        => :string,
           :optional    => false,
           :maxlength   => 37

    input  :template_id,
           :prompt      => "Template ID",
           :description => "Template ID",
           :validation  => '^[a-zA-Z\-_\d]+$',
           :type        => :string,
           :optional    => true,
           :maxlength   => 37

    input  :memory,
           :prompt      => "Virtual Machine Memory",
           :description => "Virtual Machine Memory",
           :type        => :integer,
           :optional    => true

    output :vm_id,
           :description => 'ID of created Virtual Machine',
           :display_as  => "Virtual Machine ID"
end

action "add_storage", :description => "Add storage to provided Virtual Machine" do
    display :always

    input  :vm_id,
           :prompt      => "Virtual Machine ID",
           :description => "Virtual Machine Unique Identification",
           :validation  => '^[a-zA-Z\-_\d]+$',
           :type        => :string,
           :optional    => false,
           :maxlength   => 37

    input  :size,
           :prompt      => "Storage Size",
           :description => "Storage Size",
           :type        => :integer,
           :optional    => false

    input  :type,
           :prompt      => "Storage Type",
           :description => "Storage Type",
           :type        => :list,
           :optional    => false,
           :list        => ["system", "data", "iso", "export"]

    input  :interface,
           :prompt      => "Storage Interface",
           :description => "Storage Interface",
           :type        => :list,
           :optional    => false,
           :list        => ["virtio", "ide", "scsi"]
 
    input  :format,
           :prompt      => "Storage Format",
           :description => "Storage Format",
           :type        => :list,
           :optional    => false,
           :list        => ["cow", "raw"]

    input  :bootable,
           :prompt      => "Storage is bootable?",
           :description => "Bootable flag on storage",
           :type        => :boolean,
           :optional    => true

    output :status,
           :description => 'Status of executed operation',
           :display_as  => "Status"
end

action "add_network", :description => "Add network interface to provided Virtual Machine" do
    display :always

    input  :vm_id,
           :prompt      => "Virtual Machine ID",
           :description => "Virtual Machine Unique Identification",
           :validation  => '^[a-zA-Z\-_\d]+$',
           :type        => :string,
           :optional    => false,
           :maxlength   => 37

    input  :name,
           :prompt      => "Name",
           :description => "Name",
           :validation  => '^[a-zA-Z\-_\d]+$',
           :type        => :string,
           :optional    => false,
           :maxlength   => 10

    input  :interface,
           :prompt      => "Network Interface",
           :description => "Network Interface",
           :type        => :list,
           :optional    => true,
           :list        => ["virtio", "e1000", "rtl8139"]
 
    input  :network_name,
           :prompt      => "Network Name",
           :description => "Network Name",
           :validation  => '^[a-zA-Z\-_\d]+$',
           :type        => :string,
           :optional    => true,
           :maxlength   => 10

    output :status,
           :description => 'Status of executed operation',
           :display_as  => "Status"
end
