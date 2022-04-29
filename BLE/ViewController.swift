//
//  ViewController.swift
//  BLE
//
//  Created by Ryota on 1/11/20.
//


import UIKit
import CoreBluetooth

let peripheralName                = "Envi Sensor"
let environmentalSensingServiceId = CBUUID.init(string: "181A")
let temperatureCharacteristicId   = CBUUID.init(string: "2A6E")
let humidityCharacteristicId      = CBUUID.init(string: "2A6F")

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet weak var tempLabel: UILabel!
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
            print ("1. scanning...")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name?.contains(peripheralName) == true {
            print ("2. found \(peripheralName), advertisement data: \(advertisementData)")
            connect(toPeripheral: peripheral)
        }
    }
    
    func connect(toPeripheral : CBPeripheral) {
        print ("3. about to connect to \(toPeripheral.name ?? "no name")")
        centralManager.stopScan()
        centralManager.connect(toPeripheral, options: nil)
        myPeripheral = toPeripheral
    }
    
    // // TODO LORIS: need it?
    // func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    //     central.scanForPeripherals(withServices: nil, options: nil)
    // }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print ("4. did connect to \(peripheral.name ?? "peripheral")")
        peripheral.discoverServices(nil)
        peripheral.delegate = self
        UserDefaults.standard.setValue(peripheral.identifier.uuidString, forKey: "PUUID")
        UserDefaults.standard.synchronize()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for svc in services {
                print("5. iterating service \(svc.uuid)")
                if svc.uuid == environmentalSensingServiceId {
                    peripheral.discoverCharacteristics(nil, for: svc)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let chars = service.characteristics {
            for char in chars {
                print ("5. found characteristic \(char.uuid.uuidString)")
                if char.uuid == temperatureCharacteristicId {
                    checkTemperature(curChar: char)
                }
            }
        }
    }
    
    func checkTemperature(curChar: CBCharacteristic) {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { (timer) in
            self.myPeripheral?.readValue(for: curChar)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let val = characteristic.value {
//            print (val)
           print ("6. characteristic value \([UInt8](val))")
            // if let string = String(bytes: val, encoding: .utf8) {
            //     print(string)
            //     tempLabel.text = String(string)
            // } else {
            //     print("not a valid UTF-8 sequence")
            // }
        }
    }
    
    var centralManager : CBCentralManager!
    var myPeripheral : CBPeripheral?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager.init(delegate: self, queue: nil)
    }
}
