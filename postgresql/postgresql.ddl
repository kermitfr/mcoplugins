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

    input  :sqlfile,
           :prompt      => "SQL file name",
           :description => "File name of the SQL file to execute",
           :type        => :string,
           :validation  => '^[a-zA-Z\-_\d\.]+$',
           :optional    => false,
           :maxlength   => 40

    input  :dbname,
           :prompt      => "Database name",
           :description => "Name of the database where you want to execute script",
           :type        => :string,
           :validation  => '^[a-zA-Z\-_\d\.]+$',
           :optional    => true,
           :maxlength   => 40

    output :logfile,
           :description => "The status of the script execution",
           :display_as  => "Execution Log"
end

action "get_databases", :description => "Get list of databases in the local PostgreSQL instance" do
    display :always

    output :databases,
           :description => "List of database",
           :display_as  => "Databases"
end

action "inventory", :description => "Create inventory of local PostgreSQL DB" do
    display :always

    output :result,
           :description => "Inventory File Name",
           :display_as  => "Inventory"
end

action "get_data_dir", :description => "Getting Data Directory" do
    display :always

    output :data_dir,
           :description => "Data Directory",
           :display_as  => "Data Directory"
end

action "get_version", :description => "Getting PostgreSQL Version" do
    display :always

    output :version,
           :description => "PostgreSQL Version",
           :display_as  => "Version"
end

action "sql_list", :description => "Get list of executable SQLs" do
    display :always

    output :sqllist,
           :description => "List of executable SQLs scripts",
           :display_as  => "SQL List"
end

action "get_database_size", :description => "Get Size of the Given Database" do
    display :always

    input  :dbname,
           :prompt      => "Database Name",
           :description => "Name of the database to check",
           :type        => :string,
           :validation  => '^[a-zA-Z\-_\d\.]+$',
           :optional    => false,
           :maxlength   => 40

    output :size,
           :description => "Database Size",
           :display_as  => "Size"
end

action "get_tables", :description => "Get Tables in the Given Database" do
    display :always

    input  :dbname,
           :prompt      => "Database Name",
           :description => "Name of the database to check",
           :type        => :string,
           :validation  => '^[a-zA-Z\-_\d\.]+$',
           :optional    => false,
           :maxlength   => 40

    output :tables,
           :description => "List of tables",
           :display_as  => "Tables"
end
