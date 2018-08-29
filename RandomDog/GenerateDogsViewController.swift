//
//  GenerateDogsViewController.swift
//  RandomDog
//
//  Created by Suhayb Al-Absi on 8/29/18.
//  Copyright © 2018 Suhayb Al-Absi. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage


class GenerateDogsViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var generateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func loadDogImage(urlPath:String) -> Void {
        
        self.generateButton.isEnabled = false
        
        LRUCache.shared.getImage(forUrl: urlPath) { [weak self] (image) in
            
            self?.generateButton.isEnabled = true
            self?.imageView.image = image
            
            if image == nil {
                self?.showDefaultErrorMessage()
            }
        }
    }

    
    @IBAction func generateRandomDog(_ sender: AnyObject) {
        
        self.generateButton.isEnabled = false
        
        Alamofire.request("https://dog.ceo/api/breeds/image/random").responseJSON { [weak self] (response) in
            
            self?.generateButton.isEnabled = true
            
            switch response.result {
            
            case .success(let data):
                
                guard let json = data as? [String:Any] else {
                    self?.showDefaultErrorMessage()
                    return
                }
                
                guard let message = json["message"] as? String else {
                    self?.showDefaultErrorMessage()
                    return
                }
                
                if let status = json["status"] as? String, status == "success" {
                    
                    self?.loadDogImage(urlPath: message)
                    
                } else {
                    
                    self?.showErrorMessage(message)
                }
                
                
            case .failure(let error):
                
                print(error.localizedDescription)
                self?.showDefaultErrorMessage()
            }
            
        }
    }
    
    func showDefaultErrorMessage() -> Void {
        
        self.showErrorMessage("Sorry !. Couldn't generate a dog for you at the moment. Try Again later !")
    }
    
    func showErrorMessage(_ message:String?) -> Void {
        
        let msg = message ?? "Something went wrong !"
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        
        let okayAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(okayAction)
        
        self.present(alert, animated: true, completion: nil)
    }

}
