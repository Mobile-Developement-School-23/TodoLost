//
//  URLSession+.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 07.07.2023.
//

import Foundation

extension URLSession {
    func dataTask(for request: URLRequest) async throws -> (Data, URLResponse) {
        var task: URLSessionDataTask?
        
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                task = self.dataTask(with: request) { data, response, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else if let data, let response {
                        continuation.resume(returning: (data, response))
                    } else {
                        if let url = request.url?.absoluteString {
                            let error = NSError(domain: url, code: -1)
                            continuation.resume(throwing: error)
                        }
                    }
                }
                task?.resume()
            }
        } onCancel: { [weak task] in
            task?.resume()
        }
    }
}
