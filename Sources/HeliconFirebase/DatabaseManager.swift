
import Foundation
import FirebaseAuth
import FirebaseFirestore

/// A high-level generic Firestore wrapper that provides type-safe CRUD,
/// querying, and real-time observation for models conforming to `DatabaseType`.
///
/// `DatabaseManager` centralizes all database access logic and exposes both:
/// - completion-handler APIs
/// - async/await APIs
///
/// The collection path is automatically resolved using `DatabaseType.endpoint`,
/// and documents are decoded directly into strongly typed models.
///
/// This class is `Sendable` and safe to use across concurrency domains.
///
/// ## Overview
///
/// Typical workflow:
/// 1. Define a model conforming to `DatabaseType`
/// 2. Use the shared manager to fetch, observe, create, update, or delete
///
/// ## Quick Example
///
/// ```swift
/// struct Project: DatabaseType, Codable {
///     static let endpoint = "projects"
///     var id: String?
///     var ownerId: String
///     var name: String
/// }
///
/// let manager = DatabaseManager.shared
///
/// // fetch
/// let projects: [Project] = try await manager.getOwned()
///
/// // create
/// try await manager.create(Project(id: nil, ownerId: uid, name: "Trip"))
///
/// // update
/// try await manager.setField("name", ofObjectWithId: "abc", ofType: Project.self, to: "Updated")
///
/// // delete
/// try await manager.delete(projects.first!)
/// ```
///
/// Access via ``DatabaseManager/shared``.
public final class DatabaseManager: Sendable {

    // MARK: - Shared

    /// Shared singleton instance of `DatabaseManager`.
    public static let shared = DatabaseManager()

    /// Internal error domain for custom manager errors.
    private static let errorDomain = "com.helicon.error"

    /// Lazily resolved Firestore reference.
    private var firestoreReference: Firestore {
        .firestore()
    }

    // MARK: - Topic: Owned Fetching

    /// Fetches all objects owned by the currently authenticated user.
    ///
    /// Ownership is determined by matching the `ownerId` field with the current user's UID.
    ///
    /// ## Example
    /// ```swift
    /// let projects: [Project] = try await DatabaseManager.shared.getOwned()
    /// ```
    ///
    /// - Parameter completion: Completion handler returning decoded objects or an error.
    public func getOwned<T: DatabaseType>(
        completion: @escaping @Sendable ([T], Error?) -> ()
    ) {
        if let uid = Auth.auth().currentUser?.uid {
            firestoreReference
                .collection(T.endpoint)
                .whereField("ownerId", isEqualTo: uid)
                .getDocuments { snapshot, error in
                    self.decode(snapshot: snapshot, error: error, completion: completion)
                }
        } else {
            completion([], NSError(
                domain: Self.errorDomain,
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No user is signed in"]
            ))
        }
    }

    /// Async version of ``getOwned(completion:)``.
    ///
    /// - Returns: Array of decoded objects.
    /// - Throws: Firestore or decoding errors, or if no user is signed in.
    public func getOwned<T: DatabaseType>() async throws -> [T] {
        try await withCheckedThrowingContinuation { continuation in
            getOwned { data, error in
                error.map { continuation.resume(throwing: $0) }
                    ?? continuation.resume(returning: data)
            }
        }
    }

    /// Fetches all objects owned by the specified user ID.
    ///
    /// - Parameters:
    ///   - id: Owner identifier.
    ///   - completion: Completion handler returning decoded objects or an error.
    public func getOwned<T: DatabaseType>(
        withId id: String,
        completion: @escaping @Sendable ([T], Error?) -> ()
    ) {
        firestoreReference
            .collection(T.endpoint)
            .whereField("ownerId", isEqualTo: id)
            .getDocuments { snapshot, error in
                self.decode(snapshot: snapshot, error: error, completion: completion)
            }
    }

    /// Async version of ``getOwned(withId:completion:)``.
    public func getOwned<T: DatabaseType>(withId id: String) async throws -> [T] {
        try await withCheckedThrowingContinuation { continuation in
            getOwned(withId: id) { data, error in
                error.map { continuation.resume(throwing: $0) }
                    ?? continuation.resume(returning: data)
            }
        }
    }

    // MARK: - Topic: Collection Fetching

    /// Fetches all documents in the collection for the given type.
    ///
    /// ## Example
    /// ```swift
    /// let allProjects: [Project] = try await DatabaseManager.shared.getAll()
    /// ```
    public func getAll<T: DatabaseType>(
        completion: @escaping @Sendable ([T], Error?) -> ()
    ) {
        firestoreReference.collection(T.endpoint).getDocuments { snapshot, error in
            self.decode(snapshot: snapshot, error: error, completion: completion)
        }
    }

    /// Async version of ``getAll(completion:)``.
    public func getAll<T: DatabaseType>() async throws -> [T] {
        try await withCheckedThrowingContinuation { continuation in
            getAll { data, error in
                error.map { continuation.resume(throwing: $0) }
                    ?? continuation.resume(returning: data)
            }
        }
    }

    /// Fetches all documents where a field equals a specific value.
    ///
    /// ## Example
    /// ```swift
    /// let shared: [Project] = try await manager.getAll(whereField: "isShared", isEqualTo: true)
    /// ```
    public func getAll<T: DatabaseType>(
        whereField field: String,
        isEqualTo fieldValue: Any,
        completion: @escaping @Sendable ([T], Error?) -> ()
    ) {
        firestoreReference
            .collection(T.endpoint)
            .whereField(field, isEqualTo: fieldValue)
            .getDocuments { snapshot, error in
                self.decode(snapshot: snapshot, error: error, completion: completion)
            }
    }

    /// Async version of filtered fetch.
    public func getAll<T: DatabaseType>(
        whereField field: String,
        isEqualTo fieldValue: Any
    ) async throws -> [T] {
        try await withCheckedThrowingContinuation { continuation in
            getAll(whereField: field, isEqualTo: fieldValue) { data, error in
                error.map { continuation.resume(throwing: $0) }
                    ?? continuation.resume(returning: data)
            }
        }
    }

    // MARK: - Topic: Single Object

    /// Fetches a single document by its Firestore ID.
    ///
    /// ## Example
    /// ```swift
    /// let project: Project? = try await manager.get(withId: "abc")
    /// ```
    public func get<T: DatabaseType>(
        withId objectId: String,
        completion: @escaping @Sendable (T?, Error?) -> ()
    ) {
        firestoreReference
            .collection(T.endpoint)
            .document(objectId)
            .getDocument { document, error in
                if let error {
                    completion(nil, error)
                } else if let document, document.exists {
                    completion(try? document.data(as: T.self), nil)
                } else {
                    completion(nil, NSError(
                        domain: Self.errorDomain,
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Document does not exist"]
                    ))
                }
            }
    }

    /// Async version of ``get(withId:completion:)``.
    public func get<T: DatabaseType>(withId objectId: String) async throws -> T? {
        try await withCheckedThrowingContinuation { continuation in
            get(withId: objectId) { data, error in
                error.map { continuation.resume(throwing: $0) }
                    ?? continuation.resume(returning: data)
            }
        }
    }

    // MARK: - Topic: Observation

    /// Observes a single document in real time.
    ///
    /// The completion is called whenever the document changes.
    ///
    /// ## Example
    /// ```swift
    /// manager.observe(withId: "abc") { (project: Project?, _) in
    ///     print(project?.name)
    /// }
    /// ```
    public func observe<T: DatabaseType>(
        withId objectId: String,
        completion: @escaping (T?, Error?) -> ()
    ) {
        firestoreReference
            .collection(T.endpoint)
            .document(objectId)
            .addSnapshotListener { snapshot, error in
                if let error {
                    completion(nil, error)
                } else if let snapshot, snapshot.exists {
                    completion(try? snapshot.data(as: T.self), nil)
                }
            }
    }

    /// Observes a filtered collection in real time.
    public func observeCollection<T: DatabaseType>(
        whereField field: String,
        isEqualTo fieldValue: Any,
        completion: @escaping ([T]?, Error?) -> ()
    ) {
        firestoreReference
            .collection(T.endpoint)
            .whereField(field, isEqualTo: fieldValue)
            .addSnapshotListener { snapshot, error in
                self.decode(snapshot: snapshot, error: error, completion: completion)
            }
    }

    // MARK: - Topic: Writing

    /// Creates or overwrites a document using the object's `id`.
    ///
    /// If the ID is `nil`, a new UUID is generated.
    ///
    /// ## Example
    /// ```swift
    /// try await manager.set(project)
    /// ```
    public func `set`<T: DatabaseType>(_ object: T, completion: ((Error?) -> Void)? = nil) {
        let firestoreId = object.id ?? UUID().uuidString
        try? firestoreReference
            .collection(T.endpoint)
            .document(firestoreId)
            .setData(from: object, completion: completion)
    }

    /// Async version of ``set(_:completion:)``.
    public func `set`<T: DatabaseType>(_ object: T) async throws {
        try await withCheckedThrowingContinuation { continuation in
            set(object) { $0.map { continuation.resume(throwing: $0) }
                ?? continuation.resume() }
        }
    }

    /// Updates a single field of a document.
    ///
    /// ## Example
    /// ```swift
    /// try await manager.setField("name", ofObjectWithId: id, ofType: Project.self, to: "New")
    /// ```
    public func setField<T: DatabaseType>(
        _ field: String,
        ofObjectWithId objectId: String,
        ofType objectType: T.Type,
        to value: Any,
        completion: (@Sendable (Error?) -> Void)? = nil
    ) {
        firestoreReference
            .collection(objectType.endpoint)
            .document(objectId)
            .updateData([field: value], completion: completion)
    }

    public func setField<T: DatabaseType>(
        _ field: String,
        ofObjectWithId objectId: String,
        ofType objectType: T.Type,
        to value: Any
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            setField(field, ofObjectWithId: objectId, ofType: objectType, to: value) {
                $0.map { continuation.resume(throwing: $0) }
                    ?? continuation.resume()
            }
        }
    }

    /// Creates a new document with an automatically generated Firestore ID.
    ///
    /// ## Example
    /// ```swift
    /// try await manager.create(project)
    /// ```
    public func create<T: DatabaseType>(_ object: T, completion: ((Error?) -> Void)? = nil) {
        do {
            try firestoreReference
                .collection(T.endpoint)
                .addDocument(from: object, completion: completion)
        } catch let error {
            completion?(error)
        }
    }

    public func create<T: DatabaseType>(_ object: T) async throws {
        try await withCheckedThrowingContinuation { continuation in
            create(object) {
                $0.map { continuation.resume(throwing: $0) }
                    ?? continuation.resume()
            }
        }
    }

    /// Deletes a document corresponding to the provided object.
    ///
    /// ## Example
    /// ```swift
    /// try await manager.delete(project)
    /// ```
    public func delete<T: DatabaseType>(_ object: T, completion: (@Sendable (Error?) -> ())? = nil) {
        guard let id = object.id else {
            completion?(NSError(domain: Self.errorDomain, code: -1))
            return
        }
        firestoreReference.collection(T.endpoint).document(id).delete(completion: completion)
    }

    public func delete<T: DatabaseType>(_ object: T) async throws {
        try await withCheckedThrowingContinuation { continuation in
            delete(object) {
                $0.map { continuation.resume(throwing: $0) }
                    ?? continuation.resume()
            }
        }
    }

    // MARK: - Private

    /// Decodes a Firestore `QuerySnapshot` into strongly typed models.
    ///
    /// Documents that fail decoding are skipped.
    private func decode<T: DatabaseType>(
        snapshot: QuerySnapshot?,
        error: Error?,
        completion: @escaping ([T], Error?) -> ()
    ) {
        if let error {
            completion([], error)
            return
        }

        let result = snapshot?.documents.compactMap { try? $0.data(as: T.self) } ?? []
        completion(result, nil)
    }
    
    /// Fetches documents where a model property (specified via `KeyPath`)
    /// equals the provided value.
    ///
    /// This is a type-safe alternative to string-based queries.
    /// The field name is automatically derived from the key path,
    /// removing the need for "magic strings".
    ///
    /// Internally this method converts the key path into the corresponding
    /// Firestore field name and forwards the request to
    /// ``getAll(whereField:isEqualTo:)``.
    ///
    /// ## Why use this
    /// - Compile-time safety
    /// - Refactor-friendly (renaming properties won't break queries)
    /// - Cleaner syntax
    ///
    /// ## Example
    /// ```swift
    /// // instead of:
    /// // getAll(whereField: "ownerId", isEqualTo: uid)
    ///
    /// let projects: [Project] = try await DatabaseManager.shared
    ///     .get(whereField: \Project.ownerId, isEqualTo: uid)
    /// ```
    ///
    /// - Parameters:
    ///   - field: KeyPath pointing to a property of `T`.
    ///   - fieldValue: Value to compare against.
    /// - Returns: Array of decoded objects matching the filter.
    /// - Throws: Firestore or decoding errors.
    public func get<T: DatabaseType, V>(
        whereField field: KeyPath<T, V>,
        isEqualTo fieldValue: Any
    ) async throws -> [T] {
        guard let propertyString = String(describing: field)
            .components(separatedBy: ".")
            .last else { return [] }

        let result: [T] = try await getAll(
            whereField: propertyString,
            isEqualTo: fieldValue
        )

        return result
    }
}
