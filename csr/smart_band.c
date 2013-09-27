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

#define BUZZER_PIO                          3
#define BUTTON_PIO                          11
#define LED1_PIO                            12
#define SHOCK_PIO                           10
#define GLED_PIO                            13

// #define BUZZER_PIO                          14
// #define BUTTON_PIO                          3
// #define LED1_PIO                            1
// #define SHOCK_PIO                           0
// #define GLED_PIO                            11

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

#define MAX_APP_TIMERS                      9

#define SYNC_ERROR_THRESHOLD                5

#define MEASURE_MAX_LENGTH                  16

#define BATTERY_FULL_BATTERY_VOLTAGE        (3720)
#define BATTERY_FLAT_BATTERY_VOLTAGE        (3000)

#define SPARK_LATENCY                       5
#define SPARK_DURATION                      100
#define SHOCK_DURATION                      200

#define SETUP_CODE                          0x1985
#define NVM_OFFSET_SETUP_CODE               0

#define NVM_OFFSET_METRO_DATA               1

#define PRESS_RELEASE_LOCKER_INTERVAL       200

/*define metro data*/
typedef struct
{
    uint8       status;
    uint8       play;
    uint8       measure[MEASURE_MAX_LENGTH];
    uint8       measure_length;
    uint32      micro_duration;
    uint32      milli_duration;
    uint16      device_name[DEVICE_NAME_MAX_LENGTH / 2];
} METRO_DATA;

METRO_DATA metro_data;

/*sync struct*/
typedef struct
{
    bool        finded;
    uint8       sn;
    uint32      timestamp;
} ZERO;

ZERO zero;

/*define timer*/
typedef struct
{
    timer_id metronome;
    timer_id buzzer;
    timer_id shock;
    timer_id spark;
    timer_id read;
    timer_id button;
    timer_id switch_locker;
    timer_id press_locker;
    timer_id release_locker;
}TIMER;

TIMER timer;

typedef struct
{
    uint16 alert_notification_control_point;
    uint16 unread_alert;
    uint16 new_alert;
    uint16 supported_new_alert_category;
    uint16 supported_unread_alert_category;
} CHARACTERISTICS_HANDLE;

CHARACTERISTICS_HANDLE characteristics_handle;

bool is_connected = FALSE;

uint16      st_ucid, div;
TYPED_BD_ADDR_T     connect_bd_addr;

bool has_notification_service = FALSE;
uint16 service_start_handle, service_end_handle;

bool long_press_keep = FALSE, fix_start_time = FALSE, press_locked = FALSE, release_locked = FALSE, switch_locked = FALSE;

uint32 spark_pio_mask;

uint32 play_run_times, play_start_time, phone_previous_time, phone_current_time, interval;



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

static void clearEnv(void){
    //clean up
    MemSet(&metro_data, 0, sizeof(METRO_DATA));
    MemSet(&zero, 0 , sizeof(ZERO));
}

static void clearTime(void){
    phone_current_time = phone_previous_time = 0;
    play_run_times = play_start_time = 0;
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

static void sparkStartTimerHandler(timer_id tid){
    PioSets(spark_pio_mask, spark_pio_mask);

    timer.spark = TimerCreate((SPARK_DURATION* MILLISECOND), TRUE, sparkStopTimerHandler);
}

static void spark(uint32 mask){
    spark_pio_mask = mask;

    timer.spark = TimerCreate((SPARK_LATENCY* MILLISECOND), TRUE, sparkStartTimerHandler);
}

/*shock timer*/
static void shockTimerHandler(timer_id tid){
    PioSet(SHOCK_PIO, 0);
}

static void shock(void){
    PioSet(SHOCK_PIO, 1);

    timer.shock = TimerCreate((SHOCK_DURATION* MILLISECOND), TRUE, shockTimerHandler);
}

/*metronome timer*/
static void metronomeHandler(timer_id tid){
    if (metro_data.play){

        if(metro_data.measure[play_run_times % metro_data.measure_length] == 100){
            buzzer();

            if(metro_data.status & 2){
                spark(SPARK_HEAVY_MASK);
            }

            if(metro_data.status & 1){
                shock();
            }
            
            // DebugWriteString("heavy!!!!\r\n");
        }else{
            if(metro_data.status & 2){
                spark(SPARK_LIGHT_MASK);
            }

            if(play_run_times % metro_data.measure_length == metro_data.measure_length - 1 && fix_start_time){

                play_run_times = -1;
                play_start_time = zero.timestamp + interval + metro_data.micro_duration * metro_data.measure_length;

                fix_start_time = FALSE;
            }
        }
        
        play_run_times++;

        uint32 current = TimeGet32();
        uint32 next = (play_start_time + metro_data.micro_duration * play_run_times - current)/1000;

        timer.metronome = TimerCreate((next* MILLISECOND), TRUE, metronomeHandler);
    }
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

static void switchLockerHandler(timer_id tid){
    DebugWriteString("unlocked!!!\r\n");
    switch_locked = FALSE;
}

/*
    read and write timer handle
*/

static void readTimerHandler(timer_id tid){
    DebugWriteString("\r\nr:");
    // DebugWriteUint16(GattReadCharValue(st_ucid, characteristics_handle.supported_new_alert_category));
    DebugWriteString("\r\n");
}

// static void writeControlPoint(void){
//     uint8 notification_enabled[2] = {0x10, 0xff};

//     GattWriteCharValueReq(st_ucid, GATT_WRITE_REQUEST, characteristics_handle.alert_notification_control_point, 2, notification_enabled);
// }

static void buttonTimerHandler(timer_id tid){

    long_press_keep = FALSE;

    unlockBotton();

    //long press
    buzzer();

    DebugWriteString("wo ca!!\r\n");

    WarmReset();
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
    uint16 i;

    if(p_access_e->flags & ATT_ACCESS_WRITE){

        switch(p_access_e->handle){

            case HANDLE_METRONOME_DURATION:

                DebugWriteString("DURATION: ");
                
                /*from app*/
                metro_data.micro_duration = ntohl(p_access_e->value);
                metro_data.milli_duration = metro_data.micro_duration / 1000;

                DebugWriteUint32(metro_data.micro_duration);
                DebugWriteString("\r\n");

                break;

            case HANDLE_METRONOME_PLAY:

                if(p_access_e->size_value == 4){

                    DebugWriteUint16(NvmWrite((uint16 *)&metro_data, sizeof(METRO_DATA), NVM_OFFSET_METRO_DATA));
                    NvmDisable();
                    
                    interval = ntohl(p_access_e->value);

                    if(metro_data.play == 0){

                        PioSets(SPARK_HEAVY_MASK, 0x00UL);

                        metro_data.play = 1;

                        clearTime();

                        DebugWriteString("play!");

                        play_run_times = 0;

                        play_start_time = zero.timestamp + interval + metro_data.micro_duration * metro_data.measure_length;

                        uint32 now = TimeGet32();

                        DebugWriteUint32(play_start_time);
                        DebugWriteString("\r\n");

                        DebugWriteUint32(now);
                        DebugWriteString("\r\n");

                        DebugWriteUint32(zero.timestamp);
                        DebugWriteString("\r\n");

                        TimerDelete(timer.metronome);
                        timer.metronome = TimerCreate((play_start_time - now) / 1000 * MILLISECOND, TRUE, metronomeHandler);

                        DebugWriteString("\r\n");

                    }else{

                        fix_start_time = TRUE;
                    }


                }else{
                    metro_data.play = 0;

                    DebugWriteString("stop!\r\n");
                }

                break;

            case HANDLE_METRONOME_STATUS:

                metro_data.status = p_access_e->value[0];

                break;

            case HANDLE_METRONOME_MEASURE:

                metro_data.measure_length = p_access_e->size_value;

                for (i = 0; i < p_access_e->size_value; ++i)
                {
                    metro_data.measure[i] = p_access_e->value[i];

                    DebugWriteUint8(metro_data.measure[i]);
                    DebugWriteString("~~\r\n");
                }

                break;

            case HANDLE_METRONOME_SYNC:

                if((uint8)p_access_e->value[0] == 0){
                    phone_previous_time = 0;
                    MemSet(&zero, 0 , sizeof(ZERO));
                }

                phone_current_time = TimeGet32();

                if (phone_previous_time){

                    uint32 minus = (phone_current_time - phone_previous_time) / 1000;

                    DebugWriteString("d:");
                    DebugWriteUint32(minus);
                    DebugWriteString("\r\n");

                    if(!zero.finded){
                        if(minus == 60){
                            zero.sn = (uint8)p_access_e->value[0];
                            zero.timestamp = phone_current_time;
                        }else if(minus == 90){
                            DebugWriteString("!f\r\n");
                            zero.finded = 1;
                        }
                    }
                }
                
                phone_previous_time = phone_current_time;

                break;

            case HANDLE_CUSTORM_NAME:

                DebugWriteString("fuck!\r\n");

                uint16 setup_code = SETUP_CODE;
                DebugWriteUint16(NvmWrite(&setup_code, sizeof(setup_code), NVM_OFFSET_SETUP_CODE));
                NvmDisable();

                /*word*/

                DebugWriteString("\r\n");

                for(i =0; i < p_access_e->size_value; i++){
                    DebugWriteUint8(p_access_e->value[i]);
                }

                DebugWriteString("\r\n");

                MemSet(metro_data.device_name, 0, DEVICE_NAME_MAX_LENGTH/2);

                MemCopyPack(metro_data.device_name, p_access_e->value, p_access_e->size_value);

                for(i =0; i < DEVICE_NAME_MAX_LENGTH/2; i++){
                    DebugWriteUint16(metro_data.device_name[i]);
                }

                DebugWriteString("\r\n");

                DebugWriteUint16(NvmWrite((uint16 *)&metro_data, sizeof(METRO_DATA), NVM_OFFSET_METRO_DATA));
                NvmDisable();

                WarmReset();

                break;

            default:
                break;
        }

        GattAccessRsp(p_access_e->cid, p_access_e->handle, rc, p_access_e->size_value, p_access_e->value);

    }else if(p_access_e->flags & ATT_ACCESS_READ){
        
        switch(p_access_e->handle){

            case HANDLE_METRONOME_ZERO:
                GattAccessRsp(p_access_e->cid, p_access_e->handle, rc, 1, &zero.sn);

                // PioSet(BLED_PIO, 1);
                // PioSet(GLED_PIO, 0);

                PioSets(SPARK_HEAVY_MASK, SPARK_HEAVY_MASK);

                is_connected = TRUE;

                break;

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
        LE8_L(UUID_METRONOME_SERVICE),
        LE8_H(UUID_METRONOME_SERVICE)
    };

    uint8 device_appearance[ATTR_LEN_DEVICE_APPEARANCE + 1] = {
        AD_TYPE_APPEARANCE,
        LE8_L(APPEARANCE_METRONOME_VALUE),
        LE8_H(APPEARANCE_METRONOME_VALUE)
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

        // NvmRead(&metro_data.device_name_length, 1, NVM_OFFSET_METRO_DATA_LENGTH);
        // NvmDisable();

        

        uint8 device_name[DEVICE_NAME_MAX_LENGTH + 1];
        MemSet(device_name, 0, DEVICE_NAME_MAX_LENGTH + 1);

        device_name[0] = AD_TYPE_LOCAL_NAME_COMPLETE;

        /*word*/
        // MemCopyUnPack(&device_name[1], metro_data.device_name, DEVICE_NAME_MAX_LENGTH / 2);

        NvmRead((uint16 *)&metro_data, sizeof(METRO_DATA), NVM_OFFSET_METRO_DATA);
        NvmDisable();

        DebugWriteString("\r\n");

        int i, count = 0;

        for(i = 0; i < DEVICE_NAME_MAX_LENGTH/2; i++){
            DebugWriteUint16(metro_data.device_name[i]);
        }

        MemCopyUnPack(&device_name[1], metro_data.device_name, DEVICE_NAME_MAX_LENGTH/2);

        DebugWriteString("\r\n");

        for(i = 0; i < DEVICE_NAME_MAX_LENGTH + 1; i++){
            DebugWriteUint8(device_name[i]);

            count++;
            if(device_name[i] == 0x00){
                break;
            }
        }

        // DebugWriteUint16(metro_data.device_name_length);
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

    // ra.lap = 0x020202;
    ra.lap = Random32()>>8;
    ra.uap = Random16()>>8;
    ra.nap = Random16();

    GapSetRandomAddress(&ra);

    GattConnectReq(NULL,  L2CAP_CONNECTION_SLAVE_UNDIRECTED | L2CAP_OWN_ADDR_TYPE_RANDOM);
}

// static bool GattIsAddressResolvableRandom(TYPED_BD_ADDR_T *addr)
// {
//     if ((addr->type != L2CA_RANDOM_ADDR_TYPE) || 
//         (addr->addr.nap & BD_ADDR_NAP_RANDOM_TYPE_MASK)
//                                       != BD_ADDR_NAP_RANDOM_TYPE_RESOLVABLE)
//     {
//         /* This isn't a resolvable private address... */
//         return FALSE;
//     }
//     return TRUE;
// }

static void handleSignalGattConnectCFM(GATT_CONNECT_CFM_T *event_data){
    
    // connect_bd_addr = event_data->bd_addr;

    // if(GattIsAddressResolvableRandom(&event_data->bd_addr)){
    //     DebugWriteString("ca");
    // }

    // // uint16 bonded_irk[8];

    // // DebugWriteUint16(SMPrivacyMatchAddress(&connect_bd_addr, bonded_irk, 1, 8));

    // if(SMRequestSecurityLevel(&connect_bd_addr)){
    //     DebugWriteString("wo");
    // }

    GattDiscoverAllPrimaryServices(st_ucid);
}

static void handleGattServInfoInd(GATT_SERV_INFO_IND_T *ind){
    DebugWriteString("s: ");
    DebugWriteUint16(ind->uuid[0]);
    DebugWriteString("\r\n");

    if (ind->uuid[0] == UUID_ALERT_NOTIFICATION_SERVICE)
    {
        has_notification_service = TRUE;

        service_start_handle = ind->strt_handle;
        service_end_handle = ind->end_handle;
    }
}

static void handleGattDiscAllPrimServCfm(GATT_DISC_ALL_PRIM_SERV_CFM_T *cfm){

    if(has_notification_service){
        GattDiscoverServiceChar(st_ucid, service_start_handle, service_end_handle, GATT_UUID_NONE, NULL);
    }
}

static void handleGattCharDeclInfoInd(GATT_CHAR_DECL_INFO_IND_T *ind){
    DebugWriteString("c: ");
    DebugWriteUint16(ind->uuid[0]);
    DebugWriteString("\r\n");

    switch(ind->uuid[0]){
        case UUID_ALERT_NOTIFICATION_CONTROL_POINT:
            characteristics_handle.alert_notification_control_point = ind->val_handle;
            break;

        case UUID_UNREAD_ALERT_CHARACTERISTIC:
            characteristics_handle.unread_alert = ind->val_handle;
            break;
            
        case UUID_NEW_ALERT_CHARACTERISTIC:
            characteristics_handle.new_alert = ind->val_handle;
            break;

        case UUID_NEW_ALERT_SUPPORTED_CATEGORY:
            characteristics_handle.supported_new_alert_category = ind->val_handle;
            break;

        case UUID_SUPPORTED_UNREAD_ALERT_CATEGORY:
            characteristics_handle.supported_unread_alert_category = ind->val_handle;
            break;

        default:
            break;
    }
}

static void handleGattDiscServCharCfm(GATT_DISC_SERVICE_CHAR_CFM_T *ind){
    

    // writeControlPoint();
    timer.read = TimerCreate((500* MILLISECOND), TRUE, readTimerHandler);
}



static void handleGattReadCharValCFM(GATT_READ_CHAR_VAL_CFM_T *event_data){
    DebugWriteString("\r\nv:");
    DebugWriteUint16(event_data->size_value);
    DebugWriteString("\r\n");
}

static void handleSignalSmSimplePairingCompleteInd(SM_SIMPLE_PAIRING_COMPLETE_IND_T *event_data){

    if(event_data->status == sys_status_success){
        LsAddWhiteListDevice(&connect_bd_addr);
        // writeControlPoint();
        DebugWriteString("haha");
    }
}

static void handleSignalSmKeysInd(SM_KEYS_IND_T *event_data){

    // DebugWriteUint16(SMPrivacyMatchAddress(&connect_bd_addr, (event_data->keys)->irk, 1, 8));

    // SMRequestSecurityLevel(&connect_bd_addr);
}

static void handleSignalGattCharValNotCfm(GATT_CHAR_VAL_IND_CFM_T *p_event_data){


}

static void localSwitch(void){

    if(metro_data.play){

        TimerDelete(timer.metronome);
        metro_data.play = 0;

    }else{

        metro_data.play = 1;
        play_run_times = 0;
        

        uint32 current = TimeGet32();
        play_start_time = current + 100000;

        timer.metronome = TimerCreate(100 * MILLISECOND, TRUE, metronomeHandler);
    }
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

    TimerDelete(timer.metronome);
    TimerDelete(timer.buzzer);
    TimerDelete(timer.shock);
    TimerDelete(timer.spark);
    TimerDelete(timer.read);
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

    /*LED*/
    PioSetMode(LED2_PIO, pio_mode_user);
    PioSetDir(LED2_PIO, PIO_DIR_OUTPUT);

    PioSetMode(LED1_PIO, pio_mode_user);
    PioSetDir(LED1_PIO, PIO_DIR_OUTPUT);

    PioSetMode(SHOCK_PIO, pio_mode_user);
    PioSetDir(SHOCK_PIO, PIO_DIR_OUTPUT);

    // PioSetMode(RLED_PIO, pio_mode_user);
    // PioSetDir(RLED_PIO, PIO_DIR_OUTPUT);

    // PioSetMode(GLED_PIO, pio_mode_user);
    // PioSetDir(GLED_PIO, PIO_DIR_OUTPUT);

    // PioSetMode(BLED_PIO, pio_mode_user);
    // PioSetDir(BLED_PIO, PIO_DIR_OUTPUT);

    // PioSet(RLED_PIO, 0);
    // PioSet(GLED_PIO, 1);
    // PioSet(BLED_PIO, 0);

    /*gatt init*/
    GattInit();

    GattInstallClientRole();
    GattInstallServerWrite();

    SMInit(div);
    
    /*init Nvm*/
    NvmConfigureI2cEeprom();

    NvmDisable();

    clearEnv();
    clearTime();

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

                                if(is_connected){

                                    uint8 phone_play;

                                    if(metro_data.play){
                                        phone_play = 0;
                                    }else{
                                        phone_play = 1;
                                    }

                                    GattCharValueNotification(st_ucid, HANDLE_PHONE_PLAY, ATTR_LEN_PHONE_PLAY, &phone_play);

                                    DebugWriteString("send!!!!\r\n");

                                }else{

                                    localSwitch();
                                }

                            }

                            switch_locked = TRUE;

                            TimerDelete(timer.switch_locker);
                            DebugWriteString("fuck  !!!!\r\n");
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

            handleSignalGattConnectCFM((GATT_CONNECT_CFM_T *)event_data);

            break;
            
        case GATT_ACCESS_IND:

            DebugWriteString("acc_ind:\r\n");

            p_access_e = ((GATT_ACCESS_IND_T*) event_data);

            if(p_access_e->handle == HANDLE_PHONE_PLAY_C_CFG || p_access_e->handle == HANDLE_PHONE_PLAY){
                DebugWriteString("yeah:\r\n");
                uint8 play = 0x01;
                GattCharValueNotification(st_ucid, HANDLE_PHONE_PLAY, ATTR_LEN_PHONE_PLAY, &play);
            }
                        
            handleSignalGattAccessInd((GATT_ACCESS_IND_T*) p_access_e);
            
            break;

        case GATT_CHAR_VAL_NOT_CFM:

            handleSignalGattCharValNotCfm((GATT_CHAR_VAL_IND_CFM_T *)event_data);

            break;
        
        case SM_SIMPLE_PAIRING_COMPLETE_IND:

            DebugWriteString("22:\r\n");

            handleSignalSmSimplePairingCompleteInd((SM_SIMPLE_PAIRING_COMPLETE_IND_T *)event_data);

            DebugWriteUint16(((SM_SIMPLE_PAIRING_COMPLETE_IND_T *)event_data)->status);
            // GattDisconnectReq(st_ucid);
            // writeControlPoint();

            break;
            

        case SM_KEYS_IND:

            DebugWriteString("21:\r\n");

            handleSignalSmKeysInd((SM_KEYS_IND_T *)event_data);

            break;

        case GATT_DISC_ALL_PRIM_SERV_CFM:
            
            DebugWriteString("ALL_SERV:\r\n");

            handleGattDiscAllPrimServCfm((GATT_DISC_ALL_PRIM_SERV_CFM_T *)event_data);

            break;
            
        case GATT_SERV_INFO_IND:
            
            // DebugWriteString("GATT_SERV_INFO_IND:\r\n");
            handleGattServInfoInd((GATT_SERV_INFO_IND_T *)event_data);

            break;
            

        case GATT_CHAR_DECL_INFO_IND:
            // DebugWriteString("GATT_CHAR_DECL_INFO_IND:\r\n");

            handleGattCharDeclInfoInd((GATT_CHAR_DECL_INFO_IND_T *)event_data);

            break;
            
        case GATT_DISC_SERVICE_CHAR_CFM:
            // DebugWriteString("GATT_DISC_SERVICE_CHAR_CFM:\r\n");

            handleGattDiscServCharCfm((GATT_DISC_SERVICE_CHAR_CFM_T *) event_data);

            break;
            

        case GATT_WRITE_CHAR_VAL_CFM:

            DebugWriteString("WRITE:\r\n");
            DebugWriteUint16(((GATT_WRITE_CHAR_VAL_CFM_T *)event_data)->result );
            //     SMRequestSecurityLevel(&connect_bd_addr);
            // }
            break;

        case GATT_READ_CHAR_VAL_CFM:

            DebugWriteString("READ:\r\n");

            handleGattReadCharValCFM((GATT_READ_CHAR_VAL_CFM_T *)event_data);

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

            WarmReset();

            addDb();

            // buzzer();

            // PioSet(BLED_PIO, 0);
            // PioSet(GLED_PIO, 1);

            is_connected = FALSE;

            break;
        case GATT_DISCONNECT_IND:
            DebugWriteString("DISCONNECT\r\n");
            
            // clearEnv();
            // clearTime();

            addDb();

            // buzzer();

            // PioSet(BLED_PIO, 0);
            // PioSet(GLED_PIO, 1);

            PioSets(SPARK_HEAVY_MASK, 0x00UL);

            is_connected = FALSE;

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