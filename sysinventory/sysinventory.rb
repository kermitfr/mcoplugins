module MCollective
    module Agent
        class Sysinventory<RPC::Agent

            action "rpmlist" do
              rpmlist = []

              if Gem.available?('ruby-rpm')
                # I love APIs and gems !
                require 'rpm'
                rpmdb = RPM::DB.new
                rpmdb.each do |pkg|
                    rpmlist << { 'name' => pkg.name,
                                 'version' => pkg.version.v,
                                 'release' => pkg.version.r,
                                 'architecture' => pkg.arch,
                                 'epoch' => pkg.version.e }
                end
                # The two following lines seem necessary to close the rpm db
                # and avoid locks/hangups with rpm 
                rpmdb.close
                GC.start

              else
                # I prefer running a shell command !
                keys = ['name','version','release','architecture','epoch']
                rpmqa = `rpm -qa --qf '%{NAME}:%{VERSION}:%{RELEASE}:%{ARCH}:%{EPOCH}\n'`
                rpmqa.each do |line|
                  vals = line.chomp.split(':')
                  rpmlist << keys.zip(vals).inject({}){|h,e| h[e[0]] = e[1]; h}
                end
              end

              reply["rpmlist"] = rpmlist
            end
        end
    end
end
