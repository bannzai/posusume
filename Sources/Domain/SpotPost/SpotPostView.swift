import SwiftUI
import Combine
import CoreLocation
import PhotosUI
import Photos
import MapKit
import FirebaseStorageSwift

struct SpotPostView: View {
    @Environment(\.presentationMode) var presentationMode

    @State var error: Error?
    @State var image: UIImage?
    @State var title: String = ""
    @State var geoPoint: CLLocationCoordinate2D?

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    SpotPostImage(image: $image)
                    SpotPostTitle(title: $title)
                    SpotPostGeoPoint(geoPoint: $geoPoint)
                    Spacer()
                    SpotPostSubmitButton(
                        image: $image,
                        title: $title,
                        geoPoint: $geoPoint
                    )
                    Spacer().frame(height: 32)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(Color.screenBackground.edgesIgnoringSafeArea(.all))
            .navigationBarItems(
                leading:
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .renderingMode(.template)
                            .foregroundColor(.appPrimary)
                    }
            )
            .navigationBarTitle("", displayMode: .inline)
        }
    }


}

struct SpotListView_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            SpotPostView()
        }
    }
}
