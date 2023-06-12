//
//  TodosAPI+Closure.swift
//  TodoApp
//
//  Created by 김도훈 on 2023/06/12.
//

import Foundation

extension TodosAPI {
    static func fetchTodos(page: Int = 1, completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void) {
        
        let urlString = baseURL + "/todos" + "?page=\(page)"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedURL))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            
            if let error = error {
                return completion(.failure(ApiError.unknownError(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print(#fileID, #function, #line, "- bad Status code: ")
                return completion(.failure(ApiError.unknownError(error)))
            }
            
            switch httpResponse.statusCode {
            case 400:
                return completion(.failure(ApiError.badRequestError))
            case 204:
                return completion(.failure(ApiError.noContentsError))
            default:
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(ApiError.badStatus(httpResponse.statusCode)))
            }
            
            if let jsonData = data {
                // convert data to our swift model
                do {
                    // JSON -> struct로 디코딩 / 데이터 파싱
                    let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: jsonData)
                    let todos = listResponse.data
                    
                    print(#fileID, #function, #line, "- todosResponse: \(listResponse)")
                    
                    // 상태코드는 200인데 파싱한 데이터에 따라서 에러처리
                    guard let todos = todos,
                          !todos.isEmpty else {
                        return completion(.failure(ApiError.noContentsError))
                    }
                    
                    completion(.success(listResponse))

                } catch {
                    // decoding error
                    completion(.failure(ApiError.decodingError))

                }
            }

        }.resume()
        
    }
}
