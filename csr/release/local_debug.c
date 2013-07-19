/******************************************************************************
 *  Copyright (C) Cambridge Silicon Radio Limited 2012-2013
 *  Part of CSR uEnergy SDK 2.1.0
 *  Application version 2.1.0.0
 *
 *  FILE
 *      local_debug.c
 *
 *  DESCRIPTION
 *      This file defines debug functions
 *
 *  NOTES
 *
 ******************************************************************************/

/*============================================================================*
 *  Local Header File
 *============================================================================*/
#include "local_debug.h"

#ifdef DEBUG_THRU_UART

extern void writeString(const char *string)
{
    DebugWriteString(string);
    DebugWriteString("\n\r");
}

extern void writeNumAlerts(uint8 const val)
{
    DebugWriteString("\tN=");
    DebugWriteUint8(val);
}
#endif /* DEBUG_THRU_UART */
