//
//  DatabaseErrorVC.swift
//  Faraway Frames
//
//  Created by Steven Hill on 04/06/2026.
//

import UIKit

final class DatabaseErrorVC: UIViewController {
    
    //MARK: - Property
    private let errorMessage: String
    
    //MARK: - Initialisation
    init(errorMessage: String) {
        self.errorMessage = errorMessage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupErrorUI()
    }
    
    private func setupErrorUI() {
        var config = UIContentUnavailableConfiguration.empty()
        config.text = "Database Error"
        config.secondaryText = errorMessage + " Check device storage and try relaunching the app."
        config.image = SFSymbols.exclamationMarkTriangle
        config.imageProperties.tintColor = .systemRed
        self.contentUnavailableConfiguration = config
    }
}

//MARK: - Preview
#Preview("Database Error VC") {
    let vc = DatabaseErrorVC(errorMessage: "Failed to load database. Check device storage and try relaunching the app.")
    vc
}
