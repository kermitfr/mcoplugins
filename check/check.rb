require 'time'
require 'sys/filesystem'
include Sys

module MCollective
    module Agent
        class Check<RPC::Agent

            action "timegap" do
                validate :reftime, String
                reply[:output] = Time.now.to_i - request[:reftime].to_i
                reply[:hostname]   = `hostname`.chomp
            end

            action "fsstat" do
                fslist=Hash.new

                Sys::Filesystem.mounts.each do |fs|
                  next if fs.name =~ /^(none|sunrpc|usbfs|proc|sysfs|tmpfs|devpts|binfmt_misc)$/
                  fsstat = Filesystem.stat(fs.mount_point)
                  free = (fsstat.blocks_available * fsstat.block_size)/1024/1024
                  size = (fsstat.blocks * fsstat.block_size)/1024/1024
                  fslist[fs.mount_point] = Hash.new
                  fslist[fs.mount_point]['size'] = size
                  fslist[fs.mount_point]['free'] = free
                end
                reply[:output] = fslist
                reply[:hostname] = `hostname`.chomp
            end

        end
    end
end
# vi:tabstop=4:expandtab:ai:filetype=ruby
