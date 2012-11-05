module MCollective
    module Agent
        class Curb<RPC::Agent
            metadata :name        => "curl - transfer a URL",
                     :description => "Tool to transfer data from or to a server, using URLs",
                     :author      => "Louis Coilliot",
                     :license     => "",
                     :version     => "0.1",
                     :url         => "",
                     :timeout     => 30

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
