import Foundation
import SwiftUI

struct SpotPostImage: View {
    @Environment(\.geocoder) var geocoder

    @State var showsActionSheet: Bool = false
    @State var error: Error?

    let image: UIImage?
    let takenPhoto: ((UIImage) -> Void)
    let selectedPhoto: (PhotoLibraryResult) -> Void

    var body: some View {
        Button (
            action: {
                showsActionSheet = true
            },
            label: {
                if let image = image {
                    GeometryReader { reader in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: reader.size.width, height: reader.size.width / 4 * 3)
                            .clipped()
                    }
                } else {
                    VStack {
                        Spacer()
                        Image("anyPicture")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                        Text("画像を選択")
                            .font(.footnote)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .aspectRatio(.init(width: 4, height: 3), contentMode: .fit)
                    .foregroundColor(.placeholder)
                    .background(Color.white)
                }
            })
            .buttonStyle(PlainButtonStyle())
            .adaptImagePickEvent(
                showsActionSheet: $showsActionSheet,
                error: $error,
                takenPhoto: takenPhoto,
                selectedPhoto: selectedPhoto
            )
            .handle(error: $error)
    }
}


private struct Preview: PreviewProvider {
    static var previews: some View {
        SpotPostImage(image: nil, takenPhoto: { _ in }, selectedPhoto: { _ in })
    }
}
