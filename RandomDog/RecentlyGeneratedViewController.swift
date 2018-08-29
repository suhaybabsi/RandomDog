//
//  RecentlyGeneratedViewController.swift
//  RandomDog
//
//  Created by Suhayb Al-Absi on 8/29/18.
//  Copyright © 2018 Suhayb Al-Absi. All rights reserved.
//

import UIKit

class RecentlyGeneratedViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LRUCache.shared.insureImages()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }

    @IBAction func clearDogs(_ sender: AnyObject) {
        
        LRUCache.shared.clear()
        self.collectionView.reloadData()
    }
}

extension RecentlyGeneratedViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return LRUCache.shared.itemList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let reuseId = DogPhotoCollectionViewCell.reuseIdentifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! DogPhotoCollectionViewCell
        
        let item = LRUCache.shared.itemList[indexPath.row]
        cell.imageView.image = item.image
        
        return cell
    }
}

extension RecentlyGeneratedViewController:UICollectionViewDelegateFlowLayout {


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 5, left: 7, bottom: 0, right: 7)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let rf = self.view.frame
        let w = max(rf.width - 30, 320)
        
        return CGSize(width: w, height: 260)
    }
}
