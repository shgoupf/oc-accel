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

#include <malloc.h>
#include "ThreadRegex.h"
#include "JobRegex.h"

ThreadRegex::ThreadRegex()
    : ThreadBase (0, 600),
      m_tuples_base (0),
      m_num_tups (0),
      m_pkt_src_base (NULL),
      m_max_alloc_pkt_size (0),
      m_stat_dest_base (NULL),
      m_stat_size (0),
      m_worker (NULL)
{
}

ThreadRegex::ThreadRegex (int in_id)
    : ThreadBase (in_id),
      m_tuples_base (0),
      m_num_tups (0),
      m_pkt_src_base (NULL),
      m_max_alloc_pkt_size (0),
      m_stat_dest_base (NULL),
      m_stat_size (0),
      m_worker (NULL)
{
}

ThreadRegex::ThreadRegex (int in_id, int in_timeout)
    : ThreadBase (in_id, in_timeout),
      m_tuples_base (0),
      m_num_tups (0),
      m_pkt_src_base (NULL),
      m_max_alloc_pkt_size (0),
      m_stat_dest_base (NULL),
      m_stat_size (0),
      m_worker (NULL)
{
}

ThreadRegex::~ThreadRegex()
{
    //elog (DEBUG5, "ThreadRegex destroyed!");
}

int ThreadRegex::init()
{

    int thd_start_tup_id = 0;
    int thd_num_tups = m_worker->get_num_tups_per_thread (m_id, &thd_start_tup_id);

    set_tup_info (thd_start_tup_id, thd_num_tups);
    allocate_buffers();

    return 0;
}

void ThreadRegex::set_worker (WorkerRegexPtr in_worker)
{
    m_worker = in_worker;
}

void ThreadRegex::set_tup_info (int in_base, int in_num)
{
    m_tuples_base = in_base;
    m_num_tups = in_num;
}

int ThreadRegex::get_num_tups_per_job (int in_job_id, int* out_start_tup_id)
{
    int num_jobs = m_jobs.size();
    int num_tups_per_job = 0;

    if (m_num_tups <= 0) {
        return -1;
    }

    if (num_jobs <= 0) {
        return -1;
    }

    int tups_per_job = m_num_tups / num_jobs;
    int tups_last_job = m_num_tups % num_jobs;

    if (0 == tups_per_job) {
        // TODO: if number of total blocks is less than number of jobs, get panic.
        // Need to revisit this behavior.
        return -1;
    }

    *out_start_tup_id = m_tuples_base + in_job_id * tups_per_job;

    num_tups_per_job = tups_per_job;

    if (in_job_id == (num_jobs - 1)) {
        num_tups_per_job += tups_last_job;
    }

    return num_tups_per_job;
}

int ThreadRegex::allocate_buffers()
{
    int num_jobs = m_jobs.size();

    // TODO: is there a way to know exactly how many tuples we have before iterating all buffers?
    uint64_t total_row_count = m_num_tups;
    uint64_t row_count = 2 * total_row_count / (num_jobs + 1);


    // Allocate the packet buffer
    // The max size that should be alloc
    // TODO: assume maximum size in packet buffer for tuples is 2048 bytes
    size_t row_size = 2048 + 64;
    size_t max_alloc_size = (row_count < MIN_NUM_PKT ? MIN_NUM_PKT : row_count) * row_size;
    m_pkt_src_base = alloc_mem (64, max_alloc_size);
    m_max_alloc_pkt_size = max_alloc_size;

    if (m_pkt_src_base == NULL) {
        elog (ERROR, "Failed to allocate packet buffer for thread %d", m_id);
        return -1;
    }

    // Allocate the result buffer
    // TODO: Estimate the result buffer by the presumption: num_pkt == num_tuples
    size_t real_stat_size = (OUTPUT_STAT_WIDTH / 8) * row_count * 2;
    size_t stat_size = (real_stat_size % 4096 == 0) ? real_stat_size : real_stat_size + (4096 - (real_stat_size % 4096));

    // At least 4K for output buffer.
    if (stat_size == 0) {
        stat_size = 4096;
    }

    m_stat_dest_base = alloc_mem (64, stat_size);
    m_stat_size = stat_size;

    if (NULL == m_stat_dest_base) {
        elog (ERROR, "Unable to allocate stat buffer!");
        return -1;
    }

    return 0;
}

void ThreadRegex::work_with_job (JobPtr in_job)
{
    JobRegexPtr job = boost::dynamic_pointer_cast<JobRegex> (in_job);

    if (NULL == job) {
        elog (ERROR, "Failed to get pointer to JobRegex");
        return;
    }

    do {
        if (0 != job->set_packet_buffer (m_pkt_src_base, m_max_alloc_pkt_size)) {
            elog (ERROR, "Failed to set packet buffer for JobRegex");
            return;
        }

        if (0 != job->set_result_buffer (m_stat_dest_base, m_stat_size)) {
            elog (ERROR, "Failed to set result buffer for JobRegex");
            return;
        }
    } while (0);

    do {
        if (0 != job->run()) {
            elog (ERROR, "Failed to run the JobRegex");
            return;
        }
    } while (0);

    return;
}

void ThreadRegex::cleanup()
{
    free_mem (m_pkt_src_base);
    free_mem (m_stat_dest_base);

    for (size_t i = 0; i < m_jobs.size(); i++) {
        m_jobs[i]->cleanup();
    }

    m_jobs.clear();

    m_worker = NULL;
    m_thread = NULL;
}

int ThreadRegex::get_id()
{
    return m_id;
}

