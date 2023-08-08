//
//  TodosAPI+Rx.swift
//  TodoApp
//
//  Created by 김도훈 on 2023/08/07.
//

import Foundation
import MultipartForm
import RxSwift
import RxRelay
import RxCocoa

extension TodosAPI {
    
    /// 모든 할 일 가져오기
    /// - Parameters:
    ///   - page: 가져올 페이지
    ///   - completion: 컴플레션
    static func fetchTodosWithObservableWithError(page: Int = 1) -> Observable<Result<BaseListResponse<Todo>, ApiError>> {
        
        // 1. urlRequest 만들기
        // 2. urlSession으로 API 호출
        // 3. API 호출에 대한 응답을 받는다
        
        let urlString = baseURL + "/todos" + "?page=\(page)"
        
        guard let url = URL(string: urlString) else {
            return Observable.just(.failure(ApiError.notAllowedURL)) // just는 하나의 값을 방출하는 연산자
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.rx
            .response(request: urlRequest)
            .map({ (urlResponse: HTTPURLResponse, data: Data) -> Result<BaseListResponse<Todo>, ApiError> in
                
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print(#fileID, #function, #line, "- bad Status code: ")
                    return .failure(ApiError.unknownError(nil))
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    return .failure(ApiError.badStatus(httpResponse.statusCode))
                }
                
                switch httpResponse.statusCode {
                case 400:
                    return .failure(ApiError.badRequestError)
                case 204:
                    return .failure(ApiError.noContentsError)
                default:
                    print("default")
                }

                do {
                    // JSON -> struct로 디코딩 / 데이터 파싱
                    let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
                    let todos = listResponse.data
                    
                    print(#fileID, #function, #line, "- todosResponse: \(listResponse)")
                    
                    // 상태코드는 200인데 파싱한 데이터에 따라서 에러처리
                    guard let todos = todos,
                          !todos.isEmpty else {
                        return .failure(ApiError.noContentsError)
                    }
                    
                    return .success(listResponse)

                } catch {
                    // decoding error
                    return .failure(ApiError.decodingError)

                }
            })
        
    }
    
    static func fetchTodosWithObservable(page: Int = 1) -> Observable<BaseListResponse<Todo>> {
        
        // 1. urlRequest 만들기
        // 2. urlSession으로 API 호출
        // 3. API 호출에 대한 응답을 받는다
        
        let urlString = baseURL + "/todos" + "?page=\(page)"
        
        guard let url = URL(string: urlString) else {
//            return Observable.just(.failure(ApiError.notAllowedURL)) // just는 하나의 값을 방출하는 연산자
            return Observable.error(ApiError.notAllowedURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.rx
            .response(request: urlRequest)
            .map({ (urlResponse: HTTPURLResponse, data: Data) -> BaseListResponse<Todo> in
                
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print(#fileID, #function, #line, "- bad Status code: ")
//                    return .failure(ApiError.unknownError(nil))
                    throw ApiError.unknownError(nil)
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
//                    return .failure(ApiError.badStatus(httpResponse.statusCode))
                    throw ApiError.badStatus(httpResponse.statusCode)
                }
                
                switch httpResponse.statusCode {
                case 400:
//                    return .failure(ApiError.badRequestError)
                    throw ApiError.badRequestError
                case 204:
//                    return .failure(ApiError.noContentsError)
                    throw ApiError.noContentsError
                default:
                    print("default")
                }

                do {
                    // JSON -> struct로 디코딩 / 데이터 파싱
                    let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
                    let todos = listResponse.data
                    
                    print(#fileID, #function, #line, "- todosResponse: \(listResponse)")
                    
                    // 상태코드는 200인데 파싱한 데이터에 따라서 에러처리
                    guard let todos = todos,
                          !todos.isEmpty else {
//                        return .failure(ApiError.noContentsError)
                        throw ApiError.noContentsError
                    }
                    
                    return listResponse
//                    return .success(listResponse)

                } catch {
                    // decoding error
//                    return .failure(ApiError.decodingError)
                    throw ApiError.decodingError

                }
            })
        
    }

    /// 특정 할 일 가져오기
    /// - Parameters:
    ///   - id: 가져올 데이터 아이디
    ///   - completion: 컴플레션
    static func fetchATodoWithObservable(id: Int) -> Observable<BaseResponse<Todo>> {
        
        // 1. urlRequest 만들기
        // 2. urlSession으로 API 호출
        // 3. API 호출에 대한 응답을 받는다
        
        let urlString = baseURL + "/todos" + "/\(id)"
        
        guard let url = URL(string: urlString) else {
            return Observable.error(ApiError.notAllowedURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.rx
            .response(request: urlRequest)
            .map({ (urlResponse: HTTPURLResponse, data: Data) -> BaseResponse<Todo> in
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print(#fileID, #function, #line, "- bad Status code: ")
                    throw ApiError.unknownError(nil)
                }

                
                switch httpResponse.statusCode {
                case 400:
                    throw ApiError.badRequestError
                case 204:
                    throw ApiError.noContentsError
                default:
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(httpResponse.statusCode)
                }
                
                do {
                    // JSON -> struct로 디코딩 / 데이터 파싱
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                
                    return baseResponse

                } catch {
                    // decoding error
                    throw ApiError.decodingError

                }

            })
        
    }

    /// 할 일 검색하기
    /// - Parameters:
    ///   - searchTerm: 검색할 내용
    ///   - page: 가져올 페이지
    ///   - completion: 컴플레션
    static func searchTodosWithObservable(searchTerm: String, page: Int = 1) -> Observable<BaseListResponse<Todo>> {
        
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
            return Observable.error(ApiError.notAllowedURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession
            .shared
            .rx
            .response(request: urlRequest)
            .map({ (urlResponse: HTTPURLResponse, data: Data) -> BaseListResponse<Todo> in
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print(#fileID, #function, #line, "- bad Status code: ")
                    throw ApiError.unknownError(nil)
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(httpResponse.statusCode)
                }
                
                switch httpResponse.statusCode {
                case 400:
                    throw ApiError.badRequestError
                case 204:
                    throw ApiError.badRequestError
                default:
                    print("default")
                }

                do {
                    // JSON -> struct로 디코딩 / 데이터 파싱
                    let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
                    let todos = listResponse.data
                    
                    print(#fileID, #function, #line, "- todosResponse: \(listResponse)")
                    
                    // 상태코드는 200인데 파싱한 데이터에 따라서 에러처리
                    guard let todos = todos,
                          !todos.isEmpty else {
                        throw ApiError.noContentsError
                    }
                    
                    return listResponse

                } catch {
                    // decoding error
                    throw ApiError.decodingError

                }
            })
        
    }
    
    /// 할 일 추가하기
    /// - Parameters:
    ///   - title: 추가할 내용
    ///   - isDone: 완료 여부
    ///   - completion: 컴플레션
    static func addATodoWithObservable(title: String, isDone: Bool = false) -> Observable<BaseResponse<Todo>> {
        
        // 1. urlRequest 만들기
        // 2. urlSession으로 API 호출
        // 3. API 호출에 대한 응답을 받는다
        
        let urlString = baseURL + "/todos"
        
        guard let url = URL(string: urlString) else {
            return Observable.error(ApiError.notAllowedURL)
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
        
        return URLSession
            .shared
            .rx
            .response(request: urlRequest)
            .map({ (urlResponse: HTTPURLResponse, data: Data) -> BaseResponse<Todo> in
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print(#fileID, #function, #line, "- bad Status code: ")
                    throw ApiError.unknownError(nil)
                }

                
                switch httpResponse.statusCode {
                case 401:
                    throw ApiError.badRequestError
                    
                case 204:
                    throw ApiError.badRequestError
                default:
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(httpResponse.statusCode)
                }

                do {
                    // JSON -> struct로 디코딩 / 데이터 파싱
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                    
                    return baseResponse

                } catch {
                    // decoding error
                    throw ApiError.decodingError

                }

            })
        
    }
    
    /// 할 일 추가 - JSON
    /// - Parameters:
    ///   - title: 추가할 내용
    ///   - isDone: 완료 여부
    ///   - completion: 컴플레션
    static func addATodoJsonWithObservable(title: String, isDone: Bool = false) -> Observable<BaseResponse<Todo>> {
        
        // 1. urlRequest 만들기
        // 2. urlSession으로 API 호출
        // 3. API 호출에 대한 응답을 받는다
        
        let urlString = baseURL + "/todos-json"
        
        guard let url = URL(string: urlString) else {
            return Observable.error(ApiError.notAllowedURL)
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
            return Observable.error(ApiError.jsonDecodingError)
        }
        
        
        return URLSession
            .shared
            .rx
            .response(request: urlRequest)
            .map({ (urlResponse: HTTPURLResponse, data: Data) -> BaseResponse<Todo> in
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print(#fileID, #function, #line, "- bad Status code: ")
                    throw ApiError.unknownError(nil)
                }

                
                switch httpResponse.statusCode {
                case 400:
                    throw ApiError.badRequestError
                case 204:
                    throw ApiError.badRequestError
                default:
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(httpResponse.statusCode)
                }

                do {
                    // JSON -> struct로 디코딩 / 데이터 파싱
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                    
                    return baseResponse

                } catch {
                    // decoding error
                    throw ApiError.decodingError

                }
            })
        
    }
    
    /// 할 일 수정 - JSON
    /// - Parameters:
    ///   - id: 수정할 데이터 아이디
    ///   - title: 수정할 내용
    ///   - isDone: 완료 여부
    ///   - completion: 컴플레션
    static func editATodoJsonWithObservable(id: Int, title: String, isDone: Bool = false) -> Observable<BaseResponse<Todo>> {
        
        // 1. urlRequest 만들기
        // 2. urlSession으로 API 호출
        // 3. API 호출에 대한 응답을 받는다
        
        let urlString = baseURL + "/todos-json/\(id)"
        
        guard let url = URL(string: urlString) else {
            return Observable.error(ApiError.notAllowedURL)
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
            return Observable.error(ApiError.jsonDecodingError)
        }
        
        
        return URLSession
            .shared
            .rx
            .response(request: urlRequest)
            .map({ (urlResponse: HTTPURLResponse, data: Data) -> BaseResponse<Todo> in
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print(#fileID, #function, #line, "- bad Status code: ")
                    throw ApiError.unknownError(nil)
                }

                
                switch httpResponse.statusCode {
                case 400:
                    throw ApiError.badRequestError
                case 204:
                    throw ApiError.badRequestError
                default:
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(httpResponse.statusCode)
                }

                do {
                    // JSON -> struct로 디코딩 / 데이터 파싱
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                    
                    return baseResponse

                } catch {
                    // decoding error
                    throw ApiError.decodingError
                }
                
            })
    }
    
    /// 할 일 수정
    /// - Parameters:
    ///   - id: 수정할 데이터 아이디
    ///   - title: 수정할 내용
    ///   - isDone: 완료 여부
    ///   - completion: 컴플레션
    static func editATodoWithObservable(id: Int, title: String, isDone: Bool = false) -> Observable<BaseResponse<Todo>> {
        
        // 1. urlRequest 만들기
        // 2. urlSession으로 API 호출
        // 3. API 호출에 대한 응답을 받는다
        
        let urlString = baseURL + "/todos/\(id)"
        
        guard let url = URL(string: urlString) else {
            return Observable.error(ApiError.notAllowedURL)
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
        
        
        return URLSession
            .shared
            .rx
            .response(request: urlRequest)
            .map({ (response: HTTPURLResponse, data: Data) -> BaseResponse<Todo> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    print(#fileID, #function, #line, "- bad Status code: ")
                    throw ApiError.unknownError(nil)
                }

                
                switch httpResponse.statusCode {
                case 400:
                    throw ApiError.badRequestError
                case 204:
                    throw ApiError.badRequestError
                default:
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(httpResponse.statusCode)
                }
                
                do {
                    // JSON -> struct로 디코딩 / 데이터 파싱
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                    
                    return baseResponse

                } catch {
                    // decoding error
                    throw ApiError.decodingError

                }
            })
        
    }
    
    /// 할 일 삭제
    /// - Parameters:
    ///   - id: 삭제할 데이터 아이디
    ///   - completion: 컴플레션
    static func deleteATodoWithObservable(id: Int) -> Observable<BaseResponse<Todo>> {
        
        // 1. urlRequest 만들기
        // 2. urlSession으로 API 호출
        // 3. API 호출에 대한 응답을 받는다
        
        let urlString = baseURL + "/todos" + "/\(id)"
        
        guard let url = URL(string: urlString) else {
            return Observable.error(ApiError.notAllowedURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession
            .shared
            .rx
            .response(request: urlRequest)
            .map({ (urlResponse: HTTPURLResponse, data: Data) -> BaseResponse<Todo> in
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print(#fileID, #function, #line, "- bad Status code: ")
                    throw ApiError.unknownError(nil)
                }

                
                switch httpResponse.statusCode {
                case 400:
                    throw ApiError.badRequestError
                case 204:
                    throw ApiError.badRequestError
                default:
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(httpResponse.statusCode)
                }
                
                do {
                    // JSON -> struct로 디코딩 / 데이터 파싱
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                    
                    return baseResponse

                } catch {
                    // decoding error
                    throw ApiError.decodingError
                }
            })
    }
    
    
    /// 할 일 추가 -> 모든 할 일 가져오기 (연쇄 처리)
    /// - Parameters:
    ///   - title:
    ///   - isDone:
    ///   - completion:
    static func addATodoAndFetchTodosWithObservable(title: String, isDone: Bool = false) -> Observable<[Todo]> {
        
        // 1.
        return self.addATodoWithObservable(title: title)
            .flatMapLatest { _ in
                self.fetchTodosWithObservable()
            } // BaseListResponse<Todo>
            .compactMap{ $0.data } // [Todo]
            .catch({ err in
                return Observable.just([])
            })
            .share(replay: 1)
    }
    
    
    /// 선택된 할 일들 삭제 (클로저 기반 모두 삭제, 연쇄 처리)
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할 일 아이디들
    ///   - completion: 실제 삭제가 완료된 아이디들
    static func deleteSelectedTodosWithObservableWithZip(selectedTodoIds: [Int]) -> Observable<[Int]> {
        
        // 1. 매개변수 배열 -> Observable 스트림 배열로 만들기
        
        // 2. 배열로 단일 API 호출
        let apiCallObservables = selectedTodoIds.map{ id -> Observable<Int?> in
            return self.deleteATodoWithObservable(id: id)
                .map{ $0.data?.id } // Int?
                .catchAndReturn(nil)
//                .catch{ err in
//                    return Observable.just(nil)
//                }
        }
        
        return Observable.zip(apiCallObservables) // Observable<[Int?]>
            .map{ $0.compactMap{ $0 } } // [Int]
    }
    
    static func deleteSelectedTodosWithObservableWithMerge(selectedTodoIds: [Int]) -> Observable<Int> {
        
        // 1. 매개변수 배열 -> Observable 스트림 배열로 만들기
        
        // 2. 배열로 단일 API 호출
        let apiCallObservables = selectedTodoIds.map{ id -> Observable<Int?> in
            return self.deleteATodoWithObservable(id: id)
                .map{ $0.data?.id } // Int?
                .catchAndReturn(nil)
        }
        
        return Observable.merge(apiCallObservables).compactMap{ $0 }
    }
    
    /// 선택된 할 일들 가져오기
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할 일 아이디들
    ///   - completion: 응답 결과
    static func fetchedSelectedTodosWithObservableWithZip(selectedTodoIds: [Int]) -> Observable<[Int]> {
        
        let apiCallObservables = selectedTodoIds.map{ id -> Observable<Int?> in
            return self.fetchATodoWithObservable(id: id)
                .map{ $0.data?.id}
                .catchAndReturn(nil)
        }
        
        return Observable.zip(apiCallObservables)
            .map{ $0.compactMap{ $0 } }
        
    }
    
    static func fetchedSelectedTodosWithObservableWithMerge(selectedTodoIds: [Int]) -> Observable<Int> {
        
        let apiCallObservables = selectedTodoIds.map{ id -> Observable<Int?> in
            return self.fetchATodoWithObservable(id: id)
                .map{ $0.data?.id}
                .catchAndReturn(nil)
        }
        
        return Observable.merge(apiCallObservables).compactMap{ $0 }
        
    }
    
}
