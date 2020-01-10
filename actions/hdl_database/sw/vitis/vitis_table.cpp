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

#include "vitis_table.h"
#include "q6_cfg.hpp"

VitisTable::VitisTable()
    : table_l (NULL),
      table_x (NULL),
      table_result_a (NULL),
      table_result_b (NULL),
      table_cfg6 (NULL)
{
    for (int i = 0; i < PU_NM; i++) {
        htb_buf[i] = NULL;
        stb_buf[i] = NULL;
    }
}

VitisTable::~VitisTable()
{
    free_mem (table_l);
    free_mem (table_x);
    free_mem (table_result_a);
    free_mem (table_result_b);
    free_mem (table_cfg6);

    for (int i = 0; i < PU_NM; i++) {
        free_mem (htb_buf[i]);
        free_mem (stb_buf[i]);
    }
}

int VitisTable::init_tables(std::string in_dir)
{
    int l_nrow = L_MAX_ROW;
    std::cout << "Lineitem " << l_nrow << " rows\n";

    const size_t l_depth = L_MAX_ROW + VEC_LEN * 2 - 1;
    const size_t table_l_depth = size_t ((sizeof (TPCH_INT) * l_depth + 64 - 1) / 64);
    const size_t table_x_depth = size_t ((sizeof (TPCH_INT) * l_depth + 64 - 1) / 64);
    const size_t size_table_l = table_l_depth * 4; // 4 columns
    table_l = aligned_alloc<ap_uint<512> > (size_table_l);
    table_l[0] = get_table_header (table_l_depth, l_nrow);
    table_l[1 * table_l_depth] = 0;
    table_l[2 * table_l_depth] = 0;
    table_l[3 * table_l_depth] = 0;

    std::cout << "table_l_depth=" << table_l_depth << std::endl;

    const size_t size_table_x = table_x_depth * 4; // 4 columns
    table_x = aligned_alloc<ap_uint<512> > (size_table_x);

    const size_t table_result_depth = 32;                    // XXX at least enough for burst.
    const size_t size_table_result = table_result_depth * 8; // XXX 5 column, required by write_out
    table_result_a = aligned_alloc<ap_uint<512> > (size_table_result);
    table_result_a[0] = get_table_header (table_result_depth, 0);
    table_result_a[1 * table_result_depth] = 0;
    table_result_a[2 * table_result_depth] = 0;
    table_result_a[3 * table_result_depth] = 0;
    table_result_a[4 * table_result_depth] = 0;
    table_result_b = aligned_alloc<ap_uint<512> > (size_table_result);
    table_result_b[0] = get_table_header (table_result_depth, 0);
    table_result_b[1 * table_result_depth] = 0;
    table_result_b[2 * table_result_depth] = 0;
    table_result_b[3 * table_result_depth] = 0;
    table_result_b[4 * table_result_depth] = 0;

    std::cout << "table_result_depth=" << table_result_depth << std::endl;

    table_cfg6 = aligned_alloc<ap_uint<512> > (9); //(size_table_result);
    get_q6_cfg (table_cfg6);

    for (int i = 0; i < PU_NM; i++) {
        htb_buf[i] = aligned_alloc<ap_uint<64> > (HT_BUFF_DEPTH);
        stb_buf[i] = aligned_alloc<ap_uint<64> > (S_BUFF_DEPTH);
    }

    std::cout << "Host map buffer has been allocated.\n";

    int err;

    {
        // 0
        memcpy (table_l, &l_nrow, sizeof (TPCH_INT));
        err = load_dat<TPCH_INT> (table_l + 1, "l_extendedprice", in_dir, l_nrow);

        if (err) {
            return err;
        }

        // 1
        memcpy (table_l, &l_nrow, sizeof (TPCH_INT));
        err = load_dat<TPCH_INT> (table_l + 1 + table_l_depth * 1, "l_discount", in_dir, l_nrow);

        if (err) {
            return err;
        }

        // 2
        memcpy (table_l, &l_nrow, sizeof (TPCH_INT));
        err = load_dat<TPCH_INT> (table_l + 1 + table_l_depth * 2, "l_shipdate", in_dir, l_nrow);

        if (err) {
            return err;
        }

        // 2
        memcpy (table_l, &l_nrow, sizeof (TPCH_INT));
        err = load_dat<TPCH_INT> (table_l + 1 + table_l_depth * 3, "l_quantity", in_dir, l_nrow);

        if (err) {
            return err;
        }
    }

    std::cout << "Lineitem table has been read from disk\n";

    return err;
}

template <typename T>
T* VitisTable::aligned_alloc(std::size_t num) {
    void* ptr = NULL;
    if (posix_memalign(&ptr, 4096, num * sizeof(T))) {
        throw std::bad_alloc();
    }
    return reinterpret_cast<T*>(ptr);
}

void VitisTable::free_mem (void* a)
{
    if (a) {
        free (a);
    }
}

template <typename T>
int VitisTable::load_dat(void* data, const std::string& name, const std::string& dir, size_t n) {
    if (!data) {
        return -1;
    }
    std::string fn = dir + "/" + name + ".dat";
    FILE* f = fopen(fn.c_str(), "rb");
    if (!f) {
        std::cerr << "ERROR: " << fn << " cannot be opened for binary read." << std::endl;
    }
    size_t cnt = fread(data, sizeof(T), n, f);
    fclose(f);
    if (cnt != n) {
        std::cerr << "ERROR: " << cnt << " entries read from " << fn << ", " << n << " entries required." << std::endl;
        return -1;
    }
    return 0;
}

ap_uint<512> VitisTable::get_table_header(int n512b, int nrow) {
    ap_uint<512> th = 0;
    th.range(31, 0) = nrow;
    th.range(63, 32) = n512b;
    return th;
}

void VitisTable::compload(int* a, int* b, int n) {
    for (int i = 0; i < n; i++) {
        if (a[i] != b[i]) std::cout << i << " :  " << a[i] << " " << b[i] << std::endl;
    }
}


