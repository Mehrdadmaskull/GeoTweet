//
//  OnboardingViewController.swift
//  GeographyTweet
//
//  Created by Mehrdad Ahmadi on 2019-03-21.
//  Copyright © 2019 Mehrdad Ahmadi. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    // MARK: - IBActions
    
    @IBAction func skipOnboarding(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Error", message: "Couldn't authenticate you. Please try again!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        let bearer = HelperMethods.existingToken(.bearer).bit
        let oauth = HelperMethods.existingToken(.oauth).bit
        
        if bearer.rawValue | oauth.rawValue == TokenBit.success.rawValue {
            performSegue(withIdentifier: "MainSegue", sender: nil)
        }
        else {
            if bearer.rawValue | oauth.rawValue == TokenBit.failure.rawValue {
                NetworkManager.basicAuthTwitter { [weak self] success in
                    if success {
                        NetworkManager.oauthTwitter(completionHandler: { [weak self] success in
                            if success {
                                self?.performSegue(withIdentifier: "MainSegue", sender: nil)
                            }
                            else {
                                self?.present(alertController, animated: true, completion: nil)
                            }
                        })
                    }
                    else {
                        self?.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            else if oauth.rawValue == TokenBit.failure.rawValue {
                NetworkManager.oauthTwitter { [weak self] success in
                    if success {
                        self?.performSegue(withIdentifier: "MainSegue", sender: nil)
                    }
                    else {
                        self?.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            else if bearer.rawValue == TokenBit.failure.rawValue {
                NetworkManager.basicAuthTwitter { [weak self] success in
                    if success {
                        self?.performSegue(withIdentifier: "MainSegue", sender: nil)
                    }
                    else {
                        self?.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    
    // MARK: - UIScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        pageControl.currentPage = Int(scrollView.contentOffset.x / pageWidth)
    }
    
}
