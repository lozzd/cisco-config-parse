#!/bin/env ruby

class CiscoConfigParse
    def initialize(io)
        @io = io
    end

    def parse
        @io.each do |line|
            if line =~ /^\!$/ or line =~ /^$/ # terminate current block
                end_config
                next
            elsif line =~ /^\!/ # Comment
                next
            end
            parse_config(line)
        end
    end

    def get_interfaces
        return @interfaces
    end

    def get_vlans
        return @vlans
    end

    def get_hostname
        return @config_hostname
    end

    def get_version
        return @software_version
    end

    private
    def state
        @state ||= []
    end
    def end_config
        meth = ['e_config', state].flatten.join('_')
        send(meth) if respond_to?(meth)
        state.pop
    end
    def parse_config(line)
        cmd, opts = line.strip.split(' ', 2)
        meth, opts = meth_and_opts(cmd, opts)
		if !opts.nil?
			send(meth, opts) if respond_to?(meth)
		end
    end
    def meth_and_opts(cmd, opts)
        return negated_meth_and_opts(opts) if cmd =~ /no/
            [['p_config', state, cmd.gsub('-', '_')].flatten.join('_'), opts]
    end
    def negated_meth_and_opts(line)
        cmd, opts = line.split(' ', 2)
        [['n_config', state, cmd.gsub('-', '_')].flatten.join('_'), opts]
    end

    protected
    def p_config_hostname(str)
        @config_hostname = str
    end

    def p_config_version(str)
        @software_version = str
    end

    def p_config_vlan(ids)
        @current_vlan = {:ids => ids}
    end

    def e_config_vlan
        @vlans ||= {}
        @vlans[@current_vlan.delete(:ids)] = @current_vlan
    end

    def p_config_interface(name)
        state.push(:interface)
        @current_interface = {:id => name}
    end

    def e_config_interface
        @interfaces ||= {}
        @interfaces[@current_interface.delete(:id)] = @current_interface
    end

    def p_config_interface_description(str)
        @current_interface[:description] = str
    end

    def p_config_interface_switchport(str)
        # Parse the switchport string
        command = str.split(' ', 3)
        case command[0]
        when "trunk"
            # Its a trunk command; continue to figure out what kind
            if command[1] == "allowed"
                # allow vlan
                allowed_type = str.split(' ', 5)
                # Split up the rest of the string for the list of vlans
                vlan_list = str.gsub(',',' ').split(' ')
                if allowed_type[3] == "add" then
                    @current_interface[:added_allowed_vlans] = vlan_list.slice(4, vlan_list.length)
                else
                    @current_interface[:allowed_vlans] = vlan_list.slice(3, vlan_list.length)
                end
            end
        when "access"
            @current_interface[:access_vlan] = command[2]
        end
    end

    def p_config_interface_inherit(str)
        @current_interface[:inherit] = str
    end

    def p_config_interface_spanning_tree(str)
        # Parse the spanning tree config options
        command = str.split(' ')
        case command[0]
        when "port"
            @current_interface[:spanning_tree_port_type] = command[2]
        when "guard"
            @current_interface[:spanning_tree_guard] = command[1]
        when "bpduguard"
            @current_interface[:bpduguard] = command[1]
        end
    end

    def p_config_interface_channel_group(str)
        # Is the port in a port channel?
        @current_interface[:channel_group] = str.split(' ')[0]

    end
end
