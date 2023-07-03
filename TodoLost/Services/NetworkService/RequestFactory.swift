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
        
        /// Конфигурация для синхронизации с сервером
        /// - warning: Мердж данных делает сервер, результат возвращается уже смердженным.
        /// Мердж сервером делается по "last write wins" по каждому конкретному элементу списка.
        /// Т.е. при выполнении запроса типа PATCH, если по какой-то причине происходит конкурентное
        /// изменение списка задач несколькими устройствами (например, задачи были добавлены на другом
        /// устройстве и не синхронизированы с текущим), задачи, отсутствующие в предоставленном
        /// на обновление списке, будут удалены. И наоборот, удалённые задачи, присутствующие
        /// на текущем устройстве, будут сохранены.
        ///
        /// Пример:
        /// - Устройство А содержит ревизию с элементами 1 и 2, и добавляет элемент 3
        /// - Устройство Б содержит ревизию с элементами 1 и 2, и делает запрос на обновление
        /// с целью изменить элемент 2 (PATCH)
        ///
        /// Операция PATCH удалит элемент 3 и вернёт список без него, т.к. элемент 3 не был представлен
        /// в списке на обновление (элемент считается удалённым на устройстве Б, хотя Б о нём не было известно)
        ///
        /// Пример 2:
        /// - Устройство А содержит ревизию с элементами 1 и 2, и удаляет элемент 1
        /// - Устройство Б содержит ревизию с элементами 1 и 2, и делает запрос на обновление с целью
        /// изменить элемент 2 (PATCH)
        ///
        /// Операция PATCH вернёт список задач с элементами 1 и 2, т.к. элемент 1 содержится в списке на обновление.
        static func patchListConfig(list: APIListResponse, revision: String) -> RequestConfig<JSONParser<APIListResponse>> {
            let parser = JSONParser<APIListResponse>()
            let data = parser.parse(model: list)
            let request = TodoItemPatchRequest(data: data, revision: revision)
            return RequestConfig<JSONParser>(request: request, parser: parser)
        }
        
        static func postItemConfig(dataModel: APIElementResponse, revision: String) -> RequestConfig<JSONParser<APIElementResponse>> {
            let parser = JSONParser<APIElementResponse>()
            let data = parser.parse(model: dataModel)
            let request = TodoItemPostRequest(data: data, revision: revision)
            return RequestConfig<JSONParser>(request: request, parser: parser)
        }
        
        static func putItemConfig(dataModel: APIElementResponse, id: String, revision: String) -> RequestConfig<JSONParser<APIElementResponse>> {
            let parser = JSONParser<APIElementResponse>()
            let data = parser.parse(model: dataModel)
            let request = TodoItemPutRequest(data: data, id: id, revision: revision)
            return RequestConfig<JSONParser>(request: request, parser: parser)
        }
        
        static func getItemConfig(id: String, revision: String) -> RequestConfig<JSONParser<APIElementResponse>> {
            let parser = JSONParser<APIElementResponse>()
            let request = TodoItemGetRequest(id: id, revision: revision)
            return RequestConfig<JSONParser>(request: request, parser: parser)
        }
        
        static func deleteItemConfig(id: String, revision: String) -> RequestConfig<JSONParser<APIElementResponse>> {
            let parser = JSONParser<APIElementResponse>()
            let request = TodoItemDeleteRequest(delete: id, revision: revision)
            return RequestConfig<JSONParser>(request: request, parser: parser)
        }
    }
}
