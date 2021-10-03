import Foundation
import Combine
import UIKit

@MainActor
public final class Upload: ObservableObject {
    @Published public private(set) var isProcessing = false

    internal func upload(path: CloudStorage.PathKind, image: UIImage) async throws -> CloudStorage.Uploaded {
        isProcessing = true
        defer {
            isProcessing = false
        }

        return try await CloudStorage.shared.upload(path: path, image: image)
    }

    public func callAsFunction(path: CloudStorage.PathKind, image: UIImage) async throws -> CloudStorage.Uploaded {
        try await upload(path: path, image: image)
    }
}
