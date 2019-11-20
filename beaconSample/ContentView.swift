//
//  ContentView.swift
//  beaconSample
//
//  Created by tanabe on 2019/11/20.
//  Copyright © 2019 Ryu Tanabe. All rights reserved.
//

import Combine
import SwiftUI
import CoreLocation

class BeaconDetector: NSObject, ObservableObject, CLLocationManagerDelegate {

    let willChange = PassthroughSubject<Void, Never>()
    
    var locationManager: CLLocationManager?
    @Published var lastDistance = CLProximity.unknown
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        let uuid = UUID(uuidString: "00000000-05AE-1001-B000-001C4D88CED9")
        let constraint = CLBeaconIdentityConstraint(uuid: uuid!)
        let beaconResion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: "MyBeacon")
        locationManager?.startMonitoring(for: beaconResion)
        locationManager?.startRangingBeacons(satisfying: constraint)
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if let beacon = beacons.first {
            update(distance: beacon.proximity)
        } else {
            update(distance: .unknown)
        }
    }
    
    func update(distance: CLProximity){
        lastDistance = distance
        willChange.send()
    }
}

struct BigText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font.system(size: 72))
            .frame(minWidth:0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

struct ContentView: View {
    @ObservedObject var detector = BeaconDetector()

    var body: some View {
        if detector.lastDistance == .immediate {
            return Text("IMMIDIATE")
                .modifier(BigText())
                .background(Color.red)
                .edgesIgnoringSafeArea(.all)
        } else if detector.lastDistance == .near {
            return Text("NEAR")
                .modifier(BigText())
                .background(Color.orange)
                .edgesIgnoringSafeArea(.all)
        } else if detector.lastDistance == .far {
            return Text("FAR")
                .modifier(BigText())
                .background(Color.green)
                .edgesIgnoringSafeArea(.all)
        } else {
            return Text("UNKNOWN")
                .modifier(BigText())
                .background(Color.gray)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
