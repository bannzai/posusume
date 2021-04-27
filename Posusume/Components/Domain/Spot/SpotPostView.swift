import SwiftUI
import ComposableArchitecture
import Combine
import CoreLocation
import FirebaseFirestore
import PhotosUI
import Photos

struct SpotPostState: Equatable {
    struct ViewState: Equatable {
        let context: Context
        var image: UIImage? = nil
        var title: String = ""
        var imageName: String? = nil

        var geoPoint: GeoPoint {
            switch context {
            case .create(let point):
                return point
            case .update(let spot):
                return spot.location
            }
        }

        var isNew: Bool {
            switch context {
            case .create:
                return true
            case .update:
                return false
            }
        }
        
        var error: EquatableError? = nil
        var submitButtonIsDisabled: Bool { image == nil || title.isEmpty }
    }

    var viewState: ViewState
    enum Context: Equatable {
        case create(GeoPoint)
        case update(Spot)
    }
    init(context: Context) {
        switch context {
        case .create:
            viewState = .init(context: context)
        case let .update(spot):
            viewState = .init(context: context, title: spot.title, imageName: spot.imageFileName)
        }
    }
    
    enum Presentation: Int, Identifiable {
        case photoLibrary
        case openSettingAlert
        case notPermissionAlert
        var id: Int { hashValue }
    }
    var presentationType: Presentation? = nil
    var photoLibrary: PhotoLibraryState = .init()
    
    func buildSpot() -> Spot {
        guard let imageName = viewState.imageName else {
            fatalError("unexpected not register image to remote storage")
        }
        switch viewState.context {
        case .create:
            return .init(
                location: viewState.geoPoint,
                title: viewState.title,
                imageFileName: imageName
            )
        case let .update(spot):
            return .init(
                location: viewState.geoPoint,
                title: viewState.title,
                imageFileName: imageName,
                createdDate: spot.createdDate
            )
        }
    }
}

enum SpotPostAction: Equatable {
    case post
    case create
    case update
    case posted(Result<Spot, EquatableError>)
    case dismiss
    case edited(title: String)
    case photoLibraryPrepare
    case photoLibraryAuthorized(Result<PHAuthorizationStatus, Never>)
    case presentPhotoLibrary
    case presentOpenSettingAlert
    case presentedOpenSetting
    case presentNotPermissionAlert
    case openSetting
    case confirmedNotPermission
    case cancelAlertAction
    case presentationTypeDidChanged(SpotPostState.Presentation?)
    case photoLibraryAction(PhotoLibraryAction)
}

struct SpotPostEnvironment {
    let me: Me
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let create: (DatabaseCollectionPathBuilder<Spot>, Spot) -> (AnyPublisher<Spot, Error>)
    let update: (DatabaseDocumentPathBuilder<Spot>, Spot) -> (AnyPublisher<Spot, Error>)
    let photoLibrary: PhotoLibrary
}

let spotPostReducer: Reducer<SpotPostState, SpotPostAction, SpotPostEnvironment> = .combine(
    photoLibraryReducer.pullback(
        state: \.photoLibrary,
        action: /SpotPostAction.photoLibraryAction,
        environment: { globalEnvironment in
            PhotoLibraryEnvironment(
                me: globalEnvironment.me,
                photoLibrary: photoLibrary,
                mainQueue: .main,
                pickerConfiguration: sharedPhotoLibraryConfiguration
            )
        }
    ),
    .init { state, action, environment in
        switch action {
        case .post:
            return state.viewState.isNew ? Effect(value: .create) : Effect(value: .update)
        case .create:
            guard case .create = state.viewState.context else {
                fatalError("unexpected pattern for context is not create. \(state.viewState.context)")
            }
            return environment.create(.userSpots(userID: environment.me.userID), state.buildSpot())
                .mapError(EquatableError.init(error:))
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(SpotPostAction.posted)
        case .update:
            guard case .update = state.viewState.context else {
                fatalError("unexpected pattern for context is not update. \(state.viewState.context)")
            }
            guard let identifier = state.buildSpot().id else {
                fatalError("unexpected state.buildSpot().id is nil when post for update. \(state)")
            }
            return environment.update(.userSpot(userID: environment.me.userID, spotID: identifier), state.buildSpot())
                .mapError(EquatableError.init(error:))
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(SpotPostAction.posted)
        case .posted(.success(let spot)):
            state.viewState.error = nil
            return Effect(value: .dismiss)
        case .posted(.failure(let error)):
            state.viewState.error = error
            return .none
        case .dismiss:
            return .none
        case let .edited(title):
            state.viewState.title = title
            return .none
        case .photoLibraryPrepare:
            switch environment.photoLibrary.prepareActionType() {
            case nil:
                return Effect(value: .presentPhotoLibrary)
            case .openSettingApp:
                return Effect(value: .presentOpenSettingAlert)
            case .requestAuthorization:
                return environment
                    .photoLibrary
                    .requestAuthorization()
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(SpotPostAction.photoLibraryAuthorized)
            }
        case let .photoLibraryAuthorized(.success(status)):
            switch status {
            case .authorized:
                return Effect(value: .presentPhotoLibrary)
            case .limited:
                return Effect(value: .presentPhotoLibrary)
            case .notDetermined:
                return Effect(value: .presentNotPermissionAlert)
            case .denied:
                return Effect(value: .presentNotPermissionAlert)
            case .restricted:
                return Effect(value: .presentNotPermissionAlert)
            @unknown default:
                assertionFailure("unexpected authorization status \(status):\(status.rawValue)")
                return .none
            }
        case .presentPhotoLibrary:
            state.presentationType = .photoLibrary
            return .none
        case .presentOpenSettingAlert:
            state.presentationType = .openSettingAlert
            return .none
        case .openSetting:
            guard UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!) else {
                assertionFailure("unexpected cannot open setting apps")
                return .none
            }
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            return Effect(value: .presentedOpenSetting)
        case .presentedOpenSetting:
            state.presentationType = nil
            return .none
        case .presentNotPermissionAlert:
            state.presentationType = .notPermissionAlert
            return .none
        case .confirmedNotPermission:
            state.presentationType = nil
            return .none
        case .cancelAlertAction:
            state.presentationType = nil
            return .none
        case let .presentationTypeDidChanged(presentationType):
            state.presentationType = presentationType
            return .none
        case let .photoLibraryAction(action):
            switch action {
            case let .selected(photoLibraryResult):
                state.viewState.image = photoLibraryResult.image
                return .none
            case .selectError:
                return .none
            case let .end(photoLibraryResult):
                state.presentationType = nil
                return .none
            case .dismiss:
                state.presentationType = nil
                return .none
            }
        }
    }
)


struct SpotPostView: View {
    let store: Store<SpotPostState, SpotPostAction>
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ZStack(alignment: .top) {
                    Color.screenBackground.edgesIgnoringSafeArea(.all)
                    VStack(spacing: 18) {
                        Spacer().frame(height: 16)
                        Button (action: {
                            viewStore.send(.photoLibraryPrepare)
                        },
                        label: {
                            if let value = viewStore.state.photoLibrary.result {
                                Image(uiImage: value.image)
                                    .resizable()
                                    .frame(width: UIScreen.main.bounds.width - 40)
                                    .aspectRatio(3 / 4, contentMode: .fit)
                                    .clipped()
                                    .padding(.horizontal, 20)
                            } else {
                                VStack {
                                    Image("anyPicture")
                                        .resizable()
                                        .renderingMode(.template)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40, height: 40)
                                    Text("画像を選択")
                                        .font(.footnote)
                                }
                                .foregroundColor(.placeholder)
                                .frame(maxWidth: .infinity, minHeight: 160, maxHeight: 160)
                                .background(Color.white)
                                .padding(.horizontal, 20)
                            }
                        })
                        .buttonStyle(PlainButtonStyle())

                        VStack(alignment: .leading) {
                            Text("タイトル")
                                .font(.subheadline)
                            TextField("ポスターのタイトル", text: viewStore.binding(get: \.viewState.title, send: SpotPostAction.edited(title:)))
                                .font(.caption)
                                .textFieldStyle(PlainTextFieldStyle())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 16)
                                .background(Color.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.leading, 20)
                        
                        Spacer()

                        Button(action: {
                                
                            },
                            label: {
                            Text("保存")
                                .foregroundColor(.white)
                                .font(.body)
                                .fontWeight(.medium)
                        })
                        .disabled(viewStore.viewState.submitButtonIsDisabled)
                        .frame(width: 200, height: 44, alignment: .center)
                        .background(viewStore.viewState.submitButtonIsDisabled ? Color.disabled.gradient : GradientColor.barn)

                        Spacer().frame(height: 32)
                    }
                }
                .navigationBarItems(
                    leading:
                        Button(action: {
                            viewStore.send(.dismiss)
                        }) {
                            Image(systemName: "xmark")
                                .renderingMode(.template)
                                .foregroundColor(.appPrimary)
                        }
                )
                .navigationBarTitle("", displayMode: .inline)
            }
            .sheet(
                item: viewStore.binding(
                    get: \.presentationType,
                    send: { .presentationTypeDidChanged($0) }
                ),
                content: { type -> AnyView in
                    switch type {
                    case .photoLibrary:
                        return AnyView(
                            PhotoLibraryViewConnector(
                                store: store.scope(
                                    state: \.photoLibrary,
                                    action: { .photoLibraryAction($0) }
                                )
                            )
                        )
                    case .openSettingAlert:
                        return AnyView(EmptyView())
                    case .notPermissionAlert:
                        return AnyView(EmptyView())
                    }
                }
            )
        }
    }
    
}

struct SpotListView_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            SpotPostView(
                store: .init(
                    initialState: .init(context: .create(spot.location)),
                    reducer: spotPostReducer,
                    environment: SpotPostEnvironment(
                        me: .init(id: .init(rawValue: "1")),
                        mainQueue: .main,
                        create: { (_,_) in Future(value: spot).eraseToAnyPublisher() },
                        update: { (_, _) in Future(value: spot).eraseToAnyPublisher() },
                        photoLibrary: MockPhotoLibrary()
                    )
                )
            )
            SpotPostView(
                store: .init(
                    initialState: {
                        var state = SpotPostState(context: .update(spot2))
                        state.photoLibrary = .init()
                        state.photoLibrary.result = .init(
                            image: UIImage(named: "hanahana")!,
                            location: nil,
                            takeDate: .init()
                        )
                        
                        state.viewState.image = state.photoLibrary.result?.image
                        return state
                    }(),
                    reducer: spotPostReducer,
                    environment: SpotPostEnvironment(
                        me: .init(id: .init(rawValue: "1")),
                        mainQueue: .main,
                        create: { (_,_) in Future(value: spot2).eraseToAnyPublisher() },
                        update: { (_, _) in Future(value: spot2).eraseToAnyPublisher() },
                        photoLibrary: MockPhotoLibrary()
                    )
                )
            )
        }
    }
    static let spot = Spot(location: .init(latitude: 10, longitude: 10), title: "", imageFileName: "")
    static let spot2 = Spot(location: .init(latitude: 10, longitude: 10), title: "title", imageFileName: "")
}
