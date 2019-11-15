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
#ifndef THREADREGEX_H_h
#define THREADREGEX_H_h

#include <iostream>
#include <vector>
#include <boost/shared_ptr.hpp>
#include <boost/thread.hpp>
#include "ThreadBase.h"
#include "WorkerRegex.h"
#include "HardwareManager.h"

class ThreadRegex : public ThreadBase
{
public:
    // Constructor of thread regex
    ThreadRegex();
    ThreadRegex (int in_id);
    ThreadRegex (int in_id, int in_timeout);

    // Destructor of thread regex
    ~ThreadRegex();

    // Set blocks (buffers) information for this thread
    // Allocate packet buffer and result buffer for this thread
    virtual int init();

    // Set pointer to worker
    void set_worker (WorkerRegexPtr in_worker);

    // Set tuples base and number of tuples
    void set_tup_info (int in_base, int in_num);

    // Get the number of tuples for different job
    int get_num_tups_per_job (int in_job_id, int* out_start_tup_id);

    // Allocate the reused packet buffer and result buffer for this thread
    int allocate_buffers();

    // Get the id of this thread
    int get_id();

    // Work with the jobs
    virtual void work_with_job (JobPtr in_job);

    // Cleanup
    virtual void cleanup();

private:
    // Base address of worker's tuples for this thread
    int m_tuples_base;

    // Total number of tuples assigned to this thread
    int m_num_tups;

    // Pattern buffer base address for this thread
    void* m_pkt_src_base;

    // Maximum allocated size of the packet buffer
    size_t m_max_alloc_pkt_size;

    // Result buffer base address for this thread
    void* m_stat_dest_base;

    // Size of the output buffer
    size_t m_stat_size;

    // Pointer to worker
    WorkerRegexPtr m_worker;
};

typedef boost::shared_ptr<ThreadRegex> ThreadRegexPtr;

#endif
