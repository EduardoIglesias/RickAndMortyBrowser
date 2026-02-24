//
//  DefaultNetworkClientTests.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 24/2/26.
//

import Foundation
import Testing
@testable import RickAndMortyBrowser

@Suite("DefaultNetworkClient")
struct DefaultNetworkClientTests {

    private struct SampleDTO: Decodable, Equatable {
        let name: String
    }

    @Test
    @MainActor
    func request_200_decodesAndReturnsDTO() async throws {
        defer { URLProtocolStub.reset() }

        let id = UUID().uuidString
        let baseURL = try Self.makeURL("https://example.com/api")
        let endpoint = Endpoint(baseURL: baseURL, path: "test-\(id)")
        let request = try endpoint.makeURLRequest()
        let url = try #require(request.url)

        let json = #"{"name":"Rick"}"#
        let data = Data(json.utf8)

        let response = try #require(
            HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        )

        var capturedAccept: String?
        var intercepted = false

        URLProtocolStub.setStub(
            for: url,
            data: data,
            response: response,
            error: nil,
            requestObserver: { req in
                intercepted = true
                capturedAccept = req.value(forHTTPHeaderField: "Accept")
            }
        )

        let client = Self.makeClient()
        let dto: SampleDTO = try await client.request(endpoint)

        #expect(intercepted == true)
        #expect(dto == SampleDTO(name: "Rick"))
        #expect(capturedAccept == "application/json")
    }

    @Test
    @MainActor
    func request_non2xx_throwsHttpStatus_withBody() async throws {
        defer { URLProtocolStub.reset() }

        let id = UUID().uuidString
        let baseURL = try Self.makeURL("https://example.com/api")
        let endpoint = Endpoint(baseURL: baseURL, path: "test-\(id)")
        let request = try endpoint.makeURLRequest()
        let url = try #require(request.url)

        let body = "Not Found"
        let data = Data(body.utf8)

        let response = try #require(
            HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)
        )

        URLProtocolStub.setStub(for: url, data: data, response: response, error: nil)

        let client = Self.makeClient()

        do {
            let _: SampleDTO = try await client.request(endpoint)
            #expect(Bool(false))
        } catch let error as NetworkError {
            switch error {
            case .httpStatus(let code, let returnedData):
                #expect(code == 404)
                let returnedBody = returnedData.flatMap { String(data: $0, encoding: .utf8) }
                #expect(returnedBody == "Not Found")
            default:
                #expect(Bool(false))
            }
        } catch {
            #expect(Bool(false))
        }
    }

    @Test
    @MainActor
    func request_200_withInvalidJSON_throwsDecodingFailed() async throws {
        defer { URLProtocolStub.reset() }

        let id = UUID().uuidString
        let baseURL = try Self.makeURL("https://example.com/api")
        let endpoint = Endpoint(baseURL: baseURL, path: "test-\(id)")
        let request = try endpoint.makeURLRequest()
        let url = try #require(request.url)

        let data = Data("invalid-json".utf8)

        let response = try #require(
            HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        )

        URLProtocolStub.setStub(for: url, data: data, response: response, error: nil)

        let client = Self.makeClient()

        do {
            let _: SampleDTO = try await client.request(endpoint)
            #expect(Bool(false))
        } catch let error as NetworkError {
            #expect(error == .decodingFailed)
        } catch {
            #expect(Bool(false))
        }
    }

    @Test
    @MainActor
    func request_nonHTTPResponse_throwsInvalidResponse() async throws {
        defer { URLProtocolStub.reset() }

        let id = UUID().uuidString
        let baseURL = try Self.makeURL("https://example.com/api")
        let endpoint = Endpoint(baseURL: baseURL, path: "test-\(id)")
        let request = try endpoint.makeURLRequest()
        let url = try #require(request.url)

        let response = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)

        URLProtocolStub.setStub(for: url, data: Data(), response: response, error: nil)

        let client = Self.makeClient()

        do {
            let _: SampleDTO = try await client.request(endpoint)
            #expect(Bool(false))
        } catch let error as NetworkError {
            #expect(error == .invalidResponse)
        } catch {
            #expect(Bool(false))
        }
    }

    @Test
    @MainActor
    func request_transportError_throwsTransportError() async throws {
        defer { URLProtocolStub.reset() }

        let id = UUID().uuidString
        let baseURL = try Self.makeURL("https://example.com/api")
        let endpoint = Endpoint(baseURL: baseURL, path: "test-\(id)")
        let request = try endpoint.makeURLRequest()
        let url = try #require(request.url)

        URLProtocolStub.setStub(
            for: url,
            data: nil,
            response: nil,
            error: URLError(.notConnectedToInternet)
        )

        let client = Self.makeClient()

        do {
            let _: SampleDTO = try await client.request(endpoint)
            #expect(Bool(false))
        } catch let error as NetworkError {
            switch error {
            case .transportError(let message):
                #expect(message.isEmpty == false)
            default:
                #expect(Bool(false))
            }
        } catch {
            #expect(Bool(false))
        }
    }


    // MARK: - Helpers

    private static func makeClient() -> DefaultNetworkClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self] // solo stub
        let session = URLSession(configuration: config)
        return DefaultNetworkClient(session: session)
    }

    private static func makeURL(_ string: String) throws -> URL {
        guard let url = URL(string: string) else {
            throw URLError(.badURL)
        }
        return url
    }
}

