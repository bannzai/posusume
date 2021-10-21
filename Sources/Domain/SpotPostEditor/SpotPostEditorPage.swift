import Foundation
import SwiftUI

public struct SpotPostEditorPage: View {
    let image: UIImage
    init(image: UIImage) {
        self.image = image
    }

    @State var elements: [SpotPostEditorEffectCoverElementValue] = []
    @State var selectedElement: SpotPostEditorEffectCoverElementValue?
    @FocusState var elementTextFieldIsFocused: Bool

    public var body: some View {
        VStack {
            ZStack {
                GeometryReader { geometry in
                    Image(uiImage: image)
                        .resizable()
                        .spotImageFrame(width: geometry.size.width)
                        .clipped()
                }
                SpotPostEditorEffectCover(
                    elements: $elements,
                    selected: $selectedElement,
                    elementTextFieldIsFocused: $elementTextFieldIsFocused
                )
            }
            .onTapGesture {
                elementTextFieldIsFocused = false
                selectedElement = nil
            }

            ScrollView(.horizontal) {
                HStack {
                    Image(systemName: "textformat")
                        .font(.system(size: 32))
                        .onTapGesture {
                            let element = SpotPostEditorEffectCoverElementValue(text: "Hello, world")
                            elements.append(element)
                            selectedElement = element
                        }
                }
            }
        }
        .padding()
    }
}


struct SpotPostEditorPage_Previews: PreviewProvider {
    static var previews: some View {
        SpotPostEditorPage(image: .init(named: "IMG_0005")!)
    }
}
