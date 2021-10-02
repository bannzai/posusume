import SwiftUI
import Combine
import MapKit

extension SpotsQuery.Data.Me.Spot: Identifiable {
    var coordinate: CLLocationCoordinate2D {
        .init()
    }
}

struct SpotMapView: View {
    @State var region: MKCoordinateRegion = defaultRegion
    @State var spots: [SpotsQuery.Data.Me.Spot] = []
    @State var isAddSpotPresented = false;
    @State var isLoading: Bool = false
    @State var error: Error?
    @StateObject var cache = Cache<SpotsQuery>()
    @StateObject var query = Query<SpotsQuery>()

    var body: some View {
        ZStack(alignment: .init(horizontal: .center, vertical: .bottom)) {
            Map(
                coordinateRegion: $region,
                showsUserLocation: true,
                annotationItems: spots,
                annotationContent: { spot in
                    MapAnnotation(coordinate: spot.coordinate) {
                        Text(spot.title)
                    }
                }
            )

            VStack(spacing: -32) {
                HStack(alignment: .bottom) {
                    Spacer()
                    Button {
                        isAddSpotPresented = true
                    } label: {
                        Image("addSpot")
                            .frame(width: 64, height: 64, alignment: .center)
                            .background(GradientColor.lower)
                            .clipShape(Circle())
                    }
                }
                .padding(.trailing, 20)

                ZStack {
                    BarnBottomSheet()
                    SpotList()
                    .frame(alignment: .bottom)
                    .padding()
                }
                .frame(width: UIScreen.main.bounds.width, height: BarnBottomSheet.height, alignment: .bottom)
            }
        }
        .sheet(
            isPresented: $isAddSpotPresented,
            content: {
                SpotPostView()
            }
        )
        .edgesIgnoringSafeArea(.all)
        .task {
            do {
                spots = try await cache(query: .init())?.me?.spots ?? []

                isLoading = spots.isEmpty
                spots = try await query(query: .init()).me?.spots ?? []
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
}


struct SpotMapView_Previews: PreviewProvider {
    static var previews: some View {
        SpotMapView()
    }
}
