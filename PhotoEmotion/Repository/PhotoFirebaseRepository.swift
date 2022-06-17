//
//  PhotoFirebaseRepository.swift
//  PhotoEmotion
//
//  Created by Yoshitaka Tanaka on 2022/05/30.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseStorage
import FirebaseFirestore

final class PhotoFirebaseRepository {
    static let shared = PhotoFirebaseRepository()

    private init() { }
}

extension PhotoFirebaseRepository: PhotoFirebaseRepositoryable {
    func fetch(emotionType: EmotionType) -> Single<[PhotoItem]> {
        return Single<[PhotoItem]>.create(subscribe: { single in
            let db = Firestore.firestore()
            db.collection("photoEmotion").whereField("tag", isEqualTo: emotionType.rawValue)
                .getDocuments() { (querySnapshot, error) in
                    if let error = error {
                        single(.failure(error as NSError))
                    } else {
                        var photoList = [PhotoItem]()
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            let photoItem = PhotoItem(id: data["id"] as! String, photoURL: data["photoURL"] as! String, tag: data["tag"] as! String)
                            photoList.append(photoItem)
                        }
                        single(.success(photoList))
                    }
                }
            return Disposables.create()
        })
    }

    func upload(image: UIImage, emotionType: EmotionType, imageId: UUID) -> Completable {
        return Completable.create { completable in
            let uploadImageData = image.jpegData(compressionQuality: 0.3)!
            // Get a reference to the storage service using the default Firebase App
            let storage = Storage.storage()
            // Create a root reference
            let storageRef = storage.reference()
            // Create a reference to 'images/___.jpg'
            let uploadImageRef = storageRef.child("images/\(imageId).jpg")

            // Upload the file to the path "images/___.jpg"
            _ = uploadImageRef.putData(uploadImageData, metadata: nil) { (metadata, error) in
                guard metadata != nil else {
                    completable(.error(error!))
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                // let size = metadata.size
                // You can also access to download URL after upload.
                uploadImageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        completable(.error(error!))
                        return
                    }
                    let photoItem = PhotoItem(id: imageId.uuidString, photoURL: downloadURL.absoluteString, tag: emotionType.rawValue)
                    let db = Firestore.firestore()
                    var ref: DocumentReference?
                    ref = db.collection("photoEmotion").addDocument(data: [
                        "id": photoItem.id,
                        "photoURL": photoItem.photoURL,
                        "tag": photoItem.tag
                    ]) { err in
                        if let err = err {
                            completable(.error(err))
                        } else {
                            completable(.completed)
                            print("Document added with ID: \(ref!.documentID)")
                        }
                    }
                }
            }
            return Disposables.create()
        }
    }
}
