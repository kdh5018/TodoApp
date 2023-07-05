//
//  TodosAPI+Closure.swift
//  TodoApp
//
//  Created by 김도훈 on 2023/06/12.
//

import Foundation
import MultipartForm

extension TodosAPI {
    
    /// 모든 할 일 가져오기
    /// - Parameters:
    ///   - page: 가져올 페이지
    ///   - completion: 컴플레션
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

    /// 특정 할 일 가져오기
    /// - Parameters:
    ///   - id: 가져올 데이터 아이디
    ///   - completion: 컴플레션
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

    /// 할 일 검색하기
    /// - Parameters:
    ///   - searchTerm: 검색할 내용
    ///   - page: 가져올 페이지
    ///   - completion: 컴플레션
    static func searchTodos(searchTerm: String, page: Int = 1, completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void) {
        
        // 1. urlRequest 만들기
        // 2. urlSession으로 API 호출
        // 3. API 호출에 대한 응답을 받는다
        
//        let urlString = baseURL + "/todos/search" + "?page=\(page)" + "&query=\(searchTerm)"
        
        // URLComponents : URL 구성하는 구조로써 정의하면 보다 편하게 URL 설정을 할 수 있음
        // URL+Ext로 익스텐션(헬퍼 메소드)을 설정해서 보다 편하게 URL 설정
        let requestUrl = URL(baseUrl: baseURL + "/todos/search", queryItems: ["query": searchTerm, "page": "\(page)"])
        
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
    
    /// 할 일 추가하기
    /// - Parameters:
    ///   - title: 추가할 내용
    ///   - isDone: 완료 여부
    ///   - completion: 컴플레션
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
            case 401:
                return completion(.failure(ApiError.badRequestError))
            case 422:
                if let data = data,
                   let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    return completion(.failure(ApiError.erroResponseFromServer(errorResponse)))
                    
                }
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
    
    /// 할 일 추가 - JSON
    /// - Parameters:
    ///   - title: 추가할 내용
    ///   - isDone: 완료 여부
    ///   - completion: 컴플레션
    static func addATodoJson(title: String, isDone: Bool = false, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        
        // 1. urlRequest 만들기
        // 2. urlSession으로 API 호출
        // 3. API 호출에 대한 응답을 받는다
        
        let urlString = baseURL + "/todos-json"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedURL))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let form = MultipartForm(parts: [
            MultipartForm.Part(name: "title", value: title),
            MultipartForm.Part(name: "is_done", value: "\(isDone)")
        ])
        
        let requestParams: [String : Any] = ["title" : title, "is_done" : "\(isDone)"]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestParams, options: [.prettyPrinted])
            
            urlRequest.httpBody = jsonData
        } catch {
            return completion(.failure(ApiError.jsonDecodingError))
        }
        
        
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
    
    /// 할 일 수정 - JSON
    /// - Parameters:
    ///   - id: 수정할 데이터 아이디
    ///   - title: 수정할 내용
    ///   - isDone: 완료 여부
    ///   - completion: 컴플레션
    static func editATodoJson(id: Int, title: String, isDone: Bool = false, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        
        // 1. urlRequest 만들기
        // 2. urlSession으로 API 호출
        // 3. API 호출에 대한 응답을 받는다
        
        let urlString = baseURL + "/todos-json/\(id)"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedURL))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let form = MultipartForm(parts: [
            MultipartForm.Part(name: "title", value: title),
            MultipartForm.Part(name: "is_done", value: "\(isDone)")
        ])
        
        let requestParams: [String : Any] = ["title" : title, "is_done" : "\(isDone)"]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestParams, options: [.prettyPrinted])
            
            urlRequest.httpBody = jsonData
        } catch {
            return completion(.failure(ApiError.jsonDecodingError))
        }
        
        
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
    
    /// 할 일 수정
    /// - Parameters:
    ///   - id: 수정할 데이터 아이디
    ///   - title: 수정할 내용
    ///   - isDone: 완료 여부
    ///   - completion: 컴플레션
    static func editATodo(id: Int, title: String, isDone: Bool = false, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        
        // 1. urlRequest 만들기
        // 2. urlSession으로 API 호출
        // 3. API 호출에 대한 응답을 받는다
        
        let urlString = baseURL + "/todos/\(id)"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedURL))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let form = MultipartForm(parts: [
            MultipartForm.Part(name: "title", value: title),
            MultipartForm.Part(name: "is_done", value: "\(isDone)")
        ])
        
        let requestParams: [String : String] = ["title" : title, "is_done" : "\(isDone)"]
        
        // URLRequest -> urlEncoding하기 위해 선언한 확장자 percentEncodeParameters
        urlRequest.percentEncodeParameters(parameters: requestParams)
        
        
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
    
    /// 할 일 삭제
    /// - Parameters:
    ///   - id: 삭제할 데이터 아이디
    ///   - completion: 컴플레션
    static func deleteATodo(id: Int, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        
        // 1. urlRequest 만들기
        // 2. urlSession으로 API 호출
        // 3. API 호출에 대한 응답을 받는다
        
        let urlString = baseURL + "/todos" + "/\(id)"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedURL))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
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
    
    
    /// 할 일 추가 -> 모든 할 일 가져오기 (연쇄 처리)
    /// - Parameters:
    ///   - title:
    ///   - isDone:
    ///   - completion:
    static func addATodoAndFetchTodos(title: String, isDone: Bool = false, completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void) {
        
        // 1
        self.addATodo(title: title, completion: { result in
            switch result {
                // 1-1
            case .success(_):
                self.fetchTodos(completion: {
                    switch $0 {
                        // 2-1
                    case .success(let data):
                        completion(.success(data))
                        // 2-2
                    case .failure(let failure):
                        return completion(.failure(failure))
                    }
                })
                // 1-2
            case .failure(let failure):
                return completion(.failure(failure))
            }
        })
        
    }
    
    
    /// 선택된 할 일들 삭제 (클로저 기반 모두 삭제, 연쇄 처리)
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할 일 아이디들
    ///   - completion: 실제 삭제가 완료된 아이디들
    static func deleteSelectedTodos(selectedTodoIds: [Int], completion: @escaping ([Int]) -> Void) {
        
        // 동시에 처리하기 위해 디스패치그룹을 사용
        let group = DispatchGroup()
        
        // 성공적으로 삭제가 이뤄진 데이터
        var deletedTodoIds : [Int] = [Int]()
        
        selectedTodoIds.forEach { aTodoId in
            // 디스패치 그룹에 넣음
            group.enter()
            self.deleteATodo(id: aTodoId, completion: { result in
                switch result {
                case .success(let response):
                    // 삭제된 아이디를 삭제된 아이디 배열에 넣기
                    if let todoId = response.data?.id {
                        deletedTodoIds.append(todoId)
                        print("inner deleteATodo - Success: \(todoId)")
                    }
                case .failure(let failure):
                    print("inner deleteATodo - Failure: \(failure)")
                }
                group.leave()
            })// 단일 삭제 API 호출
            group.notify(queue: .main) {
                print("모든 API 완료됨")
                completion(deletedTodoIds)
            }
        }
        
    }
    
    /// 선택된 할 일들 가져오기
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할 일 아이디들
    ///   - completion: 응답 결과
    static func fetchedSelectedTodos(selectedTodoIds: [Int], completion: @escaping (Result<[Todo], ApiError>) -> Void) {
        
        // 동시에 처리하기 위해 디스패치그룹을 사용
        let group = DispatchGroup()
        
        // 가져온 데이터
        var fetchedTodos: [Todo] = [Todo]()
        
        // 에러가 난 것들
        var apiErrors: [ApiError] = []
        
        // 응답 결과들
        var apiResult: [Int : Result<BaseResponse<Todo>, ApiError>] = [:]
        
        selectedTodoIds.forEach { aTodoId in
            // 디스패치 그룹에 넣음
            group.enter()
            self.fetchATodo(id: aTodoId, completion: { result in
                switch result {
                case .success(let response):
                    // 가져온 할 일을 가져온 할 일 배열에 넣는다
                    if let todo = response.data {
                        fetchedTodos.append(todo)
                        print("inner fetchATodo - Success: \(todo)")
                    }
                case .failure(let failure):
                    apiErrors.append(failure)
                    print("inner fetchATodo - Failure: \(failure)")
                }
                group.leave()
            })// 단일 할일 조회 API
            group.notify(queue: .main) {
                print("모든 API 완료됨")
                // 만약 에러가 있다면 에러 올려주기
                if !apiErrors.isEmpty {
                    if let firstError = apiErrors.first {
                        completion(.failure(firstError))
                        return
                    }
                }
                completion(.success(fetchedTodos))
            }
        }
        
    }
    
}
