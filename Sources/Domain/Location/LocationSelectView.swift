import SwiftUI
import Combine
import MapKit
import CoreLocation

struct LocationSelectView: View {
    @Environment(\.locationManager) var locationManager
    @Environment(\.geocoder) var geocoder

    @State var error: Error?
    @State var searchText: String = ""
    @State var places: [Placemark] = []
    @State var userLocation: CLLocation?
    @State var presentingAlertType: AlertType?

    @Binding var selectedPlacemark: Placemark?

    enum AlertType: Int, Identifiable {
        case openSetting
        case choseNoPermission

        var id: Self { self }
    }

    var body: some View {
        VStack(alignment: .leading) {
            List {
                HStack {
                    Image(systemName: "location.circle")
                    Text("現在地を選択")
                        .font(.headline)
                        .onTapGesture {
                            switch locationManager.prepareActionType() {
                            case nil:
                                updateUserLocation()
                            case .openSettingApp:
                                presentingAlertType = .openSetting
                            case .requiredAutentification:
                                requestAuthentification()
                            }
                        }
                }
                ForEach(places) { mark in
                    HStack {
                        Text(mark.formattedLocationAddress())
                            .font(.footnote)
                            .onTapGesture {
                                selectedPlacemark = mark
                            }
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("住所を入力"))
        .onSubmit(of: .search) {
            Task {
                do {
                    places = try await geocoder.geocode(address: searchText)
                } catch {
                    self.error = error
                }
            }
        }
        .navigationTitle(Text("撮影場所を選択"))
        .handle(error: $error)
        .alert(item: $presentingAlertType, content: { alertType in
            switch alertType {
            case .openSetting:
                return Alert(
                    title: Text("位置情報を取得できません"),
                    message: Text("位置情報の取得が許可されていません。設定アプリから許可をしてください"),
                    primaryButton: .default(Text("設定を開く"), action: openSetting),
                    secondaryButton: .cancel()
                )
            case .choseNoPermission:
                return Alert(
                    title: Text("位置情報の取得を拒否しました"),
                    message: Text("位置情報の取得が拒否されました。操作を続ける場合は設定アプリから許可をしてください"),
                    primaryButton: .default(Text("設定を開く"), action: openSetting),
                    secondaryButton: .cancel()
                )
            }
        })
    }

    private func updateUserLocation() {
        Task {
            do {
                userLocation = try await locationManager.userLocation()
            } catch {
                self.error = error
            }
        }
    }

    private func requestAuthentification() {
        Task {
            let status = await locationManager.requestAuthorization()
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                return
            case .notDetermined:
                return
            case .denied:
                presentingAlertType = .choseNoPermission
            case .restricted:
                presentingAlertType = .openSetting
            @unknown default:
                assertionFailure("unexpected authorization status \(status):\(status.rawValue)")
            }
        }
    }
}

private struct LocationSelectView_Previews: PreviewProvider {
    @State static var place: Placemark?
    static var previews: some View {
        Group {
            LocationSelectView(selectedPlacemark: $place)
        }
    }
}

private func openSetting() {
    let settingURL = URL(string: UIApplication.openSettingsURLString)!
    if UIApplication.shared.canOpenURL(settingURL) {
        UIApplication.shared.open(settingURL)
    }
}
