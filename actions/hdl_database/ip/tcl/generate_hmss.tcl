
################################################################
# This is a generated script based on design: hmss
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################
#
set root [lindex $argv 0]
set fpga_part  [lindex $argv 1]

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2019.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source hmss_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 $root/myproj -part $fpga_part
   #set_property BOARD_PART xilinx.com:au280:part0:1.0 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name hmss

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design -bdsource SBD $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: path_29
proc create_hier_cell_path_29 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_path_29() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S16_AXI


  # Create pins
  create_bd_pin -dir I -type clk aclk1
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type rst aresetn1
  create_bd_pin -dir I -type clk hbm_aclk

  # Create instance: interconnect16_29, and set properties
  set interconnect16_29 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 interconnect16_29 ]
  set_property -dict [ list \
   CONFIG.ADVANCED_PROPERTIES {__view__ {functional {S00_Entry {SUPPORTS_WRAP 0}} timing {S00_Entry {MMU_REGSLICE 1} M00_Exit {REGSLICE 1}}}} \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_SI {1} \
 ] $interconnect16_29

  # Create instance: slice16_29, and set properties
  set slice16_29 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 slice16_29 ]
  set_property -dict [ list \
   CONFIG.REG_AR {7} \
   CONFIG.REG_AW {7} \
   CONFIG.REG_B {7} \
   CONFIG.REG_R {1} \
   CONFIG.REG_W {1} \
 ] $slice16_29

  # Create interface connections
  connect_bd_intf_net -intf_net S16_AXI_1 [get_bd_intf_pins S16_AXI] [get_bd_intf_pins interconnect16_29/S00_AXI]
  connect_bd_intf_net -intf_net interconnect16_29_M00_AXI [get_bd_intf_pins interconnect16_29/M00_AXI] [get_bd_intf_pins slice16_29/S_AXI]
  connect_bd_intf_net -intf_net slice16_29_M_AXI [get_bd_intf_pins M_AXI] [get_bd_intf_pins slice16_29/M_AXI]

  # Create port connections
  connect_bd_net -net aclk1_1 [get_bd_pins aclk1] [get_bd_pins interconnect16_29/aclk]
  connect_bd_net -net aresetn1_1 [get_bd_pins aresetn1] [get_bd_pins interconnect16_29/aresetn]
  connect_bd_net -net hbm_aclk_1 [get_bd_pins hbm_aclk] [get_bd_pins interconnect16_29/aclk1] [get_bd_pins slice16_29/aclk]
  connect_bd_net -net hbm_reset_sync_SLR0_interconnect_aresetn [get_bd_pins aresetn] [get_bd_pins slice16_29/aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: path_28
proc create_hier_cell_path_28 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_path_28() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S15_AXI


  # Create pins
  create_bd_pin -dir I -type clk aclk1
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type rst aresetn1
  create_bd_pin -dir I -type clk hbm_aclk

  # Create instance: interconnect15_28, and set properties
  set interconnect15_28 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 interconnect15_28 ]
  set_property -dict [ list \
   CONFIG.ADVANCED_PROPERTIES {__view__ {functional {S00_Entry {SUPPORTS_WRAP 0}} timing {S00_Entry {MMU_REGSLICE 1} M00_Exit {REGSLICE 1}}}} \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_SI {1} \
 ] $interconnect15_28

  # Create instance: slice15_28, and set properties
  set slice15_28 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 slice15_28 ]
  set_property -dict [ list \
   CONFIG.REG_AR {7} \
   CONFIG.REG_AW {7} \
   CONFIG.REG_B {7} \
   CONFIG.REG_R {1} \
   CONFIG.REG_W {1} \
 ] $slice15_28

  # Create interface connections
  connect_bd_intf_net -intf_net S15_AXI_1 [get_bd_intf_pins S15_AXI] [get_bd_intf_pins interconnect15_28/S00_AXI]
  connect_bd_intf_net -intf_net interconnect15_28_M00_AXI [get_bd_intf_pins interconnect15_28/M00_AXI] [get_bd_intf_pins slice15_28/S_AXI]
  connect_bd_intf_net -intf_net slice15_28_M_AXI [get_bd_intf_pins M_AXI] [get_bd_intf_pins slice15_28/M_AXI]

  # Create port connections
  connect_bd_net -net aclk1_1 [get_bd_pins aclk1] [get_bd_pins interconnect15_28/aclk]
  connect_bd_net -net aresetn1_1 [get_bd_pins aresetn1] [get_bd_pins interconnect15_28/aresetn]
  connect_bd_net -net hbm_aclk_1 [get_bd_pins hbm_aclk] [get_bd_pins interconnect15_28/aclk1] [get_bd_pins slice15_28/aclk]
  connect_bd_net -net hbm_reset_sync_SLR0_interconnect_aresetn [get_bd_pins aresetn] [get_bd_pins slice15_28/aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: path_25
proc create_hier_cell_path_25 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_path_25() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S08_AXI


  # Create pins
  create_bd_pin -dir I -type clk aclk1
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type rst aresetn1
  create_bd_pin -dir I -type clk hbm_aclk

  # Create instance: interconnect8_25, and set properties
  set interconnect8_25 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 interconnect8_25 ]
  set_property -dict [ list \
   CONFIG.ADVANCED_PROPERTIES {__view__ {functional {S00_Entry {SUPPORTS_WRAP 0}} timing {S00_Entry {MMU_REGSLICE 1} M00_Exit {REGSLICE 1}}}} \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_SI {1} \
 ] $interconnect8_25

  # Create instance: slice8_25, and set properties
  set slice8_25 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 slice8_25 ]
  set_property -dict [ list \
   CONFIG.REG_AR {7} \
   CONFIG.REG_AW {7} \
   CONFIG.REG_B {7} \
   CONFIG.REG_R {1} \
   CONFIG.REG_W {1} \
 ] $slice8_25

  # Create interface connections
  connect_bd_intf_net -intf_net S08_AXI_1 [get_bd_intf_pins S08_AXI] [get_bd_intf_pins interconnect8_25/S00_AXI]
  connect_bd_intf_net -intf_net interconnect8_25_M00_AXI [get_bd_intf_pins interconnect8_25/M00_AXI] [get_bd_intf_pins slice8_25/S_AXI]
  connect_bd_intf_net -intf_net slice8_25_M_AXI [get_bd_intf_pins M_AXI] [get_bd_intf_pins slice8_25/M_AXI]

  # Create port connections
  connect_bd_net -net aclk1_1 [get_bd_pins aclk1] [get_bd_pins interconnect8_25/aclk]
  connect_bd_net -net aresetn1_1 [get_bd_pins aresetn1] [get_bd_pins interconnect8_25/aresetn]
  connect_bd_net -net hbm_aclk_1 [get_bd_pins hbm_aclk] [get_bd_pins interconnect8_25/aclk1] [get_bd_pins slice8_25/aclk]
  connect_bd_net -net hbm_reset_sync_SLR0_interconnect_aresetn [get_bd_pins aresetn] [get_bd_pins slice8_25/aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: path_24
proc create_hier_cell_path_24 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_path_24() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S07_AXI


  # Create pins
  create_bd_pin -dir I -type clk aclk1
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type rst aresetn1
  create_bd_pin -dir I -type clk hbm_aclk

  # Create instance: interconnect7_24, and set properties
  set interconnect7_24 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 interconnect7_24 ]
  set_property -dict [ list \
   CONFIG.ADVANCED_PROPERTIES {__view__ {functional {S00_Entry {SUPPORTS_WRAP 0}} timing {S00_Entry {MMU_REGSLICE 1} M00_Exit {REGSLICE 1}}}} \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_SI {1} \
 ] $interconnect7_24

  # Create instance: slice7_24, and set properties
  set slice7_24 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 slice7_24 ]
  set_property -dict [ list \
   CONFIG.REG_AR {7} \
   CONFIG.REG_AW {7} \
   CONFIG.REG_B {7} \
   CONFIG.REG_R {1} \
   CONFIG.REG_W {1} \
 ] $slice7_24

  # Create interface connections
  connect_bd_intf_net -intf_net S07_AXI_1 [get_bd_intf_pins S07_AXI] [get_bd_intf_pins interconnect7_24/S00_AXI]
  connect_bd_intf_net -intf_net interconnect7_24_M00_AXI [get_bd_intf_pins interconnect7_24/M00_AXI] [get_bd_intf_pins slice7_24/S_AXI]
  connect_bd_intf_net -intf_net slice7_24_M_AXI [get_bd_intf_pins M_AXI] [get_bd_intf_pins slice7_24/M_AXI]

  # Create port connections
  connect_bd_net -net aclk1_1 [get_bd_pins aclk1] [get_bd_pins interconnect7_24/aclk]
  connect_bd_net -net aresetn1_1 [get_bd_pins aresetn1] [get_bd_pins interconnect7_24/aresetn]
  connect_bd_net -net hbm_aclk_1 [get_bd_pins hbm_aclk] [get_bd_pins interconnect7_24/aclk1] [get_bd_pins slice7_24/aclk]
  connect_bd_net -net hbm_reset_sync_SLR0_interconnect_aresetn [get_bd_pins aresetn] [get_bd_pins slice7_24/aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: path_21
proc create_hier_cell_path_21 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_path_21() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S14_AXI


  # Create pins
  create_bd_pin -dir I -type clk aclk1
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type rst aresetn1
  create_bd_pin -dir I -type clk hbm_aclk

  # Create instance: interconnect14_21, and set properties
  set interconnect14_21 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 interconnect14_21 ]
  set_property -dict [ list \
   CONFIG.ADVANCED_PROPERTIES {__view__ {functional {S00_Entry {SUPPORTS_WRAP 0}} timing {S00_Entry {MMU_REGSLICE 1} M00_Exit {REGSLICE 1}}}} \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_SI {1} \
 ] $interconnect14_21

  # Create instance: slice14_21, and set properties
  set slice14_21 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 slice14_21 ]
  set_property -dict [ list \
   CONFIG.REG_AR {7} \
   CONFIG.REG_AW {7} \
   CONFIG.REG_B {7} \
   CONFIG.REG_R {1} \
   CONFIG.REG_W {1} \
 ] $slice14_21

  # Create interface connections
  connect_bd_intf_net -intf_net S14_AXI_1 [get_bd_intf_pins S14_AXI] [get_bd_intf_pins interconnect14_21/S00_AXI]
  connect_bd_intf_net -intf_net interconnect14_21_M00_AXI [get_bd_intf_pins interconnect14_21/M00_AXI] [get_bd_intf_pins slice14_21/S_AXI]
  connect_bd_intf_net -intf_net slice14_21_M_AXI [get_bd_intf_pins M_AXI] [get_bd_intf_pins slice14_21/M_AXI]

  # Create port connections
  connect_bd_net -net aclk1_1 [get_bd_pins aclk1] [get_bd_pins interconnect14_21/aclk]
  connect_bd_net -net aresetn1_1 [get_bd_pins aresetn1] [get_bd_pins interconnect14_21/aresetn]
  connect_bd_net -net hbm_aclk_1 [get_bd_pins hbm_aclk] [get_bd_pins interconnect14_21/aclk1] [get_bd_pins slice14_21/aclk]
  connect_bd_net -net hbm_reset_sync_SLR0_interconnect_aresetn [get_bd_pins aresetn] [get_bd_pins slice14_21/aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: path_20
proc create_hier_cell_path_20 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_path_20() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S13_AXI


  # Create pins
  create_bd_pin -dir I -type clk aclk1
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type rst aresetn1
  create_bd_pin -dir I -type clk hbm_aclk

  # Create instance: interconnect13_20, and set properties
  set interconnect13_20 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 interconnect13_20 ]
  set_property -dict [ list \
   CONFIG.ADVANCED_PROPERTIES {__view__ {functional {S00_Entry {SUPPORTS_WRAP 0}} timing {S00_Entry {MMU_REGSLICE 1} M00_Exit {REGSLICE 1}}}} \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_SI {1} \
 ] $interconnect13_20

  # Create instance: slice13_20, and set properties
  set slice13_20 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 slice13_20 ]
  set_property -dict [ list \
   CONFIG.REG_AR {7} \
   CONFIG.REG_AW {7} \
   CONFIG.REG_B {7} \
   CONFIG.REG_R {1} \
   CONFIG.REG_W {1} \
 ] $slice13_20

  # Create interface connections
  connect_bd_intf_net -intf_net S13_AXI_1 [get_bd_intf_pins S13_AXI] [get_bd_intf_pins interconnect13_20/S00_AXI]
  connect_bd_intf_net -intf_net interconnect13_20_M00_AXI [get_bd_intf_pins interconnect13_20/M00_AXI] [get_bd_intf_pins slice13_20/S_AXI]
  connect_bd_intf_net -intf_net slice13_20_M_AXI [get_bd_intf_pins M_AXI] [get_bd_intf_pins slice13_20/M_AXI]

  # Create port connections
  connect_bd_net -net aclk1_1 [get_bd_pins aclk1] [get_bd_pins interconnect13_20/aclk]
  connect_bd_net -net aresetn1_1 [get_bd_pins aresetn1] [get_bd_pins interconnect13_20/aresetn]
  connect_bd_net -net hbm_aclk_1 [get_bd_pins hbm_aclk] [get_bd_pins interconnect13_20/aclk1] [get_bd_pins slice13_20/aclk]
  connect_bd_net -net hbm_reset_sync_SLR0_interconnect_aresetn [get_bd_pins aresetn] [get_bd_pins slice13_20/aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: path_17
proc create_hier_cell_path_17 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_path_17() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S06_AXI


  # Create pins
  create_bd_pin -dir I -type clk aclk1
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type rst aresetn1
  create_bd_pin -dir I -type clk hbm_aclk

  # Create instance: interconnect6_17, and set properties
  set interconnect6_17 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 interconnect6_17 ]
  set_property -dict [ list \
   CONFIG.ADVANCED_PROPERTIES {__view__ {functional {S00_Entry {SUPPORTS_WRAP 0}} timing {S00_Entry {MMU_REGSLICE 1} M00_Exit {REGSLICE 1}}}} \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_SI {1} \
 ] $interconnect6_17

  # Create instance: slice6_17, and set properties
  set slice6_17 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 slice6_17 ]
  set_property -dict [ list \
   CONFIG.REG_AR {7} \
   CONFIG.REG_AW {7} \
   CONFIG.REG_B {7} \
   CONFIG.REG_R {1} \
   CONFIG.REG_W {1} \
 ] $slice6_17

  # Create interface connections
  connect_bd_intf_net -intf_net S06_AXI_1 [get_bd_intf_pins S06_AXI] [get_bd_intf_pins interconnect6_17/S00_AXI]
  connect_bd_intf_net -intf_net interconnect6_17_M00_AXI [get_bd_intf_pins interconnect6_17/M00_AXI] [get_bd_intf_pins slice6_17/S_AXI]
  connect_bd_intf_net -intf_net slice6_17_M_AXI [get_bd_intf_pins M_AXI] [get_bd_intf_pins slice6_17/M_AXI]

  # Create port connections
  connect_bd_net -net aclk1_1 [get_bd_pins aclk1] [get_bd_pins interconnect6_17/aclk]
  connect_bd_net -net aresetn1_1 [get_bd_pins aresetn1] [get_bd_pins interconnect6_17/aresetn]
  connect_bd_net -net hbm_aclk_1 [get_bd_pins hbm_aclk] [get_bd_pins interconnect6_17/aclk1] [get_bd_pins slice6_17/aclk]
  connect_bd_net -net hbm_reset_sync_SLR0_interconnect_aresetn [get_bd_pins aresetn] [get_bd_pins slice6_17/aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: path_16
proc create_hier_cell_path_16 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_path_16() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S05_AXI


  # Create pins
  create_bd_pin -dir I -type clk aclk1
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type rst aresetn1
  create_bd_pin -dir I -type clk hbm_aclk

  # Create instance: interconnect5_16, and set properties
  set interconnect5_16 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 interconnect5_16 ]
  set_property -dict [ list \
   CONFIG.ADVANCED_PROPERTIES {__view__ {functional {S00_Entry {SUPPORTS_WRAP 0}} timing {S00_Entry {MMU_REGSLICE 1} M00_Exit {REGSLICE 1}}}} \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_SI {1} \
 ] $interconnect5_16

  # Create instance: slice5_16, and set properties
  set slice5_16 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 slice5_16 ]
  set_property -dict [ list \
   CONFIG.REG_AR {7} \
   CONFIG.REG_AW {7} \
   CONFIG.REG_B {7} \
   CONFIG.REG_R {1} \
   CONFIG.REG_W {1} \
 ] $slice5_16

  # Create interface connections
  connect_bd_intf_net -intf_net S05_AXI_1 [get_bd_intf_pins S05_AXI] [get_bd_intf_pins interconnect5_16/S00_AXI]
  connect_bd_intf_net -intf_net interconnect5_16_M00_AXI [get_bd_intf_pins interconnect5_16/M00_AXI] [get_bd_intf_pins slice5_16/S_AXI]
  connect_bd_intf_net -intf_net slice5_16_M_AXI [get_bd_intf_pins M_AXI] [get_bd_intf_pins slice5_16/M_AXI]

  # Create port connections
  connect_bd_net -net aclk1_1 [get_bd_pins aclk1] [get_bd_pins interconnect5_16/aclk]
  connect_bd_net -net aresetn1_1 [get_bd_pins aresetn1] [get_bd_pins interconnect5_16/aresetn]
  connect_bd_net -net hbm_aclk_1 [get_bd_pins hbm_aclk] [get_bd_pins interconnect5_16/aclk1] [get_bd_pins slice5_16/aclk]
  connect_bd_net -net hbm_reset_sync_SLR0_interconnect_aresetn [get_bd_pins aresetn] [get_bd_pins slice5_16/aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: path_14
proc create_hier_cell_path_14 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_path_14() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI


  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type rst aresetn1
  create_bd_pin -dir I -type clk hbm_aclk

  # Create instance: interconnect0_14, and set properties
  set interconnect0_14 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 interconnect0_14 ]
  set_property -dict [ list \
   CONFIG.ADVANCED_PROPERTIES {__view__ {functional {S00_Entry {SUPPORTS_WRAP 0}} timing {S00_Entry {MMU_REGSLICE 1} M00_Exit {REGSLICE 1}}}} \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_SI {1} \
 ] $interconnect0_14

  # Create instance: slice0_14, and set properties
  set slice0_14 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 slice0_14 ]
  set_property -dict [ list \
   CONFIG.NUM_SLR_CROSSINGS {2} \
   CONFIG.PIPELINES_MASTER_AR {4} \
   CONFIG.PIPELINES_MASTER_AW {4} \
   CONFIG.PIPELINES_MASTER_B {4} \
   CONFIG.PIPELINES_MASTER_R {4} \
   CONFIG.PIPELINES_MASTER_W {4} \
   CONFIG.PIPELINES_MIDDLE_AR {4} \
   CONFIG.PIPELINES_MIDDLE_AW {4} \
   CONFIG.PIPELINES_MIDDLE_B {4} \
   CONFIG.PIPELINES_MIDDLE_R {4} \
   CONFIG.PIPELINES_MIDDLE_W {4} \
   CONFIG.PIPELINES_SLAVE_AR {4} \
   CONFIG.PIPELINES_SLAVE_AW {4} \
   CONFIG.PIPELINES_SLAVE_B {4} \
   CONFIG.PIPELINES_SLAVE_R {4} \
   CONFIG.PIPELINES_SLAVE_W {4} \
   CONFIG.REG_AR {15} \
   CONFIG.REG_AW {15} \
   CONFIG.REG_B {15} \
   CONFIG.REG_R {15} \
   CONFIG.REG_W {15} \
 ] $slice0_14

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins interconnect0_14/S00_AXI]
  connect_bd_intf_net -intf_net interconnect0_14_M00_AXI [get_bd_intf_pins interconnect0_14/M00_AXI] [get_bd_intf_pins slice0_14/S_AXI]
  connect_bd_intf_net -intf_net slice0_14_M_AXI [get_bd_intf_pins M_AXI] [get_bd_intf_pins slice0_14/M_AXI]

  # Create port connections
  connect_bd_net -net aclk_1 [get_bd_pins aclk] [get_bd_pins interconnect0_14/aclk]
  connect_bd_net -net aresetn_1 [get_bd_pins aresetn] [get_bd_pins interconnect0_14/aresetn]
  connect_bd_net -net hbm_aclk_1 [get_bd_pins hbm_aclk] [get_bd_pins interconnect0_14/aclk1] [get_bd_pins slice0_14/aclk]
  connect_bd_net -net hbm_reset_sync_SLR2_interconnect_aresetn [get_bd_pins aresetn1] [get_bd_pins slice0_14/aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: path_13
proc create_hier_cell_path_13 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_path_13() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S12_AXI


  # Create pins
  create_bd_pin -dir I -type clk aclk1
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type rst aresetn1
  create_bd_pin -dir I -type clk hbm_aclk

  # Create instance: interconnect12_13, and set properties
  set interconnect12_13 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 interconnect12_13 ]
  set_property -dict [ list \
   CONFIG.ADVANCED_PROPERTIES {__view__ {functional {S00_Entry {SUPPORTS_WRAP 0}} timing {S00_Entry {MMU_REGSLICE 1} M00_Exit {REGSLICE 1}}}} \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_SI {1} \
 ] $interconnect12_13

  # Create instance: slice12_13, and set properties
  set slice12_13 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 slice12_13 ]
  set_property -dict [ list \
   CONFIG.REG_AR {7} \
   CONFIG.REG_AW {7} \
   CONFIG.REG_B {7} \
   CONFIG.REG_R {1} \
   CONFIG.REG_W {1} \
 ] $slice12_13

  # Create interface connections
  connect_bd_intf_net -intf_net S12_AXI_1 [get_bd_intf_pins S12_AXI] [get_bd_intf_pins interconnect12_13/S00_AXI]
  connect_bd_intf_net -intf_net interconnect12_13_M00_AXI [get_bd_intf_pins interconnect12_13/M00_AXI] [get_bd_intf_pins slice12_13/S_AXI]
  connect_bd_intf_net -intf_net slice12_13_M_AXI [get_bd_intf_pins M_AXI] [get_bd_intf_pins slice12_13/M_AXI]

  # Create port connections
  connect_bd_net -net aclk1_1 [get_bd_pins aclk1] [get_bd_pins interconnect12_13/aclk]
  connect_bd_net -net aresetn1_1 [get_bd_pins aresetn1] [get_bd_pins interconnect12_13/aresetn]
  connect_bd_net -net hbm_aclk_1 [get_bd_pins hbm_aclk] [get_bd_pins interconnect12_13/aclk1] [get_bd_pins slice12_13/aclk]
  connect_bd_net -net hbm_reset_sync_SLR0_interconnect_aresetn [get_bd_pins aresetn] [get_bd_pins slice12_13/aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: path_12
proc create_hier_cell_path_12 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_path_12() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S11_AXI


  # Create pins
  create_bd_pin -dir I -type clk aclk1
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type rst aresetn1
  create_bd_pin -dir I -type clk hbm_aclk

  # Create instance: interconnect11_12, and set properties
  set interconnect11_12 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 interconnect11_12 ]
  set_property -dict [ list \
   CONFIG.ADVANCED_PROPERTIES {__view__ {functional {S00_Entry {SUPPORTS_WRAP 0}} timing {S00_Entry {MMU_REGSLICE 1} M00_Exit {REGSLICE 1}}}} \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_SI {1} \
 ] $interconnect11_12

  # Create instance: slice11_12, and set properties
  set slice11_12 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 slice11_12 ]
  set_property -dict [ list \
   CONFIG.REG_AR {7} \
   CONFIG.REG_AW {7} \
   CONFIG.REG_B {7} \
   CONFIG.REG_R {1} \
   CONFIG.REG_W {1} \
 ] $slice11_12

  # Create interface connections
  connect_bd_intf_net -intf_net S11_AXI_1 [get_bd_intf_pins S11_AXI] [get_bd_intf_pins interconnect11_12/S00_AXI]
  connect_bd_intf_net -intf_net interconnect11_12_M00_AXI [get_bd_intf_pins interconnect11_12/M00_AXI] [get_bd_intf_pins slice11_12/S_AXI]
  connect_bd_intf_net -intf_net slice11_12_M_AXI [get_bd_intf_pins M_AXI] [get_bd_intf_pins slice11_12/M_AXI]

  # Create port connections
  connect_bd_net -net aclk1_1 [get_bd_pins aclk1] [get_bd_pins interconnect11_12/aclk]
  connect_bd_net -net aresetn1_1 [get_bd_pins aresetn1] [get_bd_pins interconnect11_12/aresetn]
  connect_bd_net -net hbm_aclk_1 [get_bd_pins hbm_aclk] [get_bd_pins interconnect11_12/aclk1] [get_bd_pins slice11_12/aclk]
  connect_bd_net -net hbm_reset_sync_SLR0_interconnect_aresetn [get_bd_pins aresetn] [get_bd_pins slice11_12/aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: path_9
proc create_hier_cell_path_9 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_path_9() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S04_AXI


  # Create pins
  create_bd_pin -dir I -type clk aclk1
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type rst aresetn1
  create_bd_pin -dir I -type clk hbm_aclk

  # Create instance: interconnect4_9, and set properties
  set interconnect4_9 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 interconnect4_9 ]
  set_property -dict [ list \
   CONFIG.ADVANCED_PROPERTIES {__view__ {functional {S00_Entry {SUPPORTS_WRAP 0}} timing {S00_Entry {MMU_REGSLICE 1} M00_Exit {REGSLICE 1}}}} \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_SI {1} \
 ] $interconnect4_9

  # Create instance: slice4_9, and set properties
  set slice4_9 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 slice4_9 ]
  set_property -dict [ list \
   CONFIG.REG_AR {7} \
   CONFIG.REG_AW {7} \
   CONFIG.REG_B {7} \
   CONFIG.REG_R {1} \
   CONFIG.REG_W {1} \
 ] $slice4_9

  # Create interface connections
  connect_bd_intf_net -intf_net S04_AXI_1 [get_bd_intf_pins S04_AXI] [get_bd_intf_pins interconnect4_9/S00_AXI]
  connect_bd_intf_net -intf_net interconnect4_9_M00_AXI [get_bd_intf_pins interconnect4_9/M00_AXI] [get_bd_intf_pins slice4_9/S_AXI]
  connect_bd_intf_net -intf_net slice4_9_M_AXI [get_bd_intf_pins M_AXI] [get_bd_intf_pins slice4_9/M_AXI]

  # Create port connections
  connect_bd_net -net aclk1_1 [get_bd_pins aclk1] [get_bd_pins interconnect4_9/aclk]
  connect_bd_net -net aresetn1_1 [get_bd_pins aresetn1] [get_bd_pins interconnect4_9/aresetn]
  connect_bd_net -net hbm_aclk_1 [get_bd_pins hbm_aclk] [get_bd_pins interconnect4_9/aclk1] [get_bd_pins slice4_9/aclk]
  connect_bd_net -net hbm_reset_sync_SLR0_interconnect_aresetn [get_bd_pins aresetn] [get_bd_pins slice4_9/aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: path_8
proc create_hier_cell_path_8 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_path_8() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S03_AXI


  # Create pins
  create_bd_pin -dir I -type clk aclk1
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type rst aresetn1
  create_bd_pin -dir I -type clk hbm_aclk

  # Create instance: interconnect3_8, and set properties
  set interconnect3_8 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 interconnect3_8 ]
  set_property -dict [ list \
   CONFIG.ADVANCED_PROPERTIES {__view__ {functional {S00_Entry {SUPPORTS_WRAP 0}} timing {S00_Entry {MMU_REGSLICE 1} M00_Exit {REGSLICE 1}}}} \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_SI {1} \
 ] $interconnect3_8

  # Create instance: slice3_8, and set properties
  set slice3_8 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 slice3_8 ]
  set_property -dict [ list \
   CONFIG.REG_AR {7} \
   CONFIG.REG_AW {7} \
   CONFIG.REG_B {7} \
   CONFIG.REG_R {1} \
   CONFIG.REG_W {1} \
 ] $slice3_8

  # Create interface connections
  connect_bd_intf_net -intf_net S03_AXI_1 [get_bd_intf_pins S03_AXI] [get_bd_intf_pins interconnect3_8/S00_AXI]
  connect_bd_intf_net -intf_net interconnect3_8_M00_AXI [get_bd_intf_pins interconnect3_8/M00_AXI] [get_bd_intf_pins slice3_8/S_AXI]
  connect_bd_intf_net -intf_net slice3_8_M_AXI [get_bd_intf_pins M_AXI] [get_bd_intf_pins slice3_8/M_AXI]

  # Create port connections
  connect_bd_net -net aclk1_1 [get_bd_pins aclk1] [get_bd_pins interconnect3_8/aclk]
  connect_bd_net -net aresetn1_1 [get_bd_pins aresetn1] [get_bd_pins interconnect3_8/aresetn]
  connect_bd_net -net hbm_aclk_1 [get_bd_pins hbm_aclk] [get_bd_pins interconnect3_8/aclk1] [get_bd_pins slice3_8/aclk]
  connect_bd_net -net hbm_reset_sync_SLR0_interconnect_aresetn [get_bd_pins aresetn] [get_bd_pins slice3_8/aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: path_5
proc create_hier_cell_path_5 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_path_5() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S10_AXI


  # Create pins
  create_bd_pin -dir I -type clk aclk1
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type rst aresetn1
  create_bd_pin -dir I -type clk hbm_aclk

  # Create instance: interconnect10_5, and set properties
  set interconnect10_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 interconnect10_5 ]
  set_property -dict [ list \
   CONFIG.ADVANCED_PROPERTIES {__view__ {functional {S00_Entry {SUPPORTS_WRAP 0}} timing {S00_Entry {MMU_REGSLICE 1} M00_Exit {REGSLICE 1}}}} \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_SI {1} \
 ] $interconnect10_5

  # Create instance: slice10_5, and set properties
  set slice10_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 slice10_5 ]
  set_property -dict [ list \
   CONFIG.REG_AR {7} \
   CONFIG.REG_AW {7} \
   CONFIG.REG_B {7} \
   CONFIG.REG_R {1} \
   CONFIG.REG_W {1} \
 ] $slice10_5

  # Create interface connections
  connect_bd_intf_net -intf_net S10_AXI_1 [get_bd_intf_pins S10_AXI] [get_bd_intf_pins interconnect10_5/S00_AXI]
  connect_bd_intf_net -intf_net interconnect10_5_M00_AXI [get_bd_intf_pins interconnect10_5/M00_AXI] [get_bd_intf_pins slice10_5/S_AXI]
  connect_bd_intf_net -intf_net slice10_5_M_AXI [get_bd_intf_pins M_AXI] [get_bd_intf_pins slice10_5/M_AXI]

  # Create port connections
  connect_bd_net -net aclk1_1 [get_bd_pins aclk1] [get_bd_pins interconnect10_5/aclk]
  connect_bd_net -net aresetn1_1 [get_bd_pins aresetn1] [get_bd_pins interconnect10_5/aresetn]
  connect_bd_net -net hbm_aclk_1 [get_bd_pins hbm_aclk] [get_bd_pins interconnect10_5/aclk1] [get_bd_pins slice10_5/aclk]
  connect_bd_net -net hbm_reset_sync_SLR0_interconnect_aresetn [get_bd_pins aresetn] [get_bd_pins slice10_5/aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: path_4
proc create_hier_cell_path_4 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_path_4() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S09_AXI


  # Create pins
  create_bd_pin -dir I -type clk aclk1
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type rst aresetn1
  create_bd_pin -dir I -type clk hbm_aclk

  # Create instance: interconnect9_4, and set properties
  set interconnect9_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 interconnect9_4 ]
  set_property -dict [ list \
   CONFIG.ADVANCED_PROPERTIES {__view__ {functional {S00_Entry {SUPPORTS_WRAP 0}} timing {S00_Entry {MMU_REGSLICE 1} M00_Exit {REGSLICE 1}}}} \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_SI {1} \
 ] $interconnect9_4

  # Create instance: slice9_4, and set properties
  set slice9_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 slice9_4 ]
  set_property -dict [ list \
   CONFIG.REG_AR {7} \
   CONFIG.REG_AW {7} \
   CONFIG.REG_B {7} \
   CONFIG.REG_R {1} \
   CONFIG.REG_W {1} \
 ] $slice9_4

  # Create interface connections
  connect_bd_intf_net -intf_net S09_AXI_1 [get_bd_intf_pins S09_AXI] [get_bd_intf_pins interconnect9_4/S00_AXI]
  connect_bd_intf_net -intf_net interconnect9_4_M00_AXI [get_bd_intf_pins interconnect9_4/M00_AXI] [get_bd_intf_pins slice9_4/S_AXI]
  connect_bd_intf_net -intf_net slice9_4_M_AXI [get_bd_intf_pins M_AXI] [get_bd_intf_pins slice9_4/M_AXI]

  # Create port connections
  connect_bd_net -net aclk1_1 [get_bd_pins aclk1] [get_bd_pins interconnect9_4/aclk]
  connect_bd_net -net aresetn1_1 [get_bd_pins aresetn1] [get_bd_pins interconnect9_4/aresetn]
  connect_bd_net -net hbm_aclk_1 [get_bd_pins hbm_aclk] [get_bd_pins interconnect9_4/aclk1] [get_bd_pins slice9_4/aclk]
  connect_bd_net -net hbm_reset_sync_SLR0_interconnect_aresetn [get_bd_pins aresetn] [get_bd_pins slice9_4/aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: path_1
proc create_hier_cell_path_1 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_path_1() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S02_AXI


  # Create pins
  create_bd_pin -dir I -type clk aclk1
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type rst aresetn1
  create_bd_pin -dir I -type clk hbm_aclk

  # Create instance: interconnect2_1, and set properties
  set interconnect2_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 interconnect2_1 ]
  set_property -dict [ list \
   CONFIG.ADVANCED_PROPERTIES {__view__ {functional {S00_Entry {SUPPORTS_WRAP 0}} timing {S00_Entry {MMU_REGSLICE 1} M00_Exit {REGSLICE 1}}}} \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_SI {1} \
 ] $interconnect2_1

  # Create instance: slice2_1, and set properties
  set slice2_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 slice2_1 ]
  set_property -dict [ list \
   CONFIG.REG_AR {7} \
   CONFIG.REG_AW {7} \
   CONFIG.REG_B {7} \
   CONFIG.REG_R {1} \
   CONFIG.REG_W {1} \
 ] $slice2_1

  # Create interface connections
  connect_bd_intf_net -intf_net S02_AXI_1 [get_bd_intf_pins S02_AXI] [get_bd_intf_pins interconnect2_1/S00_AXI]
  connect_bd_intf_net -intf_net interconnect2_1_M00_AXI [get_bd_intf_pins interconnect2_1/M00_AXI] [get_bd_intf_pins slice2_1/S_AXI]
  connect_bd_intf_net -intf_net slice2_1_M_AXI [get_bd_intf_pins M_AXI] [get_bd_intf_pins slice2_1/M_AXI]

  # Create port connections
  connect_bd_net -net aclk1_1 [get_bd_pins aclk1] [get_bd_pins interconnect2_1/aclk]
  connect_bd_net -net aresetn1_1 [get_bd_pins aresetn1] [get_bd_pins interconnect2_1/aresetn]
  connect_bd_net -net hbm_aclk_1 [get_bd_pins hbm_aclk] [get_bd_pins interconnect2_1/aclk1] [get_bd_pins slice2_1/aclk]
  connect_bd_net -net hbm_reset_sync_SLR0_interconnect_aresetn [get_bd_pins aresetn] [get_bd_pins slice2_1/aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: path_0
proc create_hier_cell_path_0 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_path_0() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S01_AXI


  # Create pins
  create_bd_pin -dir I -type clk aclk1
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type rst aresetn1
  create_bd_pin -dir I -type clk hbm_aclk

  # Create instance: interconnect1_0, and set properties
  set interconnect1_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 interconnect1_0 ]
  set_property -dict [ list \
   CONFIG.ADVANCED_PROPERTIES {__view__ {functional {S00_Entry {SUPPORTS_WRAP 0}} timing {S00_Entry {MMU_REGSLICE 1} M00_Exit {REGSLICE 1}}}} \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_SI {1} \
 ] $interconnect1_0

  # Create instance: slice1_0, and set properties
  set slice1_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 slice1_0 ]
  set_property -dict [ list \
   CONFIG.REG_AR {7} \
   CONFIG.REG_AW {7} \
   CONFIG.REG_B {7} \
   CONFIG.REG_R {1} \
   CONFIG.REG_W {1} \
 ] $slice1_0

  # Create interface connections
  connect_bd_intf_net -intf_net S01_AXI_1 [get_bd_intf_pins S01_AXI] [get_bd_intf_pins interconnect1_0/S00_AXI]
  connect_bd_intf_net -intf_net interconnect1_0_M00_AXI [get_bd_intf_pins interconnect1_0/M00_AXI] [get_bd_intf_pins slice1_0/S_AXI]
  connect_bd_intf_net -intf_net slice1_0_M_AXI [get_bd_intf_pins M_AXI] [get_bd_intf_pins slice1_0/M_AXI]

  # Create port connections
  connect_bd_net -net aclk1_1 [get_bd_pins aclk1] [get_bd_pins interconnect1_0/aclk]
  connect_bd_net -net aresetn1_1 [get_bd_pins aresetn1] [get_bd_pins interconnect1_0/aresetn]
  connect_bd_net -net hbm_aclk_1 [get_bd_pins hbm_aclk] [get_bd_pins interconnect1_0/aclk1] [get_bd_pins slice1_0/aclk]
  connect_bd_net -net hbm_reset_sync_SLR0_interconnect_aresetn [get_bd_pins aresetn] [get_bd_pins slice1_0/aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: init_logic
proc create_hier_cell_init_logic { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_init_logic() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I -from 0 -to 0 In0
  create_bd_pin -dir I -from 0 -to 0 In1
  create_bd_pin -dir O hbm_mc_init_seq_complete

  # Create instance: init_concat, and set properties
  set init_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 init_concat ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {2} \
 ] $init_concat

  # Create instance: init_reduce, and set properties
  set init_reduce [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_reduced_logic:2.0 init_reduce ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {and} \
   CONFIG.C_SIZE {2} \
 ] $init_reduce

  # Create port connections
  connect_bd_net -net hbm_inst_apb_complete_0 [get_bd_pins In0] [get_bd_pins init_concat/In0]
  connect_bd_net -net hbm_inst_apb_complete_1 [get_bd_pins In1] [get_bd_pins init_concat/In1]
  connect_bd_net -net init_concat_dout [get_bd_pins init_concat/dout] [get_bd_pins init_reduce/Op1]
  connect_bd_net -net init_reduce_Res [get_bd_pins hbm_mc_init_seq_complete] [get_bd_pins init_reduce/Res]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set S00_AXI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {512} \
   CONFIG.NUM_READ_OUTSTANDING {16} \
   CONFIG.NUM_WRITE_OUTSTANDING {16} \
   CONFIG.SLR_ASSIGNMENT {} \
   CONFIG.FREQ_HZ {200000000} \
   ] $S00_AXI

  set S01_AXI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S01_AXI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {30} \
   CONFIG.NUM_READ_OUTSTANDING {16} \
   CONFIG.NUM_WRITE_OUTSTANDING {16} \
   CONFIG.SLR_ASSIGNMENT {} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {200000000} \
   ] $S01_AXI

  set S02_AXI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S02_AXI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {30} \
   CONFIG.NUM_READ_OUTSTANDING {16} \
   CONFIG.NUM_WRITE_OUTSTANDING {16} \
   CONFIG.SLR_ASSIGNMENT {} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {200000000} \
   ] $S02_AXI

  set S03_AXI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S03_AXI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.NUM_READ_OUTSTANDING {16} \
   CONFIG.NUM_WRITE_OUTSTANDING {16} \
   CONFIG.SLR_ASSIGNMENT {} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {200000000} \
   ] $S03_AXI

  set S04_AXI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S04_AXI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.NUM_READ_OUTSTANDING {16} \
   CONFIG.NUM_WRITE_OUTSTANDING {16} \
   CONFIG.SLR_ASSIGNMENT {} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {200000000} \
   ] $S04_AXI

  set S05_AXI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S05_AXI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.NUM_READ_OUTSTANDING {16} \
   CONFIG.NUM_WRITE_OUTSTANDING {16} \
   CONFIG.SLR_ASSIGNMENT {} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {200000000} \
   ] $S05_AXI

  set S06_AXI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S06_AXI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.NUM_READ_OUTSTANDING {16} \
   CONFIG.NUM_WRITE_OUTSTANDING {16} \
   CONFIG.SLR_ASSIGNMENT {} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {200000000} \
   ] $S06_AXI

  set S07_AXI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S07_AXI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.NUM_READ_OUTSTANDING {16} \
   CONFIG.NUM_WRITE_OUTSTANDING {16} \
   CONFIG.SLR_ASSIGNMENT {} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {200000000} \
   ] $S07_AXI

  set S08_AXI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S08_AXI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.NUM_READ_OUTSTANDING {16} \
   CONFIG.NUM_WRITE_OUTSTANDING {16} \
   CONFIG.SLR_ASSIGNMENT {} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {200000000} \
   ] $S08_AXI

  set S09_AXI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S09_AXI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {31} \
   CONFIG.NUM_READ_OUTSTANDING {16} \
   CONFIG.NUM_WRITE_OUTSTANDING {16} \
   CONFIG.SLR_ASSIGNMENT {} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {200000000} \
   ] $S09_AXI

  set S10_AXI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S10_AXI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {31} \
   CONFIG.NUM_READ_OUTSTANDING {16} \
   CONFIG.NUM_WRITE_OUTSTANDING {16} \
   CONFIG.SLR_ASSIGNMENT {} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {200000000} \
   ] $S10_AXI

  set S11_AXI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S11_AXI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.NUM_READ_OUTSTANDING {16} \
   CONFIG.NUM_WRITE_OUTSTANDING {16} \
   CONFIG.SLR_ASSIGNMENT {} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {200000000} \
   ] $S11_AXI

  set S12_AXI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S12_AXI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.NUM_READ_OUTSTANDING {16} \
   CONFIG.NUM_WRITE_OUTSTANDING {16} \
   CONFIG.SLR_ASSIGNMENT {} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {200000000} \
   ] $S12_AXI

  set S13_AXI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S13_AXI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.NUM_READ_OUTSTANDING {16} \
   CONFIG.NUM_WRITE_OUTSTANDING {16} \
   CONFIG.SLR_ASSIGNMENT {} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {200000000} \
   ] $S13_AXI

  set S14_AXI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S14_AXI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.NUM_READ_OUTSTANDING {16} \
   CONFIG.NUM_WRITE_OUTSTANDING {16} \
   CONFIG.SLR_ASSIGNMENT {} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {200000000} \
   ] $S14_AXI

  set S15_AXI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S15_AXI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.NUM_READ_OUTSTANDING {16} \
   CONFIG.NUM_WRITE_OUTSTANDING {16} \
   CONFIG.SLR_ASSIGNMENT {} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {200000000} \
   ] $S15_AXI

  set S16_AXI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S16_AXI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.NUM_READ_OUTSTANDING {16} \
   CONFIG.NUM_WRITE_OUTSTANDING {16} \
   CONFIG.SLR_ASSIGNMENT {} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {200000000} \
   ] $S16_AXI

  set S_AXI_CTRL [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_CTRL ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {23} \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.FREQ_HZ {200000000} \
   ] $S_AXI_CTRL


  # Create ports
  set DRAM_0_STAT_TEMP [ create_bd_port -dir O -from 6 -to 0 DRAM_0_STAT_TEMP ]
  set DRAM_1_STAT_TEMP [ create_bd_port -dir O -from 6 -to 0 DRAM_1_STAT_TEMP ]
  set DRAM_STAT_CATTRIP [ create_bd_port -dir O -from 0 -to 0 -type intr DRAM_STAT_CATTRIP ]
  set aclk [ create_bd_port -dir I -type clk aclk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI} \
   CONFIG.FREQ_HZ {200000000} \
 ] $aclk
  set aclk1 [ create_bd_port -dir I -type clk aclk1 ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S01_AXI:S02_AXI:S03_AXI:S04_AXI:S05_AXI:S06_AXI:S07_AXI:S08_AXI:S09_AXI:S10_AXI:S11_AXI:S12_AXI:S13_AXI:S14_AXI:S15_AXI:S16_AXI} \
   CONFIG.FREQ_HZ {200000000} \
 ] $aclk1
  set aresetn [ create_bd_port -dir I -type rst aresetn ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
   CONFIG.FREQ_HZ {200000000} \
 ] $aresetn
  set aresetn1 [ create_bd_port -dir I -type rst aresetn1 ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
   CONFIG.FREQ_HZ {200000000} \
 ] $aresetn1
  set ctrl_aclk [ create_bd_port -dir I -type clk ctrl_aclk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S_AXI_CTRL} \
   CONFIG.ASSOCIATED_RESET {ctrl_aresetn} \
   CONFIG.FREQ_HZ {200000000} \
 ] $ctrl_aclk
  set ctrl_aresetn [ create_bd_port -dir I -type rst ctrl_aresetn ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
   CONFIG.FREQ_HZ {200000000} \
 ] $ctrl_aresetn
  set hbm_aclk [ create_bd_port -dir I -type clk -freq_hz 450000000 hbm_aclk ]
  set hbm_aresetn [ create_bd_port -dir I -type rst hbm_aresetn ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
   CONFIG.FREQ_HZ {200000000} \
 ] $hbm_aresetn
  set hbm_mc_init_seq_complete [ create_bd_port -dir O hbm_mc_init_seq_complete ]
  set hbm_ref_clk [ create_bd_port -dir I -type clk -freq_hz 100000000 hbm_ref_clk ]

  # Create instance: axi_apb_bridge_inst, and set properties
  set axi_apb_bridge_inst [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_apb_bridge:3.0 axi_apb_bridge_inst ]
  set_property -dict [ list \
   CONFIG.C_APB_NUM_SLAVES {2} \
   CONFIG.C_M_APB_PROTOCOL {apb3} \
 ] $axi_apb_bridge_inst

  # Create instance: hbm_inst, and set properties
  set hbm_inst [ create_bd_cell -type ip -vlnv xilinx.com:ip:hbm:1.0 hbm_inst ]
  set_property -dict [ list \
   CONFIG.USER_CLK_SEL_LIST0 {AXI_14_ACLK} \
   CONFIG.USER_CLK_SEL_LIST1 {AXI_29_ACLK} \
   CONFIG.USER_DIS_REF_CLK_BUFG {TRUE} \
   CONFIG.USER_HBM_DENSITY {8GB} \
   CONFIG.USER_HBM_STACK {2} \
   CONFIG.USER_INIT_TIMEOUT_VAL {0} \
   CONFIG.USER_MC0_ECC_SCRUB_PERIOD {0x0032} \
   CONFIG.USER_MC0_ENABLE_ECC_CORRECTION {true} \
   CONFIG.USER_MC0_ENABLE_ECC_SCRUBBING {true} \
   CONFIG.USER_MC0_EN_DATA_MASK {false} \
   CONFIG.USER_MC0_INITILIZE_MEM_USING_ECC_SCRUB {true} \
   CONFIG.USER_MC0_TEMP_CTRL_SELF_REF_INTVL {true} \
   CONFIG.USER_MC10_ECC_SCRUB_PERIOD {0x0032} \
   CONFIG.USER_MC10_ENABLE_ECC_CORRECTION {true} \
   CONFIG.USER_MC10_ENABLE_ECC_SCRUBBING {true} \
   CONFIG.USER_MC10_EN_DATA_MASK {false} \
   CONFIG.USER_MC10_INITILIZE_MEM_USING_ECC_SCRUB {true} \
   CONFIG.USER_MC10_TEMP_CTRL_SELF_REF_INTVL {true} \
   CONFIG.USER_MC11_ECC_SCRUB_PERIOD {0x0032} \
   CONFIG.USER_MC11_ENABLE_ECC_CORRECTION {true} \
   CONFIG.USER_MC11_ENABLE_ECC_SCRUBBING {true} \
   CONFIG.USER_MC11_EN_DATA_MASK {false} \
   CONFIG.USER_MC11_INITILIZE_MEM_USING_ECC_SCRUB {true} \
   CONFIG.USER_MC11_TEMP_CTRL_SELF_REF_INTVL {true} \
   CONFIG.USER_MC12_ECC_SCRUB_PERIOD {0x0032} \
   CONFIG.USER_MC12_ENABLE_ECC_CORRECTION {true} \
   CONFIG.USER_MC12_ENABLE_ECC_SCRUBBING {true} \
   CONFIG.USER_MC12_EN_DATA_MASK {false} \
   CONFIG.USER_MC12_INITILIZE_MEM_USING_ECC_SCRUB {true} \
   CONFIG.USER_MC12_TEMP_CTRL_SELF_REF_INTVL {true} \
   CONFIG.USER_MC13_ECC_SCRUB_PERIOD {0x0032} \
   CONFIG.USER_MC13_ENABLE_ECC_CORRECTION {true} \
   CONFIG.USER_MC13_ENABLE_ECC_SCRUBBING {true} \
   CONFIG.USER_MC13_EN_DATA_MASK {false} \
   CONFIG.USER_MC13_INITILIZE_MEM_USING_ECC_SCRUB {true} \
   CONFIG.USER_MC13_TEMP_CTRL_SELF_REF_INTVL {true} \
   CONFIG.USER_MC14_ECC_SCRUB_PERIOD {0x0032} \
   CONFIG.USER_MC14_ENABLE_ECC_CORRECTION {true} \
   CONFIG.USER_MC14_ENABLE_ECC_SCRUBBING {true} \
   CONFIG.USER_MC14_EN_DATA_MASK {false} \
   CONFIG.USER_MC14_INITILIZE_MEM_USING_ECC_SCRUB {true} \
   CONFIG.USER_MC14_TEMP_CTRL_SELF_REF_INTVL {true} \
   CONFIG.USER_MC15_ECC_SCRUB_PERIOD {0x0032} \
   CONFIG.USER_MC15_ENABLE_ECC_CORRECTION {true} \
   CONFIG.USER_MC15_ENABLE_ECC_SCRUBBING {true} \
   CONFIG.USER_MC15_EN_DATA_MASK {false} \
   CONFIG.USER_MC15_INITILIZE_MEM_USING_ECC_SCRUB {true} \
   CONFIG.USER_MC15_TEMP_CTRL_SELF_REF_INTVL {true} \
   CONFIG.USER_MC1_ECC_SCRUB_PERIOD {0x0032} \
   CONFIG.USER_MC1_ENABLE_ECC_CORRECTION {true} \
   CONFIG.USER_MC1_ENABLE_ECC_SCRUBBING {true} \
   CONFIG.USER_MC1_EN_DATA_MASK {false} \
   CONFIG.USER_MC1_INITILIZE_MEM_USING_ECC_SCRUB {true} \
   CONFIG.USER_MC1_TEMP_CTRL_SELF_REF_INTVL {true} \
   CONFIG.USER_MC2_ECC_SCRUB_PERIOD {0x0032} \
   CONFIG.USER_MC2_ENABLE_ECC_CORRECTION {true} \
   CONFIG.USER_MC2_ENABLE_ECC_SCRUBBING {true} \
   CONFIG.USER_MC2_EN_DATA_MASK {false} \
   CONFIG.USER_MC2_INITILIZE_MEM_USING_ECC_SCRUB {true} \
   CONFIG.USER_MC2_TEMP_CTRL_SELF_REF_INTVL {true} \
   CONFIG.USER_MC3_ECC_SCRUB_PERIOD {0x0032} \
   CONFIG.USER_MC3_ENABLE_ECC_CORRECTION {true} \
   CONFIG.USER_MC3_ENABLE_ECC_SCRUBBING {true} \
   CONFIG.USER_MC3_EN_DATA_MASK {false} \
   CONFIG.USER_MC3_INITILIZE_MEM_USING_ECC_SCRUB {true} \
   CONFIG.USER_MC3_TEMP_CTRL_SELF_REF_INTVL {true} \
   CONFIG.USER_MC4_ECC_SCRUB_PERIOD {0x0032} \
   CONFIG.USER_MC4_ENABLE_ECC_CORRECTION {true} \
   CONFIG.USER_MC4_ENABLE_ECC_SCRUBBING {true} \
   CONFIG.USER_MC4_EN_DATA_MASK {false} \
   CONFIG.USER_MC4_INITILIZE_MEM_USING_ECC_SCRUB {true} \
   CONFIG.USER_MC4_TEMP_CTRL_SELF_REF_INTVL {true} \
   CONFIG.USER_MC5_ECC_SCRUB_PERIOD {0x0032} \
   CONFIG.USER_MC5_ENABLE_ECC_CORRECTION {true} \
   CONFIG.USER_MC5_ENABLE_ECC_SCRUBBING {true} \
   CONFIG.USER_MC5_EN_DATA_MASK {false} \
   CONFIG.USER_MC5_INITILIZE_MEM_USING_ECC_SCRUB {true} \
   CONFIG.USER_MC5_TEMP_CTRL_SELF_REF_INTVL {true} \
   CONFIG.USER_MC6_ECC_SCRUB_PERIOD {0x0032} \
   CONFIG.USER_MC6_ENABLE_ECC_CORRECTION {true} \
   CONFIG.USER_MC6_ENABLE_ECC_SCRUBBING {true} \
   CONFIG.USER_MC6_EN_DATA_MASK {false} \
   CONFIG.USER_MC6_INITILIZE_MEM_USING_ECC_SCRUB {true} \
   CONFIG.USER_MC6_TEMP_CTRL_SELF_REF_INTVL {true} \
   CONFIG.USER_MC7_ECC_SCRUB_PERIOD {0x0032} \
   CONFIG.USER_MC7_ENABLE_ECC_CORRECTION {true} \
   CONFIG.USER_MC7_ENABLE_ECC_SCRUBBING {true} \
   CONFIG.USER_MC7_EN_DATA_MASK {false} \
   CONFIG.USER_MC7_INITILIZE_MEM_USING_ECC_SCRUB {true} \
   CONFIG.USER_MC7_TEMP_CTRL_SELF_REF_INTVL {true} \
   CONFIG.USER_MC8_ECC_SCRUB_PERIOD {0x0032} \
   CONFIG.USER_MC8_ENABLE_ECC_CORRECTION {true} \
   CONFIG.USER_MC8_ENABLE_ECC_SCRUBBING {true} \
   CONFIG.USER_MC8_EN_DATA_MASK {false} \
   CONFIG.USER_MC8_INITILIZE_MEM_USING_ECC_SCRUB {true} \
   CONFIG.USER_MC8_TEMP_CTRL_SELF_REF_INTVL {true} \
   CONFIG.USER_MC9_ECC_SCRUB_PERIOD {0x0032} \
   CONFIG.USER_MC9_ENABLE_ECC_CORRECTION {true} \
   CONFIG.USER_MC9_ENABLE_ECC_SCRUBBING {true} \
   CONFIG.USER_MC9_EN_DATA_MASK {false} \
   CONFIG.USER_MC9_INITILIZE_MEM_USING_ECC_SCRUB {true} \
   CONFIG.USER_MC9_TEMP_CTRL_SELF_REF_INTVL {true} \
   CONFIG.USER_MC_ENABLE_00 {TRUE} \
   CONFIG.USER_MC_ENABLE_01 {TRUE} \
   CONFIG.USER_MC_ENABLE_02 {FALSE} \
   CONFIG.USER_MC_ENABLE_03 {TRUE} \
   CONFIG.USER_MC_ENABLE_04 {FALSE} \
   CONFIG.USER_MC_ENABLE_05 {TRUE} \
   CONFIG.USER_MC_ENABLE_06 {FALSE} \
   CONFIG.USER_MC_ENABLE_07 {TRUE} \
   CONFIG.USER_MC_ENABLE_08 {FALSE} \
   CONFIG.USER_MC_ENABLE_09 {TRUE} \
   CONFIG.USER_MC_ENABLE_10 {FALSE} \
   CONFIG.USER_MC_ENABLE_11 {TRUE} \
   CONFIG.USER_MC_ENABLE_12 {FALSE} \
   CONFIG.USER_MC_ENABLE_13 {TRUE} \
   CONFIG.USER_MC_ENABLE_14 {FALSE} \
   CONFIG.USER_MC_ENABLE_15 {TRUE} \
   CONFIG.USER_SAXI_00 {true} \
   CONFIG.USER_SAXI_01 {true} \
   CONFIG.USER_SAXI_02 {false} \
   CONFIG.USER_SAXI_03 {false} \
   CONFIG.USER_SAXI_04 {true} \
   CONFIG.USER_SAXI_05 {true} \
   CONFIG.USER_SAXI_06 {false} \
   CONFIG.USER_SAXI_07 {false} \
   CONFIG.USER_SAXI_08 {true} \
   CONFIG.USER_SAXI_09 {true} \
   CONFIG.USER_SAXI_10 {false} \
   CONFIG.USER_SAXI_11 {false} \
   CONFIG.USER_SAXI_12 {true} \
   CONFIG.USER_SAXI_13 {true} \
   CONFIG.USER_SAXI_14 {true} \
   CONFIG.USER_SAXI_15 {false} \
   CONFIG.USER_SAXI_16 {true} \
   CONFIG.USER_SAXI_17 {true} \
   CONFIG.USER_SAXI_18 {false} \
   CONFIG.USER_SAXI_19 {false} \
   CONFIG.USER_SAXI_20 {true} \
   CONFIG.USER_SAXI_21 {true} \
   CONFIG.USER_SAXI_22 {false} \
   CONFIG.USER_SAXI_23 {false} \
   CONFIG.USER_SAXI_24 {true} \
   CONFIG.USER_SAXI_25 {true} \
   CONFIG.USER_SAXI_26 {false} \
   CONFIG.USER_SAXI_27 {false} \
   CONFIG.USER_SAXI_28 {true} \
   CONFIG.USER_SAXI_29 {true} \
   CONFIG.USER_SAXI_30 {false} \
   CONFIG.USER_SAXI_31 {false} \
   CONFIG.USER_SWITCH_ENABLE_01 {TRUE} \
   CONFIG.USER_XSDB_INTF_EN {FALSE} \
 ] $hbm_inst

  # Create instance: hbm_reset_sync_SLR0, and set properties
  set hbm_reset_sync_SLR0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 hbm_reset_sync_SLR0 ]
  set_property -dict [ list \
   CONFIG.C_AUX_RESET_HIGH {1} \
 ] $hbm_reset_sync_SLR0

  # Create instance: hbm_reset_sync_SLR2, and set properties
  set hbm_reset_sync_SLR2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 hbm_reset_sync_SLR2 ]
  set_property -dict [ list \
   CONFIG.C_AUX_RESET_HIGH {1} \
 ] $hbm_reset_sync_SLR2

  # Create instance: init_logic
  create_hier_cell_init_logic [current_bd_instance .] init_logic

  # Create instance: path_0
  create_hier_cell_path_0 [current_bd_instance .] path_0

  # Create instance: path_1
  create_hier_cell_path_1 [current_bd_instance .] path_1

  # Create instance: path_4
  create_hier_cell_path_4 [current_bd_instance .] path_4

  # Create instance: path_5
  create_hier_cell_path_5 [current_bd_instance .] path_5

  # Create instance: path_8
  create_hier_cell_path_8 [current_bd_instance .] path_8

  # Create instance: path_9
  create_hier_cell_path_9 [current_bd_instance .] path_9

  # Create instance: path_12
  create_hier_cell_path_12 [current_bd_instance .] path_12

  # Create instance: path_13
  create_hier_cell_path_13 [current_bd_instance .] path_13

  # Create instance: path_14
  create_hier_cell_path_14 [current_bd_instance .] path_14

  # Create instance: path_16
  create_hier_cell_path_16 [current_bd_instance .] path_16

  # Create instance: path_17
  create_hier_cell_path_17 [current_bd_instance .] path_17

  # Create instance: path_20
  create_hier_cell_path_20 [current_bd_instance .] path_20

  # Create instance: path_21
  create_hier_cell_path_21 [current_bd_instance .] path_21

  # Create instance: path_24
  create_hier_cell_path_24 [current_bd_instance .] path_24

  # Create instance: path_25
  create_hier_cell_path_25 [current_bd_instance .] path_25

  # Create instance: path_28
  create_hier_cell_path_28 [current_bd_instance .] path_28

  # Create instance: path_29
  create_hier_cell_path_29 [current_bd_instance .] path_29

  # Create instance: util_vector_logic, and set properties
  set util_vector_logic [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {or} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_orgate.png} \
 ] $util_vector_logic

  # Create instance: vip_S00, and set properties
  set vip_S00 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 vip_S00 ]

  # Create instance: vip_S01, and set properties
  set vip_S01 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 vip_S01 ]

  # Create instance: vip_S02, and set properties
  set vip_S02 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 vip_S02 ]

  # Create instance: vip_S03, and set properties
  set vip_S03 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 vip_S03 ]

  # Create instance: vip_S04, and set properties
  set vip_S04 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 vip_S04 ]

  # Create instance: vip_S05, and set properties
  set vip_S05 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 vip_S05 ]

  # Create instance: vip_S06, and set properties
  set vip_S06 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 vip_S06 ]

  # Create instance: vip_S07, and set properties
  set vip_S07 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 vip_S07 ]

  # Create instance: vip_S08, and set properties
  set vip_S08 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 vip_S08 ]

  # Create instance: vip_S09, and set properties
  set vip_S09 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 vip_S09 ]

  # Create instance: vip_S10, and set properties
  set vip_S10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 vip_S10 ]

  # Create instance: vip_S11, and set properties
  set vip_S11 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 vip_S11 ]

  # Create instance: vip_S12, and set properties
  set vip_S12 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 vip_S12 ]

  # Create instance: vip_S13, and set properties
  set vip_S13 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 vip_S13 ]

  # Create instance: vip_S14, and set properties
  set vip_S14 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 vip_S14 ]

  # Create instance: vip_S15, and set properties
  set vip_S15 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 vip_S15 ]

  # Create instance: vip_S16, and set properties
  set vip_S16 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 vip_S16 ]

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_ports S00_AXI] [get_bd_intf_pins path_14/S00_AXI]
  connect_bd_intf_net -intf_net S01_AXI_1 [get_bd_intf_ports S01_AXI] [get_bd_intf_pins path_0/S01_AXI]
  connect_bd_intf_net -intf_net S02_AXI_1 [get_bd_intf_ports S02_AXI] [get_bd_intf_pins path_1/S02_AXI]
  connect_bd_intf_net -intf_net S03_AXI_1 [get_bd_intf_ports S03_AXI] [get_bd_intf_pins path_8/S03_AXI]
  connect_bd_intf_net -intf_net S04_AXI_1 [get_bd_intf_ports S04_AXI] [get_bd_intf_pins path_9/S04_AXI]
  connect_bd_intf_net -intf_net S05_AXI_1 [get_bd_intf_ports S05_AXI] [get_bd_intf_pins path_16/S05_AXI]
  connect_bd_intf_net -intf_net S06_AXI_1 [get_bd_intf_ports S06_AXI] [get_bd_intf_pins path_17/S06_AXI]
  connect_bd_intf_net -intf_net S07_AXI_1 [get_bd_intf_ports S07_AXI] [get_bd_intf_pins path_24/S07_AXI]
  connect_bd_intf_net -intf_net S08_AXI_1 [get_bd_intf_ports S08_AXI] [get_bd_intf_pins path_25/S08_AXI]
  connect_bd_intf_net -intf_net S09_AXI_1 [get_bd_intf_ports S09_AXI] [get_bd_intf_pins path_4/S09_AXI]
  connect_bd_intf_net -intf_net S10_AXI_1 [get_bd_intf_ports S10_AXI] [get_bd_intf_pins path_5/S10_AXI]
  connect_bd_intf_net -intf_net S11_AXI_1 [get_bd_intf_ports S11_AXI] [get_bd_intf_pins path_12/S11_AXI]
  connect_bd_intf_net -intf_net S12_AXI_1 [get_bd_intf_ports S12_AXI] [get_bd_intf_pins path_13/S12_AXI]
  connect_bd_intf_net -intf_net S13_AXI_1 [get_bd_intf_ports S13_AXI] [get_bd_intf_pins path_20/S13_AXI]
  connect_bd_intf_net -intf_net S14_AXI_1 [get_bd_intf_ports S14_AXI] [get_bd_intf_pins path_21/S14_AXI]
  connect_bd_intf_net -intf_net S15_AXI_1 [get_bd_intf_ports S15_AXI] [get_bd_intf_pins path_28/S15_AXI]
  connect_bd_intf_net -intf_net S16_AXI_1 [get_bd_intf_ports S16_AXI] [get_bd_intf_pins path_29/S16_AXI]
  connect_bd_intf_net -intf_net S_AXI_CTRL_1 [get_bd_intf_ports S_AXI_CTRL] [get_bd_intf_pins axi_apb_bridge_inst/AXI4_LITE]
  connect_bd_intf_net -intf_net axi_apb_bridge_inst_APB_M [get_bd_intf_pins axi_apb_bridge_inst/APB_M] [get_bd_intf_pins hbm_inst/SAPB_0]
  connect_bd_intf_net -intf_net axi_apb_bridge_inst_APB_M2 [get_bd_intf_pins axi_apb_bridge_inst/APB_M2] [get_bd_intf_pins hbm_inst/SAPB_1]
  connect_bd_intf_net -intf_net slice0_14_M_AXI [get_bd_intf_pins path_14/M_AXI] [get_bd_intf_pins vip_S00/S_AXI]
  connect_bd_intf_net -intf_net slice10_5_M_AXI [get_bd_intf_pins path_5/M_AXI] [get_bd_intf_pins vip_S10/S_AXI]
  connect_bd_intf_net -intf_net slice11_12_M_AXI [get_bd_intf_pins path_12/M_AXI] [get_bd_intf_pins vip_S11/S_AXI]
  connect_bd_intf_net -intf_net slice12_13_M_AXI [get_bd_intf_pins path_13/M_AXI] [get_bd_intf_pins vip_S12/S_AXI]
  connect_bd_intf_net -intf_net slice13_20_M_AXI [get_bd_intf_pins path_20/M_AXI] [get_bd_intf_pins vip_S13/S_AXI]
  connect_bd_intf_net -intf_net slice14_21_M_AXI [get_bd_intf_pins path_21/M_AXI] [get_bd_intf_pins vip_S14/S_AXI]
  connect_bd_intf_net -intf_net slice15_28_M_AXI [get_bd_intf_pins path_28/M_AXI] [get_bd_intf_pins vip_S15/S_AXI]
  connect_bd_intf_net -intf_net slice16_29_M_AXI [get_bd_intf_pins path_29/M_AXI] [get_bd_intf_pins vip_S16/S_AXI]
  connect_bd_intf_net -intf_net slice1_0_M_AXI [get_bd_intf_pins path_0/M_AXI] [get_bd_intf_pins vip_S01/S_AXI]
  connect_bd_intf_net -intf_net slice2_1_M_AXI [get_bd_intf_pins path_1/M_AXI] [get_bd_intf_pins vip_S02/S_AXI]
  connect_bd_intf_net -intf_net slice3_8_M_AXI [get_bd_intf_pins path_8/M_AXI] [get_bd_intf_pins vip_S03/S_AXI]
  connect_bd_intf_net -intf_net slice4_9_M_AXI [get_bd_intf_pins path_9/M_AXI] [get_bd_intf_pins vip_S04/S_AXI]
  connect_bd_intf_net -intf_net slice5_16_M_AXI [get_bd_intf_pins path_16/M_AXI] [get_bd_intf_pins vip_S05/S_AXI]
  connect_bd_intf_net -intf_net slice6_17_M_AXI [get_bd_intf_pins path_17/M_AXI] [get_bd_intf_pins vip_S06/S_AXI]
  connect_bd_intf_net -intf_net slice7_24_M_AXI [get_bd_intf_pins path_24/M_AXI] [get_bd_intf_pins vip_S07/S_AXI]
  connect_bd_intf_net -intf_net slice8_25_M_AXI [get_bd_intf_pins path_25/M_AXI] [get_bd_intf_pins vip_S08/S_AXI]
  connect_bd_intf_net -intf_net slice9_4_M_AXI [get_bd_intf_pins path_4/M_AXI] [get_bd_intf_pins vip_S09/S_AXI]
  connect_bd_intf_net -intf_net vip_S00_M_AXI [get_bd_intf_pins hbm_inst/SAXI_14] [get_bd_intf_pins vip_S00/M_AXI]
  connect_bd_intf_net -intf_net vip_S01_M_AXI [get_bd_intf_pins hbm_inst/SAXI_00] [get_bd_intf_pins vip_S01/M_AXI]
  connect_bd_intf_net -intf_net vip_S02_M_AXI [get_bd_intf_pins hbm_inst/SAXI_01] [get_bd_intf_pins vip_S02/M_AXI]
  connect_bd_intf_net -intf_net vip_S03_M_AXI [get_bd_intf_pins hbm_inst/SAXI_08] [get_bd_intf_pins vip_S03/M_AXI]
  connect_bd_intf_net -intf_net vip_S04_M_AXI [get_bd_intf_pins hbm_inst/SAXI_09] [get_bd_intf_pins vip_S04/M_AXI]
  connect_bd_intf_net -intf_net vip_S05_M_AXI [get_bd_intf_pins hbm_inst/SAXI_16] [get_bd_intf_pins vip_S05/M_AXI]
  connect_bd_intf_net -intf_net vip_S06_M_AXI [get_bd_intf_pins hbm_inst/SAXI_17] [get_bd_intf_pins vip_S06/M_AXI]
  connect_bd_intf_net -intf_net vip_S07_M_AXI [get_bd_intf_pins hbm_inst/SAXI_24] [get_bd_intf_pins vip_S07/M_AXI]
  connect_bd_intf_net -intf_net vip_S08_M_AXI [get_bd_intf_pins hbm_inst/SAXI_25] [get_bd_intf_pins vip_S08/M_AXI]
  connect_bd_intf_net -intf_net vip_S09_M_AXI [get_bd_intf_pins hbm_inst/SAXI_04] [get_bd_intf_pins vip_S09/M_AXI]
  connect_bd_intf_net -intf_net vip_S10_M_AXI [get_bd_intf_pins hbm_inst/SAXI_05] [get_bd_intf_pins vip_S10/M_AXI]
  connect_bd_intf_net -intf_net vip_S11_M_AXI [get_bd_intf_pins hbm_inst/SAXI_12] [get_bd_intf_pins vip_S11/M_AXI]
  connect_bd_intf_net -intf_net vip_S12_M_AXI [get_bd_intf_pins hbm_inst/SAXI_13] [get_bd_intf_pins vip_S12/M_AXI]
  connect_bd_intf_net -intf_net vip_S13_M_AXI [get_bd_intf_pins hbm_inst/SAXI_20] [get_bd_intf_pins vip_S13/M_AXI]
  connect_bd_intf_net -intf_net vip_S14_M_AXI [get_bd_intf_pins hbm_inst/SAXI_21] [get_bd_intf_pins vip_S14/M_AXI]
  connect_bd_intf_net -intf_net vip_S15_M_AXI [get_bd_intf_pins hbm_inst/SAXI_28] [get_bd_intf_pins vip_S15/M_AXI]
  connect_bd_intf_net -intf_net vip_S16_M_AXI [get_bd_intf_pins hbm_inst/SAXI_29] [get_bd_intf_pins vip_S16/M_AXI]

  # Create port connections
  connect_bd_net -net aclk1_1 [get_bd_ports aclk1] [get_bd_pins path_0/aclk1] [get_bd_pins path_1/aclk1] [get_bd_pins path_12/aclk1] [get_bd_pins path_13/aclk1] [get_bd_pins path_16/aclk1] [get_bd_pins path_17/aclk1] [get_bd_pins path_20/aclk1] [get_bd_pins path_21/aclk1] [get_bd_pins path_24/aclk1] [get_bd_pins path_25/aclk1] [get_bd_pins path_28/aclk1] [get_bd_pins path_29/aclk1] [get_bd_pins path_4/aclk1] [get_bd_pins path_5/aclk1] [get_bd_pins path_8/aclk1] [get_bd_pins path_9/aclk1]
  connect_bd_net -net aclk_1 [get_bd_ports aclk] [get_bd_pins path_14/aclk]
  connect_bd_net -net aresetn1_1 [get_bd_ports aresetn1] [get_bd_pins path_0/aresetn1] [get_bd_pins path_1/aresetn1] [get_bd_pins path_12/aresetn1] [get_bd_pins path_13/aresetn1] [get_bd_pins path_16/aresetn1] [get_bd_pins path_17/aresetn1] [get_bd_pins path_20/aresetn1] [get_bd_pins path_21/aresetn1] [get_bd_pins path_24/aresetn1] [get_bd_pins path_25/aresetn1] [get_bd_pins path_28/aresetn1] [get_bd_pins path_29/aresetn1] [get_bd_pins path_4/aresetn1] [get_bd_pins path_5/aresetn1] [get_bd_pins path_8/aresetn1] [get_bd_pins path_9/aresetn1]
  connect_bd_net -net aresetn_1 [get_bd_ports aresetn] [get_bd_pins path_14/aresetn]
  connect_bd_net -net cattrip_net [get_bd_ports DRAM_STAT_CATTRIP] [get_bd_pins hbm_reset_sync_SLR0/aux_reset_in] [get_bd_pins hbm_reset_sync_SLR2/aux_reset_in] [get_bd_pins util_vector_logic/Res]
  connect_bd_net -net ctrl_aclk_1 [get_bd_ports ctrl_aclk] [get_bd_pins axi_apb_bridge_inst/s_axi_aclk] [get_bd_pins hbm_inst/APB_0_PCLK] [get_bd_pins hbm_inst/APB_1_PCLK]
  connect_bd_net -net ctrl_aresetn_1 [get_bd_ports ctrl_aresetn] [get_bd_pins axi_apb_bridge_inst/s_axi_aresetn] [get_bd_pins hbm_inst/APB_0_PRESET_N] [get_bd_pins hbm_inst/APB_1_PRESET_N]
  connect_bd_net -net hbm_aclk_1 [get_bd_ports hbm_aclk] [get_bd_pins hbm_inst/AXI_00_ACLK] [get_bd_pins hbm_inst/AXI_01_ACLK] [get_bd_pins hbm_inst/AXI_04_ACLK] [get_bd_pins hbm_inst/AXI_05_ACLK] [get_bd_pins hbm_inst/AXI_08_ACLK] [get_bd_pins hbm_inst/AXI_09_ACLK] [get_bd_pins hbm_inst/AXI_12_ACLK] [get_bd_pins hbm_inst/AXI_13_ACLK] [get_bd_pins hbm_inst/AXI_14_ACLK] [get_bd_pins hbm_inst/AXI_16_ACLK] [get_bd_pins hbm_inst/AXI_17_ACLK] [get_bd_pins hbm_inst/AXI_20_ACLK] [get_bd_pins hbm_inst/AXI_21_ACLK] [get_bd_pins hbm_inst/AXI_24_ACLK] [get_bd_pins hbm_inst/AXI_25_ACLK] [get_bd_pins hbm_inst/AXI_28_ACLK] [get_bd_pins hbm_inst/AXI_29_ACLK] [get_bd_pins hbm_reset_sync_SLR0/slowest_sync_clk] [get_bd_pins hbm_reset_sync_SLR2/slowest_sync_clk] [get_bd_pins path_0/hbm_aclk] [get_bd_pins path_1/hbm_aclk] [get_bd_pins path_12/hbm_aclk] [get_bd_pins path_13/hbm_aclk] [get_bd_pins path_14/hbm_aclk] [get_bd_pins path_16/hbm_aclk] [get_bd_pins path_17/hbm_aclk] [get_bd_pins path_20/hbm_aclk] [get_bd_pins path_21/hbm_aclk] [get_bd_pins path_24/hbm_aclk] [get_bd_pins path_25/hbm_aclk] [get_bd_pins path_28/hbm_aclk] [get_bd_pins path_29/hbm_aclk] [get_bd_pins path_4/hbm_aclk] [get_bd_pins path_5/hbm_aclk] [get_bd_pins path_8/hbm_aclk] [get_bd_pins path_9/hbm_aclk] [get_bd_pins vip_S00/aclk] [get_bd_pins vip_S01/aclk] [get_bd_pins vip_S02/aclk] [get_bd_pins vip_S03/aclk] [get_bd_pins vip_S04/aclk] [get_bd_pins vip_S05/aclk] [get_bd_pins vip_S06/aclk] [get_bd_pins vip_S07/aclk] [get_bd_pins vip_S08/aclk] [get_bd_pins vip_S09/aclk] [get_bd_pins vip_S10/aclk] [get_bd_pins vip_S11/aclk] [get_bd_pins vip_S12/aclk] [get_bd_pins vip_S13/aclk] [get_bd_pins vip_S14/aclk] [get_bd_pins vip_S15/aclk] [get_bd_pins vip_S16/aclk]
  connect_bd_net -net hbm_aresetn_1 [get_bd_ports hbm_aresetn] [get_bd_pins hbm_reset_sync_SLR0/ext_reset_in] [get_bd_pins hbm_reset_sync_SLR2/ext_reset_in]
  connect_bd_net -net hbm_inst_DRAM_0_STAT_CATTRIP [get_bd_pins hbm_inst/DRAM_0_STAT_CATTRIP] [get_bd_pins util_vector_logic/Op1]
  connect_bd_net -net hbm_inst_DRAM_0_STAT_TEMP [get_bd_ports DRAM_0_STAT_TEMP] [get_bd_pins hbm_inst/DRAM_0_STAT_TEMP]
  connect_bd_net -net hbm_inst_DRAM_1_STAT_CATTRIP [get_bd_pins hbm_inst/DRAM_1_STAT_CATTRIP] [get_bd_pins util_vector_logic/Op2]
  connect_bd_net -net hbm_inst_DRAM_1_STAT_TEMP [get_bd_ports DRAM_1_STAT_TEMP] [get_bd_pins hbm_inst/DRAM_1_STAT_TEMP]
  connect_bd_net -net hbm_inst_apb_complete_0 [get_bd_pins hbm_inst/apb_complete_0] [get_bd_pins init_logic/In0]
  connect_bd_net -net hbm_inst_apb_complete_1 [get_bd_pins hbm_inst/apb_complete_1] [get_bd_pins init_logic/In1]
  connect_bd_net -net hbm_ref_clk_1 [get_bd_ports hbm_ref_clk] [get_bd_pins hbm_inst/HBM_REF_CLK_0] [get_bd_pins hbm_inst/HBM_REF_CLK_1]
  connect_bd_net -net hbm_reset_sync_SLR0_interconnect_aresetn [get_bd_pins hbm_inst/AXI_00_ARESET_N] [get_bd_pins hbm_inst/AXI_01_ARESET_N] [get_bd_pins hbm_inst/AXI_04_ARESET_N] [get_bd_pins hbm_inst/AXI_05_ARESET_N] [get_bd_pins hbm_inst/AXI_08_ARESET_N] [get_bd_pins hbm_inst/AXI_09_ARESET_N] [get_bd_pins hbm_inst/AXI_12_ARESET_N] [get_bd_pins hbm_inst/AXI_13_ARESET_N] [get_bd_pins hbm_inst/AXI_14_ARESET_N] [get_bd_pins hbm_inst/AXI_16_ARESET_N] [get_bd_pins hbm_inst/AXI_17_ARESET_N] [get_bd_pins hbm_inst/AXI_20_ARESET_N] [get_bd_pins hbm_inst/AXI_21_ARESET_N] [get_bd_pins hbm_inst/AXI_24_ARESET_N] [get_bd_pins hbm_inst/AXI_25_ARESET_N] [get_bd_pins hbm_inst/AXI_28_ARESET_N] [get_bd_pins hbm_inst/AXI_29_ARESET_N] [get_bd_pins hbm_reset_sync_SLR0/interconnect_aresetn] [get_bd_pins path_0/aresetn] [get_bd_pins path_1/aresetn] [get_bd_pins path_12/aresetn] [get_bd_pins path_13/aresetn] [get_bd_pins path_16/aresetn] [get_bd_pins path_17/aresetn] [get_bd_pins path_20/aresetn] [get_bd_pins path_21/aresetn] [get_bd_pins path_24/aresetn] [get_bd_pins path_25/aresetn] [get_bd_pins path_28/aresetn] [get_bd_pins path_29/aresetn] [get_bd_pins path_4/aresetn] [get_bd_pins path_5/aresetn] [get_bd_pins path_8/aresetn] [get_bd_pins path_9/aresetn] [get_bd_pins vip_S01/aresetn] [get_bd_pins vip_S02/aresetn] [get_bd_pins vip_S03/aresetn] [get_bd_pins vip_S04/aresetn] [get_bd_pins vip_S05/aresetn] [get_bd_pins vip_S06/aresetn] [get_bd_pins vip_S07/aresetn] [get_bd_pins vip_S08/aresetn] [get_bd_pins vip_S09/aresetn] [get_bd_pins vip_S10/aresetn] [get_bd_pins vip_S11/aresetn] [get_bd_pins vip_S12/aresetn] [get_bd_pins vip_S13/aresetn] [get_bd_pins vip_S14/aresetn] [get_bd_pins vip_S15/aresetn] [get_bd_pins vip_S16/aresetn]
  connect_bd_net -net hbm_reset_sync_SLR2_interconnect_aresetn [get_bd_pins hbm_reset_sync_SLR2/interconnect_aresetn] [get_bd_pins path_14/aresetn1] [get_bd_pins vip_S00/aresetn]
  connect_bd_net -net init_reduce_Res [get_bd_ports hbm_mc_init_seq_complete] [get_bd_pins init_logic/hbm_mc_init_seq_complete]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x00400000 -target_address_space [get_bd_addr_spaces S_AXI_CTRL] [get_bd_addr_segs hbm_inst/SAPB_0/Reg] -force
  assign_bd_address -offset 0x00400000 -range 0x00400000 -target_address_space [get_bd_addr_spaces S_AXI_CTRL] [get_bd_addr_segs hbm_inst/SAPB_1/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S00_AXI] [get_bd_addr_segs hbm_inst/SAXI_14/HBM_MEM00] -force
  assign_bd_address -offset 0x20000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S00_AXI] [get_bd_addr_segs hbm_inst/SAXI_14/HBM_MEM02] -force
  assign_bd_address -offset 0x20000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S01_AXI] [get_bd_addr_segs hbm_inst/SAXI_00/HBM_MEM02] -force
  assign_bd_address -offset 0x30000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S00_AXI] [get_bd_addr_segs hbm_inst/SAXI_14/HBM_MEM03] -force
  assign_bd_address -offset 0x30000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S02_AXI] [get_bd_addr_segs hbm_inst/SAXI_01/HBM_MEM03] -force
  assign_bd_address -offset 0x60000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S09_AXI] [get_bd_addr_segs hbm_inst/SAXI_04/HBM_MEM06] -force
  assign_bd_address -offset 0x60000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S00_AXI] [get_bd_addr_segs hbm_inst/SAXI_14/HBM_MEM06] -force
  assign_bd_address -offset 0x70000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S00_AXI] [get_bd_addr_segs hbm_inst/SAXI_14/HBM_MEM07] -force
  assign_bd_address -offset 0x70000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S10_AXI] [get_bd_addr_segs hbm_inst/SAXI_05/HBM_MEM07] -force
  assign_bd_address -offset 0xA0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S03_AXI] [get_bd_addr_segs hbm_inst/SAXI_08/HBM_MEM10] -force
  assign_bd_address -offset 0xA0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S00_AXI] [get_bd_addr_segs hbm_inst/SAXI_14/HBM_MEM10] -force
  assign_bd_address -offset 0xB0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S00_AXI] [get_bd_addr_segs hbm_inst/SAXI_14/HBM_MEM11] -force
  assign_bd_address -offset 0xB0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S04_AXI] [get_bd_addr_segs hbm_inst/SAXI_09/HBM_MEM11] -force
  assign_bd_address -offset 0xE0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S00_AXI] [get_bd_addr_segs hbm_inst/SAXI_14/HBM_MEM14] -force
  assign_bd_address -offset 0xE0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S11_AXI] [get_bd_addr_segs hbm_inst/SAXI_12/HBM_MEM14] -force
  assign_bd_address -offset 0xF0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S12_AXI] [get_bd_addr_segs hbm_inst/SAXI_13/HBM_MEM15] -force
  assign_bd_address -offset 0xF0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S00_AXI] [get_bd_addr_segs hbm_inst/SAXI_14/HBM_MEM15] -force
  assign_bd_address -offset 0x000120000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S00_AXI] [get_bd_addr_segs hbm_inst/SAXI_14/HBM_MEM18] -force
  assign_bd_address -offset 0x000120000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S05_AXI] [get_bd_addr_segs hbm_inst/SAXI_16/HBM_MEM18] -force
  assign_bd_address -offset 0x000130000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S00_AXI] [get_bd_addr_segs hbm_inst/SAXI_14/HBM_MEM19] -force
  assign_bd_address -offset 0x000130000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S06_AXI] [get_bd_addr_segs hbm_inst/SAXI_17/HBM_MEM19] -force
  assign_bd_address -offset 0x000160000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S13_AXI] [get_bd_addr_segs hbm_inst/SAXI_20/HBM_MEM22] -force
  assign_bd_address -offset 0x000160000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S00_AXI] [get_bd_addr_segs hbm_inst/SAXI_14/HBM_MEM22] -force
  assign_bd_address -offset 0x000170000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S14_AXI] [get_bd_addr_segs hbm_inst/SAXI_21/HBM_MEM23] -force
  assign_bd_address -offset 0x000170000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S00_AXI] [get_bd_addr_segs hbm_inst/SAXI_14/HBM_MEM23] -force
  assign_bd_address -offset 0x0001A0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S07_AXI] [get_bd_addr_segs hbm_inst/SAXI_24/HBM_MEM26] -force
  assign_bd_address -offset 0x0001A0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S00_AXI] [get_bd_addr_segs hbm_inst/SAXI_14/HBM_MEM26] -force
  assign_bd_address -offset 0x0001B0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S08_AXI] [get_bd_addr_segs hbm_inst/SAXI_25/HBM_MEM27] -force
  assign_bd_address -offset 0x0001B0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S00_AXI] [get_bd_addr_segs hbm_inst/SAXI_14/HBM_MEM27] -force
  assign_bd_address -offset 0x0001E0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S15_AXI] [get_bd_addr_segs hbm_inst/SAXI_28/HBM_MEM30] -force
  assign_bd_address -offset 0x0001E0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S00_AXI] [get_bd_addr_segs hbm_inst/SAXI_14/HBM_MEM30] -force
  assign_bd_address -offset 0x0001F0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S00_AXI] [get_bd_addr_segs hbm_inst/SAXI_14/HBM_MEM31] -force
  assign_bd_address -offset 0x0001F0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S16_AXI] [get_bd_addr_segs hbm_inst/SAXI_29/HBM_MEM31] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""

update_compile_order -fileset sources_1
make_wrapper -files [get_files $root/myproj/project_1.srcs/sources_1/bd/hmss/hmss.bd] -top
add_files -norecurse $root/myproj/project_1.srcs/sources_1/bd/hmss/hdl/hmss_wrapper.v
ipx::package_project -root_dir $root/myproj/project_1.srcs/sources_1/bd/hmss -vendor user.org -library user -taxonomy /UserIP -module hmss -import_files -force
set_property core_revision 2 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
set_property  ip_repo_paths  $root/myproj/project_1.srcs/sources_1/bd/hmss [current_project]
update_ip_catalog
generate_target all [get_files  $root/myproj/project_1.srcs/sources_1/bd/hmss/hmss.bd]
catch { config_ip_cache -export [get_ips -all hmss_axi_apb_bridge_inst_0] }
catch { config_ip_cache -export [get_ips -all hmss_hbm_inst_0] }
catch { config_ip_cache -export [get_ips -all hmss_hbm_reset_sync_SLR0_0] }
catch { config_ip_cache -export [get_ips -all hmss_hbm_reset_sync_SLR2_0] }
catch { config_ip_cache -export [get_ips -all hmss_init_reduce_0] }
catch { config_ip_cache -export [get_ips -all hmss_interconnect1_0_0] }
catch { config_ip_cache -export [get_ips -all hmss_slice1_0_0] }
catch { config_ip_cache -export [get_ips -all hmss_interconnect2_1_0] }
catch { config_ip_cache -export [get_ips -all hmss_slice2_1_0] }
catch { config_ip_cache -export [get_ips -all hmss_interconnect9_4_0] }
catch { config_ip_cache -export [get_ips -all hmss_slice9_4_0] }
catch { config_ip_cache -export [get_ips -all hmss_interconnect10_5_0] }
catch { config_ip_cache -export [get_ips -all hmss_slice10_5_0] }
catch { config_ip_cache -export [get_ips -all hmss_interconnect3_8_0] }
catch { config_ip_cache -export [get_ips -all hmss_slice3_8_0] }
catch { config_ip_cache -export [get_ips -all hmss_interconnect4_9_0] }
catch { config_ip_cache -export [get_ips -all hmss_slice4_9_0] }
catch { config_ip_cache -export [get_ips -all hmss_interconnect11_12_0] }
catch { config_ip_cache -export [get_ips -all hmss_slice11_12_0] }
catch { config_ip_cache -export [get_ips -all hmss_interconnect12_13_0] }
catch { config_ip_cache -export [get_ips -all hmss_slice12_13_0] }
catch { config_ip_cache -export [get_ips -all hmss_interconnect0_14_0] }
catch { config_ip_cache -export [get_ips -all hmss_slice0_14_0] }
catch { config_ip_cache -export [get_ips -all hmss_interconnect5_16_0] }
catch { config_ip_cache -export [get_ips -all hmss_slice5_16_0] }
catch { config_ip_cache -export [get_ips -all hmss_interconnect6_17_0] }
catch { config_ip_cache -export [get_ips -all hmss_slice6_17_0] }
catch { config_ip_cache -export [get_ips -all hmss_interconnect13_20_0] }
catch { config_ip_cache -export [get_ips -all hmss_slice13_20_0] }
catch { config_ip_cache -export [get_ips -all hmss_interconnect14_21_0] }
catch { config_ip_cache -export [get_ips -all hmss_slice14_21_0] }
catch { config_ip_cache -export [get_ips -all hmss_interconnect7_24_0] }
catch { config_ip_cache -export [get_ips -all hmss_slice7_24_0] }
catch { config_ip_cache -export [get_ips -all hmss_interconnect8_25_0] }
catch { config_ip_cache -export [get_ips -all hmss_slice8_25_0] }
catch { config_ip_cache -export [get_ips -all hmss_interconnect15_28_0] }
catch { config_ip_cache -export [get_ips -all hmss_slice15_28_0] }
catch { config_ip_cache -export [get_ips -all hmss_interconnect16_29_0] }
catch { config_ip_cache -export [get_ips -all hmss_slice16_29_0] }
catch { config_ip_cache -export [get_ips -all hmss_util_vector_logic_0] }
catch { config_ip_cache -export [get_ips -all hmss_vip_S00_0] }
catch { config_ip_cache -export [get_ips -all hmss_vip_S01_0] }
catch { config_ip_cache -export [get_ips -all hmss_vip_S02_0] }
catch { config_ip_cache -export [get_ips -all hmss_vip_S03_0] }
catch { config_ip_cache -export [get_ips -all hmss_vip_S04_0] }
catch { config_ip_cache -export [get_ips -all hmss_vip_S05_0] }
catch { config_ip_cache -export [get_ips -all hmss_vip_S06_0] }
catch { config_ip_cache -export [get_ips -all hmss_vip_S07_0] }
catch { config_ip_cache -export [get_ips -all hmss_vip_S08_0] }
catch { config_ip_cache -export [get_ips -all hmss_vip_S09_0] }
catch { config_ip_cache -export [get_ips -all hmss_vip_S10_0] }
catch { config_ip_cache -export [get_ips -all hmss_vip_S11_0] }
catch { config_ip_cache -export [get_ips -all hmss_vip_S12_0] }
catch { config_ip_cache -export [get_ips -all hmss_vip_S13_0] }
catch { config_ip_cache -export [get_ips -all hmss_vip_S14_0] }
catch { config_ip_cache -export [get_ips -all hmss_vip_S15_0] }
catch { config_ip_cache -export [get_ips -all hmss_vip_S16_0] }
export_ip_user_files -of_objects [get_files $root/myproj/project_1.srcs/sources_1/bd/hmss/hmss.bd] -no_script -sync -force -quiet

