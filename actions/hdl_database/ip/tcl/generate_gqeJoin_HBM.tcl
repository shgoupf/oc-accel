set root [lindex $argv 0]
set fpga_part  [lindex $argv 1]
set gqeJoin_ip_repo [lindex $argv 2]
set hmss_ip_repo [lindex $argv 3]
set ip_repos [list $gqeJoin_ip_repo $hmss_ip_repo]

create_project my_proj $root/my_proj -part $fpga_part
create_bd_design "gqeJoin_HBM"
update_compile_order -fileset sources_1
set_property  ip_repo_paths  $ip_repos [current_project]
update_ip_catalog
startgroup
create_bd_cell -type ip -vlnv xilinx.com:hls:gqeJoin:1.0 gqeJoin_0
endgroup
startgroup
create_bd_cell -type ip -vlnv user.org:user:hmss:1.0 hmss_wrapper_0
endgroup
open_bd_design {$root/my_proj/my_proj.srcs/sources_1/bd/gqeJoin_HBM/gqeJoin_HBM.bd}
set_property name hmss_0 [get_bd_cells hmss_wrapper_0]
connect_bd_intf_net [get_bd_intf_pins gqeJoin_0/m_axi_gmem1_0] [get_bd_intf_pins hmss_0/S01_AXI]
connect_bd_intf_net [get_bd_intf_pins gqeJoin_0/m_axi_gmem1_1] [get_bd_intf_pins hmss_0/S02_AXI]
connect_bd_intf_net [get_bd_intf_pins gqeJoin_0/m_axi_gmem1_2] [get_bd_intf_pins hmss_0/S03_AXI]
connect_bd_intf_net [get_bd_intf_pins gqeJoin_0/m_axi_gmem1_3] [get_bd_intf_pins hmss_0/S04_AXI]
connect_bd_intf_net [get_bd_intf_pins gqeJoin_0/m_axi_gmem1_4] [get_bd_intf_pins hmss_0/S05_AXI]
connect_bd_intf_net [get_bd_intf_pins gqeJoin_0/m_axi_gmem1_5] [get_bd_intf_pins hmss_0/S06_AXI]
connect_bd_intf_net [get_bd_intf_pins gqeJoin_0/m_axi_gmem1_6] [get_bd_intf_pins hmss_0/S07_AXI]
connect_bd_intf_net [get_bd_intf_pins gqeJoin_0/m_axi_gmem1_7] [get_bd_intf_pins hmss_0/S08_AXI]
connect_bd_intf_net [get_bd_intf_pins gqeJoin_0/m_axi_gmem2_0] [get_bd_intf_pins hmss_0/S09_AXI]
connect_bd_intf_net [get_bd_intf_pins gqeJoin_0/m_axi_gmem2_1] [get_bd_intf_pins hmss_0/S10_AXI]
connect_bd_intf_net [get_bd_intf_pins gqeJoin_0/m_axi_gmem2_2] [get_bd_intf_pins hmss_0/S11_AXI]
connect_bd_intf_net [get_bd_intf_pins gqeJoin_0/m_axi_gmem2_3] [get_bd_intf_pins hmss_0/S12_AXI]
connect_bd_intf_net [get_bd_intf_pins gqeJoin_0/m_axi_gmem2_4] [get_bd_intf_pins hmss_0/S13_AXI]
connect_bd_intf_net [get_bd_intf_pins gqeJoin_0/m_axi_gmem2_5] [get_bd_intf_pins hmss_0/S14_AXI]
connect_bd_intf_net [get_bd_intf_pins gqeJoin_0/m_axi_gmem2_6] [get_bd_intf_pins hmss_0/S15_AXI]
connect_bd_intf_net [get_bd_intf_pins gqeJoin_0/m_axi_gmem2_7] [get_bd_intf_pins hmss_0/S16_AXI]
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 axilite_ctrl_hbm
set_property location {-588 -336} [get_bd_intf_ports axilite_ctrl_hbm]
set_property -dict [list CONFIG.MAX_BURST_LENGTH {1} CONFIG.NUM_WRITE_OUTSTANDING {2} CONFIG.NUM_READ_OUTSTANDING {2} CONFIG.SUPPORTS_NARROW_BURST {0} CONFIG.READ_WRITE_MODE {READ_WRITE} CONFIG.FREQ_HZ {200000000} CONFIG.PROTOCOL {AXI4LITE} CONFIG.HAS_BURST {0} CONFIG.HAS_CACHE {0} CONFIG.HAS_LOCK {0} CONFIG.HAS_QOS {0} CONFIG.HAS_REGION {0} CONFIG.HAS_WSTRB {1}] [get_bd_intf_ports axilite_ctrl_hbm]
connect_bd_intf_net [get_bd_intf_ports axilite_ctrl_hbm] [get_bd_intf_pins hmss_0/S_AXI_CTRL]
copy_bd_objs /  [get_bd_intf_ports {axilite_ctrl_hbm}]
set_property name axilite_ctrl_gqejoin [get_bd_intf_ports axilite_ctrl_hbm1]
connect_bd_intf_net [get_bd_intf_ports axilite_ctrl_gqejoin] [get_bd_intf_pins gqeJoin_0/s_axi_control]
create_bd_port -dir I -type clk -freq_hz 200000000 ap_clk
connect_bd_net [get_bd_ports ap_clk] [get_bd_pins gqeJoin_0/ap_clk]
connect_bd_net [get_bd_ports ap_clk] [get_bd_pins hmss_0/aclk1]
connect_bd_net [get_bd_ports ap_clk] [get_bd_pins hmss_0/ctrl_aclk]
startgroup
create_bd_port -dir I -type rst ap_rst_n
endgroup
connect_bd_net [get_bd_ports ap_rst_n] [get_bd_pins gqeJoin_0/ap_rst_n]
connect_bd_net [get_bd_ports ap_rst_n] [get_bd_pins hmss_0/aresetn1]
connect_bd_net [get_bd_ports ap_rst_n] [get_bd_pins hmss_0/ctrl_aresetn]
copy_bd_objs /  [get_bd_ports {ap_clk}]
set_property name hbm_aclk [get_bd_ports ap_clk1]
set_property CONFIG.FREQ_HZ 450000000 [get_bd_ports hbm_aclk]
set_property location {-268 220} [get_bd_ports hbm_aclk]
connect_bd_net [get_bd_ports hbm_aclk] [get_bd_pins hmss_0/hbm_aclk]
copy_bd_objs /  [get_bd_ports {hbm_aclk}]
set_property location {-272 245} [get_bd_ports hbm_aclk1]
set_property name hbm_ref_clk [get_bd_ports hbm_aclk1]
set_property CONFIG.FREQ_HZ 100000000 [get_bd_ports hbm_ref_clk]
connect_bd_net [get_bd_ports hbm_ref_clk] [get_bd_pins hmss_0/hbm_ref_clk]
copy_bd_objs /  [get_bd_ports {ap_rst_n}]
set_property name hbm_aresetn [get_bd_ports ap_rst_n1]
connect_bd_net [get_bd_ports hbm_aresetn] [get_bd_pins hmss_0/hbm_aresetn]
connect_bd_net [get_bd_ports ap_rst_n] [get_bd_pins hmss_0/aresetn]
connect_bd_net [get_bd_ports ap_clk] [get_bd_pins hmss_0/aclk]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_gmem0_0
set_property location {-51 -57} [get_bd_intf_ports m_axi_gmem0_0]
set_property -dict [list CONFIG.NUM_READ_OUTSTANDING {16} CONFIG.ADDR_WIDTH {64} CONFIG.FREQ_HZ {300000000} CONFIG.DATA_WIDTH {512} CONFIG.HAS_BURST {0}] [get_bd_intf_ports m_axi_gmem0_0]
connect_bd_intf_net [get_bd_intf_ports m_axi_gmem0_0] [get_bd_intf_pins gqeJoin_0/m_axi_gmem0_0]
copy_bd_objs /  [get_bd_intf_ports {m_axi_gmem0_0}]
connect_bd_intf_net [get_bd_intf_ports m_axi_gmem0_1] [get_bd_intf_pins gqeJoin_0/m_axi_gmem0_1]
copy_bd_objs /  [get_bd_intf_ports {m_axi_gmem0_1}]
copy_bd_objs /  [get_bd_intf_ports {m_axi_gmem0_2}]
connect_bd_intf_net [get_bd_intf_ports m_axi_gmem0_2] [get_bd_intf_pins gqeJoin_0/m_axi_gmem0_2]
connect_bd_intf_net [get_bd_intf_ports m_axi_gmem0_3] [get_bd_intf_pins gqeJoin_0/m_axi_gmem0_3]
save_bd_design
startgroup
make_bd_pins_external  [get_bd_pins hmss_0/DRAM_0_STAT_TEMP]
endgroup
startgroup
make_bd_pins_external  [get_bd_pins hmss_0/DRAM_1_STAT_TEMP]
endgroup
startgroup
make_bd_pins_external  [get_bd_pins hmss_0/DRAM_STAT_CATTRIP]
endgroup
startgroup
make_bd_pins_external  [get_bd_pins hmss_0/hbm_mc_init_seq_complete]
endgroup
startgroup
make_bd_intf_pins_external  [get_bd_intf_pins gqeJoin_0/m_axi_gmem0_0]
endgroup
startgroup
make_bd_intf_pins_external  [get_bd_intf_pins gqeJoin_0/m_axi_gmem0_2] [get_bd_intf_pins gqeJoin_0/m_axi_gmem0_1] [get_bd_intf_pins gqeJoin_0/m_axi_gmem0_3]
endgroup
save_bd_design
validate_bd_design

update_compile_order -fileset sources_1
make_wrapper -files [get_files $root/my_proj/my_proj.srcs/sources_1/bd/gqeJoin_HBM/gqeJoin_HBM.bd] -top
add_files -norecurse $root/my_proj/my_proj.srcs/sources_1/bd/gqeJoin_HBM/hdl/gqeJoin_HBM_wrapper.v
ipx::package_project -root_dir $root/my_proj/my_proj.srcs/sources_1/bd/gqeJoin_HBM -vendor user.org -library user -taxonomy /UserIP
set_property core_revision 2 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]

#set ip_repos [list $root/my_proj/my_proj.srcs/sources_1/bd/gqeJoin_HBM $gqeJoin_ip_repo $hmss_ip_repo]
#set_property  ip_repo_paths  $ip_repos [current_project]
#update_ip_catalog

#generate_target all [get_files  $root/my_proj/my_proj.srcs/sources_1/bd/gqeJoin_HBM/gqeJoin_HBM.bd]
#catch { config_ip_cache -export [get_ips -all gqeJoin_HBM_gqeJoin_0_0] }
#catch { config_ip_cache -export [get_ips -all gqeJoin_HBM_hmss_wrapper_0_0] }
#export_ip_user_files -of_objects [get_files $root/my_proj/my_proj.srcs/sources_1/bd/gqeJoin_HBM/gqeJoin_HBM.bd] -no_script -sync -force -quiet
