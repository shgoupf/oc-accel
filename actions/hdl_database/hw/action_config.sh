#!/bin/bash
############################################################################
############################################################################
##
## Copyright 2017 International Business Machines
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE#2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions AND
## limitations under the License.
##
############################################################################
############################################################################
echo "                        action config says ACTION_ROOT is $ACTION_ROOT"
echo "                        action config says FPGACHIP is $FPGACHIP"
echo "                        action config says there are $NUM_OF_DATABASE_KERNELS kernels used in this action"
echo "                        action config says $DATABASE_ENGINE_CONFIG is used for engine configuration"

REGEX_ENGINE=0
GQEJOIN_ENGINE=0
if [ $DATABASE_ENGINE_CONFIG == regex_64X1 ] || [ $DATABASE_ENGINE_CONFIG == regex_16X1 ] || [ $DATABASE_ENGINE_CONFIG == regex_8X1 ]; then
    REGEX_ENGINE=1
elif [ $DATABASE_ENGINE_CONFIG == vitis_gqeJoin ]; then 
    GQEJOIN_ENGINE=1
else
    echo "Invalid database engine configuration: $DATABASE_ENGINE_CONFIG"
    exit 1
fi

GQEJOIN_DESIGN=engines/gqeJoin
REGEX_DESIGN=engines/regex
REGEX_IP=../ip/engines/regex
HDL_PP=$ACTION_ROOT/../../scripts/utils/hdl_pp/

if [ -L $REGEX_DESIGN ]; then
    unlink $REGEX_DESIGN 
fi

if [ -L $REGEX_IP ]; then
    unlink $REGEX_IP
fi

if [ -L $GQEJOIN_DESIGN ]; then
    unlink $GQEJOIN_DESIGN
fi

if [ -z $NUM_OF_DATABASE_KERNELS ]; then
    echo "No number of database kernels specified, check your snap_config!"
    exit 1
fi

if [ $REGEX_ENGINE -eq 1 ]; then
    STRING_MATCH_VERILOG=../string-match-fpga/verilog

    # Create the link to regex engine
    if [ -z $STRING_MATCH_VERILOG ]; then
        echo "WARNING!!! Please set STRING_MATCH_VERILOG to the path of string match verilog"
    else
        if [ ! -d ./engines ]; then
            mkdir engines
        fi

        cd engines
        ln -s ../$STRING_MATCH_VERILOG regex 
        cd ../../

        if [ ! -d ./ip/engines ]; then
            mkdir -p ./ip/engines
        fi

        cd ip/engines
        ln -s ../../hw/$STRING_MATCH_VERILOG/../fpga_ip regex
        cd ../../hw/
    fi
fi

if [ $GQEJOIN_ENGINE -eq 1 ]; then
    VITIS_DATABASE_LIB=../Vitis_Libraries/database

    # Create the link to regex engine
    if [ -z $VITIS_DATABASE_LIB ]; then
        echo "WARNING!!! Please set VITIS_DATABASE_LIB to the path of xilinx vitis libraries"
    else
        if [ ! -d ./engines ]; then
            mkdir engines
        fi

        cd engines
        ln -s ../$VITIS_DATABASE_LIB gqeJoin
        cd ../
    fi
fi

echo "                        Generating defs.h"
if [ ! -f ./defs.h ]; then
    touch defs.h
else
    rm defs.h
fi
# Generate number of kernel configurations
echo "#define NUM_KERNELS ${NUM_OF_DATABASE_KERNELS}" >> defs.h

# Generate regex configurations
if [ $DATABASE_ENGINE_CONFIG == regex_64X1 ]; then
    echo "#define REGEX_ENGINE_ENABLE             1 " >> defs.h
    echo "#define REGEX_NUM_BUFFER_SL             4  " >> defs.h
    echo "#define REGEX_NUM_BUFFER_TL             16 " >> defs.h
    echo "#define REGEX_NUM_BUFFER_4THL           16 " >> defs.h
    echo "#define REGEX_NUM_PIPELINE_IN_A_GROUP   1  " >> defs.h
    echo "#define REGEX_NUM_OF_PIPELINE_GROUP     64 " >> defs.h
    echo "#define REGEX_NUM_STRING_MATCH_PIPELINE 64 " >> defs.h
elif [ $DATABASE_ENGINE_CONFIG == regex_16X1 ]; then
    echo "#define REGEX_ENGINE_ENABLE             1 " >> defs.h
    echo "#define REGEX_NUM_BUFFER_SL             1  " >> defs.h
    echo "#define REGEX_NUM_BUFFER_TL             2  " >> defs.h
    echo "#define REGEX_NUM_BUFFER_4THL           2  " >> defs.h
    echo "#define REGEX_NUM_PIPELINE_IN_A_GROUP   1  " >> defs.h
    echo "#define REGEX_NUM_OF_PIPELINE_GROUP     16 " >> defs.h
    echo "#define REGEX_NUM_STRING_MATCH_PIPELINE 16 " >> defs.h
elif [ $DATABASE_ENGINE_CONFIG == regex_8X1 ]; then
    echo "#define REGEX_ENGINE_ENABLE             1 " >> defs.h
    echo "#define REGEX_NUM_BUFFER_SL             1 " >> defs.h
    echo "#define REGEX_NUM_BUFFER_TL             1 " >> defs.h
    echo "#define REGEX_NUM_BUFFER_4THL           1 " >> defs.h
    echo "#define REGEX_NUM_PIPELINE_IN_A_GROUP   1 " >> defs.h
    echo "#define REGEX_NUM_OF_PIPELINE_GROUP     8 " >> defs.h
    echo "#define REGEX_NUM_STRING_MATCH_PIPELINE 8 " >> defs.h
elif [ $DATABASE_ENGINE_CONFIG == vitis_gqeJoin ]; then
    echo "#define VITIS_GQEJOIN_ENABLE            1 " >> defs.h
else
    echo "Unknown REGEX configuration: ${DATABASE_ENGINE_CONFIG}"
    exit -1
fi

# Preprocess configurable verilogs
for i in $(find -name \*.v_source); do
    vcp=${i%.v_source}.vcp
    v=${i%.v_source}.v
    echo "                        Processing $i"
    $HDL_PP/vcp -i $i -o $vcp -imacros ./defs.h 2>> defs.log

    if [ ! $? ]; then
        echo "!! ERROR processing $vcp"
        exit -1
    fi

    perl -I $HDL_PP/plugins -Meperl $HDL_PP/eperl -o $v $vcp 2>> defs.log

    if [ ! $? ]; then
        echo "!! ERROR processing $v"
        exit -1
    fi
done                         

if [ $REGEX_ENGINE -eq 1 ]; then
    echo "                        Generate IP for regex engine with config: $DATABASE_ENGINE_CONFIG"
    # Create the IP for regex engine
    if [ ! -d $STRING_MATCH_VERILOG/../fpga_ip/managed_ip_project ]; then
        echo "                        Call all_ip_gen.pl to generate regex IPs"
        $STRING_MATCH_VERILOG/../fpga_ip/all_ip_gen.pl -fpga_chip $FPGACHIP -outdir $STRING_MATCH_VERILOG/../fpga_ip >> regex_fpga_ip_gen.log

        if [ ! $? ]; then
            echo "!! ERROR generating regex IPs."
            exit -1
        fi
    fi
fi

if [ $GQEJOIN_ENGINE -eq 1 ]; then
    echo "                        Call gqejoin_hls_synth.tcl to generate gqejoin IP"
    if [ ! -d engines/hls_build ]; then
        mkdir -p engines/hls_build

        cd engines/hls_build
        vivado_hls $ACTION_ROOT/ip/tcl/gqejoin_hls_synth.tcl $ACTION_ROOT $FPGACHIP >> gqejoin_hls_synth.log

        if [ ! $? ]; then
            echo "!! ERROR generating gqejoin engine"
            exit -1;
        fi
        echo "                        Generate gqejoin IP done with return code $rc"

        cd ../../
    fi
fi

# Create IP for the gqeJoin engine
if [ ! -d $ACTION_ROOT/ip/engines/gqejoin ]; then
    echo "                        Call create_gqejoin_ip.tcl to generate gqeJoin engine IPs"
    vivado -mode batch -source $ACTION_ROOT/ip/tcl/create_gqejoin_ip.tcl -notrace -nojournal -tclargs $ACTION_ROOT $FPGACHIP >> create_gqejoin_ip.log

    if [ ! $? ]; then
        echo "!! ERROR generating gqeJoin engine IPs."
        exit -1;
    fi
fi

# Create IP for the framework
if [ ! -d $ACTION_ROOT/ip/framework/framework_ip_prj ]; then
    echo "                        Call create_framework_ip.tcl to generate framework IPs"
    vivado -mode batch -source $ACTION_ROOT/ip/tcl/create_framework_ip.tcl -notrace -nojournal -tclargs $ACTION_ROOT $FPGACHIP $NUM_OF_DATABASE_KERNELS >> framework_fpga_ip_gen.log

    if [ ! $? ]; then
        echo "!! ERROR generating framework IPs."
        exit -1;
    fi
fi
