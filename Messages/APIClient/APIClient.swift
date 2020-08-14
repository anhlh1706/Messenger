//
//  APIClient.swift
//  Base
//
//  Created by Hoàng Anh on 30/07/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import Foundation
import Alamofire
import SystemConfiguration
import SwiftyJSON

typealias CallBack = (Swift.Result<Decodable, Error>) -> Void
typealias UploadProgress = (Double, Double, Double) -> Void // current, total, percent

final class APIClient {
    
    static func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    static func request<T: Decodable>(_ apiRouter: APIRouter,_ returnType: T.Type, completion: @escaping (Swift.Result<T, Error>) -> Void) {
        
        guard isConnectedToInternet() else {
            AppHelper.visibleViewController?.showNoInternetAlert()
            let error = NSError(domain: "", code: ErrorCode.noInternet.rawValue, userInfo: nil)
            completion(.failure(error))
            return
        }
        
        AF.request(apiRouter).validate().responseJSON { response in
            switch response.result {
            case .success(let data):
                let statusCode = response.response?.statusCode ?? 0
                if (200..<300).contains(statusCode) {
                    do {
                        let rawData = try JSON(data).rawData()
                        let objects = try AppHelper.decoder.decode(T.self, from: rawData)
                        
                        completion(.success(objects))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    handleError(errorCode: ErrorCode(rawValue: statusCode))
                }
            case .failure(let error):
                if let error = response.error, error._code == NSURLErrorTimedOut {
                    AppHelper.showAlert(msg: Text.connectTimedOutMsg)
                }
                completion(.failure(error))
            }
        }
    }
    
    static func uploadImage<T: Decodable>(_ apiRouter: APIRouter, returnType: T.Type = T.self, uploadProgress: UploadProgress? = nil, completion: @escaping CallBack) {
        guard isConnectedToInternet() else {
            AppHelper.showAlert(msg: Text.noInternetMsg)
            let errorTemp = NSError(domain: "", code: 10000, userInfo: nil)
            completion(.failure(errorTemp))
            return
        }
        
        AF.upload(multipartFormData: { multipartFormData in
            self.addObjectToMutilPart(apiRouter.parameters ?? [:], multipartFormData: multipartFormData)
        }, with: apiRouter).uploadProgress { progress in
            let current = Double(progress.completedUnitCount)
            let total = Double(progress.totalUnitCount)
            uploadProgress?(current, total, progress.fractionCompleted)
        }.responseJSON { response in
            switch response.result {
            case .success(let data):
                let statusCode = response.response?.statusCode ?? 0
                if (200..<300).contains(statusCode) {
                    do {
                        let rawData = try JSON(data).rawData()
                        let objects = try AppHelper.decoder.decode(T.self, from: rawData)
                        
                        completion(.success(objects))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    handleError(errorCode: ErrorCode(rawValue: statusCode))
                }
            case .failure(let error):
                if let error = response.error, error._code == NSURLErrorTimedOut {
                    AppHelper.showAlert(msg: Text.connectTimedOutMsg)
                }
                completion(.failure(error))
            }
        }
    }
}

extension APIClient {
    
    static func handleError(errorCode: ErrorCode?) {
        let topVC = AppHelper.visibleViewController
        switch errorCode {
        case .requestUpdateApp:
            topVC?.showAlertUpdateApp()
        default:
            break
        }
    }
    
    static func addObjectToMutilPart(_ param: Parameters, multipartFormData: MultipartFormData) {
        let total = param.keys.count
        if total > 0 {
            for (key, value) in param {
                if param[key] is UIImage {
                    // do nothing
                } else {
                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                }
            }
        }

        let timestamp = "\(Date().timeIntervalSince1970)"
        for key in param.keys {
            if let image = param[key] as? UIImage {
                var dataImage: Data?
                guard let resizeImage = image.resizedImage() else { return }
                if let data = resizeImage.png(), image.size.width > 0 {
                    dataImage = data
                }
                if let dataImage = dataImage {
                    multipartFormData.append(dataImage, withName: key, fileName: "img_\(timestamp).png", mimeType: "image/png")
                }
            }
        }
    }
}
