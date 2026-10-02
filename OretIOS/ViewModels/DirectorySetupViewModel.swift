//
//  DirectorySetupViewModel.swift
//  OretIOS
//
//  ViewModel for Working Directory Setup & Path Validation
//

import Foundation
import Observation

@Observable
public final class DirectorySetupViewModel {
    public var folderName: String = WorkspaceConfiguration.defaultFolderName {
        didSet {
            validatePath()
        }
    }
    public var validationError: String? = nil
    public var isValid: Bool = true
    public var isInitializing: Bool = false
    public var isInitialized: Bool = false

    public init() {
        validatePath()
    }

    public func validatePath() {
        let result = WorkspaceConfiguration.validate(folderName: folderName)
        self.isValid = result.isValid
        self.validationError = result.errorMessage
    }

    public func confirmAndInitialize(completion: @escaping (Result<String, Error>) -> Void) {
        validatePath()
        guard isValid else {
            if let error = validationError {
                completion(.failure(NSError(domain: "OretDirectorySetup", code: 400, userInfo: [NSLocalizedDescriptionKey: error])))
            }
            return
        }

        isInitializing = true

        // Simulate or perform local sandbox directory initialization
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            self.isInitializing = false
            self.isInitialized = true

            // Persist configured localPath
            let cleanFolder = self.folderName.trimmingCharacters(in: .whitespacesAndNewlines)
            UserDefaults.standard.set(cleanFolder, forKey: "localPath")

            completion(.success(cleanFolder))
        }
    }
}
