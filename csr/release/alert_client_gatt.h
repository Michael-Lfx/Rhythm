/******************************************************************************
 *  Copyright (C) Cambridge Silicon Radio Limited 2012-2013
 *  Part of CSR uEnergy SDK 2.1.0
 *  Application version 2.1.0.0
 *
 *  FILE
 *      alert_client_gatt.h
 *
 *  DESCRIPTION
 *      Header file for alert client GATT-related routines
 *
 *  NOTES
 *
 ******************************************************************************/
#ifndef __ALERT_CLIENT_GATT_H__
#define __ALERT_CLIENT_GATT_H__

/*============================================================================*
 *         SDK Header Files
 *============================================================================*/
#include <types.h>
#include <time.h>
#include <panic.h>

/*============================================================================*
 *         Public Definitions
 *============================================================================*/
#define FAST_CONNECTION_ADVERT_TIMEOUT_VALUE      (30 * SECOND)
#define SLOW_CONNECTION_ADVERT_TIMEOUT_VALUE      (1 * MINUTE)

/*============================================================================*
 *         Public Function Prototypes
 *============================================================================*/

/* This function starts advertising */
extern void GattStartAdverts(bool fast_connection);

/* This function stops advertising */
extern void GattStopAdverts(void);

/* This function checks if the argument address is resolvable or not */
extern bool GattIsAddressResolvableRandom(TYPED_BD_ADDR_T *addr);

/* Triggers fast advertising */
extern void GattTriggerFastAdverts(void);
#endif /* __ALERT_CLIENT_GATT_H__ */

