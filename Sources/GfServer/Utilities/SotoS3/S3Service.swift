//
//  S3Service.swift
//  GfServer
//
//  Created by Rian on 11/11/25.
//

import SotoS3
import SotoCore
import Vapor

struct S3Service {
    let req: Request
    var bucket: String { Environment.get("S3_BUCKET") ?? "gambillforestapp-demo" }
    
    init(req: Request) {
        self.req = req
    }
  
    func uploadProfilePhoto(data: Data, key: String, contentType: String) async throws -> (objectKey: String, presignedURL: String) {
        let objectKey = "profilePhotos/\(key)\(Date().timeIntervalSince1970).jpg"
        let body = AWSHTTPBody(bytes: data)
        let request = S3.PutObjectRequest(
            body: body,
            bucket: bucket,
            contentType: contentType,
            key: objectKey
            )
        _ = try await req.aws.s3.putObject(request)
        
        let s3 = req.aws.s3
        let url = try await s3.signURL(url: URL(string: "https://\(bucket).s3.\(s3.region.rawValue).amazonaws.com/\(objectKey)")!, httpMethod: .GET, expires: .minutes(20))
        
        return (objectKey, url.absoluteString)
    }
    
    // New: Generate pre-signed URL
    func generatePresignedURL(forKey key: String) async throws -> String {
        let s3 = req.aws.s3
        let url = try await s3.signURL(url: URL(string: "https://\(bucket).s3.\(s3.region.rawValue).amazonaws.com/\(key)")!, httpMethod: .GET, expires: .minutes(20))
        return url.absoluteString
    }
}
