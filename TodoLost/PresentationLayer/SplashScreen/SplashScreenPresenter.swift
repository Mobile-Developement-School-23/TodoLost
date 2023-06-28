//
//  SplashScreenPresenter.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 28.06.2023
//

import UIKit

protocol ISplashScreenPresenter {
    func present()
    func dismiss(completion: (() -> Void)?)
}

final class SplashScreenPresenter {
    
    // MARK: - Private properties
    
    private lazy var animator: ISplashScreenAnimator = SplashScreenAnimator(
        foregroundSplashWindow: foregroundSplashWindow,
        backgroundSplashWindow: backgroundSplashWindow
    )
    
    private lazy var foregroundSplashWindow: UIWindow = {
        var splashVC = createSplashVC(logoIsHidden: false)
        
        return splashWindow(
            level: .normal + 1,
            rootViewController: splashVC
        )
    }()
    
    private lazy var backgroundSplashWindow: UIWindow = {
        var splashVC = createSplashVC(logoIsHidden: true)
        
        return splashWindow(
            level: .normal - 1,
            rootViewController: splashVC
        )
    }()
    
    private func createSplashVC(logoIsHidden: Bool) -> SplashScreenViewController {
        let splashVC = SplashScreenViewController(
            nibName: String(describing: SplashScreenViewController.self),
            bundle: nil
        )
        splashVC.logoIsHidden = logoIsHidden
        
        return splashVC
    }
    
    private func splashWindow(
        level: UIWindow.Level,
        rootViewController: SplashScreenViewController
    ) -> UIWindow {
        let splashWindow = UIWindow()
        splashWindow.windowLevel = level
        splashWindow.rootViewController = rootViewController
        
        return splashWindow
    }
}

// MARK: - ISplashScreenPresenter

extension SplashScreenPresenter: ISplashScreenPresenter {
    
    func present() {
        animator.animateAppearance()
    }
    
    func dismiss(completion: (() -> Void)?) {
        animator.animateDisappearance(completion: completion)
    }
}
