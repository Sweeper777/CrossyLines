import GoogleMobileAds

class AdHelper {
    static func getInterstitial(delegate: GADInterstitialDelegate) -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: adUnitID)
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        interstitial.delegate = delegate
        interstitial.load(request)
        return interstitial
    }
}
