

/*********************************************************************
 * INCLUDES
 */

#include "bcomdef.h"
#include "OSAL.h"
#include "OSAL_PwrMgr.h"
#include "OSAL_Clock.h"

#include "OnBoard.h"
#include "hal_adc.h"
#include "hal_led.h"
#include "hal_key.h"
#include "hal_lcd.h"

#include "hal_i2c.h"

#include "battservice.h"

#include "debug.h"

#include "gatt.h"

#include "hci.h"

#include "gapgattserver.h"
#include "gattservapp.h"
#include "devinfoservice.h"
#include "health_profile.h"

#if defined ( PLUS_BROADCASTER )
#include "peripheralBroadcaster.h"
#else
#include "peripheral.h"
#endif

#include "gapbondmgr.h"

#include "simpleBLEPeripheral.h"

#if defined FEATURE_OAD
#include "oad.h"
#include "oad_target.h"
#endif

/*********************************************************************
 * MACROS
 */

/*********************************************************************
 * CONSTANTS
 */

#define HI_UINT32(x)        (((x) >> 16) & 0xffff)
#define LO_UINT32(x)        ((x) & 0xffff)

// How often to perform periodic event
#define SBP_PERIODIC_EVT_PERIOD                   5000

// What is the advertising interval when device is discoverable (units of 625us, 160=100ms)
#define DEFAULT_ADVERTISING_INTERVAL          160

// Limited discoverable mode advertises for 30.72s, and then stops
// General discoverable mode advertises indefinitely

#define DEFAULT_DISCOVERABLE_MODE             GAP_ADTYPE_FLAGS_GENERAL

// Minimum connection interval (units of 1.25ms, 80=100ms) if automatic parameter update request is enabled
#define DEFAULT_DESIRED_MIN_CONN_INTERVAL     80

// Maximum connection interval (units of 1.25ms, 800=1000ms) if automatic parameter update request is enabled
#define DEFAULT_DESIRED_MAX_CONN_INTERVAL     160

// Slave latency to use if automatic parameter update request is enabled
#define DEFAULT_DESIRED_SLAVE_LATENCY         4

// Supervision timeout value (units of 10ms, 1000=10s) if automatic parameter update request is enabled
#define DEFAULT_DESIRED_CONN_TIMEOUT          5000

// Whether to enable automatic parameter update request when a connection is formed
#define DEFAULT_ENABLE_UPDATE_REQUEST         TRUE

// Connection Pause Peripheral time value (in seconds)
#define DEFAULT_CONN_PAUSE_PERIPHERAL         6

// Company Identifier: Texas Instruments Inc. (13)
#define TI_COMPANY_ID                         0x000D

#define INVALID_CONNHANDLE                    0xFFFF

// Length of bd addr as a string
#define B_ADDR_STR_LEN                        15

// Battery level is critical when it is less than this %
#define DEFAULT_BATT_CRITICAL_LEVEL           6

// Battery measurement period in ms
#define DEFAULT_BATT_PERIOD                   15000

// Battery measurement period in ms
#define DEFAULT_ADXL345_PERIOD                100

#if defined ( PLUS_BROADCASTER )
#define ADV_IN_CONN_WAIT                      500 // delay 500 ms
#endif

// define i2c address
#define ADXL345_ADDRESS                       0x1D

#define EEPROM_ADDRESS                        0x50

//define i2c clock rate
#define I2C_CLOCK_RATE                        i2cClock_33KHZ

// define for adxl345
#define Reg_ID 0
#define Reg_thresh_tap 0x1D
#define Reg_OFSX 0x1E
#define Reg_OFSY 0x1F
#define Reg_OFSZ 0x20
#define Reg_DUR 0x21
#define Reg_LATENT 0X22
#define Reg_WINDOW 0X23
#define Reg_THRESH_ACT 0X24
#define Reg_THRESH_INACT 0X25
#define Reg_TIME_INACT 0X26
#define Reg_ACT_INACT_CTL 0X27
#define Reg_THRESH_FF 0X28
#define Reg_TIME_FF 0X29
#define Reg_TAP_AXES 0X2A
#define Reg_ACT_TAP_STATUS 0X2B
#define Reg_BW_RATE 0X2C
#define Reg_POWER_CTL 0x2D
#define Reg_INT_ENABLE 0x2E
#define Reg_INT_MAP 0X2F
#define Reg_INT_SOURCE 0X30
#define Reg_DATA_FORMAT 0X31
#define Reg_DX0 0x32
#define Reg_DX1 0x33
#define Reg_DY0 0x34
#define Reg_DY1 0x35
#define Reg_DZ0 0x36
#define Reg_DZ1 0x37
#define Reg_FIFO_CTL 0X38
#define Reg_FIFO_STATUS 0X39

uint8 X0, X1, Y0, Y1, Z1, Z0;
int16 X_out, Y_out, Z_out;
uint8 INT_STATUS;

int16 PACE_DUR_MIN = 5; //0.3s
int16 PACE_DUR_MAX = 10; //1.2s
int16 ALT_MIN = 300;
int16 DIR = 1; //12?
int16 first_pace = 1; //1:?0?
int16 pace_count = 0; //
int16 PACE_PEAK = 0;
int16 PACE_BOTTOM = 0;
int16 time_count = 0;
int16 cross_count = 0; //0
int16 ACC_CUR = 0;


// define for eeprom
#define EEPROM_ADDRESS_BLOCK_SIZE           8
#define EEPROM_ADDRESS_BLOCK_COUNT          100

#define EEPROM_ADDRESS_RESERVE_MAX          32768
#define EEPROM_ADDRESS_DATA_MAX             (EEPROM_ADDRESS_BLOCK_SIZE * EEPROM_ADDRESS_BLOCK_COUNT)

#define EEPROM_POSITION_STEP_DATA_START     (EEPROM_ADDRESS_DATA_MAX)
#define EEPROM_POSITION_STEP_DATA_STOP      (EEPROM_POSITION_STEP_DATA_START + 2)


/*********************************************************************
 * TYPEDEFS
 */

/*********************************************************************
 * GLOBAL VARIABLES
 */

/*********************************************************************
 * EXTERNAL VARIABLES
 */

/*********************************************************************
 * EXTERNAL FUNCTIONS
 */

/*********************************************************************
 * LOCAL VARIABLES
 */
static uint8 simpleBLEPeripheral_TaskID;   // Task ID for internal task/event processing

static gaprole_States_t gapProfileState = GAPROLE_INIT;

// GAP - SCAN RSP data (max size = 31 bytes)
uint8 scanRspData[] =
{
    // complete name
    0x11,   // length of this data, p.s. contain header and body
    GAP_ADTYPE_LOCAL_NAME_COMPLETE,
    'A',
    'd',
    'd',
    'i',
    'n',
    'g',
    ' ',
    'A',
    '1',
    '-',
    '0',
    '0',
    '0',
    '0',
    '0',
    '0',

    // connection interval range
    0x05,   // length of this data
    GAP_ADTYPE_SLAVE_CONN_INTERVAL_RANGE,
    LO_UINT16( DEFAULT_DESIRED_MIN_CONN_INTERVAL ),
    HI_UINT16( DEFAULT_DESIRED_MIN_CONN_INTERVAL ),
    LO_UINT16( DEFAULT_DESIRED_MAX_CONN_INTERVAL ),
    HI_UINT16( DEFAULT_DESIRED_MAX_CONN_INTERVAL ),

    // Tx power level
    0x02,   // length of this data
    GAP_ADTYPE_POWER_LEVEL,
    0       // 0dBm
};

// GAP - Advertisement data (max size = 31 bytes, though this is
// best kept short to conserve power while advertisting)
static uint8 advertData[] =
{
    // Flags; this sets the device to use limited discoverable
    // mode (advertises for 30 seconds at a time) instead of general
    // discoverable mode (advertises indefinitely)
    0x02,   // length of this data
    GAP_ADTYPE_FLAGS,
    DEFAULT_DISCOVERABLE_MODE | GAP_ADTYPE_FLAGS_BREDR_NOT_SUPPORTED,

    // service UUID, to notify central devices what services are included
    // in this peripheral
    0x05,   // length of this data
    GAP_ADTYPE_16BIT_MORE,      // some of the UUID's, but not all
    LO_UINT16( HEALTH_SERV_UUID ),
    HI_UINT16( HEALTH_SERV_UUID ),
    LO_UINT16(BATT_SERVICE_UUID),
    HI_UINT16(BATT_SERVICE_UUID)

};

// GAP GATT Attributes
uint8 attDeviceName[GAP_DEVICE_NAME_LEN] = "Adding A1-000000";

// define for eeprom
uint16 stepDataStart = 0, stepDataStop = 0;

typedef struct
{
    UTCTimeStruct       tm;
    UTCTime             hourSeconds;
    uint16              count;
    uint8               type;
}one_data_t;

one_data_t oneData;

uint8 db[EEPROM_ADDRESS_DATA_MAX];

/*********************************************************************
 * LOCAL FUNCTIONS
 */
static void simpleBLEPeripheral_ProcessOSALMsg( osal_event_hdr_t *pMsg );
static void peripheralStateNotificationCB( gaprole_States_t newState );
static void performPeriodicTask( void );
static void simpleProfileChangeCB( uint8 paramID );

static void heartRateBattPeriodicTask( void );
static void heartRateBattCB(uint8 event);

static void adxl345Init(void);
static void adxl345Loop(void);

static void adxl345GetIntData(void);
static void adxl345GetAccData(void);

static void eepromWriteStep(void);
static void eepromReadStep(void);

#if (defined HAL_LCD) && (HAL_LCD == TRUE)
static char *bdAddr2Str ( uint8 *pAddr );
#endif // (defined HAL_LCD) && (HAL_LCD == TRUE)



/*********************************************************************
 * PROFILE CALLBACKS
 */

// GAP Role Callbacks
static gapRolesCBs_t simpleBLEPeripheral_PeripheralCBs =
{
    peripheralStateNotificationCB,  // Profile State Change Callbacks
    NULL                            // When a valid RSSI is read from controller (not used by application)
};

// GAP Bond Manager Callbacks
static gapBondCBs_t simpleBLEPeripheral_BondMgrCBs =
{
    NULL,                     // Passcode callback (not used by application)
    NULL                      // Pairing / Bonding state Callback (not used by application)
};

// Simple GATT Profile Callbacks
static simpleProfileCBs_t simpleBLEPeripheral_SimpleProfileCBs =
{
    simpleProfileChangeCB    // Charactersitic value change callback
};

/*********************************************************************
 * PUBLIC FUNCTIONS
 */

/*********************************************************************
 * @fn      SimpleBLEPeripheral_Init
 *
 * @brief   Initialization function for the Simple BLE Peripheral App Task.
 *          This is called during initialization and should contain
 *          any application specific initialization (ie. hardware
 *          initialization/setup, table initialization, power up
 *          notificaiton ... ).
 *
 * @param   task_id - the ID assigned by OSAL.  This ID should be
 *                    used to send messages and set timers.
 *
 * @return  none
 */
void SimpleBLEPeripheral_Init( uint8 task_id )
{
    simpleBLEPeripheral_TaskID = task_id;

    Debug_init(simpleBLEPeripheral_TaskID);

    //xp code
    adxl345Init();
    //xp code

    DebugWrite("Status OK");

    // use low 6 bytes mac address of ti2541 to be our sn
    char hex[] = "0123456789ABCDEF";
    uint8 ownAddress[B_ADDR_LEN];

    // read unique ieee address
    LL_ReadBDADDR(ownAddress);

    uint8 sn[] =
    {
        hex[HI_UINT8(ownAddress[2])],
        hex[LO_UINT8(ownAddress[2])],
        hex[HI_UINT8(ownAddress[1])],
        hex[LO_UINT8(ownAddress[1])],
        hex[HI_UINT8(ownAddress[0])],
        hex[LO_UINT8(ownAddress[0])]
    };

    // rewrite device name
    osal_memcpy(&scanRspData[12], sn, sizeof(sn));
    osal_memcpy(&attDeviceName[10], sn, sizeof(sn));

    DebugWrite(attDeviceName);

    // Setup the GAP
    VOID GAP_SetParamValue( TGAP_CONN_PAUSE_PERIPHERAL, DEFAULT_CONN_PAUSE_PERIPHERAL );

    // Setup the GAP Peripheral Role Profile
    {
        // For other hardware platforms, device starts advertising upon initialization
        uint8 initial_advertising_enable = TRUE;

        // By setting this to zero, the device will go into the waiting state after
        // being discoverable for 30.72 second, and will not being advertising again
        // until the enabler is set back to TRUE
        uint16 gapRole_AdvertOffTime = 0;

        uint8 enable_update_request = DEFAULT_ENABLE_UPDATE_REQUEST;
        uint16 desired_min_interval = DEFAULT_DESIRED_MIN_CONN_INTERVAL;
        uint16 desired_max_interval = DEFAULT_DESIRED_MAX_CONN_INTERVAL;
        uint16 desired_slave_latency = DEFAULT_DESIRED_SLAVE_LATENCY;
        uint16 desired_conn_timeout = DEFAULT_DESIRED_CONN_TIMEOUT;

        // Set the GAP Role Parameters
        GAPRole_SetParameter( GAPROLE_ADVERT_ENABLED, sizeof( uint8 ), &initial_advertising_enable );
        GAPRole_SetParameter( GAPROLE_ADVERT_OFF_TIME, sizeof( uint16 ), &gapRole_AdvertOffTime );

        GAPRole_SetParameter( GAPROLE_SCAN_RSP_DATA, sizeof ( scanRspData ), scanRspData );
        GAPRole_SetParameter( GAPROLE_ADVERT_DATA, sizeof( advertData ), advertData );

        GAPRole_SetParameter( GAPROLE_PARAM_UPDATE_ENABLE, sizeof( uint8 ), &enable_update_request );
        GAPRole_SetParameter( GAPROLE_MIN_CONN_INTERVAL, sizeof( uint16 ), &desired_min_interval );
        GAPRole_SetParameter( GAPROLE_MAX_CONN_INTERVAL, sizeof( uint16 ), &desired_max_interval );
        GAPRole_SetParameter( GAPROLE_SLAVE_LATENCY, sizeof( uint16 ), &desired_slave_latency );
        GAPRole_SetParameter( GAPROLE_TIMEOUT_MULTIPLIER, sizeof( uint16 ), &desired_conn_timeout );
    }

    // Set the GAP Characteristics
    GGS_SetParameter( GGS_DEVICE_NAME_ATT, GAP_DEVICE_NAME_LEN, attDeviceName );

    // Set advertising interval
    {
        uint16 advInt = DEFAULT_ADVERTISING_INTERVAL;

        GAP_SetParamValue( TGAP_LIM_DISC_ADV_INT_MIN, advInt );
        GAP_SetParamValue( TGAP_LIM_DISC_ADV_INT_MAX, advInt );
        GAP_SetParamValue( TGAP_GEN_DISC_ADV_INT_MIN, advInt );
        GAP_SetParamValue( TGAP_GEN_DISC_ADV_INT_MAX, advInt );
    }

    // Setup the GAP Bond Manager
    {
            uint32 passkey = 0; // passkey "000000"
            uint8 pairMode = GAPBOND_PAIRING_MODE_WAIT_FOR_REQ;
        // uint8 pairMode = GAPBOND_PAIRING_MODE_NO_PAIRING;
            uint8 mitm = TRUE;
            uint8 ioCap = GAPBOND_IO_CAP_DISPLAY_ONLY;
        uint8 bonding = TRUE;
            GAPBondMgr_SetParameter( GAPBOND_DEFAULT_PASSCODE, sizeof ( uint32 ), &passkey );
        GAPBondMgr_SetParameter( GAPBOND_PAIRING_MODE, sizeof ( uint8 ), &pairMode );
        GAPBondMgr_SetParameter( GAPBOND_MITM_PROTECTION, sizeof ( uint8 ), &mitm );
            GAPBondMgr_SetParameter( GAPBOND_IO_CAPABILITIES, sizeof ( uint8 ), &ioCap );
        GAPBondMgr_SetParameter( GAPBOND_BONDING_ENABLED, sizeof ( uint8 ), &bonding );
    }

    // Initialize GATT attributes
    GGS_AddService( GATT_ALL_SERVICES );            // GAP
    GATTServApp_AddService( GATT_ALL_SERVICES );    // GATT attributes
    // DevInfo_AddService();                           // Device Information Service
    SimpleProfile_AddService( GATT_ALL_SERVICES );  // Simple GATT Profile
    Batt_AddService();
#if defined FEATURE_OAD
    VOID OADTarget_AddService();                    // OAD Profile
#endif

    // Setup the SimpleProfile Characteristic Values
    {
        // uint8   healthSync = 1;
        // uint32  healthClock = 0;
        // uint16  healthDataHeader = 1234;
        // uint8   healthDataBody = 0;
        // SimpleProfile_SetParameter( HEALTH_SYNC, sizeof ( uint8 ), &healthSync );
        // SimpleProfile_SetParameter( HEALTH_CLOCK, sizeof ( uint32 ), &healthClock );
        // SimpleProfile_SetParameter( HEALTH_DATA_HEADER, sizeof ( uint16 ), &healthDataHeader );
        // SimpleProfile_SetParameter( HEALTH_DATA_BODY, sizeof ( uint8 ), &healthDataBody );
    }

    // Setup Battery Characteristic Values
    {
        uint8 critical = DEFAULT_BATT_CRITICAL_LEVEL;
        Batt_SetParameter( BATT_PARAM_CRITICAL_LEVEL, sizeof (uint8 ), &critical );
    }

#if (defined FAC_TEST) && (FAC_TEST == TRUE)

    P0DIR |= BV(0) | BV(1) | BV(2) | BV(3) | BV(4);
    P0SEL &= ~(BV(0) | BV(1) | BV(2) | BV(3) | BV(4));

    P0_0 = 1;
    P0_1 = 1;
    P0_2 = 1;
    P0_3 = 1;
    P0_4 = 1;

    P1DIR |= BV(0) | BV(1);
    P1SEL &= ~(BV(0) | BV(1));

    P1_0 = 1;
    P1_1 = 1;

    osal_start_timerEx( simpleBLEPeripheral_TaskID, SBP_LED_STOP_EVT, SBP_PERIODIC_EVT_PERIOD );

#endif

#if (defined HAL_LCD) && (HAL_LCD == TRUE)

#if defined FEATURE_OAD
#if defined (HAL_IMAGE_A)
    HalLcdWriteStringValue( "BLE Peri-A", OAD_VER_NUM( _imgHdr.ver ), 16, HAL_LCD_LINE_1 );
#else
    HalLcdWriteStringValue( "BLE Peri-B", OAD_VER_NUM( _imgHdr.ver ), 16, HAL_LCD_LINE_1 );
#endif // HAL_IMAGE_A
#else
    HalLcdWriteString( "BLE Peripheral", HAL_LCD_LINE_1 );
#endif // FEATURE_OAD

#endif // (defined HAL_LCD) && (HAL_LCD == TRUE)

    // Register callback with SimpleGATTprofile
    VOID SimpleProfile_RegisterAppCBs( &simpleBLEPeripheral_SimpleProfileCBs );

    // Register for Battery service callback;
    Batt_Register ( heartRateBattCB );

    // Enable clock divide on halt
    // This reduces active current while radio is active and CC254x MCU
    // is halted
    HCI_EXT_ClkDivOnHaltCmd( HCI_EXT_ENABLE_CLK_DIVIDE_ON_HALT );

#if defined ( DC_DC_P0_7 )

    // Enable stack to toggle bypass control on TPS62730 (DC/DC converter)
    HCI_EXT_MapPmIoPortCmd( HCI_EXT_PM_IO_PORT_P0, HCI_EXT_PM_IO_PORT_PIN7 );

#endif // defined ( DC_DC_P0_7 )

    osal_set_event( simpleBLEPeripheral_TaskID, ADXL345_PERIODIC_EVT );

    // Setup a delayed profile startup
    osal_set_event( simpleBLEPeripheral_TaskID, SBP_START_DEVICE_EVT );




}

/*********************************************************************
 * @fn      SimpleBLEPeripheral_ProcessEvent
 *
 * @brief   Simple BLE Peripheral Application Task event processor.  This function
 *          is called to process all events for the task.  Events
 *          include timers, messages and any other user defined events.
 *
 * @param   task_id  - The OSAL assigned task ID.
 * @param   events - events to process.  This is a bit map and can
 *                   contain more than one event.
 *
 * @return  events not processed
 */
uint16 SimpleBLEPeripheral_ProcessEvent( uint8 task_id, uint16 events )
{

    VOID task_id; // OSAL required parameter that isn't used in this function

    if ( events & SYS_EVENT_MSG )
    {
        uint8 *pMsg;

        if ( (pMsg = osal_msg_receive( simpleBLEPeripheral_TaskID )) != NULL )
        {
            simpleBLEPeripheral_ProcessOSALMsg( (osal_event_hdr_t *)pMsg );

            // Release the OSAL message
            VOID osal_msg_deallocate( pMsg );
        }

        // return unprocessed events
        return (events ^ SYS_EVENT_MSG);
    }

    if ( events & SBP_START_DEVICE_EVT )
    {
        // Start the Device
        VOID GAPRole_StartDevice( &simpleBLEPeripheral_PeripheralCBs );

        // Start Bond Manager
        VOID GAPBondMgr_Register( &simpleBLEPeripheral_BondMgrCBs );

        // Set timer for first periodic event
        osal_start_timerEx( simpleBLEPeripheral_TaskID, SBP_PERIODIC_EVT, SBP_PERIODIC_EVT_PERIOD );

        return ( events ^ SBP_START_DEVICE_EVT );
    }

    if ( events & ADXL345_PERIODIC_EVT )
    {

        adxl345Loop();

        // restart timer
        osal_start_timerEx( simpleBLEPeripheral_TaskID, ADXL345_PERIODIC_EVT, 100 );

        return (events ^ ADXL345_PERIODIC_EVT);
    }



    if ( events & BATT_PERIODIC_EVT )
    {
        // Perform periodic battery task
        heartRateBattPeriodicTask();

        return (events ^ BATT_PERIODIC_EVT);
    }

    if ( events & SBP_PERIODIC_EVT )
    {
        // Restart timer
        if ( SBP_PERIODIC_EVT_PERIOD )
        {
            osal_start_timerEx( simpleBLEPeripheral_TaskID, SBP_PERIODIC_EVT, SBP_PERIODIC_EVT_PERIOD );
        }

        // Perform periodic application task
        performPeriodicTask();

        return (events ^ SBP_PERIODIC_EVT);
    }



#if (defined FAC_TEST) && (FAC_TEST == TRUE)

    if ( events & SBP_LED_STOP_EVT )
    {

        P0_0 = 0;
        P0_1 = 0;
        P0_2 = 0;
        P0_3 = 0;
        P0_4 = 0;

        P1_0 = 0;
        P1_1 = 0;

        // HalI2CInit(EEPROM_ADDRESS, I2C_CLOCK_RATE);

        // uint8 aBuf[2] = {
        //     LO_UINT16(stepDataStop),
        //     HI_UINT16(stepDataStop)
        // };

        // SimpleProfile_SetParameter( HEALTH_DATA_HEADER, 2,  aBuf);

        // uint8 w[] = {3,4};

        // HalI2CWrite(2, aBuf);

        // asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");

        // HalI2CWrite(1, w);

        // asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");

        // uint8 r[] = {0,0};

        // HalI2CWrite(2, aBuf);

        // asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");

        // HalI2CRead(1, r);

        // SimpleProfile_SetParameter( HEALTH_DATA_HEADER, 2,  r);


        // osal_start_timerEx( simpleBLEPeripheral_TaskID, SBP_LED_STOP_EVT, SBP_PERIODIC_EVT_PERIOD );

        return (events ^ SBP_LED_STOP_EVT);
    }

#endif

#if defined ( PLUS_BROADCASTER )
    if ( events & SBP_ADV_IN_CONNECTION_EVT )
    {
        uint8 turnOnAdv = TRUE;
        // Turn on advertising while in a connection
        GAPRole_SetParameter( GAPROLE_ADVERT_ENABLED, sizeof( uint8 ), &turnOnAdv );

        return (events ^ SBP_ADV_IN_CONNECTION_EVT);
    }
#endif // PLUS_BROADCASTER

    // Discard unknown events
    return 0;
}

/*********************************************************************
 * @fn      simpleBLEPeripheral_ProcessOSALMsg
 *
 * @brief   Process an incoming task message.
 *
 * @param   pMsg - message to process
 *
 * @return  none
 */
static void simpleBLEPeripheral_ProcessOSALMsg( osal_event_hdr_t *pMsg )
{
    switch ( pMsg->event )
    {

    default:
        // do nothing
        break;
    }
}

/*********************************************************************
 * @fn      peripheralStateNotificationCB
 *
 * @brief   Notification from the profile of a state change.
 *
 * @param   newState - new state
 *
 * @return  none
 */
static void peripheralStateNotificationCB( gaprole_States_t newState )
{
    switch ( newState )
    {
    case GAPROLE_STARTED:
    {
        uint8 ownAddress[B_ADDR_LEN];
        uint8 systemId[DEVINFO_SYSTEM_ID_LEN];

        GAPRole_GetParameter(GAPROLE_BD_ADDR, ownAddress);

        // use 6 bytes of device address for 8 bytes of system ID value
        systemId[0] = ownAddress[0];
        systemId[1] = ownAddress[1];
        systemId[2] = ownAddress[2];

        // set middle bytes to zero
        systemId[4] = 0x00;
        systemId[3] = 0x00;

        // shift three bytes up
        systemId[7] = ownAddress[5];
        systemId[6] = ownAddress[4];
        systemId[5] = ownAddress[3];


        DevInfo_SetParameter(DEVINFO_SYSTEM_ID, DEVINFO_SYSTEM_ID_LEN, systemId);

#if (defined HAL_LCD) && (HAL_LCD == TRUE)
        // Display device address
        HalLcdWriteString( bdAddr2Str( ownAddress ),  HAL_LCD_LINE_2 );
        HalLcdWriteString( "Initialized",  HAL_LCD_LINE_3 );
#endif // (defined HAL_LCD) && (HAL_LCD == TRUE)
    }
    break;

    case GAPROLE_ADVERTISING:
    {
#if (defined HAL_LCD) && (HAL_LCD == TRUE)
        HalLcdWriteString( "Advertising",  HAL_LCD_LINE_3 );
#endif // (defined HAL_LCD) && (HAL_LCD == TRUE)
    }
    break;

    case GAPROLE_CONNECTED:
    {
#if (defined HAL_LCD) && (HAL_LCD == TRUE)
        HalLcdWriteString( "Connected",  HAL_LCD_LINE_3 );
#endif // (defined HAL_LCD) && (HAL_LCD == TRUE)
    }
    break;

    case GAPROLE_WAITING:
    {
#if (defined HAL_LCD) && (HAL_LCD == TRUE)
        HalLcdWriteString( "Disconnected",  HAL_LCD_LINE_3 );
#endif // (defined HAL_LCD) && (HAL_LCD == TRUE)
    }
    break;

    case GAPROLE_WAITING_AFTER_TIMEOUT:
    {
#if (defined HAL_LCD) && (HAL_LCD == TRUE)
        HalLcdWriteString( "Timed Out",  HAL_LCD_LINE_3 );
#endif // (defined HAL_LCD) && (HAL_LCD == TRUE)
    }
    break;

    case GAPROLE_ERROR:
    {
#if (defined HAL_LCD) && (HAL_LCD == TRUE)
        HalLcdWriteString( "Error",  HAL_LCD_LINE_3 );
#endif // (defined HAL_LCD) && (HAL_LCD == TRUE)
    }
    break;

    default:
    {
#if (defined HAL_LCD) && (HAL_LCD == TRUE)
        HalLcdWriteString( "",  HAL_LCD_LINE_3 );
#endif // (defined HAL_LCD) && (HAL_LCD == TRUE)
    }
    break;

    }

    gapProfileState = newState;

    VOID gapProfileState;     // added to prevent compiler warning with
    // "CC2540 Slave" configurations


}

/*********************************************************************
 * @fn      heartRateBattCB
 *
 * @brief   Callback function for battery service.
 *
 * @param   event - service event
 *
 * @return  none
 */
static void heartRateBattCB(uint8 event)
{
    if (event == BATT_LEVEL_NOTI_ENABLED)
    {
        // if connected start periodic measurement
        if (gapProfileState == GAPROLE_CONNECTED)
        {
            osal_start_timerEx( simpleBLEPeripheral_TaskID, BATT_PERIODIC_EVT, DEFAULT_BATT_PERIOD );
        }
    }
    else if (event == BATT_LEVEL_NOTI_DISABLED)
    {
        // stop periodic measurement
        osal_stop_timerEx( simpleBLEPeripheral_TaskID, BATT_PERIODIC_EVT );
    }
}

/*********************************************************************
 * @fn      heartRateBattPeriodicTask
 *
 * @brief   Perform a periodic task for battery measurement.
 *
 * @param   none
 *
 * @return  none
 */
static void heartRateBattPeriodicTask( void )
{
    if (gapProfileState == GAPROLE_CONNECTED)
    {
        // perform battery level check
        Batt_MeasLevel( );

        // Restart timer
        osal_start_timerEx( simpleBLEPeripheral_TaskID, BATT_PERIODIC_EVT, DEFAULT_BATT_PERIOD );
    }
}

/*********************************************************************
 * @fn      performPeriodicTask
 *
 * @brief   Perform a periodic application task. This function gets
 *          called every five seconds as a result of the SBP_PERIODIC_EVT
 *          OSAL event. In this example, the value of the third
 *          characteristic in the SimpleGATTProfile service is retrieved
 *          from the profile, and then copied into the value of the
 *          the fourth characteristic.
 *
 * @param   none
 *
 * @return  none
 */
static void performPeriodicTask( void )
{
    // uint8 valueToCopy;
    // uint8 stat;

    // // Call to retrieve the value of the third characteristic in the profile
    // stat = SimpleProfile_GetParameter( HEALTH_DATA_HEADER, &valueToCopy);

    // if ( stat == SUCCESS )
    // {
        
    //      * Call to set that value of the fourth characteristic in the profile. Note
    //      * that if notifications of the fourth characteristic have been enabled by
    //      * a GATT client device, then a notification will be sent every time this
    //      * function is called.
         
    //     SimpleProfile_SetParameter( HEALTH_DATA_BODY, sizeof(uint8), &valueToCopy);
    // }
}

/*********************************************************************
 * @fn      simpleProfileChangeCB
 *
 * @brief   Callback from SimpleBLEProfile indicating a value change
 *
 * @param   paramID - parameter ID of the value that was changed.
 *
 * @return  none
 */
static void simpleProfileChangeCB( uint8 paramID )
{
    uint16 newValue;
    uint32 clock;

    switch ( paramID )
    {
    case HEALTH_SYNC:
        SimpleProfile_GetParameter( HEALTH_SYNC, &newValue );

        if (newValue == 22)
        {
            eepromReadStep();
        }

#if (defined HAL_LCD) && (HAL_LCD == TRUE)
        HalLcdWriteStringValue( "Char 1:", (uint16)(newValue), 10,  HAL_LCD_LINE_3 );
#endif // (defined HAL_LCD) && (HAL_LCD == TRUE)

        break;

    case HEALTH_CLOCK:
        SimpleProfile_GetParameter( HEALTH_CLOCK, &clock );

        osal_setClock(clock);

        UTCTime now;

        now = osal_getClock();

        UTCTimeStruct date;

        osal_ConvertUTCTime(&date, now);

#if (defined HAL_LCD) && (HAL_LCD == TRUE)
        HalLcdWriteStringValue( "year:", date.year, 10,  HAL_LCD_LINE_4 );
        HalLcdWriteStringValue( "month:", date.month + 1, 10,  HAL_LCD_LINE_5 );
        HalLcdWriteStringValue( "day:", date.day + 1, 10,  HAL_LCD_LINE_6 );
        HalLcdWriteStringValue( "hour:", date.hour, 10,  HAL_LCD_LINE_7 );
        HalLcdWriteStringValue( "minutes:", date.minutes, 10,  HAL_LCD_LINE_8 );
#endif // (defined HAL_LCD) && (HAL_LCD == TRUE)

        break;

    case HEALTH_DATA_BODY:

        // eepromReadStep();

        break;

    default:
        // should not reach here!
        break;
    }
}

#if (defined HAL_LCD) && (HAL_LCD == TRUE)
/*********************************************************************
 * @fn      bdAddr2Str
 *
 * @brief   Convert Bluetooth address to string. Only needed when
 *          LCD display is used.
 *
 * @return  none
 */
char *bdAddr2Str( uint8 *pAddr )
{
    uint8       i;
    char        hex[] = "0123456789ABCDEF";
    static char str[B_ADDR_STR_LEN];
    char        *pStr = str;

    *pStr++ = '0';
    *pStr++ = 'x';

    // Start from end of addr
    pAddr += B_ADDR_LEN;

    for ( i = B_ADDR_LEN; i > 0; i-- )
    {
        *pStr++ = hex[*--pAddr >> 4];
        *pStr++ = hex[*pAddr & 0x0F];
    }

    *pStr = 0;

    return str;
}
#endif // (defined HAL_LCD) && (HAL_LCD == TRUE)


/*********************************************************************
 * @fn      adxl345Init
 *
 * @param   none
 *
 * @return  none
 */
static void adxl345Init( void )
{
    HalI2CInit(ADXL345_ADDRESS, I2C_CLOCK_RATE);

    uint8 pBuf[2];

    pBuf[0] = Reg_thresh_tap;
    pBuf[1] = 70;
    HalI2CWrite(2, pBuf);

    pBuf[0] = Reg_OFSX;
    pBuf[1] = 0;
    HalI2CWrite(2, pBuf);

    pBuf[0] = Reg_OFSY;
    pBuf[1] = 0;
    HalI2CWrite(2, pBuf);

    pBuf[0] = Reg_OFSZ;
    pBuf[1] = 0;
    HalI2CWrite(2, pBuf);

    pBuf[0] = Reg_DUR;
    pBuf[1] = 100;
    HalI2CWrite(2, pBuf);

    pBuf[0] = Reg_LATENT;
    pBuf[1] = 0;
    HalI2CWrite(2, pBuf);

    pBuf[0] = Reg_WINDOW;
    pBuf[1] = 0;
    HalI2CWrite(2, pBuf);

    pBuf[0] = Reg_THRESH_ACT;
    pBuf[1] = 10;
    HalI2CWrite(2, pBuf);

    pBuf[0] = Reg_THRESH_INACT;
    pBuf[1] = 5;
    HalI2CWrite(2, pBuf);

    pBuf[0] = Reg_TIME_INACT;
    pBuf[1] = 1;
    HalI2CWrite(2, pBuf);

    pBuf[0] = Reg_ACT_INACT_CTL;
    pBuf[1] = 0xff;
    HalI2CWrite(2, pBuf);

    pBuf[0] = Reg_THRESH_FF;
    pBuf[1] = 10;
    HalI2CWrite(2, pBuf);

    pBuf[0] = Reg_TIME_FF;
    pBuf[1] = 10;
    HalI2CWrite(2, pBuf);

    pBuf[0] = Reg_TAP_AXES;
    pBuf[1] = 0x0f;
    HalI2CWrite(2, pBuf);

    pBuf[0] = Reg_BW_RATE;
    pBuf[1] = 0x17;
    HalI2CWrite(2, pBuf);

    pBuf[0] = Reg_POWER_CTL;
    pBuf[1] = 8;
    HalI2CWrite(2, pBuf);

    pBuf[0] = Reg_INT_ENABLE;
    pBuf[1] = 0x40;
    HalI2CWrite(2, pBuf);

    pBuf[0] = Reg_INT_MAP;
    pBuf[1] = 0x00;
    HalI2CWrite(2, pBuf);

    pBuf[0] = Reg_DATA_FORMAT;
    pBuf[1] = 0x0b;
    HalI2CWrite(2, pBuf);

    pBuf[0] = Reg_FIFO_CTL;
    pBuf[1] = 0;
    HalI2CWrite(2, pBuf);

}

static void adxl345Loop(void)
{

    // P0_3 = !P0_3;

    adxl345GetAccData();

    //todo
    X_out = X_out >> 2;
    Y_out = Y_out >> 2;
    Z_out = Z_out >> 2;

    // uint8 d[6];

    // osal_memcpy(&d[0], &X_out, sizeof(int16));
    // osal_memcpy(&d[2], &Y_out, sizeof(int16));
    // osal_memcpy(&d[4], &Z_out, sizeof(int16));

    // SimpleProfile_SetParameter( HEALTH_SYNC, sizeof ( d ), d );


    ACC_CUR = X_out * X_out + Y_out * Y_out + Z_out * Z_out - 4000;

    //SimpleProfile_SetParameter( HEALTH_SYNC, sizeof ( ACC_CUR ), &ACC_CUR );

    if ((DIR == 1) && (ACC_CUR > 0))
    {

        if (first_pace == 0)
        {
            cross_count = cross_count + 1;
            if (cross_count == 1)
            {

                time_count = 0;
                PACE_PEAK = ACC_CUR;
                PACE_BOTTOM = 0;
                P0_0 = 0;
            }
            else if (cross_count == 2)
            {

                if (((time_count) >= PACE_DUR_MIN) && ((time_count) <= PACE_DUR_MAX) && ((PACE_PEAK - PACE_BOTTOM) >= ALT_MIN))
                {
                    // add one step
                    pace_count = pace_count + 1;
                    P0_0 = 1;
                    cross_count = 0;

                    // uint8 d[6];

                    // osal_memcpy(&d[0], &pace_count, sizeof(int16));

                    // SimpleProfile_SetParameter( HEALTH_SYNC, sizeof ( d ), d );

                    eepromWriteStep();

                }
                else
                {

                    time_count = 0;
                    PACE_PEAK = ACC_CUR;
                    PACE_BOTTOM = 0;
                    cross_count = 1;
                }
            }
        }
        else
        {
            first_pace = 0;

            time_count = 0;
            PACE_PEAK = ACC_CUR;
            PACE_BOTTOM = 0;
        }
        DIR = 2;
    }
    else if ((DIR == 2) && (ACC_CUR >= 0))
    {
        if (ACC_CUR > PACE_PEAK) PACE_PEAK = ACC_CUR;
    }
    else if ((DIR == 2) && (ACC_CUR < 0))
    {
        PACE_BOTTOM = ACC_CUR;
        DIR = 1;
    }
    else if ((DIR == 1) && (ACC_CUR <= 0))
    {
        if (ACC_CUR < PACE_BOTTOM) PACE_BOTTOM = ACC_CUR;
    }

    adxl345GetIntData();//read INT registers
    if (INT_STATUS & 0x40)
    {
        //tap happened
        // Serial.print("TAP\r\n");

        int i = 10000;

        while (i)
        {
            i--;
        }

        P0_4 = !P0_4;
    }
    time_count++;
}


static void adxl345GetAccData(void)
{
    HalI2CInit(ADXL345_ADDRESS, I2C_CLOCK_RATE);

    uint8 pBuf[2];

    //read X_acc
    pBuf[0] = Reg_DX0;
    HalI2CWrite(1, pBuf);
    HalI2CRead(1, &pBuf[1]);
    X0 = pBuf[1];

    pBuf[0] = Reg_DX1;
    HalI2CWrite(1, pBuf);
    HalI2CRead(1, &pBuf[1]);
    X1 = pBuf[1];

    X_out = (int16)((X1 << 8) | X0);

    //read Y_acc
    pBuf[0] = Reg_DY0;
    HalI2CWrite(1, pBuf);
    HalI2CRead(1, &pBuf[1]);
    Y0 = pBuf[1];

    pBuf[0] = Reg_DY1;
    HalI2CWrite(1, pBuf);
    HalI2CRead(1, &pBuf[1]);
    Y1 = pBuf[1];

    Y_out = (int16)((Y1 << 8) | Y0);

    //read Z_acc
    pBuf[0] = Reg_DZ0;
    HalI2CWrite(1, pBuf);
    HalI2CRead(1, &pBuf[1]);
    Z0 = pBuf[1];

    pBuf[0] = Reg_DZ1;
    HalI2CWrite(1, pBuf);
    HalI2CRead(1, &pBuf[1]);
    Z1 = pBuf[1];

    Z_out = (int16)((Z1 << 8) | Z0);
}

static void adxl345GetIntData(void)
{
    HalI2CInit(ADXL345_ADDRESS, I2C_CLOCK_RATE);

    uint8 pBuf[2];

    //read INT
    pBuf[0] = Reg_INT_SOURCE;
    HalI2CWrite(1, pBuf);
    HalI2CRead(1, &pBuf[1]);
    INT_STATUS = pBuf[1];

    DebugValue(INT_STATUS);
}

static void eepromWriteStep(void){

    UTCTime current;
    UTCTimeStruct currentTm;

    current = osal_getClock();
    osal_ConvertUTCTime(&currentTm, current);

    // currentTm.minutes = 0;
    currentTm.seconds = 0;

    if (oneData.hourSeconds == 0)       // data is empty
    {
        oneData.tm = currentTm;
        oneData.hourSeconds = osal_ConvertUTCSecs(&oneData.tm);

        oneData.count = 1;
        oneData.type = 2;

        // uint8 d[6];

        // osal_memcpy(&d[0], &oneData.hourSeconds, sizeof(uint32));

        // SimpleProfile_SetParameter( HEALTH_SYNC, sizeof ( d ), d );

    }else if(oneData.tm.year != currentTm.year ||
             oneData.tm.month != currentTm.month ||
             oneData.tm.day != currentTm.day ||
             oneData.tm.minutes != currentTm.minutes ||         // for test, one minutes
             oneData.tm.hour != currentTm.hour){                // pass a hour, need to write

        // write to eeprom
        // HalI2CInit(EEPROM_ADDRESS, I2C_CLOCK_RATE);

        // uint8 aBuf[2];
        uint8 dBuf[8] = {
            LO_UINT16(LO_UINT32(oneData.hourSeconds)),
            HI_UINT16(LO_UINT32(oneData.hourSeconds)),
            LO_UINT16(HI_UINT32(oneData.hourSeconds)),
            HI_UINT16(HI_UINT32(oneData.hourSeconds)),
            LO_UINT16(oneData.count),
            HI_UINT16(oneData.count),
            oneData.type,
            0
        };

        osal_memcpy(&db[stepDataStop], &dBuf[0], 8);

        stepDataStop += 8;

        // arrive maxsize
        if (stepDataStop >= EEPROM_ADDRESS_DATA_MAX)
        {
            stepDataStop = 0;
        }

        // space is full
        if (stepDataStop == stepDataStart)
        {
            stepDataStart += 8;
        }

        // for (int i = 0; i < 8; i++)
        // {
        //     aBuf[0] = LO_UINT16(stepDataStop);
        //     aBuf[1] = HI_UINT16(stepDataStop);

        //     HalI2CWrite(2, aBuf);

        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");

        //     HalI2CWrite(1, &dBuf[i]);

        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");
        //     asm("nop");

        //     stepDataStop += 1;
        // }

        uint16 length = (stepDataStop - stepDataStart) / 8;

        // SimpleProfile_SetParameter( HEALTH_DATA_HEADER, 2,  &stepDataStop);
        SimpleProfile_SetParameter( HEALTH_DATA_HEADER, 2,  &length);
        SimpleProfile_SetParameter( HEALTH_SYNC, 8, dBuf);

        // refresh oneData
        oneData.tm = currentTm;
        oneData.hourSeconds = osal_ConvertUTCSecs(&oneData.tm);

        oneData.count = 1;

    }else{      // in same hour

        oneData.count ++;
    }

}

static void eepromReadStep(void){

    // HalI2CInit(EEPROM_ADDRESS, I2C_CLOCK_RATE);

    // uint8 aBuf[2];

    // for (int i = 0; i < 8; i++)
    // {
    //     aBuf[0] = LO_UINT16(stepDataStart);
    //     aBuf[1] = HI_UINT16(stepDataStart);

    //     HalI2CWrite(2, aBuf);

    //     asm("nop");
    //         asm("nop");
    //         asm("nop");
    //         asm("nop");
    //         asm("nop");
    //         asm("nop");
    //         asm("nop");
    //         asm("nop");
    //         asm("nop");

    //     HalI2CRead(1, &dBuf[i]);

    //     stepDataStart += 1;
    // }

    while(stepDataStart != stepDataStop){
        uint8 dBuf[8];

        osal_memcpy(&dBuf[0], &db[stepDataStart], 8);

        stepDataStart += 8;

        // arrive maxsize
        if (stepDataStart >= EEPROM_ADDRESS_DATA_MAX)
        {
            stepDataStart = 0;
        }

        // SimpleProfile_SetParameter( HEALTH_DATA_HEADER, 2,  &stepDataStart);
        SimpleProfile_SetParameter( HEALTH_DATA_BODY, 8,  dBuf);
        // SimpleProfile_SetParameter( HEALTH_SYNC, 8, dBuf);
    }
}

/*********************************************************************
*********************************************************************/
