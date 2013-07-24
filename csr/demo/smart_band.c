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

#include "smart_band.h"
#include "app_gatt_db.h"

#define MAX_ADV_DATA_LEN        (31)
#define LE8_L(x)                ((x) & 0xff)
#define LE8_H(x)                (((x) >> 8) & 0xff)
#define AD_TYPE_APPEARANCE      (0x19)
#define TX_POWER_VALUE_LENGTH   (2)

/* Setup PIOs
 *  PIO3    Buzzer
 *  PIO11   Button
 */

#define BUZZER_PIO              (3)
#define BUTTON_PIO              (11)


#define LED2_PIO                (4)
#define LED1_PIO                (12)

#define SHOCK_PIO               (10)

#define PIO_BIT_MASK(pio)       (0x01UL << (pio))

#define BUZZER_PIO_MASK         (PIO_BIT_MASK(BUZZER_PIO))
#define BUTTON_PIO_MASK         (PIO_BIT_MASK(BUTTON_PIO))
#define SPARK_HEAVY_MASK        (PIO_BIT_MASK(LED1_PIO)|PIO_BIT_MASK(LED2_PIO))
#define SPARK_LIGHT_MASK        (PIO_BIT_MASK(LED1_PIO))

/* PIO direction */
#define PIO_DIRECTION_INPUT     (FALSE)
#define PIO_DIRECTION_OUTPUT    (TRUE)

/* PIO state */
#define PIO_STATE_HIGH          (TRUE)
#define PIO_STATE_LOW           (FALSE)

/* Extra long button press timer */
#define EXTRA_LONG_BUTTON_PRESS_TIMER \(4*SECOND)

/* The index (0-3) of the PWM unit to be configured */
#define BUZZER_PWM_INDEX_0      (0)

/* PWM parameters for Buzzer */

/* Dull on. off and hold times */
#define DULL_BUZZ_ON_TIME       (2)    /* 60us */
#define DULL_BUZZ_OFF_TIME      (15)   /* 450us */
#define DULL_BUZZ_HOLD_TIME     (0)

/* Bright on, off and hold times */
#define BRIGHT_BUZZ_ON_TIME     (2)    /* 60us */
#define BRIGHT_BUZZ_OFF_TIME    (15)   /* 450us */
#define BRIGHT_BUZZ_HOLD_TIME   (0)    /* 0us */

#define BUZZ_RAMP_RATE          (0xFF)

/* TIMER values for Buzzer */
#define SHORT_BEEP_TIMER_VALUE  (100* MILLISECOND)
#define LONG_BEEP_TIMER_VALUE   (500* MILLISECOND)
#define BEEP_GAP_TIMER_VALUE    (25* MILLISECOND)

#define MAX_APP_TIMERS          5

#define SYNC_ERROR_THRESHOLD    5

#define MEASURE_MAX_LENGTH      16

#define BATTERY_FULL_BATTERY_VOLTAGE                  (4200)
#define BATTERY_FLAT_BATTERY_VOLTAGE                  (3000)

#define SPARK_LATENCY           5
#define SPARK_DURATION          100
#define SHOCK_DURATION          150

#define SETUP_CODE                  0x1985
#define NVM_OFFSET_SETUP_CODE       1

#define DEVICE_NAME_MAX_LENGTH      30      /*byte uint8*/
#define NVM_OFFSET_DEVICE_NAME_LENGTH    1
#define NVM_OFFSET_DEVICE_NAME      2

/*define metro data*/
typedef struct
{
    uint8       status;
    uint8       play;
    uint8       measure[MEASURE_MAX_LENGTH];
    uint8       measure_length;
    uint32      micro_duration;
    uint32      milli_duration;
    uint8       device_name[DEVICE_NAME_MAX_LENGTH];
    uint8       device_name_length;
} METRO_DATA;

METRO_DATA metro_data;

typedef struct
{
    uint16 alert_notification_control_point;
    uint16 unread_alert;
    uint16 new_alert;
    uint16 supported_new_alert_category;
    uint16 supported_unread_alert_category;
} CHARACTERISTICS_HANDLE;

CHARACTERISTICS_HANDLE characteristics_handle;

uint16 st_ucid, div;
TYPED_BD_ADDR_T     connect_bd_addr;

bool has_notification_service = FALSE;
uint16 service_start_handle, service_end_handle;

/*define timer*/
typedef struct
{
    timer_id metronome;
    timer_id buzzer;
    timer_id shock;
    timer_id spark;
    timer_id read;
}TIMER;

TIMER timer;

uint32 spark_pio_mask;

uint32 play_run_times, play_start_time, phone_previous_time, phone_current_time;

/*sync struct*/
typedef struct
{
    bool        finded;
    uint8       sn;
    uint32      timestamp;
} ZERO;

ZERO zero;


/*
    user defined function
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

    bat_voltage -= BATTERY_FLAT_BATTERY_VOLTAGE;
    
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
    timers
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
            // ledHeavy();
            spark(SPARK_HEAVY_MASK);
            shock();
            DebugWriteString("heavy!!!!\r\n");
        }else{
            // ledLight();
            spark(SPARK_LIGHT_MASK);
        }
        
        play_run_times++;

        uint32 current = TimeGet32();
        uint32 next = (play_start_time + metro_data.micro_duration * play_run_times - current)/1000;

        DebugWriteString("d:\r\n");
        DebugWriteUint32(next);
        DebugWriteString("\r\n");

        timer.metronome = TimerCreate((next* MILLISECOND), TRUE, metronomeHandler);
    }
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

                DebugWriteString("METRONOME_DURATION: ");
                
                /*from app*/
                metro_data.micro_duration = ntohl(p_access_e->value);
                metro_data.milli_duration = metro_data.micro_duration / 1000;

                DebugWriteUint32(metro_data.micro_duration);
                DebugWriteString("\r\n");

                break;

            case HANDLE_METRONOME_PLAY:

                clearTime();

                if(p_access_e->size_value == 4){
                    metro_data.play = 1;

                    DebugWriteString("play!!!");

                    uint32 interval = ntohl(p_access_e->value);
                    
                    play_start_time = zero.timestamp + interval + metro_data.micro_duration * metro_data.measure_length;

                    uint32 now = TimeGet32();

                    DebugWriteUint32(play_start_time);
                    DebugWriteString("\r\n");

                    DebugWriteUint32(now);
                    DebugWriteString("\r\n");

                    DebugWriteUint32(zero.timestamp);
                    DebugWriteString("\r\n");

                    timer.metronome = TimerCreate((play_start_time - now) / 1000 * MILLISECOND, TRUE, metronomeHandler);

                    DebugWriteString("\r\n");

                }else{
                    metro_data.play = 0;

                    DebugWriteString("stop!!!\r\n");
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
                            DebugWriteString("!finded\r\n");
                            zero.finded = 1;
                        }
                    }
                }
                
                phone_previous_time = phone_current_time;

                break;

            default:
                break;
        }

        GattAccessRsp(p_access_e->cid, p_access_e->handle, rc, p_access_e->size_value, p_access_e->value);

    }else if(p_access_e->flags & ATT_ACCESS_READ){
        
        switch(p_access_e->handle){

            case HANDLE_METRONOME_ZERO:
                GattAccessRsp(p_access_e->cid, p_access_e->handle, rc, 1, &zero.sn);

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
    if(LsStoreAdvScanData(0, NULL, ad_src_advertise)!=ls_err_none){
        
    };
    if(LsStoreAdvScanData(0, NULL, ad_src_scan_rsp)!=ls_err_none){
      
    };
    
    /*service uuid*/
    
    if(LsStoreAdvScanData(sizeof(advert_data), advert_data, ad_src_advertise)!=ls_err_none){
       
    };

    /*device appearance*/
    if(LsStoreAdvScanData(ATTR_LEN_DEVICE_APPEARANCE + 1, device_appearance, ad_src_advertise)!=ls_err_none){
     
    };

    /*what's that*/
    LsReadTransmitPowerLevel(&tx_power_level);
    device_tx_power[TX_POWER_VALUE_LENGTH - 1] = (uint8 )tx_power_level;

    if(LsStoreAdvScanData(TX_POWER_VALUE_LENGTH, device_tx_power, ad_src_advertise)!=ls_err_none){
       
    };

    /*device_name*/
    
    /*Check device name in nvm*/
    uint16 setup_code;
    NvmRead(&setup_code, sizeof(setup_code), NVM_OFFSET_SETUP_CODE);

    if(setup_code == SETUP_CODE){

        NvmRead((uint16 *)&metro_data.device_name_length, 1, NVM_OFFSET_DEVICE_NAME_LENGTH);
        NvmRead((uint16 *)metro_data.device_name, DEVICE_NAME_MAX_LENGTH/2, NVM_OFFSET_DEVICE_NAME);

        uint8 device_name[metro_data.device_name_length + 1];

        device_name[0] = AD_TYPE_LOCAL_NAME_COMPLETE;

        /*word*/
        MemCopy(device_name, metro_data.device_name, metro_data.device_name_length / 2);
        
        /*byte*/
        LsStoreAdvScanData(sizeof(device_name),  device_name, ad_src_advertise);
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

    if(GapSetRandomAddress(&ra)!=ls_err_none){
        
    };

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

    // GattDiscoverAllPrimaryServices(st_ucid);
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


/*
    app system function
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

    /*init button*/
    PioSetMode(PIO_BUTTON, pio_mode_user);
    PioSetDir(PIO_BUTTON, PIO_DIR_INPUT);
    PioSetPullModes(PIO_BIT_MASK(PIO_BUTTON), pio_mode_weak_pull_up);
    PioSetEventMask(PIO_BIT_MASK(PIO_BUTTON), pio_event_mode_falling);

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

    /*gatt init*/
    GattInit();

    GattInstallClientRole();
    GattInstallServerWrite();

    SMInit(div);
    
    /*init Nvm*/
    NvmConfigureI2cEeprom();

    uint16 rname;
    NvmRead(&rname, 1, 0);
    DebugWriteUint16(rname);

    clearEnv();
    clearTime();

    addDb();
}

void AppProcessSystemEvent (sys_event_id id, void *data){

    const pio_changed_data *pPioData;
    
    // uint8 test[ATTR_LEN_METRONOME_PLAY] = {
    //     LE8_L(0xEFEF)
    //         };
    
    switch(id){
        case sys_event_pio_changed:
            pPioData = (const pio_changed_data *)data;
            if (pPioData->pio_cause & (1UL << PIO_BUTTON)){
                if (pPioData->pio_state & (1UL << PIO_BUTTON)){
                    /* At this point the button is released */
                    buzzer();
                }else{
                    // GattCharValueNotification(st_ucid, HANDLE_METRONOME_PLAY, ATTR_LEN_METRONOME_PLAY, test);
                    buzzer();
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
            DebugWriteString("----\r\nGATT_ADD_DB_CFM:\r\n");

            handleSignalGattAddDbCfm((GATT_ADD_DB_CFM_T*)event_data);
            break;
            
        case GATT_CONNECT_CFM:
            DebugWriteString("GATT_CONNECT_CFM:\r\n");
            
            p_conn_e = (GATT_CONNECT_CFM_T *) event_data;
            st_ucid = p_conn_e->cid;
            
            buzzer();

            handleSignalGattConnectCFM((GATT_CONNECT_CFM_T *)event_data);

            break;
            
        case GATT_ACCESS_IND:

            p_access_e = ((GATT_ACCESS_IND_T*) event_data);
                        
            handleSignalGattAccessInd((GATT_ACCESS_IND_T*) p_access_e);
            
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
            
            DebugWriteString("GATT_DISC_ALL_PRIM_SERV_CFM:\r\n");

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
            DebugWriteString("GATT_WRITE_CHAR_VAL_CFM:\r\n");
            DebugWriteUint16(((GATT_WRITE_CHAR_VAL_CFM_T *)event_data)->result );
            //     SMRequestSecurityLevel(&connect_bd_addr);
            // }
            break;

        case GATT_READ_CHAR_VAL_CFM:
            DebugWriteString("GATT_READ_CHAR_VAL_CFM:\r\n");

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
            break;
        case GATT_DISCONNECT_IND:
            DebugWriteString("GATT_DISCONNECT_IND:\r\n");
            
            clearEnv();
            clearTime();

            addDb();

            buzzer();

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