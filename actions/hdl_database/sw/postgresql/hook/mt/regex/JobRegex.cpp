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
#include "time.h"
#include "JobRegex.h"
#include "constants.h"

JobRegex::JobRegex()
    : JobBase(),
      m_worker (NULL),
      m_job_desc (NULL)
{
}

JobRegex::JobRegex (int in_id, int in_thread_id)
    : JobBase (in_id, in_thread_id),
      m_worker (NULL),
      m_job_desc (NULL)
{
}

JobRegex::JobRegex (int in_id, int in_thread_id, HardwareManagerPtr in_hw_mgr)
    : JobBase (in_id, in_thread_id, in_hw_mgr),
      m_worker (NULL),
      m_job_desc (NULL)
{
}

JobRegex::JobRegex (int in_id, int in_thread_id, HardwareManagerPtr in_hw_mgr, bool in_debug)
    : JobBase (in_id, in_thread_id, in_hw_mgr, in_debug),
      m_worker (NULL),
      m_job_desc (NULL)
{
}

JobRegex::~JobRegex()
{
    //elog (DEBUG5, "JobRegex destroyed!");
}

int JobRegex::run()
{
    if (NULL == m_job_desc) {
        elog (ERROR, "Job descriptor is NULL");
        fail();
        return -1;
    }

    do {
        //elog (DEBUG3, "Thread %d Job %d: Before init()..", m_thread_id, m_id);
        if (init()) {
            elog (ERROR, "Failed to perform regex job initializing");
            fail();
            return -1;
        }

        //elog (DEBUG3, "Thread %d Job %d: Finish init()..", m_thread_id, m_id);
        if (packet()) {
            elog (ERROR, "Failed to perform regex packet preparing");
            fail();
            return -1;
        }

        //elog (INFO, "Thread %d Job %d: Finish packet()..", m_thread_id, m_id);
    } while (0);

    do {
        // TODO: Only 1 job is allowed to access hardware at a time.
        //boost::lock_guard<boost::mutex> lock (ThreadBase::m_global_mutex);

        if (scan()) {
            elog (ERROR, "Failed to perform regex scanning");
            fail();
            return -1;
        }

        //elog (INFO, "Thread %d Job %d: Finish scan()..", m_thread_id, m_id);
    } while (0);

    if (result()) {
        elog (ERROR, "Failed to perform regex packet result harvesting");
        fail();
        return -1;
    }

    //elog (INFO, "Thread %d Job %d: Finish result()..", m_thread_id, m_id);

    done();

    return 0;
}

void JobRegex::set_worker (WorkerRegexPtr in_worker)
{
    m_worker = in_worker;
}

void JobRegex::set_thread (ThreadRegexPtr in_thread)
{
    m_thread = in_thread;
}

WorkerRegexPtr JobRegex::get_worker()
{
    return m_worker;
}

int JobRegex::init()
{
    if (NULL == m_worker) {
        elog (ERROR, "Worker points to NULL, cannot perform regex job init");
        return -1;
    }

    if (NULL == m_hw_mgr) {
        elog (ERROR, "Hardware manager points to NULL, cannot perform regex job init");
        return -1;
    }

    // Copy the pattern from worker to job
    m_job_desc->patt_src_base = m_worker->get_pattern_buffer();
    m_job_desc->patt_size = m_worker->get_pattern_buffer_size();

    int start_tup_id = 0;
    int num_tups = m_thread->get_num_tups_per_job (m_id, &start_tup_id);

    // Get the tuples for this job
    m_job_desc->num_tups = num_tups;
    m_job_desc->start_tup_id = start_tup_id;

    if (0 == num_tups) {
        elog (ERROR, "Number of tuples is invalid for thread %d job %d",
              m_thread_id, m_id);
    }

    // Assign the thread id to this job descriptor
    m_job_desc->thread_id = m_thread_id;

    // Reset the engine
    m_hw_mgr->reset_engine (m_thread_id);

    return 0;
}

int JobRegex::packet()
{
    if (NULL == m_worker) {
        elog (ERROR, "Worker points to NULL, cannot perform regex packet preparation");
        return -1;
    }

    if (capi_regex_pkt_psql (m_job_desc, m_worker->get_relation(),
                             m_worker->get_attr_id())) {
        elog (ERROR, "Failed to prepare packet buffer");
        return -1;
    }

    return 0;
}

int JobRegex::scan()
{
    if (capi_regex_scan (m_job_desc)) {
        elog (ERROR, "Failed to scan the table");
        return -1;
    }

    return 0;
}

int JobRegex::result()
{
    if (NULL == m_job_desc->stat_dest_base) {
        elog (ERROR, "Invalid result buffer");
        return -1;
    }

    if (capi_regex_result_harvest (m_job_desc)) {
        elog (ERROR, "Failed to get the result of regex scan");
        return -1;
    }

    return 0;
}

void JobRegex::set_job_desc (CAPIRegexJobDescriptor* in_job_desc)
{
    m_job_desc = in_job_desc;
}

int JobRegex::set_packet_buffer (void* in_pkt_src_base, size_t in_max_alloc_pkt_size)
{
    if (NULL == m_job_desc) {
        elog (ERROR, "Job descriptor is NULL");
        fail();
        return -1;
    }

    m_job_desc->pkt_src_base = in_pkt_src_base;

    if (NULL == m_job_desc->pkt_src_base) {
        elog (ERROR, "packet buffer assigned: fail");
        return -1;
    }

    m_job_desc->max_alloc_pkt_size = in_max_alloc_pkt_size;
    return 0;
}

int JobRegex::set_result_buffer (void* in_stat_dest_base, size_t in_stat_size)
{
    if (NULL == m_job_desc) {
        elog (ERROR, "Job descriptor is NULL");
        fail();
        return -1;
    }

    m_job_desc->stat_dest_base = in_stat_dest_base;
    m_job_desc->stat_size = in_stat_size;
    return 0;
}


void JobRegex::cleanup()
{
    m_hw_mgr = NULL;
    m_worker = NULL;
    m_thread = NULL;
}

int JobRegex::capi_regex_pkt_psql_internal (Relation rel, int attr_id,
        int start_tup_id, int num_tups,
        void* pkt_src_base,
        size_t* size, size_t* size_wo_hw_hdr,
        size_t* num_pkt, int64_t* t_pkt_cpy)
{
    if (NULL == pkt_src_base) {
        return -1;
    }

    void* pkt_src      = pkt_src_base;
    TupleDesc tupdesc  = RelationGetDescr (rel);

    for (int tup_num = 0; tup_num < num_tups; ++tup_num) {
        //elog (DEBUG1, "before get tuphdr");
        HeapTupleHeader tuphdr = m_worker->m_tuples[start_tup_id + tup_num];
        //elog (DEBUG1, "tuphdr is at %p", (void*)tuphdr);
        //elog (DEBUG1, "after get tuphdr");
        // TODO: be careful about the packet id.
        // The packet id is supposed to be the row ID in the relation,
        // is this really the correct way to do this?
        int pkt_id = start_tup_id + tup_num;

        uint16 lp_len = m_worker->m_tuples_len[start_tup_id + tup_num];
        int attr_len = 0;
        //elog (DEBUG1, "before datumgetbyteap");
        char* attrChar = get_attr (tuphdr, tupdesc, lp_len, attr_id, &attr_len);
        //elog (DEBUG1, "after get_attr");
        bytea* attr_ptr = DatumGetByteaP (attrChar);
        //elog (DEBUG1, "after datumgetbyteap");
        attr_len = VARSIZE (attr_ptr) - VARHDRSZ;
        (*size_wo_hw_hdr) += attr_len;
        pkt_src = fill_one_packet (VARDATA (attr_ptr), attr_len, pkt_src, pkt_id);
        (*num_pkt)++;
    }

    (*size) = (uint64_t) pkt_src - (uint64_t) pkt_src_base;

    //return pkt_src_base;
    return 0;
}

int JobRegex::capi_regex_pkt_psql (CAPIRegexJobDescriptor* job_desc, Relation rel, int attr_id)
{
    if (NULL == job_desc) {
        return -1;
    }

    if (NULL == job_desc->pkt_src_base) {
        elog (ERROR, "Invalid packet buffer");
        return -1;
    }

    if (capi_regex_pkt_psql_internal (rel,
                                      attr_id,
                                      job_desc->start_tup_id,
                                      job_desc->num_tups,
                                      job_desc->pkt_src_base,
                                      & (job_desc->pkt_size),
                                      & (job_desc->pkt_size_wo_hw_hdr),
                                      & (job_desc->num_pkt),
                                      & (job_desc->t_regex_pkt_copy))) {
        elog (ERROR, "Failed to run capi_regex_pkt_psql_internal");
        return -1;
    }

    if (job_desc->pkt_size > job_desc->max_alloc_pkt_size) {
        elog (ERROR, "In packet preparation, the real number of packet buffer (%zu)"
              " is larger than estimated (%zu)", job_desc->pkt_size, job_desc->max_alloc_pkt_size);
        return -1;
    }

    return 0;
}

int JobRegex::get_results (void* result, size_t num_matched_pkt, void* stat_dest_base, void* result_len)
{
    int i = 0, j = 0;
    uint32_t pkt_id = 0;

    if (result == NULL) {
        return -1;
    }

    for (i = 0; i < (int)num_matched_pkt; i++) {
        for (j = 4; j < 8; j++) {
            pkt_id |= (((uint8_t*)stat_dest_base)[i * 10 + j] << (j % 4) * 8);
        }

        ((HeapTupleHeader*)result)[i] = m_worker->m_tuples[ (int)pkt_id];
        ((uint32*)result_len)[i] = m_worker->m_tuples_len[ (int)pkt_id];
        pkt_id = 0;
    }

    return 0;
}

int JobRegex::capi_regex_result_harvest (CAPIRegexJobDescriptor* job_desc)
{
    if (job_desc == NULL) {
        return -1;
    }

    int count = 0;

    // Wait for transaction to be done.
    do {
        action_read (job_desc->context->dn, ACTION_STATUS_L, job_desc->thread_id);
        count++;
    } while (count < 10);

    uint32_t reg_data = action_read (job_desc->context->dn, ACTION_STATUS_H, job_desc->thread_id);
    job_desc->num_matched_pkt = reg_data;
    job_desc->results = (HeapTupleHeader*) malloc (reg_data * sizeof (HeapTupleHeader));
    job_desc->results_len = (uint32*) malloc (reg_data * sizeof (uint32));

    //elog (DEBUG1, "Thread %d finished with %d matched packets", job_desc->thread_id, reg_data);

    if (get_results (job_desc->results, reg_data, job_desc->stat_dest_base, job_desc->results_len)) {
        errno = ENODEV;
        return -1;
    }

    return 0;
}


