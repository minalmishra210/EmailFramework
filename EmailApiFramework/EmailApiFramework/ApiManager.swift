//
//  ApiManager.swift
//  EmailApiFramework
//
//  Created by Meenal Mishra on 02/07/24.
//

import Foundation
import Alamofire

public class APIManager {
    public static let shared = APIManager()
    
    private let baseUrl = "https://api.example.com" // Replace with your API base URL
    
    private init() { }
    
    private var retryDelay: TimeInterval = 2.0 // Initial retry delay
        
        public func getEmailAddresses(completion: @escaping (Result<[Dictionary<String, Any>], Error>) -> Void) {
            let url = "https://dummy.restapiexample.com/api/v1/employees"
            
            AF.request(url)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            // Parse JSON response
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            if let jsonDict = json as? [String: Any], let empDetails = jsonDict["data"] as? [[String: Any]] {
                                completion(.success(empDetails))
                            } else {
                                completion(.failure(NSError(domain: "Parsing Error", code: 0, userInfo: nil)))
                            }
                        } catch {
                            completion(.failure(error))
                        }
                    case .failure(let error):
                        if let afError = error as? AFError, afError.responseCode == 429 {
                            // Retry logic with exponential backoff
                            DispatchQueue.global().asyncAfter(deadline: .now() + self.retryDelay) {
                                self.getEmailAddresses(completion: completion) // Retry after delay
                            }
                            self.retryDelay *= 2 // Exponential backoff
                        } else {
                            completion(.failure(error))
                        }
                    }
                }
        }
//    public func getEmailAddresses(completion: @escaping (Result<[Dictionary<String, Any>], Error>) -> Void) {
//        AF.request("https://dummy.restapiexample.com/api/v1/employees")
//            .validate()
//            .responseJSON { response in
//                switch response.result {
//                case .success(_):
//                    if let jsonDict = response.value as? Dictionary<String,Any>, let empDetails = jsonDict["data"] as? [Dictionary<String,Any>] {
//                        
//                        completion(.success(empDetails))
//                    } else {
//                        completion(.failure(NSError(domain: "Parsing Error", code: 0, userInfo: nil)))
//                    }
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//            }
//    }
}


