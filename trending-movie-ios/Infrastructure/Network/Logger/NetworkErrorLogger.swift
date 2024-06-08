//
//  NetworkErrorLogger.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 5/6/24.
//

import Foundation

protocol NetworkErrorLogger {
    func log(request: URLRequest)
    func log(responseData data: Data?, response: URLResponse?)
    func log(error: Error)
}

final class DefaultNetworkErrorLogger: NetworkErrorLogger {
    func log(request: URLRequest) {
        printIfDebug("[\(request.cURL)]" + "\n")
    }

    func log(responseData data: Data?, response: URLResponse?) {
        guard let data = data else { return }
        if let dataDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            printIfDebug("[Response: \(String(describing: dataDict))]")
        }
    }

    func log(error: Error) {
        printIfDebug("\(error)")
    }
}

extension URLRequest {
    var cURL: String {
        guard let url = self.url else {
            return ""
        }
        var method = "GET"
        if let aMethod = self.httpMethod {
            method = aMethod
        }
        let baseCommand = "curl -X \(method) '\(url.absoluteString)'"
        var command: [String] = [baseCommand]
        if let headers = self.allHTTPHeaderFields {
            for (key, value) in headers {
                command.append("-H '\(key): \(value)'")
            }
        }

        if let httpBodyString = self.getHttpBodyString() {
            command.append("-d '\(httpBodyString)'")
        }
        return command.joined(separator: " ")
    }

    fileprivate func getHttpBodyString() -> String? {
        if let httpBodyString = self.getHttpBodyStream() {
            return httpBodyString
        }
        if let httpBodyString = self.getHttpBody() {
            return httpBodyString
        }
        return nil
    }

    fileprivate func getHttpBodyStream() -> String? {
        guard let httpBodyStream = self.httpBodyStream else {
            return nil
        }
        let data = NSMutableData()
        var buffer = [UInt8](repeating: 0, count: 4096)

        httpBodyStream.open()
        while httpBodyStream.hasBytesAvailable {
            let length = httpBodyStream.read(&buffer, maxLength: 4096)
            if length == 0 {
                break
            } else {
                data.append(&buffer, length: length)
            }
        }
        return NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue) as String?
    }

    fileprivate func getHttpBody() -> String? {
        guard let httpBody = httpBody, httpBody.count > 0 else {
            return nil
        }
        guard let httpBodyString = String(data: httpBody, encoding: String.Encoding.utf8) else {
            return nil
        }
        let escapedHttpBody = self.escapeAllSingleQuotes(httpBodyString)
        return escapedHttpBody
    }

    func escapeAllSingleQuotes(_ value: String) -> String {
        return value.replacingOccurrences(of: "'", with: "'\\''")
    }
}
