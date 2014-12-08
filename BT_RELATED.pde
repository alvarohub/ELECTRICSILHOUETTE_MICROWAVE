// BLUETOOTH commands for the BlueSmirf SILVER v.2
// NOTE: this is  Class 1, 100 mW (20 dBm), approx ~100 meters. 
// SAFETY: Much more safe than a cell phone! (approx 0.001 watts per kilogram, while a cellphone reaches 0.25W/kg. And note that
// the U.S. and Canadian governments have set a maximum SAR of 1.6 watts per kilogram, while the European Union permits a slightly higher level.) 
// Uses AT commands: BGB203 AT Command Set (http://www.sparkfun.com/datasheets/Wireless/Bluetooth/BGB203_SPP_UserGuide.pdf)

// Attempt to connect: 
void BTConnectCLIENT() {
// REM: AT+BTBDA returns local address 
// REM: depending on which is this program (the one which will attempt connection or not), set the bluetooth to accept incomming connections
// port.write("AT+BTSRV=1\r");
  println("trying to establish the bluetooth connection...");
  port.write("+++"); // escape sequence (just in case). REM: no need to add <CR>
  delay(250);
   port.write("AT+BTAUT=0,1\r"); // for some reason, the AUTO mode is reset to 1 and then "CONNECT" does not appears!??
   delay(250);
  port.write("AT+BTCLT="+remoteAddress+", 1\r"); // ex: "0711080E3824";
  delay(250);
}

void BTSetSERVER() {
// REM: AT+BTBDA returns local address 
// REM: depending on which is this program (the one which will attempt connection or not), set the bluetooth to accept incomming connections
// port.write("AT+BTSRV=1\r");
  
  port.write("+++"); // escape sequence (just in case): 
  delay(500);
  port.write("AT+BTAUT=0,1\r"); // for some reason, the AUTO mode is reset to 1 and then "CONNECT" does not appears!??
   delay(250);
  port.write("AT+BTSRV=1\r");
  delay(250);
}

// Configure bluetooth for the very first time: 
void BTSetup() { //For using BlueSmirf SILVER v.2
    port.write("+++"); // escape sequence (just in case): 
    delay(500);

  // (1) Configure baud rate: (rem: this MUST be done beforehand, and save the values in the flash memory, otherwise it would be
  // impossible to connect to the serial-usb port...)
  // AT+BTURT=115200,8,0,1,0
  
  // Disable ECHO when in command mode (if we want - but we will have the "OKs" and also the "ATE0" command itself)
    port.write("ATE0\r");
    delay(250);
  // (2) not automatic mode and not suppressed responses (to get information back about connection/disconnection states):
  port.write("AT+BTAUT=0,1\r");
  delay(250);
  port.write("AT+BTCFG=32\r");
  delay(250);
  // (3) link timeout (MAKE IT SHORT to avoid getting stuck when program stops...):
  port.write("AT+BTLSV=3"); //from 2 seconds to 40 seconds
   delay(250);
   
  // Finally, store in flash memory just in case (no need if we re-call to BTSetup each time): 
   port.write("AT+BTFLS\r");
   delay(2000);
  
  // In these conditions, if the connection is established, the module will answer "CONNECT XXXX", and when connection is lost,  "NO CARRIER"
}

void BTdisconnect() {
   port.write("+++"); 
   delay(500);
   connected = false;
    neverConnectedBefore=true;
    canTalk=true;
    
   delay(250);
}

void BTreconnect() {
   port.write("+++"); 
   delay(1000); // to give time to the MASK to discover the disconnection and enter again SERVER mode
   BTConnectCLIENT();
}
