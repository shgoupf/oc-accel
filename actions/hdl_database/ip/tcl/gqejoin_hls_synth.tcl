catch {::common::set_param -quiet hls.xocc.mode csynth};

set action_root   [lindex $argv 0]
set fpga_part  	  [lindex $argv 1]
set action_hw     $action_root/hw

set gqejoin_dir  $action_hw/engines/gqeJoin

set vpp_optimize_level 0
open_project gqeJoin
set_top gqeJoin
add_files "$gqejoin_dir/L2/src/gqe_join.cpp" -cflags " -g -I $gqejoin_dir/L2/src -I $gqejoin_dir/L1/include/hw -I $gqejoin_dir/L2/include -I $action_hw/../Vitis_Libraries/utils/L1/include "
open_solution solution
set_part $fpga_part
create_clock -period 200MHz -name default
config_sdx -target xocc
config_rtl -kernel_profile
config_export -vivado_optimization_level $vpp_optimize_level
config_dataflow -strict_mode warning
config_debug -enable
set_clock_uncertainty 27.000000%
config_rtl -enable_maxiConservative=1
config_interface -m_axi_addr64
config_export -format ip_catalog -ipname gqeJoin
csynth_design
export_design
close_project
puts "HLS completed successfully"
exit
