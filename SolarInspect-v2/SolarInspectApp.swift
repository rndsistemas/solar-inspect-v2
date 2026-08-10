import SwiftUI

@main
struct SolarInspectApp: App {
    @StateObject private var data = SolarData()
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(data)
        }
    }
}
