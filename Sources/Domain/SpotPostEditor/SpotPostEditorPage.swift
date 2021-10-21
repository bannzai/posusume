import Foundation
import SwiftUI

public struct SpotPostEditorPage: View {
    let image: UIImage
    init(image: UIImage) {
        self.image = image
    }

    @State var elements: [SpotPostEditorEffectCoverElementValue] = []
    @State var selectedElementID: SpotPostEditorEffectCoverElementValue.ID?
    @FocusState var elementTextFieldIsFocused: Bool

    public var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .clipped()

                    SpotPostEditorEffectCover(
                        elements: $elements,
                        selectedElementID: $selectedElementID,
                        elementTextFieldIsFocused: $elementTextFieldIsFocused
                    )
                }.spotImageFrame(width: geometry.size.width)
            }
            .onTapGesture {
                elementTextFieldIsFocused = false
                selectedElementID = nil
            }

            ScrollView(.horizontal) {
                HStack {
                    if let selectedElementIndex = selectedElementIndex {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 32))
                            .frame(width: 40, height: 40)
                            .onTapGesture {
                                elements.remove(at: selectedElementIndex)
                            }

                        Image(systemName: "bold")
                            .font(.system(size: 32))
                            .frame(width: 40, height: 40)
                            .onTapGesture {
                                elements[selectedElementIndex].isBold.toggle()
                            }

                        ColorPicker(elements[selectedElementIndex].text, selection: .init(get: { elements[selectedElementIndex].textColor }, set: {
                            elements[selectedElementIndex].textColor = $0
                        })).frame(width: 40, height: 40)
                    } else {
                        Image(systemName: "textformat")
                            .font(.system(size: 32))
                            .frame(width: 40, height: 40)
                            .onTapGesture {
                                let element = SpotPostEditorEffectCoverElementValue(text: "Hello, world")
                                elements.append(element)
                                selectedElementID = element.id
                            }
                    }
                }
            }
        }
        .padding()
    }

    private var selectedElementIndex: Int? {
        elements.firstIndex(where: { $0.id == selectedElementID })
    }
}


struct SpotPostEditorPage_Previews: PreviewProvider {
    static var previews: some View {
        SpotPostEditorPage(image: .init(named: "IMG_0005")!)
    }
}
