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

#include <boost/chrono.hpp>
#include "WorkerRegex.h"
#include "ThreadRegex.h"
#include "constants.h"

using namespace boost::chrono;

WorkerRegex::WorkerRegex (HardwareManagerPtr in_hw_mgr, Relation in_relation, int in_attr_id, bool in_debug)
    : WorkerBase (in_hw_mgr),
      m_buffers (NULL),
      m_tuples (NULL),
      m_tuples_len (NULL),
      m_interrupt (true),
      m_patt_src_base (NULL),
      m_patt_size (0),
      m_relation (in_relation),
      m_attr_id (in_attr_id),
      m_num_blks (0),
      m_num_tuples (0)
{
    m_job_manager_en = false;

    if (m_attr_id < 0) {
        elog (ERROR, "Invalid attribute ID %d", m_attr_id);
    }
}

WorkerRegex::~WorkerRegex()
{
    elog (DEBUG5, "WorkerRegex destroyed!");
}

void WorkerRegex::set_mode (bool in_interrupt)
{
    m_interrupt = in_interrupt;
}

int WorkerRegex::init()
{
    for (size_t i = 0; i < m_threads.size(); i++) {
        if (m_threads[i]->init()) {
            return -1;
        }
    }

    return 0;
}

void WorkerRegex::check_thread_done()
{
    if (m_interrupt) {
        elog (ERROR, "Interrupt mode is not supported yet!");
    } else {
        do {
            bool all_done = true;

            for (int i = 0; i < (int)m_threads.size(); i++) {
                if (0 == m_threads[i]->get_num_remaining_jobs()) {
                    m_threads[i]->stop();
                } else {
                    all_done = false;
                }
            }

            if (all_done) {
                elog (DEBUG1, "Worker -- All jobs done");
                break;
            }

            boost::this_thread::interruption_point();
        } while (1);
    }
}

int WorkerRegex::check_start()
{
    if (NULL == m_buffers) {
        elog (ERROR, "Invalid m_buffers");
        return -1;
    }

    if (NULL == m_patt_src_base || 0 == m_patt_size) {
        elog (ERROR, "Invalid pattern buffer");
        return -1;
    }

    return 0;
}

int WorkerRegex::regex_compile (const char* in_patt)
{
    if (NULL == in_patt) {
        elog (ERROR, "Invalid input pattern pointer!");
        return -1;
    }

    m_patt_src_base = capi_regex_compile_internal (in_patt, &m_patt_size);

    if (NULL == m_patt_src_base || 0 == m_patt_size) {
        elog (ERROR, "Failed to compile regex pattern!");
        return -1;
    }

    return 0;
}

void* WorkerRegex::get_pattern_buffer()
{
    return m_patt_src_base;
}

size_t WorkerRegex::get_pattern_buffer_size()
{
    return m_patt_size;
}

Relation WorkerRegex::get_relation()
{
    return m_relation;
}

int WorkerRegex::get_attr_id()
{
    return m_attr_id;
}

size_t WorkerRegex::get_num_tups_per_thread (int in_thread_id, int* out_start_tup_id)
{
    int num_threads = m_threads.size();

    if (m_num_tuples <= 0) {
        return -1;
    }

    if (num_threads <= 0) {
        return -1;
    }

    int tuples_per_thread = m_num_tuples / num_threads;
    int tuples_last_thread = m_num_tuples % num_threads;

    if (0 == tuples_per_thread) {
        // TODO: if number of total blocks is less than number of threads, get panic.
        // Need to revisit this behavior.
        return -1;
    }

    *out_start_tup_id = in_thread_id * tuples_per_thread;

    int num_tuples_per_thread = tuples_per_thread;

    if (in_thread_id == (num_threads - 1)) {
        num_tuples_per_thread += tuples_last_thread;
    }

    return num_tuples_per_thread;
}

void WorkerRegex::cleanup()
{
    free_mem (m_patt_src_base);
    release_buffers();
    m_hw_mgr = NULL;

    high_resolution_clock::time_point t_start = high_resolution_clock::now();

    for (size_t i = 0; i < m_threads.size(); i++) {
        m_threads[i]->cleanup();
    }

    high_resolution_clock::time_point t_end = high_resolution_clock::now();
    auto duration = duration_cast<microseconds> (t_end - t_start).count();
    elog (DEBUG1, "Free all threads after %lu microseconds (us)", (uint64_t) duration);

    m_threads.clear();
}

void WorkerRegex::read_buffers()
{
    capi_regex_check_relation (m_relation);

    m_num_blks = RelationGetNumberOfBlocksInFork (m_relation, MAIN_FORKNUM);
    int m_est_num_blks = m_relation->rd_rel->relpages;
    int m_est_num_tups; //just estimation collected by pg vacuum, not accurate

    if (m_est_num_blks == m_num_blks) {
        m_est_num_tups = (int)m_relation->rd_rel->reltuples + 1;
    } else {
        m_est_num_tups = (int) (m_relation->rd_rel->reltuples * 1.1);
    }

    m_buffers = (Buffer*) malloc (sizeof (Buffer) * m_num_blks);
    m_tuples = (HeapTupleHeader*) malloc (sizeof (HeapTupleHeader) * m_est_num_tups);
    m_tuples_len = (uint32*) malloc (sizeof (uint32) * m_est_num_tups);

    int count = 0;

    for (int blk_num = 0; blk_num < m_num_blks; ++blk_num) {
        Buffer buf = ReadBufferExtended (m_relation, MAIN_FORKNUM, blk_num, RBM_NORMAL, NULL);

        Page page = (Page) BufferGetPage (buf);
        int num_lines = PageGetMaxOffsetNumber (page);
        m_num_tuples += num_lines;

        m_buffers[blk_num] = buf;

        for (int line_num = 0; line_num <= num_lines; ++line_num) {
            ItemId id = PageGetItemId (page, line_num);
            uint16 lp_offset = ItemIdGetOffset (id);
            uint16 lp_len = ItemIdGetLength (id);

            if (lp_len >= MinHeapTupleSize &&
                lp_offset == MAXALIGN (lp_offset)) {
                HeapTupleHeader tuphdr = (HeapTupleHeader) PageGetItem (page, id); // also check ItemIdHasStorage (id)
                m_tuples[count] = tuphdr;
                m_tuples_len[count] = lp_len;
                count++;
            }
        }
    }

    elog (DEBUG1, "Read %d buffers from relation", m_num_blks);
    elog (DEBUG1, "Read %zu tuples from relation", m_num_tuples);
}

void WorkerRegex::release_buffers()
{
    if (m_buffers) {
        for (int blk_num = 0; blk_num < m_num_blks; ++blk_num) {
            Buffer buf = m_buffers[blk_num];
            ReleaseBuffer (buf);
        }

        free (m_buffers);
        free (m_tuples);
        free (m_tuples_len);
    }
}

