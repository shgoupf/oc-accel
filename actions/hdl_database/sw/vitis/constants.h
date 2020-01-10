// ****************************************************************
// (C) Copyright International Business Machines Corporation 2017
// Author: Gou Peng Fei (shgoupf@cn.ibm.com)
// ****************************************************************

#ifndef F_CONSTANTS
#define F_CONSTANTS

/* Header file for SNAP Framework DATABASE DIRECT code */
#define ACTION_TYPE_DATABASE           0x00000003	/* Action Type */
#define ACTION_REG_BASE                0x200
#define ACTION_REG_ENG_RANGE           0x100

#define REG(_reg,_id) ((ACTION_REG_BASE + (_id * ACTION_REG_ENG_RANGE)) + _reg)

#define ACTION_HW_VERSION              0x14
#define VITIS_CTRL_BASE                0x00
#define VITIS_REG_BASE                 0x10
#define PU_NM                          8
#define ACTION_WAIT_TIME               1000


// Copied from database/L2/tests/gqeJoin/host/table_dt.hpp
typedef int32_t TPCH_INT;

typedef TPCH_INT MONEY_T;
typedef TPCH_INT DATE_T;
typedef TPCH_INT KEY_T;

#define MONEY_SZ sizeof(TPCH_INT)
#define DATE_SZ sizeof(TPCH_INT)
#define KEY_SZ sizeof(TPCH_INT)
#define REGION_LEN 25

#define TPCH_INT_SZ sizeof(TPCH_INT)

// every cycle, 4 input rows.
#define VEC_LEN 16

//
// ensure when kernel read in vec, won't over read
#define C_MAX_ROW (150000)
#define S_MAX_ROW (10000)
#define L_MAX_ROW (6001215)
#define O_MAX_ROW (1500000)
#define R_MAX_ROW (5)
#define N_MAX_ROW (25)

#define BUFF_DEPTH (O_MAX_ROW / 8 * 2)

#define HT_BUFF_DEPTH (1 << 25)  // 30M
#define S_BUFF_DEPTH (1 << 25)   // 30M
#define HBM_BUFF_DEPTH (1 << 25) // 30M

#endif
