//
//  Bundle+Extension.swift
//  Dreamio
//
//  Created by Bold Lion on 18.04.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    var releaseVersionNumberPretty: String {
        return "v\(releaseVersionNumber ?? "1.0.0")"
    }
}

// usage: someLabel.text = Bundle.main.releaseVersionNumberPretty
