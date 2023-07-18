/*******************************************************************************
* Copyright 2009, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions, 
* disclaimers, and limitations in the end user license agreement accompanying 
* the software package with which this file was provided.
********************************************************************************/

//
//	This file processes the device and family defines and determines
//	which include files to use.  It also allows for Warp or simulation
//	compliations.
//

`ifdef CYPRESS_ALREADY_INCLUDED
    // Only include the rest of this file once.
`else
    `define CYPRESS_ALREADY_INCLUDED
    //	This is **_temporarily_** the only device being used
    `define CPSOC3

    `ifdef CPSOC3
	`ifdef WARP
	    `include "cy_psoc3_inc.v"
	`else
	    `include "cy_psoc3.v"
	`endif
    `endif
`endif
