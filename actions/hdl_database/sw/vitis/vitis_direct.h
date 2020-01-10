/*
 * Copyright 2019 International Business Machines
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#include <ap_int.h>
#include "constants.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "unistd.h"
#include "libosnap.h"

/*
 * This makes it obvious that we are influenced by HLS details ...
 * The ACTION control bits are defined in the following file.
 */
#include <osnap_hls_if.h>

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <errno.h>
#include <malloc.h>
#include <unistd.h>
#include <getopt.h>
#include <ctype.h>

#include <libosnap.h>
#include <osnap_tools.h>
#include <osnap_global_regs.h>

#ifdef __cplusplus
}
#endif
