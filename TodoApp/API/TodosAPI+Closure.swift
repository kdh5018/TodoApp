//
//  TodosAPI+Closure.swift
//  TodoApp
//
//  Created by 김도훈 on 2023/06/12.
//

import Foundation
import MultipartForm

extension TodosAPI {
    // 모든 할 일 가져오기
    static func fetchTodos(page: Int = 1, completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void) {
        
        // 1. urlRequest 만들기
        // 2. urlSession으로 API 호출
        // 3. API 호출에 대한 응답을 받는다
        
        let urlString = baseURL + "/todos" + "?page=\(page)"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedURL))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            print(#fileID, #function, #line, "- data: \(data)")
            print(#fileID, #function, #line, "- urlResponse: \(urlResponse)")
            print(#fileID, #function, #line, "- error: \(error)")
            
            if let error = error {
                return completion(.failure(ApiError.unknownError(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print(#fileID, #function, #line, "- bad Status code: ")
                return completion(.failure(ApiError.unknownError(nil)))
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(ApiError.badStatus(httpResponse.statusCode)))
            }
            
            switch httpResponse.statusCode {
            case 400:
                return completion(.failure(ApiError.badRequestError))
            case 204:
                return completion(.failure(ApiError.noContentsError))
            default:
                print("default")
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
    
    // 특정 할 일 가져오기
    static func fetchATodo(id: Int, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        
        // 1. urlRequest 만들기
        // 2. urlSession으로 API 호출
        // 3. API 호출에 대한 응답을 받는다
        
        let urlString = baseURL + "/todos" + "/\(id)"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedURL))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            print(#fileID, #function, #line, "- data: \(data)")
            print(#fileID, #function, #line, "- urlResponse: \(urlResponse)")
            print(#fileID, #function, #line, "- error: \(error)")
            
            if let error = error {
                return completion(.failure(ApiError.unknownError(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print(#fileID, #function, #line, "- bad Status code: ")
                return completion(.failure(ApiError.unknownError(nil)))
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
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                    
                    completion(.success(baseResponse))

                } catch {
                    // decoding error
                    completion(.failure(ApiError.decodingError))

                }
            }

        }.resume()
        
    }
    
    // 할 일 검색하기
    static func searchTodos(searchTerm: String, page: Int = 1, completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void) {
        
        // 1. urlRequest 만들기
        // 2. urlSession으로 API 호출
        // 3. API 호출에 대한 응답을 받는다
        
//        let urlString = baseURL + "/todos/search" + "?page=\(page)" + "&query=\(searchTerm)"
        
        // URLComponents : URL 구성하는 구조로써 정의하면 보다 편하게 URL 설정을 할 수 있음
        // URL+Ext로 익스텐션(헬퍼 메소드)을 설정해서 보다 편하게 URL 설정
        let requestUrl = URL(baseUrl: baseURL + "/todos/search", queryItems: ["quary": searchTerm, "page": "\(page)"])
        
//        var urlComponents = URLComponents(string: baseURL + "/todos/search")
//        urlComponents?.queryItems = [
//            URLQueryItem(name: "query", value: searchTerm),
//            URLQueryItem(name: "page", value: "\(page)")
//        ]
        
        guard let url = requestUrl else {
            return completion(.failure(ApiError.notAllowedURL))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            print(#fileID, #function, #line, "- data: \(data)")
            print(#fileID, #function, #line, "- urlResponse: \(urlResponse)")
            print(#fileID, #function, #line, "- error: \(error)")
            
            if let error = error {
                return completion(.failure(ApiError.unknownError(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print(#fileID, #function, #line, "- bad Status code: ")
                return completion(.failure(ApiError.unknownError(nil)))
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(ApiError.badStatus(httpResponse.statusCode)))
            }
            
            switch httpResponse.statusCode {
            case 400:
                return completion(.failure(ApiError.badRequestError))
            case 204:
                return completion(.failure(ApiError.noContentsError))
            default:
                print("default")
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
    
    // 할 일 추가하기
    static func addATodo(title: String, isDone: Bool = false, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        
        // 1. urlRequest 만들기
        // 2. urlSession으로 API 호출
        // 3. API 호출에 대한 응답을 받는다
        
        let urlString = baseURL + "/todos"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedURL))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        
        let form = MultipartForm(parts: [
            MultipartForm.Part(name: "title", value: title),
            MultipartForm.Part(name: "is_done", value: "\(isDone)")
        ])
        
        urlRequest.addValue(form.contentType, forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = form.bodyData
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            print(#fileID, #function, #line, "- data: \(data)")
            print(#fileID, #function, #line, "- urlResponse: \(urlResponse)")
            print(#fileID, #function, #line, "- error: \(error)")
            
            if let error = error {
                return completion(.failure(ApiError.unknownError(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print(#fileID, #function, #line, "- bad Status code: ")
                return completion(.failure(ApiError.unknownError(nil)))
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
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                    
                    completion(.success(baseResponse))

                } catch {
                    // decoding error
                    completion(.failure(ApiError.decodingError))

                }
            }

        }.resume()
        
    }
    
}
