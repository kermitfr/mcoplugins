# Copyright (C) 2011 Marco Mornati (<ilmorna@gmail.com>) 
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

metadata     :name        => "Agent to Manage PostgreSQL Database",
             :description => "PostgreSQL Management Agent",
             :author      => "Marco Mornati",
             :license     => "GPLv3",
             :version     => "0.1",
             :url         => "",
             :timeout     => 120

action "execute_sql", :description => "Execute a SQL file on local PostgreSQL database" do
    display :always

    input :sqlfile,
          :prompt      => "SQL file name",
          :description => "File name of the SQL file to execute",
          :type        => :string,
          :validation  => '^[a-zA-Z\-_\d\.]+$',
          :optional    => false,
          :maxlength   => 40

    input :instance,
          :prompt      => "Instance Nale",
          :description => "Name of Oracle Instance to use",
          :type        => :string,
          :validation  => '^[a-zA-Z\-_\d\.]+$',
          :optional    => false,
          :maxlength   => 40

    output :logfile,
           :description => "The status of the script execution",
           :display_as  => "Execution Log"
end

action "inventory", :description => "Create inventory of local PostgreSQL DB" do
    display :always

    output :result,
           :description => "Inventory File Name",
           :display_as  => "Inventory"
end
