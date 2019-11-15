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

#ifndef JobRegex_H_h
#define JobRegex_H_h

#include <iostream>
#include "JobBase.h"
#include "WorkerRegex.h"
#include "ThreadRegex.h"

class JobRegex : public JobBase
{
public:
    enum eStatus {
        DONE = 0,
        FAIL,
        NUM_STATUS
    };

    // Constructor of the job base
    JobRegex();
    JobRegex (int in_id, int in_thread_id);
    JobRegex (int in_id, int in_thread_id, HardwareManagerPtr in_hw_mgr);
    JobRegex (int in_id, int in_thread_id, HardwareManagerPtr in_hw_mgr, bool in_debug);

    // Destructor of the job base
    ~JobRegex();

    // Run this job
    virtual int run();

    // Set pointer to worker
    void set_worker (WorkerRegexPtr in_worker);

    // Set pointer to thread the job resides in
    void set_thread (ThreadRegexPtr in_thread);

    // Get pointer to worker
    WorkerRegexPtr get_worker();

    // Initialize the job
    virtual int init();

    // Prepare the packet buffer
    int packet();

    // Perform the regex scan
    int scan();

    // Get the result
    int result();

    // Cleanup smart pointers' references
    virtual void cleanup();

    // Set the job descriptor
    void set_job_desc (CAPIRegexJobDescriptor* in_job_desc);

    // Set the (reused) packet buffer
    int set_packet_buffer (void* in_pkt_src_base, size_t in_max_alloc_pkt_size);

    // Set the (reused) result buffer
    int set_result_buffer (void* in_stat_dest_base, size_t in_stat_size);

private:
    // Pointer to worker for adding job descriptors
    WorkerRegexPtr m_worker;

    // Pointer to thread in which the job resides
    ThreadRegexPtr m_thread;

    // The Job descritpor which contains all information for a regex job
    CAPIRegexJobDescriptor* m_job_desc;

    // Internal functions to handle relation buffers
    //void* capi_regex_pkt_psql_internal (Relation rel,
    int capi_regex_pkt_psql_internal (Relation rel,
                                      int attr_id,
                                      int start_tup_id,
                                      int num_tups,
                                      void* pkt_src_base,
                                      size_t* size,
                                      size_t* size_wo_hw_hdr,
                                      size_t* num_pkt,
                                      int64_t* t_pkt_cpy);

    // Internal functions to handle results
    int capi_regex_result_harvest (CAPIRegexJobDescriptor* job_desc);

    // Helper function to write results
    int get_results (void* result, size_t num_matched_pkt, void* stat_dest_base, void* result_len);

    // Handle the packet preparation
    int capi_regex_pkt_psql (CAPIRegexJobDescriptor* job_desc,
                             Relation rel, int attr_id);

};

typedef boost::shared_ptr<JobRegex> JobRegexPtr;

#endif
