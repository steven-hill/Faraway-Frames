//
//  HomeVC.swift
//  Faraway Frames
//
//  Created by Steven Hill on 22/03/2026.
//

import UIKit

final class HomeVC: UIViewController {

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Home"
    }
}
