/*********************************************************************************************************/
//
// Lecture 5 - ADXL345 Using SPI
//
//
//
/*********************************************************************************************************/
#include "mbed.h"
#include "RN41.h"
#include <SPI.h>
#include "Adafruit_BLE_UART.h"

BusOut led(LED4,LED3,LED2,LED1);
Serial pc(USBTX,USBRX);

// Connect CLK/MISO/MOSI to hardware SPI
// e.g. On UNO & compatible: CLK = 13, MISO = 12, MOSI = 11
#define ADAFRUITBLE_REQ 10
#define ADAFRUITBLE_RDY 2     // This should be an interrupt pin, on Uno thats #2 or #3
#define ADAFRUITBLE_RST 9

//Adafruit_BLE_UART BTLEserial = Adafruit_BLE_UART(ADAFRUITBLE_REQ, ADAFRUITBLE_RDY, ADAFRUITBLE_RST);
Adafruit_BLE_UART BTLEserial = Adafruit_BLE_UART(p25, p26, p27);
/**************************************************************************/
/*!
    Configure the Arduino and start advertising with the radio
*/
/**************************************************************************/
SPI spi();

int main()
{
	// Minicom
	pc.baud(115200);
	pc.printf("Final Project : Bluetooth...\r\n\r\n");


//	Serial.begin(9600);
//	  while(!Serial); // Leonardo/Micro should wait for serial init
//	  Serial.println(F("Adafruit Bluefruit Low Energy nRF8001 Print echo demo"));

	  // BTLEserial.setDeviceName("NEWNAME"); /* 7 characters max! */

	  BTLEserial.begin();
	}

	/**************************************************************************/
	/*!
	    Constantly checks for new events on the nRF8001
	*/
	/**************************************************************************/
	aci_evt_opcode_t laststatus = ACI_EVT_DISCONNECTED;

	while(1)
	{

		// Tell the nRF8001 to do whatever it should be working on.
		  BTLEserial.pollACI();

		  // Ask what is our current status
		  aci_evt_opcode_t status = BTLEserial.getState();
		  // If the status changed....
		  if (status != laststatus) {
		    // print it out!
		    if (status == ACI_EVT_DEVICE_STARTED) {
		    	pc.printf("* Advertising started");
		    }
		    if (status == ACI_EVT_CONNECTED) {
		    	pc.printf("* Connected!");
		    }
		    if (status == ACI_EVT_DISCONNECTED) {
		    	pc.printf("* Disconnected or advertising timed out");
		    }
		    // OK set the last status change to this one
		    laststatus = status;
		  }

		  if (status == ACI_EVT_CONNECTED) {
		    // Lets see if there's any data for us!
		    if (BTLEserial.available()) {
		    	pc.printf("available "); //pc.printf(BTLEserial.available()); pc.printf(" bytes available from BTLE");
		    }
		    // OK while we still have something to read, get a character and print it out
		    while (BTLEserial.available()) {
		      char c = BTLEserial.read();
		      pc.printf("%d",c);
		    }

		    // Next up, see if we have any data to get from the Serial console

//		    if (Serial.available()) {
//		      // Read a line from Serial
//		      Serial.setTimeout(100); // 100 millisecond timeout
//		      wait_ms(100);
//		      String s = Serial.readString();

		      // We need to convert the line to bytes, no more than 20 at this time
//		      uint8_t sendbuffer[20];
//		      s.getBytes(sendbuffer, 20);
//		      char sendbuffersize = min(20, s.length());
//
//		      pc.printf("\n* Sending -> \"");
//		      Serial.print((char *)sendbuffer);
//		      Serial.println("\"");

		      // write the data
		      BTLEserial.write(sendbuffer, sendbuffersize);
		    }
		  }

	}
}

void initialise_connection(){
//	wait(0.5);
//	rn42.putc('$'); // Enter command mode
//	rn42.putc('$');
//	rn42.putc('$');
//	wait(1.2);
//	rn42.putc('S');
//	rn42.putc('M');
//	rn42.putc(',');
//	rn42.putc('3');
//	rn42.putc('0x0D');
//	wait(1.2);
////	rn42.putc('S');
////	rn42.putc('A');
////	rn42.putc(',');
////	rn42.putc('0');
////	rn42.putc('0x0D');
////	wait(0.1);
//	rn42.putc('C');
//	rn42.putc(',');
//	rn42.putc('A');
//	rn42.putc('C');
//	rn42.putc('B');
//	rn42.putc('C');
//	rn42.putc('3');
//	rn42.putc('2');
//	rn42.putc('A');
//	rn42.putc('0');
//	rn42.putc('1');
//	rn42.putc('7');
//	rn42.putc('0');
//	rn42.putc('8');
//	rn42.putc('0x0D');
////	wait(0.1);
////	rn42.putc('G');
////	rn42.putc('B');
////	rn_read = rn42.getc();
////	rn42.putc('0x0D');
//	wait(1.2);
//	rn42.putc('-');
//	rn42.putc('-');
//	rn42.putc('-');
//	rn42.putc('0x0D');
//	wait(0.5);
}

