#!/usr/bin/env python
#
# Copyright 2019 International Business Machines
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

import os
import sys
from os.path import join as pathjoin
from os.path import isfile as isfile
from ocaccel_utils import run_and_poll_with_progress
from ocaccel_utils import msg 

def make_image(log, options = None):
    msg.ok_msg_blue("--------> Make the FPGA image")
    msg.warn_msg("Make image might take quiet a long time to finish, be patient ... ")
    if os.environ['OCACCEL_LSF_IMPL'] is not None:
        msg.warn_msg('Multiple LSF runs enabled')

    if os.environ['LSF_IMPL_LIST'] is not None:
        list_path = pathjoin('hardware', 'setup', os.environ['LSF_IMPL_LIST'])

        if not isfile(list_path):
            msg.warn_msg('file %s not exist. Please check your env variable LSF_IMPL_LIST settings' % list_path)
            msg.warn_msg('LSF_IMPL_LIST should be set as the name of a tcl file in hardware/setup/')

        msg.warn_msg('List of strategies can be found in %s' % list_path)
    else:
        msg.warn_msg('Use default strategy list in ./hardware/setup/create_other_strategy_impls.tcl')

    rc = run_and_poll_with_progress(cmd = "make image", work_dir = ".", log = log, max_log_len = 120, timeout = options.make_timeout)

    if rc == 0:
        msg.ok_msg("====================")
        msg.ok_msg("FPGA image generated")
        msg.ok_msg("====================")
        msg.ok_msg("Images are available in %s" % pathjoin(options.ocaccel_root, 'hardware', 'build', 'Images'))
    else:
        msg.warn_msg("Failed to make image, check log in %s" % log)
        msg.warn_msg("Failed to make image! Exiting ... ")
        msg.warn_msg("Here are some of the error logs:")
        f = open(log,"r")
        l = f.readlines()
        f.close()
        print "".join(l[-10:])
        msg.fail_msg("End of the error log!")

if __name__ == '__main__':
    make_image("./make_image.log")
