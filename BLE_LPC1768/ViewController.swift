
import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
  
    @IBOutlet weak var imgBluetoothStatus: UIImageView!
    @IBOutlet weak var positionSlider: UISlider!
   
    @IBOutlet weak var led1: UISwitch!
    @IBOutlet weak var led2: UISwitch!
    @IBOutlet weak var led3: UISwitch!
    @IBOutlet weak var led4: UISwitch!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tempLabel: UILabel!
    
    var alertTemperatureDone = false;

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegate
        textField.delegate = self
        
        // Initialize
        led1.isOn = false
        led2.isOn = false
        led3.isOn = false
        led4.isOn = false
        positionSlider.setValue(0, animated: true)
 
        // Initialize slider
        positionSlider.setThumbImage(UIImage(named: "triangle"), for: UIControlState())
        positionSlider.minimumValue = 0.0
        positionSlider.maximumValue = 1.0
        positionSlider.isContinuous = false
        
        let thumbImageNormal = UIImage(named: "SliderThumb-Normal")!
        positionSlider.setThumbImage(thumbImageNormal, for: .normal)
        
        let thumbImageHighlighted = UIImage(named: "SliderThumb-Highlighted")!
        positionSlider.setThumbImage(thumbImageHighlighted, for: .highlighted)
        
        let insets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        
        let trackLeftImage = UIImage(named: "SliderTrackLeft")!
        let trackLeftResizable =
            trackLeftImage.resizableImage(withCapInsets: insets)
        positionSlider.setMinimumTrackImage(trackLeftResizable, for: .normal)
        
        let trackRightImage = UIImage(named: "SliderTrackRight")!
        let trackRightResizable =
            trackRightImage.resizableImage(withCapInsets: insets)
        positionSlider.setMaximumTrackImage(trackRightResizable, for: .normal)

        
        // Start the Bluetooth discovery process
        _ = btDiscoverySharedInstance
        
        // Watch Bluetooth connection
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.connectionChanged(_:)), name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.methodOfReceivedNotification(notification:)), name: Notification.Name("NotificationIdentifier"), object: nil)
    }
    
    // Show alert on high temperature measured
    func showTemperatureAlert() {
        let message = "The temperature is high now"
        
        let alert = UIAlertController(title: "Alert !",
                                      message: message,    // changed
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK",          // changed
            style: .default,
            handler: nil)
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
   
    // Update Temperature Label
    func methodOfReceivedNotification(notification: Notification){
        if let bleService = btDiscoverySharedInstance.bleService {
            let currentTemperature = bleService.rxTemperatureDataRead
            DispatchQueue.main.async {
                self.tempLabel.text = "\(String(describing: currentTemperature)) C"
                if(currentTemperature > 29.0 && !self.alertTemperatureDone) {
                    self.showTemperatureAlert()
                    self.alertTemperatureDone = true
                } else if (currentTemperature < 28.5) {
                    self.alertTemperatureDone = false
                }
            }
        }
    }
    
    // Send Button Clicked
    @IBAction func sendButton(_ sender: Any) {
        sendStr(textField.text!)
        textField.resignFirstResponder()
    }
    
    @IBAction func clearButton(_ sender: Any) {
        textField.text = ""
        sendStr(" ")
    }
    @IBAction func positionSliderChanged(_ sender: UISlider) {
        let data = "PWM-"+String(sender.value)
        print("Slider \(data)")
        sendStr(data)
    }
    
    // Toggole LED
    @IBAction func led1Changed(_ sender: Any) {
        if led1.isOn {
            sendStr("LED1-ON")
        } else {
            sendStr("LED1-OFF")
        }
    }
    
    // Toggole LED
    @IBAction func led2Changed(_ sender: Any) {
        if led2.isOn {
            sendStr("LED2-ON")
        } else {
            sendStr("LED2-OFF")
        }
    }
    
    // Toggole LED
    @IBAction func led3Changed(_ sender: Any) {
        if led3.isOn {
            sendStr("LED3-ON")
        } else {
            sendStr("LED3-OFF")
        }
    }
    
    // Toggole LED
    @IBAction func led4Changed(_ sender: Any) {
        if led4.isOn {
            sendStr("LED4-ON")
        } else {
            sendStr("LED4-OFF")
        }
    }
    
    func sendData(_ data: UInt8) {
        if let bleService = btDiscoverySharedInstance.bleService {
            bleService.writeData(data)
        }
    }
    
    func sendStr(_ string: String) {
        if let bleService = btDiscoverySharedInstance.bleService {
            bleService.writeStr(string)
        }
    }
    
    // Hide keyboard after done typing
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    deinit {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
    }

    func connectionChanged(_ notification: Notification) {
        // Connection status changed. Indicate on GUI.
        let userInfo = (notification as NSNotification).userInfo as! [String: Bool]
        
        DispatchQueue.main.async(execute: {
          // Set image based on connection status
          if let isConnected: Bool = userInfo["isConnected"] {
            if isConnected {
              self.imgBluetoothStatus.image = UIImage(named: "Bluetooth_Connected")
            } else {
              self.imgBluetoothStatus.image = UIImage(named: "Bluetooth_Disconnected")
            }
          }
        });
    }
}

