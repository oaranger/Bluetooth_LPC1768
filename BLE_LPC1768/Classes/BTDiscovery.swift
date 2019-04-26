
import Foundation
import CoreBluetooth

let btDiscoverySharedInstance = BTDiscovery();

class BTDiscovery: NSObject, CBCentralManagerDelegate {
  
    fileprivate var centralManager: CBCentralManager?
    fileprivate var peripheralBLE: CBPeripheral?
  
    override init() {
        super.init()
        let centralQueue = DispatchQueue(label: "com.raywenderlich", attributes: [])
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    }
  
    func startScanning() {
        if let central = centralManager {
            central.scanForPeripherals(withServices: nil, options: nil)
        }
    }
  
    var bleService: BTService? {
        didSet {
            if let service = self.bleService {
                service.startDiscoveringServices()
            }
        }
    }
  
    // MARK: - CBCentralManagerDelegate
  
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // Be sure to retain the peripheral or it will fail during connection.
        print("centralManager didDiscoverPeripheral - CBAdvertisementDataLocalNameKey is \"\(CBAdvertisementDataLocalNameKey)\"")

        // Retrieve the peripheral name from the advertisement data using the "kCBAdvDataLocalName" key
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            print("NEXT PERIPHERAL NAME: \(peripheralName)")
            print("NEXT PERIPHERAL UUID: \(peripheral.identifier.uuidString)")
            print("NEXT PERIPHERAL UUID: \(peripheral.identifier.uuid)")
        }
        
        // Validate peripheral information
        if ((peripheral.name == nil) || (peripheral.name == "")) {
            return
        }
        
        print("peripheral state \(String(describing: self.peripheralBLE?.state))")
        
        // If not already connected to a peripheral, then connect to this one
        if ((self.peripheralBLE == nil) || (self.peripheralBLE?.state == CBPeripheralState.disconnected)) {
            
            // Retain the peripheral before trying to connect
            self.peripheralBLE = peripheral

            print("Did discovered peripherals 2")

            // Reset service
            self.bleService = nil

            // Connect to peripheral
            central.connect(peripheral, options: nil)
        }
    }
  
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {

        // Create new service class
        if (peripheral == self.peripheralBLE) {
            print("Connected to peripheral \(peripheral)")
            self.bleService = BTService(initWithPeripheral: peripheral)
            peripheral.discoverServices(nil)
        }

        // Stop scanning for new devices
        central.stopScan()
    }
  
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {

        print("DidDisconnectPeripheral \(peripheral)")

        // See if it was our peripheral that disconnected
        if (peripheral == self.peripheralBLE) {
          self.bleService = nil;
          self.peripheralBLE = nil;
        }

        // Start scanning for new devices
        self.startScanning()
    }
  
  // MARK: - Private
  
    func clearDevices() {
        self.bleService = nil
        self.peripheralBLE = nil
    }
  
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
            case .poweredOff:
                self.clearDevices()
            
            case .unauthorized:
                // Indicate to user that the iOS device does not support BLE.
                break
            
            case .unknown:
                // Wait for another event
                break
            
            case .poweredOn:
                self.startScanning()
            
            case .resetting:
                self.clearDevices()
            
            case .unsupported:
                break
        }
    }
}
