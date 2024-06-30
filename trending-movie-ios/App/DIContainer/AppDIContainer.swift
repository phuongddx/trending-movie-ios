//
//  AppDIContainer.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 5/6/24.
//

import Foundation
import SwiftThemoviedbWrap

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        
    }
}

final class AppDIContainer {
    
    lazy var appConfiguration = AppConfiguration()
    
    // MARK: - Network
    lazy var apiDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(baseURL: URL(string: appConfiguration.apiBaseURL)!,
                                          queryParameters: [
                                            "api_key": appConfiguration.apiKey,
                                            "language": NSLocale.preferredLanguages.first ?? "en"])
        NetworkWrapConfigurationTmdb.apiKey = appConfiguration.apiKey
        NetworkWrapConfigurationTmdb.language = NSLocale.preferredLanguages.first ?? "en-US"
        return DefaultDataTransferService()
    }()

    lazy var imageDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(baseURL: URL(string: appConfiguration.imagesBaseURL)!)
        let imagesDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService()
    }()

    // MARK: - DIContainers of scenes
    func makeMoviesSceneDIContainer() -> MoviesSceneDIContainer {
        let dependencies = MoviesSceneDIContainer.Dependencies(apiDataTransferService: apiDataTransferService,
                                                               imageDataTransferService: imageDataTransferService)
        return MoviesSceneDIContainer(dependencies: dependencies)
    }
}
