//
//  APIError.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/06/02.
//

import Foundation

enum APIError: Error {
    case customError(message: String)
    case imageUploadError

    var message: String {
        switch self {
        case .customError(let message):
             return message
        case .imageUploadError:
            return R.string.localizable.error_image_upload_failed()
        }
    }
}
