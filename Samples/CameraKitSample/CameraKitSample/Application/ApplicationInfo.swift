//  Copyright Snap Inc. All rights reserved.
//  CameraKitSample

import Foundation

struct ApplicationInfo {
    private struct Constants {
        static let buildKey = "CFBundleVersion"
        static let versionKey = "CFBundleShortVersionString"
        static let apiToken = "SCCameraKitAPIToken"
        static let groupId = "LensGroupId"
    }
    
    static var build: String? {
        return Bundle.main.infoDictionary?[Constants.buildKey] as? String
    }
    
    static var version: String? {
        return Bundle.main.infoDictionary?[Constants.versionKey] as? String
    }
    
    static var apiToken: String? {
        return Bundle.main.infoDictionary?[Constants.apiToken] as? String
    }
    
    static var groupId: String? {
        return Bundle.main.infoDictionary?[Constants.groupId] as? String
    }
}
