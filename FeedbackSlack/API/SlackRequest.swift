//
//  SlackRequest.swift
//  SlackTest
//
//  Created by Kazuya Ueoka on 2016/08/22.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import Foundation

extension String {
    var urlEscape: String? {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    }
}

enum SlackMethods: String {
    case apiTest = "api.test"
    case authRevoke = "auth.revoke"
    case authTest = "auth.test"
    case filesUpload = "files.upload"
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
}

protocol RequestType {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var request: NSURLRequest { get }
    var queries: [String:String]? { get }
    var bodyParameters: [String:String]? { get }
}

extension RequestType {
    var queries: [String: String]? {
        return nil
    }
    var bodyParameters: [String:String]? {
        return nil
    }

    private func queryString(queries: [String:String]?) -> String {
        var queryString: String = ""
        if let queries = queries {
            queryString = queries.keys.flatMap({ (key: String) -> String? in
                guard let key = key.urlEscape, value = queries[key]?.urlEscape else {
                    return nil
                }

                return "\(key)=\(value)"
            }).joinWithSeparator("&")
        }
        return queryString
    }

    private var boundary: String {
        return NSUUID().UUIDString
    }

    var request: NSURLRequest {
        let url: NSURL = NSURL(string: self.baseURL + self.path + "?\(self.queryString(self.queries))")!
        let result: NSMutableURLRequest = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: 60.0)
        result.HTTPMethod = self.method.rawValue

        switch self.method {
        case .POST:
            if let bodyParameters = self.bodyParameters {
                result.HTTPBody = self.queryString(bodyParameters).dataUsingEncoding(NSUTF8StringEncoding)
            }
        default:
            break
        }

        return result
    }
}

protocol SlackRequest: RequestType {
    var token: String { get set }
}

extension SlackRequest {
    var baseURL: String {
        return "https://slack.com/api/"
    }

    var queries: [String: String]? {
        return ["token": self.token]
    }
}

protocol UploadRequest: SlackRequest {
    var filename: String { get set }
    var data: NSData { get set }
    var contentType: String { get set }
    var title: String? { get set }
    var initialComment: String? { get set }
    var channels: [String]? { get set }
}

extension UploadRequest {
    var path: String {
        return SlackMethods.filesUpload.rawValue
    }

    var method: HTTPMethod {
        return HTTPMethod.POST
    }

    var request: NSURLRequest {
        let url: NSURL = NSURL(string: self.baseURL + self.path + "?\(self.queryString(self.queries))")!
        let result: NSMutableURLRequest = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: 60.0)
        result.HTTPMethod = self.method.rawValue

        let boundaryConstant = self.boundary
        let contentType = "multipart/form-data; boundary=" + boundaryConstant
        let boundaryStart = "--\(boundaryConstant)\r\n"
        let boundaryEnd = "--\(boundaryConstant)--\r\n"
        let contentDispositionString = "Content-Disposition: form-data; name=\"file\"; filename=\"\(self.filename)\"\r\n"
        let contentTypeString = "Content-Type: \(self.contentType)\r\n\r\n"

        let requestBodyData: NSMutableData = NSMutableData()
        requestBodyData.appendData(boundaryStart.dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBodyData.appendData(contentDispositionString.dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBodyData.appendData(contentTypeString.dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBodyData.appendData(self.data)
        requestBodyData.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBodyData.appendData(boundaryEnd.dataUsingEncoding(NSUTF8StringEncoding)!)

        result.setValue(contentType, forHTTPHeaderField: "Content-Type")
        result.HTTPBody = requestBodyData

        return result
    }
}


struct FileUpload: UploadRequest {
    var token: String
    var filename: String
    var data: NSData
    var contentType: String
    var title: String?
    var initialComment: String?
    var channels: [String]?
    init(token: String, data: NSData, filename: String, contentType: String, title: String?, initialComment: String?, channels: [String]?) {
        self.token = token
        self.data = data
        self.filename = filename
        self.contentType = contentType
        self.title = title
        self.initialComment = initialComment
        self.channels = channels
    }

    var queries: [String : String]? {
        var result: [String: String] = [
            "token": self.token,
            "filename": self.filename,
            ]

        if let title = self.title {
            result["title"] = title
        }

        if let initialComment = self.initialComment {
            result["initial_comment"] = initialComment
        }

        if let channels = self.channels {
            result["channels"] = channels.joinWithSeparator(",")
        }

        return result
    }
}
