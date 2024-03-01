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
			
			let result: Result<(Parser.Model?, Data?, URLResponse?), NetworkError>
			
			defer {
				completionHandler(result)
			}
			
            if let error = error {
                SystemLogger.error(error.localizedDescription)
                result = .failure(.networkError)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                SystemLogger.error("Ошибка получения кода статуса")
				result = .failure(.statusCodeError)
                return
            }
            
            if !(200..<300).contains(statusCode) {
                SystemLogger.info("Status code: \(statusCode.description)")
                
                switch statusCode {
                case 400:
                    let serverMessage = HTTPURLResponse.localizedString(forStatusCode: statusCode)
					result = .failure(.messageError(serverMessage))
					return
                case 401:
					result = .failure(.authError)
					return
                case 404:
					result = .failure(.elementNotFound)
					return
                case 500...:
					result = .failure(.serverUnavailable)
					return
                default:
                    SystemLogger.error(statusCode.description)
                    let serverMessage = HTTPURLResponse.localizedString(forStatusCode: statusCode)
					result = .failure(.messageError(serverMessage))
					return
                }
            }
            
            // Для отладки и сверки данных
            if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                SystemLogger.info("Response JSON: \(jsonString)")
            }
            
            if let data = data,
               let parseModel: Parser.Model = config.parser?.parse(data: data) {
				result = .success((parseModel, nil, nil))
            } else if let data = data {
                // кейс на случай, когда не нужно парсить модель, но ответ получить нужно
				result = .success((nil, data, response))
            } else {
				result = .failure(.parseError)
            }
        }
        task.resume()
    }
}
