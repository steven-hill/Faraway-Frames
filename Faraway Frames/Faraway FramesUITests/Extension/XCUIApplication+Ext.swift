//
//  XCUIApplication+Ext.swift
//  Faraway FramesUITests
//
//  Created by Steven Hill on 23/02/2026.
//

import XCTest

extension XCUIApplication {
    func launch(with error: UITestNetworkError) {
        self.launchArguments += ["-UITesting",
                                "-UITestingMockNetworkFailure"]
        
        switch error {
        case .noInternetConnection:
            self.launchEnvironment["MOCK_ERROR_TYPE"] = "noInternetConnection"
        case .networkConnectionLost:
            self.launchEnvironment["MOCK_ERROR_TYPE"] = "networkConnectionLost"
        case .networkTimeout:
            self.launchEnvironment["MOCK_ERROR_TYPE"] = "networkTimeout"
        case .invalidURL:
            self.launchEnvironment["MOCK_ERROR_TYPE"] = "invalidURL"
        case .invalidResponse:
            self.launchEnvironment["MOCK_ERROR_TYPE"] = "invalidResponse"
        case .serverError(statusCode: let statusCode):
            self.launchEnvironment["MOCK_ERROR_TYPE"] = "serverError"
            self.launchEnvironment["MOCK_ERROR_CODE"] = "\(statusCode)"
        case .decodingError:
            self.launchEnvironment["MOCK_ERROR_TYPE"] = "decodingError"
        case .unknown:
            self.launchEnvironment["MOCK_ERROR_TYPE"] = "Unknown error"
        }
        self.launch()
    }
    
    func launchHomeVC(with persistenceError: UITestPersistenceError) {
        self.launchArguments = ["-UITesting",
                                "-UITestingHomeVCPersistenceLoadError"]
        guard persistenceError == .fetchFromDatabaseError else { return }
        self.launchEnvironment["MOCK_CD_FAILURE_REASON"] = "databaseError"
        self.launch()
    }
    
    func launchExploreDetailVCForSaveError(with persistenceError: UITestPersistenceError) {
        self.launchArguments = ["-UITesting",
                                "-UITestingMockNetworkSuccess",
                                "-UITestingMockPersistenceData",
                                "-UITestingPersistenceSaveError"]
        
        switch persistenceError {
        case .addToQueueDiskFull:
            self.launchEnvironment["MOCK_CD_FAILURE_REASON"] = "diskFull"
        case .addToQueueDatabaseError:
            self.launchEnvironment["MOCK_CD_FAILURE_REASON"] = "databaseError"
        case .deleteFromQueueDatabaseError:
            self.launchEnvironment["MOCK_CD_FAILURE_REASON"] = "databaseError"
        case .fetchFromDatabaseError:
            self.launchEnvironment["MOCK_CD_FAILURE_REASON"] = "databaseError"
        }
        self.launch()
    }
    
    func launchExploreDetailVCForFetchError(with persistenceError: UITestPersistenceError) {
        self.launchArguments = ["-UITesting",
                                "-UITestingMockNetworkSuccess",
                                "-UITestingExploreDetailVCPersistenceLoadError"
                                ]
        guard persistenceError == .fetchFromDatabaseError else { return }
        self.launchEnvironment["MOCK_CD_FAILURE_REASON"] = "databaseError"
        self.launch()
    }
}
