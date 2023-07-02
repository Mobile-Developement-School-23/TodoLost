//
//  RequestFactory.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 02.07.2023.
//

import Foundation
import DTLogger

struct RequestFactory {
    struct TodoListRequest {
        static func getModelConfig() -> RequestConfig<JSONParser<APIListResponse>> {
            let request = TodoListGetRequest()
            let parser = JSONParser<APIListResponse>()
            return RequestConfig<JSONParser>(request: request, parser: parser)
        }
        
        static func postModelConfig(dataModel: APIElementResponse) -> RequestConfig<JSONParser<APIElementResponse>> {
            let data = JSONParser<APIElementResponse>().parse(model: dataModel)
            let request = TodoItemPostRequest(data: data)
            
            return RequestConfig<JSONParser>(request: request, parser: nil)
        }
    }
}
