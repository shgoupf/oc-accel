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

#include <chrono>
#include <thread>
#include "vitis_direct.h"
#include "vitis_table.h"

using namespace std::chrono;

#define VERBOSE0(fmt, ...) do {         \
        printf(fmt, ## __VA_ARGS__);    \
    } while (0)

#define VERBOSE1(fmt, ...) do {         \
        if (verbose_level > 0)          \
            printf(fmt, ## __VA_ARGS__);    \
    } while (0)

#define VERBOSE2(fmt, ...) do {         \
        if (verbose_level > 1)          \
            printf(fmt, ## __VA_ARGS__);    \
    } while (0)


#define VERBOSE3(fmt, ...) do {         \
        if (verbose_level > 2)          \
            printf(fmt, ## __VA_ARGS__);    \
    } while (0)

#define VERBOSE4(fmt, ...) do {         \
        if (verbose_level > 3)          \
            printf(fmt, ## __VA_ARGS__);    \
    } while (0)

static  int verbose_level = 0;

void print_error (const char* file, const char* func, const char* line, int rc)
{
    printf ("ERROR: %s %s failed in line %s with return code %d\n", file, func, line, rc);
}

int64_t diff_time (struct timespec* t_beg, struct timespec* t_end)
{
    if (t_end == NULL || t_beg == NULL) {
        return 0;
    }

    return ((t_end-> tv_sec - t_beg-> tv_sec) * 1000000000L + t_end-> tv_nsec - t_beg-> tv_nsec);
}

float print_time (uint64_t elapsed, uint64_t size)
{
    int t;
    float fsize = (float)size / (1024 * 1024);
    float ft;

    if (elapsed > 10000) {
        t = (int)elapsed / 1000;
        ft = (1000 / (float)t) * fsize;
        VERBOSE0 (" end after %d msec (%0.3f MB/sec)\n", t, ft);
        //VERBOSE0 ("%d msec %0.3f\n", t, ft);
    } else {
        t = (int)elapsed;
        ft = (1000000 / (float)t) * fsize;
        VERBOSE0 (" end after %d usec (%0.3f MB/sec)\n", t, ft);
        //VERBOSE0 ("%d usec %0.3f\n", t, ft);
    }

    return ft;
}

/* Action or Kernel Write and Read are 32 bit MMIO */
void action_write (struct snap_card* h, uint32_t addr, uint32_t data)
{
    int rc;

    rc = snap_action_write32 (h, (uint64_t)addr, data);

    if (0 != rc) {
        VERBOSE0 ("Write MMIO 32 Err\n");
    }

    return;
}

uint32_t action_read (struct snap_card* h, uint32_t addr)
{
    int rc;
    uint32_t data;

    rc = snap_action_read32 (h, (uint64_t)addr, &data);

    if (0 != rc) {
        VERBOSE0 ("Read MMIO 32 Err\n");
    }

    return data;
}

/*
 *  Start Action and wait for Idle.
 */
int action_wait_idle (struct snap_card* h, int timeout)
{
    int rc = ETIME;

    /* FIXME Use struct snap_action and not struct snap_card */
    snap_action_start ((snap_action*)h);

    /* Wait for Action to go back to Idle */
    rc = snap_action_completed ((snap_action*)h, NULL, timeout);

    if (rc) {
        rc = 0;    /* Good */
    } else {
        VERBOSE0 ("Error. Timeout while Waiting for Idle\n");
    }

    return rc;
}

void configure_vitis_reg (struct snap_card* h, int reg_id, uint64_t reg_data, int eng_id)
{
    // Configure the address for each buffer
    // Each buffer has 3 registers:
    // 00: LSB 32 bits
    // 04: MSB 32 bits
    // 08: all zeros
    uint32_t lsb = (uint32_t) reg_data & 0x00000000FFFFFFFF;
    uint32_t msb = (uint32_t) ((reg_data & 0xFFFFFFFF00000000) >> 32);

    uint32_t reg_offset = reg_id * 0xC + 0 * 0x4;
    uint32_t reg_addr = VITIS_REG_BASE + reg_offset;
    VERBOSE1 ("----------------> Writing to %#x with %#x\n", reg_addr, lsb);
    action_write (h, REG (reg_addr, eng_id), lsb);

    reg_offset = reg_id * 0xC + 1 * 0x4;
    reg_addr = VITIS_REG_BASE + reg_offset;
    VERBOSE1 ("----------------> Writing to %#x with %#x\n", reg_addr, msb);
    action_write (h, REG (reg_addr, eng_id), msb);

    reg_offset = reg_id * 0xC + 2 * 0x4;
    reg_addr = VITIS_REG_BASE + reg_offset;
    VERBOSE1 ("----------------> Writing to %#x with %#x\n", reg_addr, 0);
    action_write (h, REG (reg_addr, eng_id), 0);

    return;
}

int action_vitis (struct snap_card* h, int eng_id, std::string & in_dir)
{
    VitisTable* vitis_table_ptr = new VitisTable();
    vitis_table_ptr->init_tables (in_dir);

    configure_vitis_reg (h, 0, (uint64_t) vitis_table_ptr->get_table_l_ptr(), eng_id);
    configure_vitis_reg (h, 1, (uint64_t) vitis_table_ptr->get_table_x_ptr(), eng_id);
    configure_vitis_reg (h, 2, (uint64_t) vitis_table_ptr->get_table_result_a_ptr(), eng_id);
    configure_vitis_reg (h, 3, (uint64_t) vitis_table_ptr->get_table_cfg6_ptr(), eng_id);

    for (int i = 0; i < PU_NM; i++) {
        configure_vitis_reg (h, i + 4, (uint64_t) vitis_table_ptr->get_htb_buf_ptr (i), eng_id);
    }

    for (int i = 0; i < PU_NM; i++) {
        configure_vitis_reg (h, i + 4 + PU_NM, (uint64_t) vitis_table_ptr->get_stb_buf_ptr (i), eng_id);
    }

    // Start the engine
    action_write (h, REG (VITIS_CTRL_BASE, eng_id), 1);

    do {
        int32_t reg_data = action_read (h, REG (VITIS_CTRL_BASE, eng_id));

        if (reg_data & 0x2) {
            VERBOSE0 ("Engine done, stop polling\n");
            break;
        }

        VERBOSE2 ("POLLING STATUS %#x\n", reg_data);
        std::this_thread::sleep_for (std::chrono::milliseconds(1000));
    } while (1);

    if (vitis_table_ptr->verify_result ()) {
        return -1;
    }

    return 0;
}

int vitis_run (struct snap_card* dnc,
               int timeout,
               int eng_id,
               std::string & in_dir)
{
    int rc;

    rc = 0;

    high_resolution_clock::time_point t_start = high_resolution_clock::now();

    rc = action_vitis (dnc, eng_id, in_dir);
    action_wait_idle (dnc, timeout);

    high_resolution_clock::time_point t_end = high_resolution_clock::now();

    auto td = duration_cast<microseconds> (t_end - t_start).count();
    VERBOSE0 ("Finished run after %lu microseconds (us)\n", (uint64_t) td);

    if (0 != rc) {
        VERBOSE0 ("ERROR!");
    }

    return rc;
}

struct snap_action* get_action (struct snap_card* handle,
                                snap_action_flag_t flags, int timeout)
{
    struct snap_action* act;

    act = snap_attach_action (handle, ACTION_TYPE_DATABASE,
                              flags, timeout);

    if (NULL == act) {
        VERBOSE0 ("Error: Can not attach Action: %x\n", ACTION_TYPE_DATABASE);
        VERBOSE0 ("       Try to run snap_main tool\n");
    }

    return act;
}

void usage (const char* prog)
{
    VERBOSE0 ("OpenCAPI VITIS Database Acceleration Direct Test.\n");
    VERBOSE0 ("Usage: %s\n"
              "    -h, --help           print usage information\n"
              "    -v, --verbose        verbose mode\n"
              "    -C, --card <cardno>  use this card for operation\n"
              // "    -V, --version\n"
              "    -q, --quiet          quiece output\n"
              "    -t, --timeout        Timeout after N sec (default 1 sec)\n"
              "    -I, --irq            Enable Action Done Interrupt (default No Interrupts)\n"
              , prog);
}

int main (int argc, char* argv[])
{
    char device[64];
    struct snap_card* dn;   /* lib snap handle */
    int card_no = 0;
    int cmd;
    int timeout = ACTION_WAIT_TIME;
    snap_action_flag_t attach_flags = (snap_action_flag_t) 0;
    struct snap_action* act = NULL;
    uint32_t hw_version = 0;
    std::string in_dir;

    while (1) {
        int option_index = 0;
        static struct option long_options[] = {
            { "card", required_argument, NULL, 'C' },
            { "verbose", no_argument, NULL, 'v' },
            { "help", no_argument, NULL, 'h' },
            // { "version"    , no_argument       , NULL , 'V' } ,
            { "quiet", no_argument, NULL, 'q' },
            { "timeout", required_argument, NULL, 't' },
            { "irq", no_argument, NULL, 'I' },
            { "in_dir", no_argument, NULL, 'i' },
            { 0, no_argument, NULL, 0   },
        };
        cmd = getopt_long (argc, argv, "C:t:p:q:n:i:Ifqvh",
                           long_options, &option_index);

        if (cmd == -1) {  /* all params processed ? */
            break;
        }

        switch (cmd) {
        case 'v':   /* verbose */
            verbose_level++;
            break;

        case 'h':   /* help */
            usage (argv[0]);
            exit (EXIT_SUCCESS);;

        case 'C':   /* card */
            card_no = strtol (optarg, (char**)NULL, 0);
            break;

        case 't':
            timeout = strtol (optarg, (char**)NULL, 0);  /* in sec */
            break;

        case 'I':      /* irq */
            attach_flags = (snap_action_flag_t) (SNAP_ACTION_DONE_IRQ | SNAP_ATTACH_IRQ);
            break;

        case 'i':   /* card */
            in_dir = std::string (optarg);
            break;

        default:
            usage (argv[0]);
            exit (EXIT_FAILURE);
        }
    }

    VERBOSE0 ("Open Card: %d\n", card_no);

    if (card_no == 0) {
        snprintf (device, sizeof (device) - 1, "IBM,oc-snap");
    } else {
        snprintf (device, sizeof (device) - 1, "/dev/ocxl/IBM,oc-snap.000%d:00:00.1.0", card_no);
    }

    VERBOSE0 ("Allocate Device\n");

    dn = snap_card_alloc_dev (device, SNAP_VENDOR_ID_IBM, SNAP_DEVICE_ID_SNAP);

    if (NULL == dn) {
        errno = ENODEV;
        VERBOSE0 ("ERROR: snap_card_alloc_dev(%s)\n", device);
        return -1;
    }

    VERBOSE0 ("Start to get action.\n");
    act = get_action (dn, attach_flags, timeout);

    if (NULL == act) {
        goto __fail;
    }

    VERBOSE0 ("--------> Start to get action.\n");
    act = get_action (dn, attach_flags, 5 * timeout);

    if (NULL == act) {
        goto __fail;
    }

    VERBOSE0 ("--------> Finish get action.\n");

    hw_version = action_read (dn, ACTION_HW_VERSION);
    VERBOSE0 ("--------> hw_version: %#x\n", hw_version);

    VERBOSE0 ("--------> HARDWARE RUN\n");
    if (vitis_run (dn, timeout, 0, in_dir)) {
        goto __fail;
    }

    snap_detach_action (act);
    // Unmap AFU MMIO registers, if previously mapped
    VERBOSE2 ("--------> Free Card Handle: %p\n", dn);
    snap_card_free (dn);

    VERBOSE1 ("End of Test\n");
    return 0;

__fail:
    snap_detach_action (act);
    // Unmap AFU MMIO registers, if previously mapped
    VERBOSE2 ("Free Card Handle: %p\n", dn);
    snap_card_free (dn);
    return -1;
}


