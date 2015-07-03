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

    let BASE_URL = "https://junctiondemo.herokuapp.com/a-porro-conference/schedule/dummy_schedule/"

    func apiRequest(path: String, method: Alamofire.Method = .GET, parameters: [String: AnyObject] = [:], successCallback: ((JSON) -> ())?, errorCallback: ((NSError) -> ())?) {

        Alamofire.request(method, path, parameters: parameters)
            .responseJSON{ (request, response, data, error) in
                if let errorResponse = error {
                    errorCallback?(errorResponse)
                } else {
                    let jsonData = JSON(data!)
                    successCallback?(jsonData)
                }
        }
    }

    func getSchedule(success: ((JSON) -> ())?, error: ((NSError) -> ())?) {
        self.apiRequest(BASE_URL,
            successCallback: {
                response in
                success?(response)
            },
            errorCallback: nil)
    }

}