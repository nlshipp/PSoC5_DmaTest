/*******************************************************************************
* Copyright 2009, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions, 
* disclaimers, and limitations in the end user license agreement accompanying 
* the software package with which this file was provided.
********************************************************************************/

//
//	PSoC3 Datapath configuration definitions
//

// Some constants to be defined
`define TRUE  1
`define FALSE 0

// The default values for the control store and static configuration registers
`define CS_DEFAULT  16'h0000
`define SC_DEFAULT  16'h0000
`define SC_MASK_NOP 16'hFFFF

// Control Store Bit Field Definitions
`define CS_ALU_OP	15:13
`define CS_SRCA		12
`define CS_SRCB		11:10
`define CS_SHFT_OP	09:08
`define CS_A0_SRC	07:06
`define CS_A1_SRC	05:04
`define CS_FEEDBACK	03
`define CS_CI_SEL	02
`define CS_SI_SEL	01
`define CS_CMP_SEL	00

// Control Store ALU OP
`define CS_ALU_OP_PASS 3'b000
`define CS_ALU_OP__INC 3'b001
`define CS_ALU_OP__DEC 3'b010
`define CS_ALU_OP__ADD 3'b011
`define CS_ALU_OP__SUB 3'b100
`define CS_ALU_OP__XOR 3'b101
`define CS_ALU_OP__AND 3'b110
`define CS_ALU_OP___OR 3'b111

// Control Store SRC A
`define CS_SRCA_A0 1'b0
`define CS_SRCA_A1 1'b1

// Control Store SRC B
`define CS_SRCB_D0 2'b00
`define CS_SRCB_D1 2'b01
`define CS_SRCB_A0 2'b10
`define CS_SRCB_A1 2'b11

// Control Store Shift OP
`define CS_SHFT_OP_PASS 2'b00
`define CS_SHFT_OP___SL 2'b01
`define CS_SHFT_OP___SR 2'b10
`define CS_SHFT_OP__SWP 2'b11

// Control Store A0 SRC
`define CS_A0_SRC_NONE 2'b00
`define CS_A0_SRC__ALU 2'b01
`define CS_A0_SRC___D0 2'b10
`define CS_A0_SRC___F0 2'b11

// Control Store A1 SRC
`define CS_A1_SRC_NONE 2'b00
`define CS_A1_SRC__ALU 2'b01
`define CS_A1_SRC___D1 2'b10
`define CS_A1_SRC___F1 2'b11

// Control Store Feedback
`define CS_FEEDBACK_DSBL 1'b0
`define CS_FEEDBACK_ENBL 1'b1

// Control Store CI Select
`define CS_CI_SEL_CFGA 1'b0
`define CS_CI_SEL_CFGB 1'b1

// Control Store SI Select
`define CS_SI_SEL_CFGA 1'b0
`define CS_SI_SEL_CFGB 1'b1

// Control Store CMP Select
`define CS_CMP_SEL_CFGA 1'b0
`define CS_CMP_SEL_CFGB 1'b1

// Static Control Register 4
// Static Control A Mask
`define SC_MASK_A 8'b11111111

// Static Control Register 5
// Static Control C Masks
`define SC_MASK_C1 8'b11111111
`define SC_MASK_C0 8'b11111111

// Static Control Register 6
`define SC_CMPB		15:14
`define SC_CMPA		13:12
`define SC_CI_B		11:10
`define SC_CI_A		09:08
`define SC_C1_MASK	07
`define SC_C0_MASK	06
`define SC__A_MASK	05
`define SC_DEF_SI	04
`define SC_SI_B		03:02
`define SC_SI_A		01:00

// Static Control CMP B
`define SC_CMPB_A1_D1 2'b00
`define SC_CMPB_A1_A0 2'b01
`define SC_CMPB_A0_D1 2'b10
`define SC_CMPB_A0_A0 2'b11

// Static Control CMP A
`define SC_CMPA_A1_D1 2'b00
`define SC_CMPA_A1_A0 2'b01
`define SC_CMPA_A0_D1 2'b10
`define SC_CMPA_A0_A0 2'b11

// Static Control CI B
`define SC_CI_B_ARITH 2'b00
`define SC_CI_B_REGIS 2'b01
`define SC_CI_B_ROUTE 2'b10
`define SC_CI_B_CHAIN 2'b11

// Static Control CI B
`define SC_CI_A_ARITH 2'b00
`define SC_CI_A_REGIS 2'b01
`define SC_CI_A_ROUTE 2'b10
`define SC_CI_A_CHAIN 2'b11

// Static Control C1 Mask En
`define SC_C1_MASK_DSBL 1'b0
`define SC_C1_MASK_ENBL 1'b1

// Static Control C0 Mask En
`define SC_C0_MASK_DSBL 1'b0
`define SC_C0_MASK_ENBL 1'b1

// Static Control A Mask En
`define SC_A_MASK_DSBL 1'b0
`define SC_A_MASK_ENBL 1'b1

// Statuc Control Def SI
`define SC_DEF_SI_0 1'b0
`define SC_DEF_SI_1 1'b1

// Static Control SI B
`define SC_SI_B_DEFSI 2'b00
`define SC_SI_B_REGIS 2'b01
`define SC_SI_B_ROUTE 2'b10
`define SC_SI_B_CHAIN 2'b11

// Static Control SI A
`define SC_SI_A_DEFSI 2'b00
`define SC_SI_A_REGIS 2'b01
`define SC_SI_A_ROUTE 2'b10
`define SC_SI_A_CHAIN 2'b11

// Static Control Register 7
`define SC_A0_SRC	15
`define SC_SHIFT_DIR	14
`define SC_PI_DYN	13
`define SC_SR_SRC	12
`define SC_FIFO1_SRC	11:10
`define SC_FIFO0_SRC	09:08
`define SC_MSB		07
`define SC_MSB_VAL	06:04
`define SC_MSB_CHAIN	03
`define SC_FB__CHAIN	02
`define SC_CMP1_CHAIN	01
`define SC_CMP0_CHAIN	00

// Static Control A0 Source
`define SC_A0_SRC_ACC 1'b0
`define SC_A0_SRC_PIN 1'b1

// Static Control Shift Direction
`define SC_SHIFT_SL 1'b0
`define SC_SHIFT_SR 1'b1

// Dynamic PI Select
`define SC_PI_DYN_EN 1'b1
`define SC_PI_DYN_DS 1'b0

// Arithmetic Shift Right Select
`define SC_SR_SRC_MSB 1'b1
`define SC_SR_SRC_REG 1'b0

// Static Control FIFO1 Source
`define SC_FIFO1_BUS 2'b00
`define SC_FIFO1__A0 2'b01
`define SC_FIFO1__A1 2'b10
`define SC_FIFO1_ALU 2'b11

// Static Control FIFO0 Source
`define SC_FIFO0_BUS 2'b00
`define SC_FIFO0__A0 2'b01
`define SC_FIFO0__A1 2'b10
`define SC_FIFO0_ALU 2'b11

// Static Control MSB Enable
`define SC_MSB_DSBL 1'b0
`define SC_MSB_ENBL 1'b1

// Static Control MSB Value
`define SC_MSB_BIT0 3'b000
`define SC_MSB_BIT1 3'b001
`define SC_MSB_BIT2 3'b010
`define SC_MSB_BIT3 3'b011
`define SC_MSB_BIT4 3'b100
`define SC_MSB_BIT5 3'b101
`define SC_MSB_BIT6 3'b110
`define SC_MSB_BIT7 3'b111

// Static Control MSB CC
`define SC_MSB_NOCHN 1'b0
`define SC_MSB_CHNED 1'b1

// Static Control FB CC
`define SC_FB_NOCHN 1'b0
`define SC_FB_CHNED 1'b1

// Static Control CMP1 CC
`define SC_CMP1_NOCHN 1'b0
`define SC_CMP1_CHNED 1'b1

// Static Control CMP0 CC
`define SC_CMP0_NOCHN 1'b0
`define SC_CMP0_CHNED 1'b1

// Static Control Register 8
`define SC_FIFO_SYNC	12
`define SC_FIFO1_DYN	09
`define SC_FIFO0_DYN	08
`define SC_FIFO_CLK1	07
`define SC_FIFO_CLK0	06
`define SC_FIFO_CLK	05
`define SC_FIFO_CAP	04
`define SC_FIFO_TRIG	03
`define SC_FIFO_TYPE	02
`define SC_EXTCRC	01
`define SC_WRK16CAT	00

// Static Control WRK16 Concatination
`define SC_WRK16CAT_DSBL 1'b0
`define SC_WRK16CAT_ENBL 1'b1

// Static Control Ext CRC/PRS
`define SC_EXTCRC_DSBL 1'b0
`define SC_EXTCRC_ENBL 1'b1

// Static Control FIFO Async
`define SC_FIFO__SYNC 1'b0
`define SC_FIFO_ASYNC 1'b1

// Static Control FIFO Edge
`define SC_FIFO_LEVEL 1'b0
`define SC_FIFO__EDGE 1'b1

// Static Control FIFO Cap
`define SC_FIFO_CAP_AX 1'b0
`define SC_FIFO_CAP_FX 1'b1

// Static Control FIFO Fast
`define SC_FIFO_CLK__DP 1'b0
`define SC_FIFO_CLK_BUS 1'b1

// Static Control FIFO 1 Clock Invert
`define SC_FIFO_CLK1_POS 1'b0
`define SC_FIFO_CLK1_NEG 1'b1

// Static Control FIFO 0 Clock Invert
`define SC_FIFO_CLK0_POS 1'b0
`define SC_FIFO_CLK0_NEG 1'b1

// Static Control FIFO 1 Dynamic Control
`define SC_FIFO1_DYN_ON 1'b1
`define SC_FIFO1_DYN_OF 1'b0

// Static Control FIFO 0 Dynamic Control
`define SC_FIFO0_DYN_ON 1'b1
`define SC_FIFO0_DYN_OF 1'b0

// Additional FIFO Status Sync
`define SC_FIFO_SYNC_NONE 1'b0
`define SC_FIFO_SYNC__ADD 1'b1
