#include <main.h>
#include <types.h>
#include <timer.h>
#include <mem.h>

/* Upper Stack API */
#include <gatt.h>
#include <gatt_prim.h>
#include <ls_app_if.h>
#include <gap_app_if.h>
#include <buf_utils.h>
#include <security.h>
#include <panic.h>
#include <nvm.h>
#include <random.h>
#include <pio.h>
#include <battery.h>
#include <debug.h>
#include <reset.h>

#include "smart_band.h"
#include "app_gatt_db.h"

#define MAX_ADV_DATA_LEN                    (31)
#define LE8_L(x)                            ((x) & 0xff)
#define LE8_H(x)                            (((x) >> 8) & 0xff)
#define AD_TYPE_APPEARANCE                  (0x19)
#define TX_POWER_VALUE_LENGTH               (2)

/* 
    dSetup PIOs
 */

// #define BUZZER_PIO                          3
// #define BUTTON_PIO                          11
// #define LED1_PIO                            12
// #define SHOCK_PIO                           10
// #define GLED_PIO                            13

#define BUZZER_PIO                          14
#define BUTTON_PIO                          3
#define LED1_PIO                            1
#define SHOCK_PIO                           0
#define GLED_PIO                            11

#define LED2_PIO                            4
#define RLED_PIO                            10
#define BLED_PIO                            9

#define PIO_BIT_MASK(pio)                   (0x01UL << (pio))

#define BUZZER_PIO_MASK                     (PIO_BIT_MASK(BUZZER_PIO))
#define BUTTON_PIO_MASK                     (PIO_BIT_MASK(BUTTON_PIO))
#define SPARK_HEAVY_MASK                    (PIO_BIT_MASK(LED1_PIO)|PIO_BIT_MASK(LED2_PIO))
#define SPARK_LIGHT_MASK                    (PIO_BIT_MASK(LED1_PIO))

/* PIO direction */
#define PIO_DIRECTION_INPUT                 (FALSE)
#define PIO_DIRECTION_OUTPUT                (TRUE)

/* PIO state */
#define PIO_STATE_HIGH                      (TRUE)
#define PIO_STATE_LOW                       (FALSE)

/* Extra long button press timer */
#define EXTRA_LONG_BUTTON_PRESS_TIMER       \(4*SECOND)

/* The index (0-3) of the PWM unit to be configured */
#define BUZZER_PWM_INDEX_0                  (0)

/* PWM parameters for Buzzer */

/* Dull on. off and hold times */
#define DULL_BUZZ_ON_TIME                   (2)    /* 60us */
#define DULL_BUZZ_OFF_TIME                  (15)   /* 450us */
#define DULL_BUZZ_HOLD_TIME                 (0)

/* Bright on, off and hold times */
#define BRIGHT_BUZZ_ON_TIME                 (2)    /* 60us */
#define BRIGHT_BUZZ_OFF_TIME                (15)   /* 450us */
#define BRIGHT_BUZZ_HOLD_TIME               (0)    /* 0us */

#define BUZZ_RAMP_RATE                      (0xFF)

/* TIMER values for Buzzer */
#define SHORT_BEEP_TIMER_VALUE              (100* MILLISECOND)
#define LONG_BEEP_TIMER_VALUE               (500* MILLISECOND)
#define BEEP_GAP_TIMER_VALUE                (25* MILLISECOND)

#define MAX_APP_TIMERS                      6

#define SYNC_ERROR_THRESHOLD                5

#define MEASURE_MAX_LENGTH                  16

#define BATTERY_FULL_BATTERY_VOLTAGE        (3720)
#define BATTERY_FLAT_BATTERY_VOLTAGE        (3000)

#define SPARK_LATENCY                       5
#define SPARK_DURATION                      100
#define SHOCK_DURATION                      150

#define SETUP_CODE                          0x1985
#define NVM_OFFSET_SETUP_CODE               0

#define NVM_OFFSET_HEALTH                   1

#define PRESS_RELEASE_LOCKER_INTERVAL       200

/*define timer*/
typedef struct
{
    uint16  device_name[DEVICE_NAME_MAX_LENGTH / 2];
    uint32  hour_zero;
}HEALTH;

HEALTH health;

/*define timer*/
typedef struct
{
    timer_id buzzer;
    timer_id spark;
    timer_id button;
    timer_id press_locker;
    timer_id release_locker;
    timer_id switch_locker;
}TIMER;

TIMER timer;

uint16  st_ucid;

bool long_press_keep = FALSE, fix_start_time = FALSE, press_locked = FALSE, release_locked = FALSE, switch_locked = FALSE;


uint32 spark_pio_mask;

uint8 click_data[360];

/*
    ---------------------
    user defined function
    ---------------------
*/

/*net to host long*/
static uint32 ntohl(uint8* x){
    uint32 u;
    u = ((uint32)x[3]<<24) | ((uint32)x[2]<<16) | (x[1]<<8) | x[0];
    return u;
}

static void addDb(void){

    uint16 *p_gatt_db = NULL;
    uint16 gatt_db_length = 0;

    /*read db*/
    p_gatt_db = GattGetDatabase(&gatt_db_length);
    GattAddDatabaseReq(gatt_db_length, p_gatt_db);
}

static uint8 readBatteryLevel(void)
{
    uint32 bat_voltage;
    uint32 bat_level;

    /* Read battery voltage and level it with minimum voltage */
    bat_voltage = BatteryReadVoltage();

    /* Level the read battery voltage to the minimum value */
    if(bat_voltage < BATTERY_FLAT_BATTERY_VOLTAGE)
    {
        bat_voltage = BATTERY_FLAT_BATTERY_VOLTAGE;
    }

    bat_voltage = bat_voltage - BATTERY_FLAT_BATTERY_VOLTAGE;
    
    /* Get battery level in percent */
    bat_level = (bat_voltage * 100) / (BATTERY_FULL_BATTERY_VOLTAGE - BATTERY_FLAT_BATTERY_VOLTAGE);

    /* Check the precision errors */
    if(bat_level > 100)
    {
        bat_level = 100;
    }

    return (uint8)bat_level;
}

static void upload(void){

}

/*
    --------------
    timer handlers
    --------------
*/

static void buzzerTimerHandler(timer_id tid){
    PioEnablePWM(BUZZER_PWM_INDEX_0, FALSE);
}

static void buzzer(void){
    PioEnablePWM(BUZZER_PWM_INDEX_0, TRUE);

    timer.buzzer = TimerCreate((SPARK_DURATION* MILLISECOND), TRUE, buzzerTimerHandler);
}

/*spark timer*/
static void sparkStopTimerHandler(timer_id tid){
    PioSets(spark_pio_mask, 0x00UL);

    spark_pio_mask = 0x00UL;
}

static void unlockBotton(void){
    release_locked = FALSE;
    press_locked = FALSE;
}

static void pressLockerHandler(timer_id tid){
    unlockBotton();
}

static void releaseLockerHandler(timer_id tid){
    unlockBotton();
}

/*
    read and write timer handle
*/

static void buttonTimerHandler(timer_id tid){

    long_press_keep = FALSE;

    unlockBotton();

    //long press
    buzzer();

    DebugWriteString("wo ca!!\r\n");

    WarmReset();
}

static void switchLockerHandler(timer_id tid){
    DebugWriteString("unlocked!!!\r\n");
    switch_locked = FALSE;
}

/*----------------------------------------------------------------------------*
 *  NAME
 *      handleSignalGattConnectCfm
 *
 *  DESCRIPTION
 *      This function handles the signal GATT_CONNECT_CFM
 *
 *  RETURNS
 *      Nothing.
 *
 *---------------------------------------------------------------------------*/

static void handleSignalGattAccessInd(GATT_ACCESS_IND_T* p_access_e)
{
    sys_status rc = sys_status_success;

    if(p_access_e->flags & ATT_ACCESS_WRITE){

        switch(p_access_e->handle){

            case HANDLE_SYNC:

                upload();

                break;

            case HANDLE_ZERO:;

                uint32 interval = ntohl(p_access_e->value);

                health.hour_zero = TimeSub(TimeGet32(), interval);

                DebugWriteUint16(NvmWrite((uint16 *)&health, sizeof(HEALTH), NVM_OFFSET_HEALTH));

                break;

            default:
                break;
        }

        GattAccessRsp(p_access_e->cid, p_access_e->handle, rc, p_access_e->size_value, p_access_e->value);

    }else if(p_access_e->flags & ATT_ACCESS_READ){
        
        switch(p_access_e->handle){
            
             case HANDLE_BATTERY_LEVEL:;

                uint8 bl = readBatteryLevel();

                GattAccessRsp(p_access_e->cid, p_access_e->handle, rc, 1, &bl);

                break;

            default:
                GattAccessRsp(p_access_e->cid, p_access_e->handle, rc, 0, NULL);

                break;
        } 
    }
}

static void handleSignalGattAddDbCfm(GATT_ADD_DB_CFM_T *event_data)
{
    int8 tx_power_level = 0xff;

    uint8 advert_data[] = {
        AD_TYPE_SERVICE_UUID_16BIT_LIST,
        LE8_L(UUID_HEALTH_SERVICE),
        LE8_H(UUID_HEALTH_SERVICE)
    };

    uint8 device_appearance[ATTR_LEN_DEVICE_APPEARANCE + 1] = {
        AD_TYPE_APPEARANCE,
        LE8_L(APPEARANCE_HEALTH_VALUE),
        LE8_H(APPEARANCE_HEALTH_VALUE)
    };

    uint8 device_tx_power[TX_POWER_VALUE_LENGTH] = {
        AD_TYPE_TX_POWER
    };

    GapSetMode(gap_role_peripheral,
               gap_mode_discover_general,
               gap_mode_connect_undirected,
               gap_mode_bond_yes,
               gap_mode_security_unauthenticate);
    
    GapSetAdvInterval(20 * MILLISECOND, 30 * MILLISECOND);
   
    /*clear up response data*/
    LsStoreAdvScanData(0, NULL, ad_src_advertise);
    LsStoreAdvScanData(0, NULL, ad_src_scan_rsp);
    
    /*service uuid*/
    
    LsStoreAdvScanData(sizeof(advert_data), advert_data, ad_src_advertise);

    /*device appearance*/
    LsStoreAdvScanData(ATTR_LEN_DEVICE_APPEARANCE + 1, device_appearance, ad_src_advertise);

    /*what's that*/
    LsReadTransmitPowerLevel(&tx_power_level);
    device_tx_power[TX_POWER_VALUE_LENGTH - 1] = (uint8 )tx_power_level;

    LsStoreAdvScanData(TX_POWER_VALUE_LENGTH, device_tx_power, ad_src_advertise);

    /*device_name*/
    
    /*Check device name in nvm*/
    uint16 setup_code;
    NvmRead(&setup_code, sizeof(setup_code), NVM_OFFSET_SETUP_CODE);
    NvmDisable();

    DebugWriteString("sc:");
    DebugWriteUint16(setup_code);
    DebugWriteString("\r\n");

    if(setup_code == SETUP_CODE){

        DebugWriteString("\r\n");

        uint8 device_name[DEVICE_NAME_MAX_LENGTH + 1];
        MemSet(device_name, 0, DEVICE_NAME_MAX_LENGTH + 1);

        device_name[0] = AD_TYPE_LOCAL_NAME_COMPLETE;

        NvmRead((uint16 *)&health, sizeof(HEALTH), NVM_OFFSET_HEALTH);
        NvmDisable();

        DebugWriteString("\r\n");

        int i, count = 0;

        for(i = 0; i < DEVICE_NAME_MAX_LENGTH/2; i++){
            DebugWriteUint16(health.device_name[i]);
        }

        MemCopyUnPack(&device_name[1], health.device_name, DEVICE_NAME_MAX_LENGTH/2);

        DebugWriteString("\r\n");

        for(i = 0; i < DEVICE_NAME_MAX_LENGTH + 1; i++){
            DebugWriteUint8(device_name[i]);

            count++;
            if(device_name[i] == 0x00){
                break;
            }
        }

        DebugWriteString("\r\n");

        /*byte*/
        LsStoreAdvScanData(count,  device_name, ad_src_advertise);
    }else{

        uint8 device_name[] = {
            AD_TYPE_LOCAL_NAME_COMPLETE,
            'Y', 'U', 'E',  '\0'
        };
        
        LsStoreAdvScanData(sizeof(device_name),  device_name, ad_src_advertise);
    }

    BD_ADDR_T ra;

    ra.lap = Random32()>>8;
    ra.uap = Random16()>>8;
    ra.nap = Random16();

    GapSetRandomAddress(&ra);

    GattConnectReq(NULL,  L2CAP_CONNECTION_SLAVE_UNDIRECTED | L2CAP_OWN_ADDR_TYPE_RANDOM);
}

static void click(void){

    timer.spark = TimerCreate((SPARK_DURATION* MILLISECOND), TRUE, sparkStopTimerHandler);
}

/*
    -------------------
    app system function
    -------------------
*/

void AppPowerOnReset(void){
}

void AppInit (sleep_state last_sleep_state){

    static uint16 app_timers[ SIZEOF_APP_TIMER * MAX_APP_TIMERS ];

    /*init debug*/
    DebugInit(1, NULL, NULL);

    /*init time*/
    TimerInit(MAX_APP_TIMERS, (void*)app_timers);

    TimerDelete(timer.buzzer);
    TimerDelete(timer.spark);
    TimerDelete(timer.button);
    TimerDelete(timer.press_locker);
    TimerDelete(timer.release_locker);
    TimerDelete(timer.switch_locker);

    /*init button*/
    PioSetMode(BUTTON_PIO, pio_mode_user);
    PioSetDir(BUTTON_PIO, PIO_DIR_INPUT);
    PioSetPullModes(BUTTON_PIO_MASK, pio_mode_weak_pull_up);
    PioSetEventMask(BUTTON_PIO_MASK, pio_event_mode_both);

    /*init buzzer*/
    PioSetModes(BUZZER_PIO_MASK, pio_mode_pwm0);

    /* Configure the buzzer on PIO3 */
    PioConfigPWM(BUZZER_PWM_INDEX_0, pio_pwm_mode_push_pull, DULL_BUZZ_ON_TIME,
                 DULL_BUZZ_OFF_TIME, DULL_BUZZ_HOLD_TIME, BRIGHT_BUZZ_ON_TIME,
                 BRIGHT_BUZZ_OFF_TIME, BRIGHT_BUZZ_HOLD_TIME, BUZZ_RAMP_RATE);
    
    /*stop buzzer*/
    PioEnablePWM(BUZZER_PWM_INDEX_0, FALSE);

    /*gatt init*/
    GattInit();

    GattInstallClientRole();
    GattInstallServerWrite();
    
    /*init Nvm*/
    NvmConfigureI2cEeprom();

    uint16 size;

    NvmSize(&size);

    DebugWriteUint16(size);

    NvmDisable();

    addDb();
}

void AppProcessSystemEvent (sys_event_id id, void *data){
    
    switch(id){

        case sys_event_pio_changed:;

            const pio_changed_data *pPioData = (const pio_changed_data *)data;

            if (pPioData->pio_cause & BUTTON_PIO_MASK){

                if(!switch_locked){

                    if (pPioData->pio_state & BUTTON_PIO_MASK){
                        
                        if(!release_locked){

                            release_locked = TRUE;

                            TimerDelete(timer.release_locker);
                            timer.release_locker = TimerCreate(PRESS_RELEASE_LOCKER_INTERVAL, TRUE, releaseLockerHandler);

                            DebugWriteString("r!\r\n");

                            if(long_press_keep){

                                TimerDelete(timer.button);
                                long_press_keep = FALSE;

                                //short press do something

                                click();

                            }

                            switch_locked = TRUE;

                            TimerDelete(timer.switch_locker);

                            timer.switch_locker = TimerCreate(200 * MILLISECOND, TRUE, switchLockerHandler);
                            timer.switch_locker = TimerCreate(200 * MILLISECOND, TRUE, switchLockerHandler);
                        }

                    }else{

                        if(!press_locked){

                            press_locked = TRUE;

                            TimerDelete(timer.press_locker);
                            timer.press_locker = TimerCreate(PRESS_RELEASE_LOCKER_INTERVAL, TRUE, pressLockerHandler);

                            DebugWriteString("p\r\n");

                            long_press_keep = TRUE;

                            TimerDelete(timer.button);
                            timer.button = TimerCreate(3000 * MILLISECOND, TRUE, buttonTimerHandler);
                        }
                        
                    }

                }
            }

            break;

        default:
            break;
    }
}

bool AppProcessLmEvent(lm_event_code event_code, LM_EVENT_T *event_data){

    GATT_CONNECT_CFM_T* p_conn_e;
    GATT_ACCESS_IND_T* p_access_e;
    
    switch(event_code){
        
        case GATT_ADD_DB_CFM:

            DebugWriteString("~-ADD_DB\r\n");

            handleSignalGattAddDbCfm((GATT_ADD_DB_CFM_T*)event_data);
            break;
            
        case GATT_CONNECT_CFM:

            DebugWriteString("CONNECT:\r\n");
            
            p_conn_e = (GATT_CONNECT_CFM_T *) event_data;
            st_ucid = p_conn_e->cid;            
            buzzer();

            break;
            
        case GATT_ACCESS_IND:

            DebugWriteString("acc_ind:\r\n");

            p_access_e = ((GATT_ACCESS_IND_T*) event_data);

            if(p_access_e->handle == HANDLE_DATA_C_CFG || p_access_e->handle == HANDLE_DATA){
                DebugWriteString("yeah:\r\n");
                uint8 play = 0x01;
                GattCharValueNotification(st_ucid, HANDLE_DATA, ATTR_LEN_DATA, &play);
            }
                        
            handleSignalGattAccessInd((GATT_ACCESS_IND_T*) p_access_e);
            
            break;

        case LM_EV_CONNECTION_COMPLETE:
            DebugWriteString("1:\r\n");
            break;
        case LM_EV_NUMBER_COMPLETED_PACKETS:
            // DebugWriteString("LM_EV_NUMBER_COMPLETED_PACKETS:\r\n");
            break;
        case LM_EV_LONG_TERM_KEY_REQUESTED:
            DebugWriteString("2:\r\n");
            break;
        case LM_EV_ENCRYPTION_CHANGE:
            DebugWriteString("3:\r\n");
            break;
        case LM_EV_DISCONNECT_COMPLETE:
            DebugWriteString("4:\r\n");

            break;
        case GATT_DISCONNECT_IND:
            DebugWriteString("DISCONNECT\r\n");

            addDb();

            PioSets(SPARK_HEAVY_MASK, 0x00UL);

            // WarmReset();

            break;
        case GATT_DISC_PRIM_SERV_BY_UUID_CFM:
            DebugWriteString("5:\r\n");
            break;
        case GATT_DISC_PRIM_SERV_BY_UUID_IND:
            DebugWriteString("6:\r\n");
            break;
            
        default: 
            DebugWriteString("h: ");
            DebugWriteUint16(event_code);
            DebugWriteString("\r\n");
            break;
    }
    return TRUE;
}