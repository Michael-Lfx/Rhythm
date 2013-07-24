/******************************************************************************
 *  Copyright (C) Cambridge Silicon Radio Limited 2012-2013
 *  Part of CSR uEnergy SDK 2.1.0
 *  Application version 2.1.0.0
 *
 *  FILE
 *      app_gatt.h
 *
 *  DESCRIPTION
 *      Header definitions for common application attributes
 *
 *  NOTES
 *
 ******************************************************************************/
#ifndef __APP_GATT_H__
#define __APP_GATT_H__

/*============================================================================*
 *  SDK Header Files
 *============================================================================*/
#include <panic.h>
#include <time.h>

/*============================================================================*
 *  Local Header File
 *============================================================================*/

/*============================================================================*
 *  Public Definitions
 *============================================================================*/

/* This macro is required to be disabled if user does not want to see messages
 * on UART
 */
#define DEBUG_THRU_UART

/* Invalid UCID indicating we are not currently connected */
#define GATT_INVALID_UCID               (0xFFFF)

/* AD type for Appearance */
#define AD_TYPE_APPEARANCE              (0x19)


/* Maximum number of words in central device IRK */
#define MAX_WORDS_IRK                   (8)

/*Number of IRKs that application can store */
#define MAX_NUMBER_IRK_STORED           (1)

/* Extract low order byte of 16-bit  */
#define LE8_L(x)                        ((x) & 0xff)

/* Extract high order byte of 16-bit  */
#define LE8_H(x)                        (((x) >> 8) & 0xff)


/* For services 0 is an invalid NVM offset as application stores bonding flag
 * information at 0 offset
 */
#define SERVICE_INVALID_NVM_OFFSET      (0)

/* CS KEY Index for PTS */
/* Application have eight CS keys for its use. Index for these keys : [0-7]
 * First CS key at index 0 will be used for PTS test cases which require 
 * application behaviour different from our current behaviour.
 * For such PTS test cases, we have implemented some work arounds which will 
 * get enabled by setting user CSkey at following index
 */
#define PTS_CS_KEY_INDEX                (0x0000)

/* Note : Both these bits should not be enabled togather as normal use case
 * does not want this.
 */


/* bit0 of CSkey will be used for those PTS test cases which want application to
 * write disable notification and indication on the client configuration
 * descriptor.
 */
#define PTS_DISABLE_NOTIFY_CS_KEY_MASK  (0x0001)


/* Bit1 will be used for generating context in every record */
#define PTS_WRITE_ONLY_SILENT_MODE      (0x0002)


/* This constant is used in defining  some arrays so it should always be large 
 * enough to hold the advertisement data.
 */
#define MAX_ADV_DATA_LEN                (31)


#define GAP_CONN_PARAM_TIMEOUT          (30 * SECOND)


/* Timer value for remote device to re-encrypt the link using old keys */
#define BONDING_CHANCE_TIMER            (30*SECOND)
/*============================================================================*
 *  Public Data Types
 *============================================================================*/

/* GATT client characteristic configuration value [Ref GATT spec, 3.3.3.3]*/
typedef enum
{
    gatt_client_config_none = 0x0000,
    gatt_client_config_notification = 0x0001,
    gatt_client_config_indication = 0x0002,
    gatt_client_config_reserved = 0xFFF4

} gatt_client_config;

/*  Application defined panic codes */
typedef enum
{
    /* Failure while setting advertisement parameters */
    app_panic_set_advert_params,

    /* Failure while setting advertisement data */
    app_panic_set_advert_data,
    
    /* Failure while setting scan response data */
    app_panic_set_scan_rsp_data,

    /* Failure while establishing connection */
    app_panic_connection_est,

    /* Failure while registering GATT DB with firmware */
    app_panic_db_registration,

    /* Failure while reading NVM */
    app_panic_nvm_read,

    /* Failure while writing NVM */
    app_panic_nvm_write,

    /* Failure while reading Tx Power Level */
    app_panic_read_tx_pwr_level,

    /* Failure while deleting device from whitelist */
    app_panic_delete_whitelist,

    /* Failure while adding device to whitelist */
    app_panic_add_whitelist,

    /* Failure while triggering connection parameter update procedure */
    app_panic_con_param_update,

    /* Event received in an unexpected application state */
    app_panic_invalid_state,

    /* Unexpected beep type */
    app_panic_unexpected_beep_type
}app_panic_code;

/*============================================================================*
 *  Public Function Prototypes
 *============================================================================*/
/* This function starts the service discovery procedure */
extern void StartDiscoveryProcedure(void);

/* This function checks if application is bonded to any device or not */
extern bool AppIsDeviceBonded(void);

/* This function is used to enable notifications on client configuration 
 * descriptors.
 */
extern void MainEnableNotifications(uint16 cid, uint16 handle);

/* This is used to report panic which results in chip reset */
extern void ReportPanic(app_panic_code panic_code);
#endif /* __APP_GATT_H__ */

