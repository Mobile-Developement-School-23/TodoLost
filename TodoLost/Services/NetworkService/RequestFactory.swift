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
        static func getListConfig() -> RequestConfig<JSONParser<APIListResponse>> {
            let request = TodoListGetRequest()
            let parser = JSONParser<APIListResponse>()
            return RequestConfig<JSONParser>(request: request, parser: parser)
        }
        
        static func postItemConfig(dataModel: APIElementResponse, revision: String) -> RequestConfig<JSONParser<APIElementResponse>> {
            let parser = JSONParser<APIElementResponse>()
            let data = parser.parse(model: dataModel)
            let request = TodoItemPostRequest(data: data, revision: revision)
            return RequestConfig<JSONParser>(request: request, parser: parser)
        }
        
        static func deleteItemConfig(id: String, revision: String) -> RequestConfig<JSONParser<APIElementResponse>> {
            let parser = JSONParser<APIElementResponse>()
            let request = TodoItemDeleteRequest(delete: id, revision: revision)
            return RequestConfig<JSONParser>(request: request, parser: parser)
        }
    }
}
