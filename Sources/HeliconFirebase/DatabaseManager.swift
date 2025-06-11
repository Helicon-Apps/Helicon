//
//  File.swift
//  Helicon
//
//  Created by Andrii Proskurin on 08.06.25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import HeliconFoundation

@MainActor
public final class DatabaseManager: Service {
    
    public static let shared = DatabaseManager()
    
    private let firestoreReference = Firestore.firestore()
    
    private var currentUser: User? {
        Auth.auth().currentUser
    }
    
    private var currentUserUid: String? {
        currentUser?.uid
    }
}

public extension DatabaseManager {
    
    func get<T: DatabaseType>(ownedObjectsOfType objectType: T.Type, completion: @escaping ([T]) -> ()) {
        guard let uid = currentUserUid else { return completion([]) }
        firestoreReference.collection(objectType.endpoint)
            .whereField("ownerId", isEqualTo: uid)
            .getDocuments { [weak self] snapshot, error in
                self?.log("Found \(snapshot?.count ?? .zero) owned documents")
                self?.decode(objectsOfType: T.self, snapshot: snapshot, error: error, completion: completion)
        }
    }
    
    func get<T: DatabaseType>(ownedObjectsOfType objectType: T.Type, id: String, completion: @escaping ([T]) -> ()) {
        firestoreReference.collection(objectType.endpoint)
            .whereField("ownerId", isEqualTo: id)
            .getDocuments { [weak self] snapshot, error in
                self?.log("Found \(snapshot?.count ?? .zero) owned documents")
                self?.decode(objectsOfType: T.self, snapshot: snapshot, error: error, completion: completion)
            }
    }
    
    func get<T: DatabaseType>(allObjectsOfType objectType: T.Type, completion: @escaping ([T]) -> ()) {
        firestoreReference.collection(objectType.endpoint).getDocuments { [weak self] snapshot, error in
            self?.log("Found \(snapshot?.count ?? .zero) documents")
            self?.decode(objectsOfType: T.self, snapshot: snapshot, error: error, completion: completion)
        }
    }
    
    func get<T: DatabaseType>(objectOfType objectType: T.Type, withId objectId: String, completion: @escaping (T?) -> ()) {
        let errorPrefix = "Error while requesting \(objectType) with ID \(objectId)"
        firestoreReference.collection(objectType.endpoint).document(objectId).getDocument { document, error in
            if let error {
                self.log("⛔️ \(errorPrefix): \(error.localizedDescription)")
            }
            if let document, document.exists {
                guard let object = try? document.data(as: T.self) else {
                    completion(nil)
                    return
                }
                completion(object)
            } else {
                self.log("⛔️ \(errorPrefix): Document does not exist")
                completion(nil)
                return
            }
        }
    }
    
    func set<T: DatabaseType>(_ object: T, completion: (() -> Void)? = nil) {
        let errorPrefix = "Error while setting object of type \(T.self)"
        guard let userId = object.firestoreId else { completion?(); return }
        do {
            try self.firestoreReference
                .collection(T.self.endpoint)
                .document(userId)
                .setData(from: object) { error in
                    if let error {
                        self.log("⛔️ \(errorPrefix): \(error.localizedDescription)")
                    }
                    completion?()
                }
        } catch {
            completion?()
        }
    }
    
    func create<T: DatabaseType>(_ object: T, completion: (() -> Void)? = nil) {
        let errorPrefix = "Error while creating object of type \(T.self)"
        do {
            try self.firestoreReference
                .collection(T.self.endpoint)
                .addDocument(from: object) { error in
                    if let error {
                        self.log("⛔️ \(errorPrefix): \(error.localizedDescription)")
                    }
                    completion?()
                }
        } catch {
            completion?()
        }
    }
    
    func create<T: DatabaseType>(_ objects: [T], completion: (() -> Void)? = nil) {
        let dispatchGroup = DispatchGroup()
        for object in objects {
            dispatchGroup.enter()
            self.create(object) {
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion?()
        }
    }
    
    func delete<T: DatabaseType>(_ objects: [T], completion: (() -> ())? = nil) {
        let dispatchGroup = DispatchGroup()
        for id in objects.map({ $0.id }) {
            dispatchGroup.enter()
            firestoreReference.collection(T.endpoint).whereField("id", isEqualTo: id).getDocuments { snapshot, error in
                guard let snapshot, let id = snapshot.documents.first?.documentID else {
                    dispatchGroup.leave()
                    return
                }
                self.firestoreReference.collection(T.endpoint).document(id).delete { _ in
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion?()
        }
    }
    
    func observe<T: DatabaseType>(ownedObjectsOfType objectType: T.Type, completion: @escaping ([T]) -> ()) {
        guard let ownerId = currentUserUid else {
            return completion([])
        }
        let query = Firestore.firestore()
            .collection(objectType.endpoint)
            .whereField("ownerId", isEqualTo: ownerId)
        
        observe(query: query, completion: completion)
    }
    
    func decode<T: DatabaseType>(objectsOfType objectType: T.Type, snapshot: QuerySnapshot?, error: Error?, completion: @escaping ([T]) -> ()) {
        log("Decoding objects of type: \(objectType)")
        let errorPrefix = "Error while decoding objects of type \(T.self)"
        if let error {
            self.log("⛔️ \(errorPrefix): \(error.localizedDescription)")
        }
        guard let snapshot else {
            self.log("⛔️ \(errorPrefix): snapshot is nil.")
            return completion([])
        }
        var result = [T]()
        for document in snapshot.documents {
            if document.exists {
                guard let object = try? document.data(as: T.self) else {
                    continue
                }
                result.append(object)
            } else {
                self.log("⛔️ \(errorPrefix): Document \(document.documentID) does not exist.")
                continue
            }
        }
        completion(result)
    }
}

private extension DatabaseManager {
    
    func observe<T: DatabaseType>(query: Query, completion: @escaping ([T]) -> ()) {
        guard currentUserUid != nil else {
            return completion([])
        }
        query
            .addSnapshotListener { [weak self] snapshot, error in
                self?.decode(
                    objectsOfType: T.self,
                    snapshot: snapshot,
                    error: error,
                    completion: completion
                )
            }
    }
}
