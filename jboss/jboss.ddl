# Copyright (C) 2011  (<Louis Coilliot>) 
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

metadata     :name        => "Manage JBoss",
             :description => "Jboss inventory and app. deployment",
             :author      => "Louis Coilliot",
             :license     => "GPLv3",
             :version     => "0.1",
             :url         => "",
             :timeout     => 120

action "inventory", :description => "Get inventory information about JBoss" do
    display :always

    output :result,
           :description => 'The filename of the inventory in json format',
           :display_as  => "Output"
end

action "applist", :description => "List applications available on a repository" do
    display :always

    input  :apptype,
           :prompt      => "Appli type",
           :description => "ear, jar, etc.",
           :validation  => '^[a-zA-Z\-_\d]+$',
           :type        => :string,
           :optional    => false,
           :maxlength   => 10

    output :applist,
           :description => "The list of available apps",
           :display_as  => "Application list"

    output :apptype,
           :description => "The type of application",
           :display_as  => "Application type"
end


action "deploylist", :description => "List the deployed applications of the running instance" do
    display :always

    output :applist,
           :description => "List the applications in the running instance",
           :display_as  => "Deployed apps"
end

action "deploy", :description => "Deploy an application in JBoss" do
    display :always

    input  :appfile,
           :prompt      => "Appli file name",
           :description => "File name of the Java application to deploy (i.e. xyz.ear)",
           :type        => :string,
           :validation  => '^[a-zA-Z\-_\d\.]+$',
           :optional    => false,
           :maxlength   => 40

    input  :instancename,
           :prompt      => "Instance name",
           :description => "Target instance for deploy",
           :type        => :string,
           :validation  => '^[a-zA-Z\-_\d\.]+$',
           :optional    => false,
           :maxlength   => 40

    output :status,
           :description => "The status of the deployment",
           :display_as  => "Deployed file"
end

action "redeploy", :description => "Redeploy an application in JBoss" do
    display :always

    input  :appfile,
           :prompt      => "Appli file name",
           :description => "File name of the Java application to deploy (i.e. xyz.ear)",
           :type        => :string,
           :validation  => '^[a-zA-Z\-_\d\.]+$',
           :optional    => false,
           :maxlength   => 40

    input  :instancename,
           :prompt      => "Instance name",
           :description => "Target instance for deploy",
           :type        => :string,
           :validation  => '^[a-zA-Z\-_\d\.]+$',
           :optional    => false,
           :maxlength   => 40

    output :status,
           :description => "The status of the deployment",
           :display_as  => "Deployed file"
end

action "undeploy", :description => "Undeploy an application in JBoss" do
    display :always

    input  :appfile,
           :prompt      => "Appli file name",
           :description => "File name of the Java application to deploy (i.e. xyz.ear)",
           :type        => :string,
           :validation  => '^[a-zA-Z\-_\d\.]+$',
           :optional    => false,
           :maxlength   => 40

    input  :instancename,
           :prompt      => "Instance name",
           :description => "Target instance for deploy",
           :type        => :string,
           :validation  => '^[a-zA-Z\-_\d\.]+$',
           :optional    => false,
           :maxlength   => 40

    output :status,
           :description => "The status of the deployment",
           :display_as  => "Undeployed file"
end

action "get_log", :description => "Get JBoss instance log file" do
    display :always

    input  :instancename,
           :prompt      => "Instance name",
           :description => "Target instance for deploy",
           :type        => :string,
           :validation  => '^[a-zA-Z\-_\d\.]+$',
           :optional    => false,
           :maxlength   => 40

    output :logfile,
           :description => "Server LogFile",
           :display_as  => "Log file"
end

action "get_app_backups", :description => "Get backups file list for provided
application" do
    display :always

    input  :appname,
           :prompt      => "Application name",
           :description => "Name of application",
           :type        => :string,
           :validation  => '^[a-zA-Z\-_\d\.]+$',
           :optional    => false,
           :maxlength   => 40

    output :backups,
           :description => "List of application backups",
           :display_as  => "App Backups"
end

action "rollback", :description => "Rollback a deployed application" do
    display :always

    input  :backupfile,
           :prompt      => "Backup file name",
           :description => "Name of the backup file to use for rollback",
           :type        => :string,
           :validation  => '^[a-zA-Z\-_\d\.]+$',
           :optional    => false,
           :maxlength   => 40

    input  :instancename,
           :prompt      => "Instance name",
           :description => "Target instance for deploy",
           :type        => :string,
           :validation  => '^[a-zA-Z\-_\d\.]+$',
           :optional    => false,
           :maxlength   => 40

    output :logfile,
           :description => "Server LogFile",
           :display_as  => "Log file"
end

