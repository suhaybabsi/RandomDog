//
//  LRUCache.swift
//  RandomDog
//
//  Created by Suhayb Al-Absi on 8/29/18.
//  Copyright © 2018 Suhayb Al-Absi. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class LRUCache {
    
    struct Keys {
        static let list = "lrucache_items_list"
    }
    
    static let shared = LRUCache()
    
    let maxSize:Int = 20
    
    private var cache = [String:ImageItem]()
    private(set) var itemList = [ImageItem]()
    
    init() {
        
        if let list = UserDefaults.standard.array(forKey: LRUCache.Keys.list) as? [[String:String]] {

            self.itemList = list.map({ (dct) -> ImageItem in
                
                let name = dct[ImageItem.Keys.file]!
                let key = dct[ImageItem.Keys.key]!
                
                let item = ImageItem(key: key, fileName: name)
                
                self.cache[key] = item
                return item
            })
        }
    }
    
    func getImage(forUrl urlPath:String, completion:@escaping (UIImage?) -> Void) -> Void {
        
        if let item = self.cache[urlPath] {
            
            if let index = self.itemList.index(of: item){
                self.itemList.remove(at: index)
                self.itemList.insert(item, at: 0)
                self.commit()
            }
            
            completion(item.image)
            
            
        } else {
        
            Alamofire.request(urlPath).responseImage { (response) in
                
                switch response.result {
                    
                case .success(let image):
                    
                    self.set(image, withKey: urlPath)
                    completion(image)
                    
                case .failure(let error):
                    
                    print("Error loading image from url: \(urlPath)")
                    print(error.localizedDescription)
                    completion(nil)
                }
            }
        }
    }
    
    private func set(_ image:UIImage, withKey key:String) -> Void {
        
        let fileName = generateImageFileName()
        let fileURL = documentsFileWithName(fileName)
        
        saveImage(image, toFile: fileURL) { (success) in
            
            if success {
                
                let item = ImageItem(key: key, fileName: fileName)
                item.image = image
                
                self.cache[key] = item
                self.itemList.insert(item, at: 0)
                
                if self.itemList.count > self.maxSize {
                    self.deleteItem( self.itemList.removeLast() )
                }
                
                self.commit()
            }
        }
    }
    
    private func generateImageFileName() -> String {
        
        return UUID().uuidString.replacingOccurrences(of: "-", with: "_") + ".jpg"
    }
    
    private func deleteItem(_ item:ImageItem) -> Void {
        
        self.cache.removeValue(forKey: item.key)
        
        do {
            
            try FileManager.default.removeItem(at: item.fileURL)
            
        } catch {
            
            print("Couldn't remove file: \(item.fileName)")
            print(error.localizedDescription)
        }
    }
    
    func clear() -> Void {
        
        self.itemList.forEach { (item) in
            self.deleteItem(item)
        }
        
        self.cache.removeAll()
        self.itemList.removeAll()
        self.commit()
    }
    
    func insureImages() -> Void {
        
        self.itemList.forEach { (item) in
            item.insure()
        }
    }
    
    private func commit() -> Void {
        
        UserDefaults.standard.set(itemList.map({ (item) -> [String:String] in
            
            return [ImageItem.Keys.key: item.key,
                    ImageItem.Keys.file: item.fileName]
            
        }), forKey: LRUCache.Keys.list)
        
        UserDefaults.standard.synchronize()
    }
}


class ImageItem: Hashable {
    
    struct Keys  {
        static let file = "file"
        static let key = "key"
    }
    
    public static func ==(lhs: ImageItem, rhs: ImageItem) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    private var img:UIImage!
    
    var image:UIImage {
        
        set {
            self.img = newValue
        }
        
        get {
            self.insure()
            return self.img
        }
    }
    
    func insure() -> Void {
        if self.img == nil {
            self.img = UIImage(contentsOfFile: self.fileURL.path)
        }
    }
    
    
    var fileName:String
    var key:String
    
    init(key:String, fileName:String) {
        self.key = key
        self.fileName = fileName
    }
    
    var hashValue: Int {
        return self.fileName.hashValue
    }
    
    var fileURL:URL {
        return documentsFileWithName(self.fileName)
    }
}



func documentsFileWithName(_ name:String) -> URL {
    
    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    return url.appendingPathComponent(name)
}

func saveImage(_ image:UIImage, toFile file:URL, completion: @escaping (Bool) -> Void) {
    
    if let data = UIImageJPEGRepresentation(image, 1.0) {
        
        do {
            try data.write(to: URL(fileURLWithPath: file.path))
            completion(true)
        } catch {
            print("Can't save image to file: \(error.localizedDescription)");
            completion(false)
        }
        
    } else {
        
        completion(false)
    }
}
