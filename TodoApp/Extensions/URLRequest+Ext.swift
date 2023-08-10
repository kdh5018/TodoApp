//
//  URLRequest+Ext.swift
//  TodoApp
//
//  Created by 김도훈 on 2023/06/21.
//

import Foundation

// URLRequest에서 URLEncoding을 하기 위해서 선언
extension URLRequest {
    
    private func percentEscapeString(_ string: String) -> String {
        var characterSet:CharacterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "-._* ")
        
        return string
            .addingPercentEncoding(withAllowedCharacters: characterSet)!
            .replacingOccurrences(of: " ", with: "+")
            .replacingOccurrences(of: " ", with: "+", options: [], range: nil)
    }
    
    // 자기 자신의 값을 변경하기 위해 사용한 mutating
    // 클래스(class)는 자기 자신의 값을 그냥 변경할 수 있는데 구조체(struct)는 값을 변경하기 위해서 mutating을 사용해야 함
    mutating func percentEncodeParameters(parameters: [String : String]) {
        
        let parameterArray : [String] = parameters.map { (arg) -> String in
            let (key, value) = arg
            return "\(key)=\(self.percentEscapeString(value))"
        }
        
        httpBody = parameterArray.joined(separator: "&").data(using: String.Encoding.utf8)
    }
}
