//
//  AVURLAsset+ThumbnailImage.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-13.
//

import Foundation
import AVFoundation
import Flow
import UIKit

extension AVURLAsset {
    enum ThumbnailImageError: Error {
        case failed
    }

    var thumbnailImage: Future<UIImage> {
        Future(on: .background) { completion in
            let imgGenerator = AVAssetImageGenerator(asset: self)
            imgGenerator.appliesPreferredTrackTransform = true

            guard let cgImage = try? imgGenerator.copyCGImage(at: self.duration, actualTime: nil) else {
                completion(.failure(ThumbnailImageError.failed))
                return NilDisposer()
            }

            completion(.success(UIImage(cgImage: cgImage)))

            return NilDisposer()
        }
    }
}
