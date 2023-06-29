//
//  SplashScreenViewController.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 28.06.2023
//

import UIKit

final class SplashScreenViewController: UIViewController {
    
    // MARK: - Public properties
    
    static let logoImage = UIImage(named: "noteIcon")
    var logoIsHidden: Bool = false
    
    // MARK: - Outlets
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var appTitle: UILabel!
    @IBOutlet weak var loadInformLabel: UILabel!
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoImageView.isHidden = logoIsHidden
    }
}
