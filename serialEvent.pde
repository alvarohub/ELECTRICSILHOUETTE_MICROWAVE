// REM: given that the electric silhouettes graphics takes time processing, a HANDSHAKE protocol may be the best solution here to avoid saturating the serial buffer...

//=====================================================================================================
 void handleSerial() {
   while(port.available()>0) { // either this, or byte by byte reading - while loop is faster, but we may get stuck if we are not using handshake!!
  // REM: the packet structure is as follows: 
  //     XAXBXCXDXF@, where each letter is a byte, 
  // X = ASCII codes of decimal representation of the range for each sensor (converted to 0-10 levels)
  // A to F are the code separators, also corresponding to the index of the module
  // "@" is the packet terminator, which is necessary to give the client the opportunity to resend commands (reset canTalk to true) in case of handshake. 

  incomingByte = port.read();
  // print(char(incomingByte));
  
  // First, intercept data from bluetooth AT protocol:
  handleSerialFromBluetooth(); 
  
// Then, process data in case we are connected (this should be done per-command basis, but the fact is that most of the commands use the 
// serial port at one point when completing the task):
if (connected) { 
   
   // RAW DATA:
   // Save only ASCII numeric characters (ASCII 0 - 9) on the string:
    if ((incomingByte >= '0') && (incomingByte <= '9')){
      inString += char(incomingByte);
      // No acknowledging of the "task" (store byte in inString) with END_TASK, because that would make a heavy "atomic" handshake
      // that would slow down things! (by the way, the canTalk mode does not change on the microcontroller side when sending raw data, 
      // not even when sending the "separator" command, see below). 
    }
    
    // ATOMIC COMMAND or "separator" telling the computer to store the raw data in a specific variable
    // (REM: we could send TASK_COMPLETED each time we get data for ONE sensor, but we won't do that unless we receive the 
    // SET_GRAPHIC_MODE commands (or another command) from the microcontroller telling what to do with this data - this is 
    // to avoid having an "atomic handshake", but instead doing handshake at the packet level) 
    if ((incomingByte >= 'A') && (incomingByte <= 'E')) { // this are the module index, also a "separator" 
    // inString[stringPos] =0; // add a 0 (end of string) before converting to integer. 
    // Store the value on the corresponding serialReadValue:
      int indexModule=incomingByte-65;
      readSerialValue[indexModule]=int(inString);
     //println(readSerialValue[indexModule]);
      
      // for (int c=0; c<5; c++) inString[c]=0;
      // stringPos=0; // reset the string counter so we can start another number
      inString=""; // reset the string counter so we can start another number
    }
    
    if (incomingByte==SET_GRAPHIC_MODE) {
      // set the graphic mode from the range data, and acknowledge the execution of the command by sending TASK_COMPLETED 
     changeGraphicModeFromRangers();
     port.write(TASK_COMPLETED); 
    }
    
    // Accelerometer data:
    if (incomingByte==STORE_ACCELERATION) { // this is "separator" code for accelerometer axis X (there is no other axis data yet)
    accelerometerData=int(inString);
    //println("Accelerometer value: "+inString);
    // println(accelerometerData); // RAW values go from 410 to 610, horizontal is about 500
    accelerometerData=1.0*(accelerometerData-500)/100.0; // about -1 to 1
    inString="";
    port.write(TASK_COMPLETED); // indicate task completition, so the computer can request accelerometer data again (or anything else, 
    // since in this version ALL the tasks are completed with the same code - i.e., we cannot issue simultaneous commands whose
    // data would be interleaved in the serial bus). 
    }
    
    if (incomingByte==TASK_COMPLETED) { // this means end of packet (=13, the ASCII code for carriage return)
      canTalk=true;
      //println("handshake: we can talk");
      //delay(1000);
    }
    
} // end "connected" mode
   } // end while things in serial buffer
 } // end handle byte


// This function intercept messages from bluetooth protocol:
void handleSerialFromBluetooth() {
  
  // (1) check if we are connected so we can start requesting data and processing data from the serial port
  //REM: we could wait for a 'T' that comes only in the CONNECT <address> message, by doing ECHO OFF in command mode, but unfortunately the command to 
  // set this echo of is ATE0, which contains a T...). So, check two consecutive 'N' for "CONNECT". IT IS IMPORTANT than echo is ON (check BTConnectCLIENT())
  if (incomingByte == 'N') {
     // while (port.available()<1) {}; // wait for next character
    delay(50); // this may be better than a "while" loop, because we may get blocked otherwise...
    if ( (port.available()>0) &&(port.read()=='N')) {
   
    // update the connection status:
    connected = true;
    canTalk=true;
     
    delay(1000); // this is a hack: it gives time to the bluetooth to write the full line "CONNECT XXXXXXXXXX" and then flush the whole content of the
    // serial buffer that can be interpreted as data from the heandband... 
    port.clear(); // PROBLEMATIC!!! THIS WAS THE SOURCE OF MANY PROBLEMS: BUT WHY????
     
    println("CONNECTED!");
  
     // Also, just in case the bluetooth in the mask does not acknoledge the connection with its own "CONNECT" from its own bluetooth (it happens...):
     port.write("CONNECT");// this will make the haptikat mask to go in "connected mode" (rem: perhaps it's unnecessary to distinguish connected and not-connected mode at the mask)
  }  
 }

  
  //"R" comes only in the NO CARRIER message (disconnection)
  if (incomingByte == 'R') {
    // blink led:  
    // blink(testLEDpin, 4 , 100);
    connected = false;
    neverConnectedBefore=true;
    canTalk=true;
    
    // in case of server, reset bluetooth to wait for connection:
    if (isThisServer==true) BTSetSERVER();
  }
}
  
// == old code ===================================================================
/*
void serialEvent(Serial serialPort) {
  // NORMALLY the program would come here when the buffer receives the character 10..

  // read the string in the buffer until it finds a special character
  String myString=serialPort.readStringUntil(10); // 10 is the carriage return ASCII code!

  if (myString != null) { // this shouldn't be necessary if bufferUntil were working okay!
    myString=trim(myString); // takes away the spaces and carriage return codes

    //split the string at the commas (the packet delimiters!) and convert the ASCII decimal numbers to integers:
    int data[] = int(split(myString, ','));

    // now, check if we actually received all the data! (we could have been reading from the second value...)
    if (data.length==3) {
      // assign the read value to the global force, using a special conversion function (that we will calibrate)
      globalFx=convertData(data[0],4000, 327, 263, 396);
      globalFy=convertData(data[1],4000, 326, 265, 403);
      thirdAxis=convertData(data[2],3000, 338, 267, 413);

      // if we got here, it means that the answer from the microcontroller was complete and well received;
      // we can re-set the can_Talk flag to true, so we can issue new requests:
      can_Talk=true;
    }
  }
}

// convert the value read from the accelerometer to the force on the ball:
float convertData(int value, float gain, int offset, int minvalue, int maxvalue) {
  float force;
  force=1.0*gain*(value-offset)/(maxvalue-minvalue);
  return(force); 
}
*/
