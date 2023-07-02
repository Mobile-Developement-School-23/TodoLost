//
//  RequestFactory.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 02.07.2023.
//

import Foundation

struct RequestFactory {
    struct TodoListRequest {
        static func getModelConfig() -> RequestConfig<TodoListParser<APIResponse>> {
            let request = TodoListGetRequest()
            let parser = TodoListParser<APIResponse>()
            return RequestConfig<TodoListParser>(request: request, parser: parser)
        }
    }
}
