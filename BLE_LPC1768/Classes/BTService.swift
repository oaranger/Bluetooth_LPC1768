
import Foundation
import CoreBluetooth

/* Services & Characteristics UUIDs */
let BLEServiceChangedStatusNotification = "kBLEServiceChangedStatusNotification"
let uartServiceUUID = CBUUID(string:"6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
let txCharacteristicUUID = CBUUID(string:"6e400002-b5a3-f393-e0a9-e50e24dcca9e")
let rxCharacteristicUUID = CBUUID(string:"6e400003-b5a3-f393-e0a9-e50e24dcca9e")
let dfuServiceUUID = CBUUID(string:"00001530-1212-efde-1523-785feabcd123")

class BTService: NSObject, CBPeripheralDelegate {
    
    var peripheral: CBPeripheral?
    var positionCharacteristic: CBCharacteristic?
    var txCharacteristic: CBCharacteristic?
    var rxCharacteristic: CBCharacteristic?
    var rxTemperatureDataRead: Float = 28.0
    var rxByteData: [UInt8]?
    var firstRead = true
  
    init(initWithPeripheral peripheral: CBPeripheral) {
        super.init()
        self.peripheral = peripheral
        self.peripheral?.delegate = self
    }
  
    deinit {
        self.reset()
    }
  
    func startDiscoveringServices() {
        self.peripheral?.discoverServices([uartServiceUUID])
    }
  
    func reset() {
        if peripheral != nil {
            peripheral = nil
        }

        // Deallocating therefore send notification
        self.sendBTServiceNotificationWithIsBluetoothConnected(false)
    }
  
  // Mark: - CBPeripheralDelegate
  
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        print("Entering didDiscoverServices \(String(describing: peripheral.services)) and error \(String(describing: error))")

        if (peripheral != self.peripheral) {
          // Wrong Peripheral
            print("Wrong Peripheral")
            return
        }
    
        if (error != nil) {
            return
        }
        
        if ((peripheral.services == nil) || (peripheral.services!.count == 0)) {
            return
        }
        
        for service in peripheral.services! {
            print("Services UUID \(service.uuid)")
            if service.uuid == uartServiceUUID {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
  
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("didDiscoverCharacteristicsFor Service \(service) \(String(describing: service.characteristics))")
        
        if (peripheral != self.peripheral) {
          // Wrong Peripheral
            return
        }

        if (error != nil) {
            return
        }

        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print("Characteristic \(characteristic)")
                if characteristic.uuid == rxCharacteristicUUID {
                    self.rxCharacteristic = characteristic
                    peripheral.setNotifyValue(true, for: characteristic)

                    // Send notification that Bluetooth is connected and all required characteristics are discovered
                    self.sendBTServiceNotificationWithIsBluetoothConnected(true)
                }

                if characteristic.uuid == txCharacteristicUUID {
                    self.txCharacteristic = (characteristic)

                    // Send notification that Bluetooth is connected and all required characteristics are discovered
                    self.sendBTServiceNotificationWithIsBluetoothConnected(true)
                }
            }
        }
    }
  
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        if error != nil {
            print("ERROR ON UPDATING VALUE FOR CHARACTERISTIC: \(characteristic) - \(String(describing: error?.localizedDescription))")
            return
        }
        
        // Another option to read data
//        let rxData = characteristic.value
//        if let rxData = rxData {
//            let numberOfBytes = rxData.count
//            var rxByteArray = [UInt8](repeating: 0, count: numberOfBytes)
//            (rxData as NSData).getBytes(&rxByteArray, length: numberOfBytes)
//            print(rxByteArray)
//            rxByteData = rxByteArray
//        }

        // extract the data from the characteristic's value property and display the value based on the characteristic type
        if let dataString = NSString.init(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue) as String? {
            print("didUpdateValueFor characteristic string data read \(dataString)")
            let floatRead = (dataString as NSString).floatValue
            if characteristic.value?.count == 5 {
                rxTemperatureDataRead = floatRead
                NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
            }
        }
    }
    
  // Mark: - Private

    func writeData(_ data: UInt8) {
        
        // Sending data
        if let txCharacteristic = self.txCharacteristic {
            let data = Data(bytes: [data])
            self.peripheral?.writeValue(data, for: txCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
        }
    }
    
    func writeStr(_ string: String) {
        
        // Sending string
        if let txCharacteristic = self.txCharacteristic {
            let data = string.data(using: String.Encoding.utf8)
            self.peripheral?.writeValue(data!, for: txCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
        }
    }
  
    func sendBTServiceNotificationWithIsBluetoothConnected(_ isBluetoothConnected: Bool) {
        
        let connectionDetails = ["isConnected": isBluetoothConnected]
        NotificationCenter.default.post(name: Notification.Name(rawValue: BLEServiceChangedStatusNotification), object: self, userInfo: connectionDetails)
    }
}
