require 'time'
require 'sys/filesystem'
include Sys

module MCollective
    module Agent
        class Check<RPC::Agent

            action "timegap" do
                validate :reftime, String
                reply[:output] = Time.now.to_i - request[:reftime].to_i
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
            end

            action "pvs" do
                pvlist = Array.new
                pvout = `pvs --noheadings -o pv_name,pv_size,pv_free,vg_name`
                pvout.each_line do |pv|
                    pvs = pv.split
                    pvs.push('N/A') if pvs.length < 4 # PV not assigned to a VG
                    pvlist.push({'PV' => pvs[0], 'VG'=> pvs[3], 'PSize'=> pvs[1],
                                 'PFree'=> pvs[2]}) 
                end
                reply[:output] = pvlist
            end

            action "vgs" do
                vglist = Array.new
                vgout = `vgs --noheadings -o vg_name,pv_count,lv_count,vg_size,vg_free`
                vgout.each_line do |vg|
                    vgs = vg.split
                    vglist.push({'VG' => vgs[0], 'CurPV' => vgs[1], 'CurLV' => vgs[2],
                                 'VSize' => vgs[3], 'VFree' => vgs[4]})
                end
                reply[:output] = vglist
            end

            action "lvs" do
                lvlist = Array.new
                lvout = `lvs --noheadings -o lv_name,vg_name,lv_size`
                lvout.each_line do |lv|
                   lvs = lv.split
                   lvlist.push({'LV' => lvs[0], 'VG' => lvs[1], 'LSize' => lvs[2]})
                end
                reply[:output] = lvlist
            end

        end
    end
end
# vi:tabstop=4:expandtab:ai:filetype=ruby
