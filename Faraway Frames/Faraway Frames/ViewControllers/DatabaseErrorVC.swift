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
    
    init(errorMessage: String) {
        self.errorMessage = errorMessage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
