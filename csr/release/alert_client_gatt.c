/******************************************************************************
 *  Copyright (C) Cambridge Silicon Radio Limited 2012-2013
 *  Part of CSR uEnergy SDK 2.1.0
 *  Application version 2.1.0.0
 *
 *  FILE
 *      alert_client_gatt.c
 *
 *  DESCRIPTION
 *      Implementation of the Alert client GATT-related routines
 *
 *  NOTES
 *
 ******************************************************************************/
/*============================================================================*
 *  SDK Header Files
 *============================================================================*/
#include <ls_app_if.h>
#include <gap_app_if.h>
#include <gatt.h>
#include <mem.h>

/*============================================================================*
 *  Local Header File
 *============================================================================*/
#include "alert_client_gatt.h"
#include "alert_client.h"
#include "app_gatt.h"
#include "appearance.h"
#include "gap_conn_params.h"
#include "app_gatt_db.h"
#include "gap_uuids.h"
#include "dev_info_uuids.h"
/*============================================================================*
 *  Private Function Prototypes
 *============================================================================*/

/* This function sets the advertising paramters */
static void gattSetAdvertParams(gap_mode_connect connect_mode);

/* This function gets called on advertising timer expiry.*/
static void gattAdvertTimerHandler(timer_id tid);

/*============================================================================*
 *  Private Definitions
 *============================================================================*/

 /* Length of Tx Power prefixed with Tx power AD type */
#define TX_POWER_VALUE_LENGTH                    (2)

/*============================================================================*
 *  Private Function Implementations
 *============================================================================*/

/*----------------------------------------------------------------------------*
 *  NAME
 *      gattSetAdvertParams
 *
 *  DESCRIPTION
 *      This function is used to set advertisement parameters
 *
 *  RETURNS
 *      Nothing.
 *
 *----------------------------------------------------------------------------*/
static void gattSetAdvertParams(bool fast_connection)
{
    uint32 adv_interval_min = RP_ADVERTISING_INTERVAL_MIN;
    uint32 adv_interval_max = RP_ADVERTISING_INTERVAL_MAX;

    int8 tx_power_level; /* Unsigned value */

    /* Tx power level value prefixed with Tx power AD type */
    uint8 device_tx_power[TX_POWER_VALUE_LENGTH] = {
                AD_TYPE_TX_POWER
                };

    uint8 device_appearance[ATTR_LEN_DEVICE_APPEARANCE + 1] = {
                AD_TYPE_APPEARANCE,
                LE8_L(APPEARANCE_TAG_VALUE),
                LE8_H(APPEARANCE_TAG_VALUE)
                };
    uint8 device_name[DEVICE_NAME_LENGTH + 1];

    uint8 advert_data[] = {
        AD_TYPE_SERVICE_UUID_16BIT_LIST,
        LE8_L(UUID_METRONOME_SERVICE),
        LE8_H(UUID_METRONOME_SERVICE)
    };

    /* Add AD type on the first byte */
    device_name[0] = AD_TYPE_LOCAL_NAME_COMPLETE;
    MemCopy(&device_name[1], DEVICE_NAME, StrLen(DEVICE_NAME));

    if(fast_connection)
    {
        /* Fast advertising: Use the fast advertising parameters */
        adv_interval_min = FC_ADVERTISING_INTERVAL_MIN;
        adv_interval_max = FC_ADVERTISING_INTERVAL_MAX;
    }

    /* Set Gap modes and advertising paramters */
    if((GapSetMode(gap_role_peripheral, gap_mode_discover_general,
                        gap_mode_connect_undirected, 
                        gap_mode_bond_yes,
                        gap_mode_security_unauthenticate) != ls_err_none) ||
       (GapSetAdvInterval(adv_interval_min, adv_interval_max) 
                        != ls_err_none))
    {
        /*Some error has occurred */
        ReportPanic(app_panic_set_advert_params);
    }

    /* Reset existing advertising data */
    if(LsStoreAdvScanData(0, NULL, ad_src_advertise) != ls_err_none)
    {
        /*Some error has occurred */
        ReportPanic(app_panic_set_advert_data);
    }

    /* Reset existing scan response data */
    if(LsStoreAdvScanData(0, NULL, ad_src_scan_rsp) != ls_err_none)
    {
        /*Some error has occurred */
        ReportPanic(app_panic_set_scan_rsp_data);
    }


    /* Setup ADVERTISEMENT DATA */

    /* Add device appearance to the advertisements */
    if (LsStoreAdvScanData(ATTR_LEN_DEVICE_APPEARANCE + 1, 
        device_appearance, ad_src_advertise) != ls_err_none)
    {
        /*Some error has occurred */
        ReportPanic(app_panic_set_advert_data);
    }

    /* Read tx power of the chip */
    if(LsReadTransmitPowerLevel(&tx_power_level) != ls_err_none)
    {
        /* Reading tx power failed */
        ReportPanic(app_panic_read_tx_pwr_level);
    }

    /* Add the read tx power level to device_tx_power 
     * Tx power level value is of 1 byte 
     */
    device_tx_power[TX_POWER_VALUE_LENGTH - 1] = (uint8 )tx_power_level;

    /* Add tx power value of device to the scan response data */
    if (LsStoreAdvScanData(TX_POWER_VALUE_LENGTH, device_tx_power, 
                          ad_src_scan_rsp) != ls_err_none)
    {
        /* Some error has occurred */
        ReportPanic(app_panic_set_scan_rsp_data);
    }

    /* Add complete device name to scan response data */
    if (LsStoreAdvScanData(sizeof(device_name), device_name, 
                      ad_src_scan_rsp) != ls_err_none)
    {
        /* control should never come here  */
        ReportPanic(app_panic_set_scan_rsp_data);
    }

    if(LsStoreAdvScanData(sizeof(advert_data), advert_data, ad_src_scan_rsp) != ls_err_none){

    }

}

/*----------------------------------------------------------------------------*
 *  NAME
 *      gattAdvertTimerHandler
 *
 *  DESCRIPTION
 *      This function is used to stop on-going advertisements at the expiry of 
 *      DISCOVERABLE or RECONNECTION timer.
 *
 *  RETURNS
 *      Nothing.
 *
 *----------------------------------------------------------------------------*/
 
static void gattAdvertTimerHandler(timer_id tid)
{
    /* Based upon the timer id, stop on-going advertisements */
    if(g_app_data.app_tid == tid)
    {
        if(g_app_data.state == app_fast_advertising)
        {
            /* Advertisement timer for reduced power connections */
            g_app_data.advert_timer_value = 
                                SLOW_CONNECTION_ADVERT_TIMEOUT_VALUE;
        }

            /* Stop on-going advertisements */
            GattStopAdverts();

    } /* Else ignore timer expiry, could be because of 
       * some race condition 
       */
    g_app_data.app_tid = TIMER_INVALID;
}

/*============================================================================*
 *  Public Function Implementations
 *============================================================================*/

/*----------------------------------------------------------------------------*
 *  NAME
 *      GattStartAdverts
 *
 *  DESCRIPTION
 *      This function is used to start undirected advertisements and moves to
 *      ADVERTISING state.
 *
 *
 *  RETURNS
 *      Nothing.
 *
 *----------------------------------------------------------------------------*/
extern void GattStartAdverts(bool fast_connection)
{
    uint16 connect_flags = L2CAP_CONNECTION_SLAVE_UNDIRECTED | 
                          L2CAP_OWN_ADDR_TYPE_PUBLIC | 
                          L2CAP_PEER_ADDR_TYPE_PUBLIC;

    /* Set UCID to INVALID_UCID */
    g_app_data.st_ucid = GATT_INVALID_UCID;

    /* Set advertisement parameters */
    gattSetAdvertParams(fast_connection);

    /* If white list is enabled, set the controller's advertising filter policy 
     * to "process scan and connection requests only from devices in the
     * White List"
     */
    if(g_app_data.bonded == TRUE && 
        (!GattIsAddressResolvableRandom(&g_app_data.bonded_bd_addr)))
    {
        connect_flags = L2CAP_CONNECTION_SLAVE_WHITELIST |
                       L2CAP_OWN_ADDR_TYPE_PUBLIC | 
                       L2CAP_PEER_ADDR_TYPE_PUBLIC;
    }

    /* Start GATT connection in Slave role */
    GattConnectReq(NULL, connect_flags);

    /* Start advertisement timer */
    if(g_app_data.advert_timer_value)
    {
        TimerDelete(g_app_data.app_tid);

        /* Start advertisement timer  */
        g_app_data.app_tid = TimerCreate(g_app_data.advert_timer_value, TRUE, 
                                        gattAdvertTimerHandler);
    }

}

/*----------------------------------------------------------------------------*
 *  NAME
 *      GattStopAdverts
 *
 *  DESCRIPTION
 *      This function is used to stop on-going advertisements.
 *
 *  RETURNS
 *      Nothing.
 *
 *----------------------------------------------------------------------------*/
extern void GattStopAdverts(void)
{
    GattCancelConnectReq();
}


/*----------------------------------------------------------------------------*
 *  NAME
 *      GattIsAddressResolvableRandom
 *
 *  DESCRIPTION
 *      This function checks if the address is resolvable random or not.
 *
 *  RETURNS
 *      Boolean - True if adress is Resolvable random address
 *                False otheriwise
 *
 *----------------------------------------------------------------------------*/

extern bool GattIsAddressResolvableRandom(TYPED_BD_ADDR_T *addr)
{
    if ((addr->type != L2CA_RANDOM_ADDR_TYPE) || 
        (addr->addr.nap & BD_ADDR_NAP_RANDOM_TYPE_MASK)
                                      != BD_ADDR_NAP_RANDOM_TYPE_RESOLVABLE)
    {
        /* This isn't a resolvable private address... */
        return FALSE;
    }
    return TRUE;
}


/*----------------------------------------------------------------------------*
 *  NAME
 *      GattTriggerFastAdverts
 *
 *  DESCRIPTION
 *      This function is used to start advertisements for fast connection 
 *      parameters
 *
 *  RETURNS
 *      Nothing
 *
 *----------------------------------------------------------------------------*/
extern void GattTriggerFastAdverts(void)
{
    /* Start the fast advertising timer */
    g_app_data.advert_timer_value = FAST_CONNECTION_ADVERT_TIMEOUT_VALUE;

    /* Trigger fast connections */
    GattStartAdverts(TRUE);
}
