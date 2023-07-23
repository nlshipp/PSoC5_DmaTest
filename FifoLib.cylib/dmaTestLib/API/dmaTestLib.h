/* ========================================
 *
 * Copyright Neil Shipp, 2023
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF your company.
 *
 * ========================================
*/

extern uint8 dataIn[1024];
extern uint8 dataOut[1024];

extern uint8 dmaInCh;
extern uint8 dmaOutCh;
extern uint8 dmaInTD;
extern uint8 dmaOutTD;

extern void dmaTestLibInit(reg8 * fifoInPtr, reg8 * fifoOutPtr, reg8 * fifoStatusPtr, const uint8 * bit_reversalPtr);
extern void dmaResetTD(uint16 count);
extern void dmaSetup(uint16 count);
extern uint8 dmaStatus(uint16 *inLeft, uint16 *outLeft);
extern void dmaTest(uint16 max);

extern uint8 fifoStatusOut;

/* [] END OF FILE */
