//
//  PermissionManager.swift
//  Messages
//
//  Created by Hoàng Anh on 24/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit
import CoreLocation

final class PermissionManager {
    
    static func checkForLocation(_ manager: CLLocationManager, completion: @escaping (Bool) -> Void) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            completion(true)
        case .denied:
            let alert = UIAlertController(title: Text.accessDeniedTitle,
                                          message: Text.locationAccessDeniedMsg,
                                          preferredStyle: .alert)
            alert.addAction(title: Text.setting) {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            alert.addCancelAction()
            AppHelper.visibleViewController?.present(alert, animated: true, completion: nil)
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
}
