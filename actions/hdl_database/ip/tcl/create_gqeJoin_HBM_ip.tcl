## Env Variables

set root [lindex $argv 0]
set fpga_part  	[lindex $argv 1]
set gqeJoin_HBM [lindex $argv 2]
set gqeJoin_hls [lindex $argv 3]
set hmss        [lindex $argv 4]

set ip_libs [list $gqeJoin_HBM $hmss $gqeJoin_hls]
set aip_dir 	$root
set log_dir     .
set log_file    $log_dir/create_gqeJoin_HBM_ip.log
set src_dir 	$aip_dir/gqeJoin_HBM_ip_prj/gqeJoin_HBM_ip_prj.srcs/sources_1/ip


## Create a new Vivado IP Project
puts "\[CREATE_GQEJOIN_ENGINE_IPs..........\] start [clock format [clock seconds] -format {%T %a %b %d/ %Y}]"
puts "                        FPGACHIP = $fpga_part"
puts "                        ROOT = $root"
puts "                        Creating IP in $src_dir"
create_project gqeJoin_HBM_ip_prj $aip_dir/gqeJoin_HBM_ip_prj -force -part $fpga_part -ip > $log_file
set_property  ip_repo_paths  $ip_libs [current_project]
update_ip_catalog

# Project IP Settings
# General
puts "                        Generating gqejoin ......"
create_ip -name gqeJoin_HBM_wrapper -vendor user.org -library user -version 1.0 -module_name gqeJoin_HBM_1
set_property generate_synth_checkpoint false [get_files $src_dir/gqeJoin_HBM_1/gqeJoin_HBM_1.xci] > $log_file
generate_target all [get_files $src_dir/gqeJoin_HBM_1/gqeJoin_HBM_1.xci] > $log_file

close_project
puts "\[CREATE_GQEJOIN_ENGINE_IPs..........\] done  [clock format [clock seconds] -format {%T %a %b %d %Y}]"
