//
//  RequestService.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 02.07.2023.
//

import Foundation
import DTLogger

protocol IRequest {
    var urlRequest: URLRequest? { get }
}

protocol IParser {
    associatedtype Model
    func parse(data: Data) -> Model?
}

protocol IRequestSender {
    func send<Parser>(
        config: RequestConfig<Parser>,
        completionHandler: @escaping (Result<(Parser.Model?, Data?, URLResponse?), NetworkError>) -> Void
    )
}

struct RequestConfig<Parser> where Parser: IParser {
    let request: IRequest
    let parser: Parser?
}

final class RequestSender: IRequestSender {
    func send<Parser>(
        config: RequestConfig<Parser>,
        completionHandler: @escaping (Result<(Parser.Model?, Data?, URLResponse?), NetworkError>) -> Void
    ) where Parser: IParser {
        guard let urlRequest = config.request.urlRequest else {
            completionHandler(.failure(.invalidURL))
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                SystemLogger.error(error.localizedDescription)
                completionHandler(.failure(.networkError))
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                SystemLogger.error("Ошибка получения кода статуса")
                completionHandler(.failure(.statusCodeError))
                return
            }
            
            if !(200..<300).contains(statusCode) {
                SystemLogger.info("Status code: \(statusCode.description)")
                
                switch statusCode {
                case 400:
                    let serverMessage = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                    completionHandler(.failure(.messageError(serverMessage)))
                case 401:
                    completionHandler(.failure(.authError))
                case 500...:
                    completionHandler(.failure(.serverUnavailable))
                default:
                    SystemLogger.error(statusCode.description)
                    let serverMessage = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                    completionHandler(.failure(.messageError(serverMessage)))
                }
            }
            
            // Для отладки и сверки данных
            if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                SystemLogger.info("Response JSON: \(jsonString)")
            }
            
            if let data = data,
               let parseModel: Parser.Model = config.parser?.parse(data: data) {
                completionHandler(.success((parseModel, nil, nil)))
            } else if let data = data {
                completionHandler(.success((nil, data, response)))
            } else {
                completionHandler(.failure(.parseError))
            }
        }
        task.resume()
    }
}
