# cisco-config-parse

## What?

cisco-config-parse is a gem that given a Cisco configuration file, parses it to provide an easy breakdown of information for manipulation. For example, you can get the list of interfaces as a hash with relevant details, such as the description on the port, the VLAN configuration, etc. 

## How to use

    require 'cisco-config-parse'
    parser = CiscoConfigParse.new(IO.readlines("/path/to/file"))
    # Parse the file
    parser.parse
    # Get a hash of the interfaces
    puts parser.get_interfaces
    
    {"FastEthernet0"=>{}, "GigabitEthernet0/1"=>{:description=>"host0119.ilo", :access_vlan=>"21", :bpduguard=>"enable"}, "GigabitEthernet0/2"=>{:description=>"host0120.ilo", :access_vlan=>"21", :bpduguard=>"enable"}, "GigabitEthernet0/3"=>{:description=>"host0123.ilo", :access_vlan=>"21", :bpduguard=>"enable"}, "GigabitEthernet0/4"=>{:description=>"host0124.ilo", :access_vlan=>"21", :bpduguard=>"enable"}, "GigabitEthernet0/5"=>{:description=>"host0127.ilo", :access_vlan=>"21", :bpduguard=>"enable"}, "GigabitEthernet0/6"=>{:description=>"host0128.ilo", :access_vlan=>"21", :bpduguard=>"enable"}, ...[snip]

## Methods

* *parse* - Parses the configuration, required for any other operation
* *get\_interfaces* - Returns a hash of all interfaces in config along with their details
* *get\_hostname* - Returns the hostname of the switch
* *get\_version* - Returns the version of the software running on the switch

## Bugs? Improvements?
Probably; this does the bare minimum right now (in my case, I wanted to compare the VLANs on all interfaces on two switches. Please do let me know if anything is broken, and as always please do submit pull requests with any improvements. 

### Thanks
* Half of this code was written by Geoff Garside (https://github.com/geoffgarside), so thanks for letting me take, finish and publish! 
