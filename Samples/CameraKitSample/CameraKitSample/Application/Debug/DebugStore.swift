import Combine
import SCSDKCameraKit

/// Protocol for DebugStore to get around iOS 12 compilation warnings.
protocol DebugStoreProtocol {
    
    /// The API token to use for requests. Defaults to the Info.plist's API token.
    var apiToken: String { get set }
    
    /// The group IDs to use for lens fetching.
    var groupIDs: [String] { get set }
    
    /// Handles a deep link for configuration.
    /// - Parameter url: a configuration deep link, in the format of:
    /// camerakitsample://debug/apitoken/set/yourtokenhere
    /// camerakitsample://debug/groups/set/group1,group2,etc
    func processDeepLink(_ url: URL) 
}

@available(iOS 13.0, *)
class DebugStore: ObservableObject, DebugStoreProtocol {
    
    @Published var apiToken: String = ApplicationInfo.apiToken!
    @Published var groupIDs: [String] = []
    let defaultGroupIDs: [String]
    private var cancellable: Set<AnyCancellable> = []
    
    /// Initializes a debug store with a default set of Group IDs.
    /// - Parameter defaultGroupIDs: The default group IDs to populate the configuration screen with.
    init(defaultGroupIDs: [String]) {
        self.defaultGroupIDs = defaultGroupIDs
        assert(apiToken != "REPLACE-THIS-WITH-YOUR-OWN-APP-SPECIFIC-VALUE", "Please specify API Token in Info.plist (SCCameraKitAPIToken)")
        /*
           Note:
           If the App ID does not update properly, it may be due to UserDefaults caching an outdated value.
           To fix this, comment out the line that retrieves the token from UserDefaults:
           UserDefaults.standard.string(forKey: Constants.apiTokenDefaultsKey)
           This forces the subscriber to notice the change and update the saved value in UserDefaults.
        */
        apiToken = UserDefaults.standard.string(forKey: Constants.apiTokenDefaultsKey) ?? apiToken
        /*
            Note: 
            If you have issues with group ID updating properly, it maybe because the defaults is not updating correctly.
            You can check for a different result by just having groupIDs = defaultGroupIDs
            Last time I made lensGroupIDsDefaultsKey = "" ran and unran it and then the groups started showing up...
         */
        groupIDs = UserDefaults.standard.stringArray(forKey: Constants.lensGroupIDsDefaultsKey) ?? defaultGroupIDs
        $apiToken.sink { newValue in
            UserDefaults.standard.set(newValue, forKey: Constants.apiTokenDefaultsKey)
        }.store(in: &cancellable)
        $groupIDs.sink { newValue in
            UserDefaults.standard.set(newValue, forKey: Constants.lensGroupIDsDefaultsKey)
        }.store(in: &cancellable)
    }
    
    func processDeepLink(_ url: URL) {
        guard url.host?.lowercased() == "debug" else { return }
        let path = Array(url.pathComponents.dropFirst())
        guard path[1].localizedLowercase == "set" else { return }
        switch path.first?.localizedLowercase {
        case "apitoken":
            apiToken = path[2]
            exit(0)
        case "groups":
            var groups = path[2].split(separator: ",").map(String.init)
            if !groups.contains(SCCameraKitLensRepositoryBundledGroup) {
                groups.insert(SCCameraKitLensRepositoryBundledGroup, at: 0)
            }
            groupIDs = groups
        default:
            return
        }
    }
    
}

@available(iOS 13.0, *)
extension DebugStore {
    
    private enum Constants {
        static let lensGroupIDsDefaultsKey = "com.snap.camerakit.sample.lensGroupIDsKey"
        static let apiTokenDefaultsKey = "com.snap.camerakit.sample.apiTokenKey"
    }
    
}
