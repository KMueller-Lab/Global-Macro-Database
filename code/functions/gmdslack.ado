* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* A SIMPLE PROGRAM TO DOCUMENT THE SEND A MESSAGE ON SLACK
* 
* Description: 
* This Stata program sends messages to slack
* 
* Created: 
* 2025-08-24
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 	
* ==============================================================================

* ==============================================================================
* DEFINE PROGRAM SYNTAX --------------------------------------------------------
* ==============================================================================
cap program drop gmdslack
program define gmdslack
    
    * Parse options
    syntax, SEND(string) 
    
    * Assert input correctness
    if missing("`send'") {
        display as error "Option send() is required (e.g., send('Your message'))"
        error 198
    }

    * Create the message text 
    tempfile payload_file
    file open payload_handle using "`payload_file'", write replace
    file write payload_handle `"{ "text": "`send'" }"' _n
    file close payload_handle
    
    * Send the message using shell
    display "Sending message to Slack: '`send''"
    shell curl -X POST -H "Content-type: application/json" --data "@`payload_file'" "$my_webhook"
    
    * Clean up
    erase "`payload_file'"
		
	* Confirm sent
    display "Message sent to Slack!"
	
end