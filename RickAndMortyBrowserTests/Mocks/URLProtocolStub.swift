//
//  URLProtocolStub.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 24/2/26.
//

import Foundation

final class URLProtocolStub: URLProtocol {

    struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
        let requestObserver: ((URLRequest) -> Void)?
    }

    private static let queue = DispatchQueue(label: "URLProtocolStub.queue")
    private static var stubsByURL: [URL: Stub] = [:]

    static func setStub(
        for url: URL,
        data: Data? = nil,
        response: URLResponse? = nil,
        error: Error? = nil,
        requestObserver: ((URLRequest) -> Void)? = nil
    ) {
        queue.sync {
            stubsByURL[url] = Stub(data: data, response: response, error: error, requestObserver: requestObserver)
        }
    }

    static func reset() {
        queue.sync { stubsByURL.removeAll() }
    }

    private static func stub(for url: URL?) -> Stub? {
        guard let url else { return nil }
        return queue.sync { stubsByURL[url] }
    }

    // clave para async/await
    override class func canInit(with task: URLSessionTask) -> Bool {
        stub(for: task.currentRequest?.url) != nil || stub(for: task.originalRequest?.url) != nil
    }

    override class func canInit(with request: URLRequest) -> Bool {
        stub(for: request.url) != nil
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let url = request.url
        guard let stub = Self.stub(for: url) else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }

        stub.requestObserver?(request)

        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
