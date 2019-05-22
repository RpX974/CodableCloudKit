//
//  CodableCloudKit.swift
//  CodableCloudKit
//
//  Created by Laurent Grondin on 22 mai 2019.
//  Copyright © 2019 CodableCloudKit. All rights reserved.
//

// Include Foundation
@_exported import Foundation
@_exported import CloudKit

// MARK: - Cloud class

open class Cloud {
    public var record: CKRecord?
    
    public init() {
    }
    
    public init(from decoder: Decoder) throws {
    }
}

/* Exemple
 class User: Cloud & Codable {}
 
 OR
 
 class User: CodableCloud {}
 */

// MARK: - Enum

public enum CloudError: Error {
    case noRecord
    case notCloudType
}

public enum Result<Value> {
    case success(Value)
    case failure(Error)
}

// MARK: - Typealias


public typealias CodableCloud = Codable & Cloud
public typealias ResultCompletion<T> = (Result<T>) -> Void


// MARK: - Extensions
// MARK: - Codable

public extension Encodable {
    
    static var stringClass: String { return "\(self)" }
    
    func string(using encoder: JSONEncoder = JSONEncoder()) -> String? {
        do {
            return try String(data: encoder.encode(self), encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    private var newRecord: CKRecord? {
        let record = CKRecord.init(recordType: Self.stringClass)
        guard let value: String = self.string() else { return nil }
        record["value"] = value
        return record
    }
    
    func saveInCloud(_ database: CKDatabase = CKContainer.default().privateCloudDatabase,
                     _ completion: ResultCompletion<CKRecord>? = nil) {
        guard let cloud = self as? Cloud else { completion?(.failure(CloudError.notCloudType)); return }
        guard let record = cloud.record ?? self.newRecord else { completion?(.failure(CloudError.noRecord)); return }
        database.save(record) { (record, error) in
            if let error = error { completion?(.failure(error)); return }
            guard let record = record else { completion?(.failure(CloudError.noRecord)); return }
            cloud.record = record
            completion?(.success(record))
        }
    }
}

public extension Decodable {
    
    static var stringClass: String { return "\(self)" }
    
    static func retrieveFromCloud(_ database: CKDatabase = CKContainer.default().privateCloudDatabase,
                                  completion: @escaping ResultCompletion<[Self]>) {
        let query = CKQuery.init(recordType: stringClass, predicate: NSPredicate.init(value: true))
        query.sortDescriptors = [NSSortDescriptor.init(key: "modificationDate", ascending: false)]
        database.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error { completion(.failure(error)); return }
            guard let records = records else { return }
            let result: [Self] = records.compactMap({ $0.toModel() })
            completion(.success(result))
        }
    }
    
    func removeFromCloud(_ database: CKDatabase = CKContainer.default().privateCloudDatabase,
                         _ completion: ResultCompletion<CKRecord.ID?>? = nil) {
        guard let cloud = self as? Cloud, let recordId = cloud.record?.recordID else { return }
        database.delete(withRecordID: recordId) { recordId, error in
            if let error = error { completion?(.failure(error)); return }
            completion?(.success(recordId))
        }
    }
}

// MARK: - CloudKit

extension CKRecord {
    
    func toModel<T: Decodable>() -> T? {
        guard let value  = self.value(forKey: "value") as? String, let data = value.data(using: String.Encoding.utf8) else { return nil }
        guard let result = try? JSONDecoder().decode(T.self, from: data) else { return nil }
        guard let cloud  = result as? Cloud else { return result }
        cloud.record     = self
        return result
    }
}
