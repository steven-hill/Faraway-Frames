//
//  SpinnerVC.swift
//  Faraway Frames
//
//  Created by Steven Hill on 23/01/2026.
//

import UIKit

class SpinnerVC: UIViewController {
    
    var spinner = UIActivityIndicatorView(style: .large)
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.25)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .black
        spinner.startAnimating()
        view.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
