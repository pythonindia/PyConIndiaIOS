//
//  cloud.swift
//  PyconIndia
//
//  Created by Rishi Mukherjee on 30/06/15.
//  Copyright (c) 2015 Rishi Mukherjee. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

// All API related code here.
class Cloud {

    let BASE_URL = "https://in.pycon.org/cfp/api/v1/"
    var manager: Alamofire.Manager!

    func apiRequest(path: String, method: Alamofire.Method = .GET, parameters: [String: AnyObject] = [:], successCallback: ((JSON) -> ())?, errorCallback: ((NSError) -> ())?) {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 4 // seconds
        configuration.timeoutIntervalForResource = 4
        manager = Alamofire.Manager(configuration: configuration)

        manager.request(method, path, parameters: parameters, encoding: ParameterEncoding.JSON)
            .responseJSON{ (request, response, data, error) in
                if let errorResponse = error {
                    errorCallback?(errorResponse)
                } else {
                    let jsonData = JSON(data!)
                    successCallback?(jsonData)
                }
        }

        //manager.request(<#method: Method#>, <#URLString: URLStringConvertible#>, parameters: <#[String : AnyObject]?#>, encoding: ParameterEncoding.)
    }

    func registerDevice(uuid: String, success: ((JSON) -> ())?, error: ((NSError) -> ())?) {
        let path = BASE_URL + "devices"
        self.apiRequest(path,
            method: .POST,
            parameters: ["uuid": uuid],
            successCallback: {
                response in
                success?(response)
            },
            errorCallback: {
                errorResponse in
                error?(errorResponse)
            }
        )
    }

    func getSchedule(success: ((JSON) -> ())?, error: ((NSError) -> ())?) {
        let path = BASE_URL + "schedules/?conference=1"
        self.apiRequest(path,
            successCallback: {
                response in
                success?(response)
            },
            errorCallback: {
                errorResponse in
                error?(errorResponse)
        })
    }

    func getRooms(success: ((JSON) -> ())?, error: ((NSError) -> ())?) {
        let path = BASE_URL + "rooms/?venue=1"
        self.apiRequest(path,
            successCallback: {
                response in
                success?(response)
            },
            errorCallback: {
                errorResponse in
                error?(errorResponse)
        })
    }

}