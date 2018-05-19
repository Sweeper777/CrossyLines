import UIKit
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UserSettings.loadUserSettings()
        GADMobileAds.configure(withApplicationID: appID)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        UserSettings.saveUserSettings()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        guard let vc = window?.rootViewController as? ViewController else { return }
        UserDefaults.standard.set(try? vc.graph.toJSON().rawData(), forKey: "lastPlayed")
        UserDefaults.standard.set(try? vc.solutionGraph.toJSON().rawData(), forKey: "lastPlayedSolution")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        UserSettings.loadUserSettings()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

