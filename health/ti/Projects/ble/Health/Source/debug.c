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

#define DEBUG_RADIX                 10
#define DEBUG_VALUE_MAX_LENGTH      24

/*********************************************************************
 * FUNCTIONS
 */

void Debug_init( uint8 task_id ){
  serialInitTransport();
}

void serialCallback( uint8 port, uint8 event ){
  
}

void serialInitTransport(){
  
  // define uart0 to alt2 mode¡£use p1.4 and p1.5
  PERCFG |= BV(0);
  P1SEL = BV(4)|BV(5);
  P2SEL&=~(BV(6)|BV(3));
    
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

void DebugWrite( uint8 text[] ){
  uint8 wrap[] = "\r\n";

  HalUARTWrite( DEBUG_UART_PORT, text, osal_strlen((char*)text));
  HalUARTWrite( DEBUG_UART_PORT, wrap, osal_strlen((char*)wrap));
}

void DebugValue( uint32 value ){
  uint8 buf[DEBUG_VALUE_MAX_LENGTH];
  
  _ltoa( value, &buf[0], DEBUG_RADIX ); 
  
  DebugWrite(buf);
}

void DebugFormat( uint8 text[], uint32 value ){
  
  HalUARTWrite( DEBUG_UART_PORT, text, osal_strlen((char*)text));
  
  DebugValue(value);
}

/******************************************************************************
******************************************************************************/
