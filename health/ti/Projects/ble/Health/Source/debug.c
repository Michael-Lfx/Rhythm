/*********************************************************************
 * INCLUDES
 */

#include "bcomdef.h"
#include "OSAL.h"
#include "OSAL_PwrMgr.h"

#include "OnBoard.h"
#include "hal_adc.h"
#include "hal_led.h"
#include "hal_key.h"
#include "hal_lcd.h"

#include "hal_uart.h"


#include "gatt.h"
#include "ll.h"
#include "hci.h"
#include "gapgattserver.h"
#include "gattservapp.h"
#include "central.h"
#include "gapbondmgr.h"
#include "health_profile.h"
#include "simpleBLEPeripheral.h"

#include "debug.h"

/*********************************************************************
 * FUNCTIONS
 */

void Debug_init( uint8 task_id ){
  serialInitTransport();
}

void serialCallback( uint8 port, uint8 event ){
  
}

void serialInitTransport(){
  halUARTCfg_t uartConfig;
  
  uartConfig.configured             = TRUE;
  uartConfig.baudRate               = DEBUG_UART_BR;
  uartConfig.flowControl            = DEBUG_UART_FC;
  uartConfig.flowControlThreshold   = DEBUG_UART_FC_THRESHOLD;
  uartConfig.rx.maxBufSize          = DEBUG_UART_RX_BUF_SIZE;
  uartConfig.tx.maxBufSize          = DEBUG_UART_TX_BUF_SIZE;
  uartConfig.idleTimeout            = DEBUG_UART_IDLE_TIMEOUT;
  uartConfig.intEnable              = DEBUG_UART_INT_ENABLE;
  uartConfig.callBackFunc           = serialCallback;
  
  (void)HalUARTOpen(DEBUG_UART_PORT, &uartConfig);
}

void DebugWrite( uint8 data[] ){
  HalUARTWrite( DEBUG_UART_PORT, data, osal_strlen((char*)data));
}

/******************************************************************************
******************************************************************************/
