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


#include <fstream>
#include <stdio.h>
#include <unistd.h>
#include <string.h>

#include "boost/make_shared.hpp"
#include "boost/shared_ptr.hpp"
#include "boost/chrono.hpp"
#include "HardwareManager.h"
#include "WorkerRegex.h"
#include "ThreadRegex.h"
#include "JobRegex.h"
#include "Interface.h"

using namespace boost::chrono;

int start_regex_workers (PGCAPIScanState* in_capiss)
{
    elog (DEBUG1, "Running on regex worker");

    if (NULL == in_capiss) {
        elog (ERROR, "Invalid CAPI Scan State pointer");
        return -1;
    }

    HardwareManagerPtr hw_mgr = boost::make_shared<HardwareManager> (0, 0, 1000);

    WorkerRegexPtr worker = boost::make_shared<WorkerRegex> (hw_mgr,
                            in_capiss->css.ss.ss_currentRelation,
                            in_capiss->capi_regex_attr_id,
                            false);
    worker->set_mode (false);

    elog (DEBUG1, "Init hardware");
    ERROR_CHECK (hw_mgr->init());
    elog (DEBUG1, "Compile pattern");
    ERROR_CHECK (worker->regex_compile (in_capiss->capi_regex_pattern));

    elog (DEBUG1, "Total %d job(s) for this worker", in_capiss->capi_regex_num_jobs);
    elog (DEBUG1, "Create %d thread(s) for this worker", in_capiss->capi_regex_num_threads);

    if (in_capiss->capi_regex_num_threads > hw_mgr->get_num_engines()) {
        elog (ERROR, "Number of threads %d is greater than number of engines %d",
              in_capiss->capi_regex_num_threads, hw_mgr->get_num_engines());
    }

    // Create threads
    for (int i = 0; i < in_capiss->capi_regex_num_threads; i++) {
        ThreadRegexPtr thd = boost::make_shared<ThreadRegex> (i, 1000);
        thd->set_worker (worker);

        // Assign jobs to each thread
        int job_start_id = (in_capiss->capi_regex_num_jobs / in_capiss->capi_regex_num_threads) * i;
        int num_jobs_in_thd = in_capiss->capi_regex_num_jobs / in_capiss->capi_regex_num_threads;

        if (i != 0 && i == in_capiss->capi_regex_num_threads - 1) {
            num_jobs_in_thd += in_capiss->capi_regex_num_jobs % num_jobs_in_thd;
        }

        for (int j = 0; j < num_jobs_in_thd; j++) {
            // Create 1 job
            JobRegexPtr job = boost::make_shared<JobRegex> (j, i, hw_mgr, false);
            job->set_job_desc (in_capiss->capi_regex_job_descs[job_start_id + j]);
            capi_regex_job_init (in_capiss->capi_regex_job_descs[job_start_id + j], hw_mgr->get_context());
            job->set_worker (worker);
            job->set_thread (thd);
            thd->add_job (job);
        }

        // Add thread to worker
        worker->add_thread (thd);
    }

    elog (DEBUG1, "Finish setting up jobs.");

    do {
        // Read relation buffers
        high_resolution_clock::time_point t_start = high_resolution_clock::now();
        worker->read_buffers();

        if (worker->init()) {
            elog (ERROR, "Failed to initialize worker");
            return -1;
        }

        high_resolution_clock::time_point t_end0 = high_resolution_clock::now();
        auto duration0 = duration_cast<microseconds> (t_end0 - t_start).count();

        // Start work, multithreading starts from here
        worker->start();
        // Multithreading ends at here

        high_resolution_clock::time_point t_end1 = high_resolution_clock::now();
        auto duration1 = duration_cast<microseconds> (t_end1 - t_end0).count();

        // Cleanup objects created for this procedure
        hw_mgr->cleanup();

        high_resolution_clock::time_point t_end1_5 = high_resolution_clock::now();
        worker->cleanup();

        high_resolution_clock::time_point t_end2 = high_resolution_clock::now();
        auto duration1_5 = duration_cast<microseconds> (t_end2 - t_end1_5).count();
        auto duration2 = duration_cast<microseconds> (t_end2 - t_end1).count();

        elog (DEBUG1, "Read buffers finished after %lu microseconds (us)", (uint64_t) duration0);
        elog (DEBUG1, "Work finished after %lu microseconds (us)", (uint64_t) duration1);
        elog (DEBUG1, "Worker Cleanup finished after %lu microseconds (us)", (uint64_t) duration1_5);
        elog (DEBUG1, "Cleanup finished after %lu microseconds (us)", (uint64_t) duration2);

        high_resolution_clock::time_point t_before_write = high_resolution_clock::now();
        std::ofstream out_file;
        out_file.open ("part_perf_tup_rec.csv", std::ios::app);
        out_file << in_capiss->capi_regex_num_threads << " threads ";
        out_file << in_capiss->capi_regex_num_jobs << " jobs,";
        out_file << (float) duration1 / 1000 << ",";
        out_file << (float) duration2 / 1000;
        out_file << "\n";
        out_file.close();
        high_resolution_clock::time_point t_after_write = high_resolution_clock::now();

        auto duration_w = duration_cast<microseconds> (t_after_write - t_before_write).count();
        elog (DEBUG1, "Writing takes %lu microseconds (us)", (uint64_t) duration_w);

        elog (DEBUG1, "Worker done!");
    } while (0);

    return 0;

fail:
    return -1;
}

