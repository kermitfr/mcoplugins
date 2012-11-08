module MCollective
    module Agent
        class Agentinfo<RPC::Agent

            # Get actions, inputs, outputs of agents 
            action "desc" do
                   validate :agentname, String
                   ddl = MCollective::RPC::DDL.new(request[:agentname])
                   actionhash = Hash.new
                   begin
                       ddl.actions.each do |i|
                           actiondesc = ddl.action_interface(i)
                           actionname = actiondesc[:action]
                           actionhash[actionname] = actiondesc
                       end
                   rescue NoMethodError
                       next
                   end
                   #reply.data = ddl.actions
                   result = { :actionhash  => actionhash }
                   reply.data = result
            end
        end
    end
end

