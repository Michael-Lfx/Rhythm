#ifndef __SMART_BAND_H__
#define __SMART_BAND_H__


#define UUID_GAP                                       0x1800
#define UUID_DEVICE_NAME                               0x2A00
#define UUID_APPEARANCE                                0x2A01
#define UUID_PER_PREF_CONN_PARAMS                      0x2A04

#define UUID_GATT                                      0x1801

/*============================================================================*
 *  Public Definitions
 *============================================================================*/

/* Advertising parameters, time is expressed in microseconds and the firmware
 * will round this down to the nearest slot. Acceptable range is 20ms to 10.24s
 * and the minimum must be no larger than the maximum.This value needs to be 
 * modified at later stage as decided GPA for specific profile.
 *
 * For Blood Pressure sensor, to enable fast connections though the recommended 
 * range is between 20 ms to 30 ms, but it has been observed that it is way too 
 * energy expensive for Blood Pressure sensor running on coin cell battery. So, we
 * have decided to use 60 ms as the fast connection advertisement interval. For 
 * reduced power connections, the recommended range is between 1s to 2.5 s. 
 * Vendors will need to tune these values as per their requirements.
 */
#define FC_ADVERTISING_INTERVAL_MIN         (20 * MILLISECOND)
#define FC_ADVERTISING_INTERVAL_MAX         (20 * MILLISECOND)

#define RP_ADVERTISING_INTERVAL_MIN         (1280 * MILLISECOND)
#define RP_ADVERTISING_INTERVAL_MAX         (1280 * MILLISECOND)

/* Maximum number of connection parameter update requests that can be send when 
 * connected
 */
#define MAX_NUM_CONN_PARAM_UPDATE_REQS      (2)

/* Brackets should not be used around the value of a macros used in db files. 
 * The parser which creates .c and .h files from .db file doesn't understand 
 * brackets and will raise syntax errors.
 */

/* NOTE: Preferred connection parameter values should be within the range 
 * specifed by the Bluetooth Specification.
 */

/* Minimum and maximum connection interval in number of frames */
#define PREFERRED_MAX_CON_INTERVAL          0x003c /* 20 ms */
#define PREFERRED_MIN_CON_INTERVAL          0x003c /* 20 ms */

/* Slave latency in number of connection intervals */
#define PREFERRED_SLAVE_LATENCY             0x0004 /* 4 conn_intervals */

/* Supervision timeout (ms) = PREFERRED_SUPERVISION_TIMEOUT * 10 ms */
#define PREFERRED_SUPERVISION_TIMEOUT       0x03e8 /* 10 seconds */

/* Generic Heart Rate Sensor appearance value */
#define APPEARANCE_HEALTH_VALUE			0x0200

/*
    custorm characteristic
  */
#define UUID_HEALTH_SERVICE					0x2300
#define UUID_SYNC							0x2301
#define UUID_ZERO                			0x2302
#define UUID_DATA                			0x2303
#define UUID_BATTERY_LEVEL                  0x2304

#define PIO_DIR_OUTPUT  TRUE 
#define PIO_DIR_INPUT   FALSE

#define DEVICE_NAME_MAX_LENGTH              16      /*byte uint8*/

#endif

