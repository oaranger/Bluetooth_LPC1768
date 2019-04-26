#include "mbed.h"
#include <string>

#ifndef RN41_H
#define RN41_H

class RN41 {

public:

    RN41(PinName tx, PinName rx);

    //Public Commands
    bool reset();

    //set commands
    bool setDeviceName(string name);
    bool setAuthenticationMode(int authMode);
    bool setMode(int mode); //done

    //get commands
    string getBluetoothAddress();
    bool getConnectionStatus();
    string getFirmwareVersion();

    //action commands
    bool connectToAddress(string address);

    //Message Mode
    bool sendMessage(string message, char terminationChar);
    string recieveMessage(char terminationChar);

private:
    //Vaiables
    Serial _RN41;
    int _baud;
    bool _commandMode;

    //Private Commands
    bool enterCommandMode();
    bool exitCommandMode();

    //Send Data
    void sendString(string msg);
    bool readable();
    string getString();
    string getString(char terminationChar);
    char getChar();
};

#endif
