module MCollective
    module Agent
        class Curb<RPC::Agent

            action "download" do
                validate :url, String
                url = request[:url]
                require 'curb'
                localpath='/tmp'
                filename=url.split('/').last
                fileout = "#{localpath}/#{filename}"
                c = Curl::Easy.download(url,filename=fileout)
                reply["response_code"] = c.response_code 
                reply["downloaded_content_length"] = c.downloaded_content_length 
            end

        end
    end
end
