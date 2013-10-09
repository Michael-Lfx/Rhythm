#ifndef DEBUG_H
#define DEBUG_H

#ifdef __cplusplus
extern "C"
{
#endif

/*********************************************************************
 * INCLUDES
 */
 
#include "hal_uart.h"

/*********************************************************************
 * CONSTANTS
 */

#define DEBUG_UART_PORT             HAL_UART_PORT_0
#define DEBUG_UART_FC               FALSE
#define DEBUG_UART_FC_THRESHOLD     48
#define DEBUG_UART_RX_BUF_SIZE      128
#define DEBUG_UART_TX_BUF_SIZE      128
#define DEBUG_UART_IDLE_TIMEOUT     6
#define DEBUG_UART_INT_ENABLE       TRUE
#define DEBUG_UART_BR               HAL_UART_BR_57600

/*********************************************************************
 * MACROS
 */

/*********************************************************************
 * FUNCTIONS
 */

extern void Debug_init( uint8 task_id );

extern void serialCallback( uint8 port, uint8 event );

extern void DebugWrite( uint8 text[] );

extern void DebugValue( uint32 value );

extern void DebugFormat( uint8 text[], uint32 value );

void serialInitTransport();

/*********************************************************************
*********************************************************************/

#ifdef __cplusplus
}
#endif

#endif /* DEBUG_H */
