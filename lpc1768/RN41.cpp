#include "RN41.h"
#include <string>

RN41::RN41(PinName tx, PinName rx) : _RN41(tx, rx){
    _baud = 115200;
    _RN41.baud(_baud);
    _commandMode = false;
}

//Resets The Device
//Also Exits Command Mode
//Device Must Be Reset After A Config Change To Take Effect
bool RN41::reset(){
    enterCommandMode();
    sendString("R,1\r\n");
    if(getString() == "Reboot!\r\n"){
        _commandMode = false;
        return true;
    }else{
        return false;
    }
}

//Sets Device Name
//Maximum 20 characters
bool RN41::setDeviceName(string name){
    enterCommandMode();
    sendString("SN," + name + "\r\n");
    if(getString() == "AOK\r\n"){
        reset();
        return true;
    }else{
        return false;
    }
}

//Set Authentication Mode
//Available Modes:
//0 - Open Mode
//1 - SSP Keyboard I/O Mode
//2 - SSP "Just Works" Mode
//4 - Pin Code
//Default Mode: 1
bool RN41::setAuthenticationMode(int authMode){
    enterCommandMode();
    if(authMode < 0 or authMode > 4 or authMode == 3){
        return false;
    }
    char buf[1];
    sprintf(buf,"SA,%d\r\n", authMode);
    string msg = buf;
    sendString(msg);
    if(getString() == "AOK\r\n"){
        reset();
        return true;
    }else{
        return false;
    }
}

//Sets Device Mode
//Available Modes:
//0 - Slave Mode
//1 - Master Mode
//2 - Trigger Mode
//3 - Auto-Connect Master Mode
//4 - Auto-Connect DTR Mode
//5 - Auto-Connect Any Mode
//6 - Pairing Mode
//Default Mode: 4
bool RN41::setMode(int mode){
    enterCommandMode();
    if(mode < 0 or mode > 6){
        return false;
    }
    char buf[1];
    sprintf(buf,"SM,%d\r\n", mode);
    string msg = buf;
    sendString(msg);
    if(getString() == "AOK\r\n"){
        reset();
        return true;
    }else{
        return false;
    }
}

//Gets Bluetooth Address
//returns the 12 didgite MAC ID
string RN41::getBluetoothAddress(){
    enterCommandMode();
    sendString("GB\r\n");
    string result = getString();
    string address = result.substr(0, result.length() - 2);
    exitCommandMode();
    return address;
}

//Gets Connection Status
//0,0,0 = Not Connected
//1,0,0 = Connected
bool RN41::getConnectionStatus(){
    enterCommandMode();
    sendString("GK\r\n");
    if(getString() == "1,0,0\r\n"){
        exitCommandMode();
        return true;
    }else{
        exitCommandMode();
        return false;
    }
}

//Get The Device's Firmware Version
string RN41::getFirmwareVersion(){
    enterCommandMode();
    sendString("V\r\n");
    string version = getString();
    exitCommandMode();
    return version;
}

bool RN41::sendMessage(string message, char terminationChar){
    if(_commandMode){return false;}
    string msg = message + terminationChar;
    _RN41.printf("%s", msg);
    return true;
}

string RN41::recieveMessage(char terminationChar){
    return getString(terminationChar);
    if(_commandMode){return "*ERROR*";}
}

//Private Functions Below

//Enter Command Mode
bool RN41::enterCommandMode(){
    if(_commandMode == true){
        return true;
    }
    sendString("$$$");
    if(getString() == "CMD\r\n"){
        _commandMode = true;
        return true;
    }else{
        return false;
    }
}

//Exit Command Mode
bool RN41::exitCommandMode(){
    if(_commandMode == false){
        return true;
    }
    sendString("---\r\n");
    if(getString() == "END\r\n"){
        _commandMode = false;
        return true;
    }else{
        return false;
    }
}

void RN41::sendString(string msg){
    _RN41.printf("%s",msg);
}

bool RN41::readable(){
    if(_RN41.readable()){return true;}else{return false;}
}

string RN41::getString(){
    string msg = "";
    char prev = ' ';
    char curr = ' ';
    while(1){
        if(_RN41.readable()){
            prev = curr;
            curr = getChar();
            msg += curr;
            if(prev=='\r' and curr=='\n'){
                break;
            }
        }
    }

    return msg;
}

string RN41::getString(char terminationChar){
    string msg = "";
    char curr = ' ';
    while(1){
        if(_RN41.readable()){
            curr = getChar();
            msg += curr;
            if(curr == terminationChar){
                break;
            }
        }
    }
    return msg;
}

char RN41::getChar(){
    return _RN41.getc();
}
