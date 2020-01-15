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
#ifndef _VitisTable_H_
#define _VitisTable_H_

#include "vitis_direct.h"

class VitisTable
{
public:
    VitisTable();
    ~VitisTable();

    ap_uint<512>* get_table_l_ptr()
    {
        return table_l;
    }

    ap_uint<512>* get_table_x_ptr()
    {
        return table_x;
    }

    ap_uint<512>* get_table_result_a_ptr()
    {
        return table_result_a;
    }

    ap_uint<512>* get_table_result_b_ptr()
    {
        return table_result_b;
    }

    ap_uint<512>* get_table_cfg6_ptr()
    {
        return table_cfg6;
    }

    ap_uint<64>* get_htb_buf_ptr (int idx)
    {
        return htb_buf[idx];
    }

    ap_uint<64>* get_stb_buf_ptr (int idx)
    {
        return stb_buf[idx];
    }


    int init_tables (std::string in_dir);

    int verify_result ();

private:
    ap_uint<512>* table_l;
    ap_uint<512>* table_x;
    ap_uint<512>* table_result_a;
    ap_uint<512>* table_result_b;
    ap_uint<512>* table_cfg6;
    ap_uint<64>*  htb_buf[PU_NM];
    ap_uint<64>*  stb_buf[PU_NM];

    const size_t l_depth = L_MAX_ROW + VEC_LEN * 2 - 1;
    const size_t table_l_depth = size_t ((sizeof (TPCH_INT) * l_depth + 64 - 1) / 64);
    const size_t table_x_depth = size_t ((sizeof (TPCH_INT) * l_depth + 64 - 1) / 64);
    const size_t size_table_x = table_x_depth * 4; // 4 columns
    const size_t size_table_l = table_l_depth * 4; // 4 columns
    const size_t table_result_depth = 32;                    // XXX at least enough for burst.
    const size_t size_table_result = table_result_depth * 8; // XXX 5 column, required by write_out

    // Load the data from files
    template <typename T>
    int load_dat (void* data, const std::string & name, const std::string & dir, size_t n);

    // Get the table header of each table
    ap_uint<512> get_table_header (int n512b, int nrow);

    // Compare result of two arrays
    void compload (int* a, int* b, int n);

    // Allocate memory buffer aligned with 4096 boundary
    template <typename T>
    T* aligned_alloc (std::size_t num);

    // Free the allocated memory buffer
    void free_mem (void* a);
};

#endif // _VitisTable_H_
