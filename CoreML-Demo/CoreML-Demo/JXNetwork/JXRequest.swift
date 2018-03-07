
//
//  JXRequest.swift
//  ShoppingGo
//
//  Created by 杜进新 on 2017/6/12.
//  Copyright © 2017年 杜进新. All rights reserved.
//

import UIKit
import AFNetworking

class JXRequest: JXBaseRequest {
    

    var construct : constructingBlock? {
        set{
            self.construct = newValue
        }
        get{
            return nil
        }
    }
    override func customConstruct() ->constructingBlock?  {
        return nil
    }
    
    override func requestSuccess(responseData: Any) {
        super.requestSuccess(responseData: responseData)
        //afmanager.responseSerializer = AFJSONResponseSerializer.init() json为NSArray or NSDictionary
        //AFHTTPResponseSerializer 为Data
        
        if type(of: JXNetworkManager.manager.afmanager.responseSerializer) == AFHTTPResponseSerializer.self{
            guard let data = responseData as? Data,
                let jsonData = try? JSONSerialization.jsonObject(with: data, options: [])
                else{
                    handleResponseResult(result: nil, message: "数据解析失败", code: JXNetworkError.kResponseUnknow.rawValue, isSuccess: false)
                    return
            }
            
            handleResponseResult(result: jsonData)
        }else if type(of: JXNetworkManager.manager.afmanager.responseSerializer) == AFJSONResponseSerializer.self{
            //let isJson = JSONSerialization.isValidJSONObject(responseData)
            if  JSONSerialization.isValidJSONObject(responseData) {
                handleResponseResult(result: responseData)
            }else{
                print("responseData is not jsonObject")
                handleResponseResult(result: nil, message: "数据解析失败", code: JXNetworkError.kResponseUnknow.rawValue, isSuccess: false)
            }
        }else{
            print("responseData is unknow")
            handleResponseResult(result: nil, message: "数据解析失败", code: JXNetworkError.kResponseUnknow.rawValue, isSuccess: false)
        }
        
        
    }
    override func requestFailure(error: Error) {
        print("请求失败:\(error)")
        handleResponseResult(result: error)
    }
    func handleResponseResult(result:Any?) {

        var msg = "请求失败"
        var netCode : Int = -9999
        var data : Any? = nil
        var isSuccess : Bool = false
        
        //print(self)
        print("requestUrl = \(self.requestUrl ?? "")")
        print("requestParam = \(self.param ?? [:])")
        print("responseData = \(result ?? "")")
        
        if result is Dictionary<String, Any> {
            
            let jsonDict = result as! Dictionary<String, Any>
 
            guard let code = jsonDict["status"] as? Int
                else {
                    msg = "状态码未知"
                    handleResponseResult(result: jsonDict, message: msg, code: JXNetworkError.kResponseUnknow.rawValue, isSuccess: true)
                    return
            }
            
            let message = jsonDict["message"] as? String
            msg = message ?? "失败"
            netCode = code
            
            if (code == JXNetworkError.kResponseSuccess.rawValue){
                data = jsonDict["data"]
                msg = message ?? "成功"
                isSuccess = true
            }else if code == JXNetworkError.kResponseShortTokenDisabled.rawValue{
                
            }else if code == JXNetworkError.kResponseLongTokenDisabled.rawValue{
               
            }else{
                msg = message ?? "失败"
            }
            
        }else if result is Array<Any>{
            print("Array")
        }else if result is String{
            print("String")
        }else if result is Error{
            print("Error")
            guard let error = result as? NSError,
                let code = JXNetworkError(rawValue: error.code)
                else {
                    handleResponseResult(result: data, message: "Error", code: JXNetworkError.kResponseUnknow.rawValue, isSuccess: isSuccess)
                    return
            }
            netCode = code.rawValue
            switch code {
            case .kRequestErrorCannotConnectToHost,
                 .kRequestErrorCannotFindHost,
                 .kRequestErrorNotConnectedToInternet,
                 .kRequestErrorNetworkConnectionLost,
                 .kRequestErrorUnknown:
                msg = kRequestNotConnectedDomain;
                break;
            case .kRequestErrorTimedOut:
                msg = kRequestTimeOutDomain;
                break;
            case .kRequestErrorResourceUnavailable:
                msg = kRequestResourceUnavailableDomain;
                break;
            case .kResponseDataError:
                msg = kRequestResourceDataErrorDomain;
                break;
            default:
                msg = error.localizedDescription;
                break;
            }
            
        }else{
            print("未知数据类型")
        }
        handleResponseResult(result: data, message: msg, code: netCode, isSuccess: isSuccess)
    }
    func handleResponseResult(result:Any?,message:String,code:Int,isSuccess:Bool) {
        
        
        //        if result is Dictionary<String, Any> {
        //            print("Dictionary")
        //
        //        }else if result is Array<Any>{
        //            print("Array")
        //        }else if result is String{
        //            print("String")
        //        }else if result is NSNull{
        //            print("NULL")
        //        }else{
        //            print("未知数据类型")
        //        }
        
        
        guard let success = self.success,
            let failure = self.failure
            else {
                return
        }
        
        if isSuccess {
            success(result,message)
        }else{
            failure(message,code)
        }
    }
}

