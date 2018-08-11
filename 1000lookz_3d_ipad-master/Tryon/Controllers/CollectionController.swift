//
//  CollectionController.swift
//  Tryon
//
//  Created by Udayakumar N on 10/01/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit
import RealmSwift
//import Alamofire
import ImageSlideshow
import Kingfisher

class CollectionController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let tryon3D = Tryon3D.sharedInstance
    
    let realm = try! Realm()
    //One for displaying Collection Banners
    //One for displaying Collections in a table row
    //One for displaying Brands in a table row
    let additionalRows = 3
    let numberFormatter = NumberFormatter()
    
    var collectionViewStoredOffsets = [Int: CGFloat]()
    var isAllCollectionDataLoaded = false
    var isBrandDataLoaded = false
    var collectionData: [Int: Any] = [:]
    var brandData: [CategoryBrand] = []
    var collectionFrameData: [Int: [InventoryFrame]] = [:]
    var imageUrls:[String] = []
    var collectionframe:[InventoryFrame] = []
    var searchString:[String] = []
  
    override func viewDidLoad() {
        super.viewDidLoad()
        initCollectionData()
        initBrandData()
        
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 2
        
        self.tableView.backgroundColor = UIColor.mainBackgroundColor
        
        log.info("Realm File Path: \(self.realm.configuration.fileURL!)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    func initCollectionData() {
        activityIndicator?.startAnimating()
        DispatchQueue.global(qos: .background).sync {
            CollectionHelper().getCollectionDistributor { (collectionDistributors, error) in
                self.activityIndicator?.stopAnimating()
                
                if Reachability.isConnectedToNetwork() == true {
                    
                    print("Internet connection OK")
                } else {
                    
                    let ProductVC = AlertViewController()
                    
                    self.present(ProductVC, animated: false, completion: nil)
                    
                    
                    
                }
                self.isAllCollectionDataLoaded = true
                
                if error == nil {
                    //Set for Collection Banner
                    var bannerCollectionDistributors: [CollectionDistributor] = []
                    for collection in collectionDistributors {
                        if let bannerImageUrl = collection.bannerImageUrl {
                            if bannerImageUrl != "" {
                                bannerCollectionDistributors.append(collection)
                            }
                        }
                    }
                    self.collectionData[0] = bannerCollectionDistributors
                    
                    //Set for Collection overall
                    self.collectionData[1] = collectionDistributors
                    
                    //Set for Brand
                    self.collectionData[2] = []
                    
                    /*   //Set for Collection Details
                     var i = self.additionalRows
                     for collection in collectionDistributors {
                     self.collectionData[i] = collection
                     i = i + 1
                     }
                     
                     //Get Data for Collection Details
                     i = self.additionalRows
                     for collection in collectionDistributors {
                     CollectionHelper().getCollectionDistributorFrame(forCollectionId: collection.id, completionHandler: { [i = i] (inventoryFrames, error) in
                     self.collectionFrameData[i] = inventoryFrames
                     
                     self.tableView.reloadData()
                     })
                     i = i + 1
                     }*/
                } else {
                    //TODO: Handle error
                    print("Error in loading page")
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func initBrandData() {
        activityIndicator?.startAnimating()
        DispatchQueue.global(qos: .background).sync {
            CategoryHelper().getCategoryBrand { (brands) in
                self.activityIndicator?.stopAnimating()
                self.isBrandDataLoaded = true
                
                self.brandData.removeAll()
                for brand in brands {
                    if let bannerImageUrl = brand.bannerImageUrl {
                        if bannerImageUrl != "" {
                            self.brandData.append(brand)
                        }
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
}

extension CollectionController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collectionData.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            //Collection Banner
            return 310
            
        case 1:
            //Collection Overall
            return 273
            
       default://case 2:
            //Brand
            return 330
            
//        default:
//            //Collection details
//            return 300
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            //Collection Banner
            return 310
            
        case 1:
            //Collection Overall
            return 273

        default://case 2:
            //Brand
            return 330

//        default:
//            //Collection details
//            return 300
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        KingfisherManager.shared.cache.pathExtension = "jpg"

        switch indexPath.row {
        case 0:
            //Collection Banner
            let cellIdentifier = "shopCollectionBannerTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ShopBannerTableViewCell
            let collections = self.collectionData[indexPath.row] as! [CollectionDistributor]
        
            var imgsData: [Any] = []
            for collection in collections {
                imgsData.append(KingfisherSource(urlString: collection.bannerImageUrl!)!)
            }
            cell.imageSlideShowView.setImageInputs(imgsData as! [InputSource])
            cell.collectionBannerDelegate = self
            
            return cell
            
        case 1:
            //Collection Overall
            let cellIdentifier = "shopCollectionTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ShopTableViewCell
            cell.titleLabel.text = "COLLECTION"
            return cell
            
        default: //case 2:
            //Brand
            let cellIdentifier = "shopCollectionBrandTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ShopBrandTableViewCell
            cell.titleLabel.text = "SHOP BY BRAND"
            
            var imgsData: [Any] = []
            for brand in self.brandData {
                imgsData.append(KingfisherSource(urlString: brand.bannerImageUrl!)!)
            }
            cell.imageSlideShowView.setImageInputs(imgsData as! [InputSource])
            cell.collectionBrandDelegate = self

            return cell
            
//        default:
//            let cellIdentifier = "shopCollectionDetailTableViewCell"
//            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ShopTableViewCell
//            let collection = self.collectionData[indexPath.row] as! CollectionDistributor
//            cell.titleLabel.text = collection.name.uppercased()
//            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let tableViewCell = cell as? ShopTableViewCell {
            tableViewCell.setFilterCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
            tableViewCell.collectionViewOffset = collectionViewStoredOffsets[indexPath.row] ?? 0
            
            //Display Activity Indicator when data is still being loaded
            if let data = collectionFrameData[indexPath.row] {
                if data.count > 0 {
                    tableViewCell.activityIndicator.stopAnimating()
                    tableViewCell.activityIndicator.isHidden = true
                } else {
                    tableViewCell.activityIndicator.startAnimating()
                    tableViewCell.activityIndicator.isHidden = false
                }
            } else if let data = collectionData[indexPath.row] as? [CollectionDistributor] {
                if data.count > 0 {
                    tableViewCell.activityIndicator.stopAnimating()
                    tableViewCell.activityIndicator.isHidden = true
                } else {
                    tableViewCell.activityIndicator.startAnimating()
                    tableViewCell.activityIndicator.isHidden = false
                }
            } else {
                tableViewCell.activityIndicator.startAnimating()
                tableViewCell.activityIndicator.isHidden = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? ShopTableViewCell else { return }
        collectionViewStoredOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
}

extension CollectionController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            //Collection Banner
            //This shouldn't occur
            log.error("Looking for creating collection view cell for Banner")
            assertionFailure("Looking for creating collection view cell for Banner")
        }
        
        switch collectionView.tag {
        case 1:
            //Collection Overall
            return (collectionData[collectionView.tag] as! [CollectionDistributor]).count
            
        default:
            return collectionFrameData[collectionView.tag]?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 0 || collectionView.tag == 2 {
            //Collection Banner
            //This shouldn't occur
            log.error("Looking for creating collection view cell for Banner / Brand")
            assertionFailure("Looking for creating collection view cell for Banner / Brand")
        }
        KingfisherManager.shared.cache.pathExtension = "jpg"

     switch collectionView.tag {
        case 1:
            //Collection Overall
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "shopCollectionCell", for: indexPath) as? ShopCollectionCell

            let collections = collectionData[collectionView.tag] as! [CollectionDistributor]
            let collection = collections[indexPath.row]
            cell?.titleLabel.text = collection.name.uppercased()

            if let url = collection.imageUrl {
                cell?.imageView.kf.setImage(with: URL(string: url)!)
            }
            return cell!
    
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "shopCollectionDetailCell", for: indexPath) as? ResultCell
            
            let inventoryFrame = self.collectionFrameData[collectionView.tag]![indexPath.row]
            
//            if UserDefaults.standard.data(forKey:"userJson") == nil{
//                let myData = NSKeyedArchiver.archivedData(withRootObject: inventoryFrame)
//                UserDefaults.standard.set(myData, forKey: "userJson")
//                let recovedUserJsonData = UserDefaults.standard.object(forKey: "userJson")
//                let recovedUserJson = NSKeyedUnarchiver.unarchiveObject(with: recovedUserJsonData as! Data)
//                print(recovedUserJson)
//            }

            var titleText = inventoryFrame.brand?.name.uppercased()
            if let modelNumber = inventoryFrame.modelNumber {
                titleText = titleText! + " - " + modelNumber
            }
            cell?.titleLabel.text = titleText
            
            if inventoryFrame.is3DCreated {
                cell?.tryon3DImageView.isHidden = false
            } else {
                cell?.tryon3DImageView.isHidden = true
            }
            
            let image: UIImage? = UIImage(named:"tryOn")?.withRenderingMode(.alwaysTemplate)
            cell?.tryOnImageView.tintColor = UIColor(red: 161/255.0, green: 161/255.0, blue: 161/255.0, alpha: 1.0)
            cell?.tryOnImageView.image = image
            
            if inventoryFrame.isTryonCreated {
                cell?.tryOnImageView.isHidden = false
            } else {
                cell?.tryOnImageView.isHidden = true
            }
            if TrayHelper().isAlreadyAvailbleInTray(inventoryFrame) {
                cell?.cartImageView.isHidden = false
            } else {
                cell?.cartImageView.isHidden = true
            }
            
            var colorName = (inventoryFrame.frameColor?.name)! + " - "
            if let _ = inventoryFrame.identifiedColor?.name {
                colorName = ""
            }
            var displayText = colorName + (inventoryFrame.shape?.name)!
            if let size = inventoryFrame.sizeText {
                displayText = displayText + " - " + size
            }
            displayText = displayText.uppercased()
            cell?.subTitleLabel.text = displayText.lowercased().capitalizingFirstLetter()
            
            cell?.imageView.kf.setImage(with: URL(string: inventoryFrame.thumbnailImageUrl!)!)

            if inventoryFrame.childFrames.count > 1 {
                //Added +1 to include the parent frame
                cell?.colorLabel.text = String(inventoryFrame.childFrames.count + 1) + "  COLORS"
            } else {
                cell?.colorLabel.text = ""
            }
            
            var priceText: String? = ""
            if let price = inventoryFrame.price.value {
                if price > 0 {
                    if let priceUnit = inventoryFrame.priceUnit {
                        priceText = priceUnit + " "
                    }
                    priceText = priceText! + numberFormatter.string(from: NSNumber(value: price))!
                }
            }
            cell?.highlightedLabel.text = priceText
            
            return cell!
        }
    }
    
    func filter(indexpath: Int) {
        
        DispatchQueue.global(qos: .background).sync {
            
            let collections = collectionData[1] as! [CollectionDistributor]
            let collection = collections[indexpath]
            var string: String?
            let nameStr = collection.name
            if nameStr == "ARCADIO JUNIOR" {
                string = "kids"
            } else if nameStr == "Optical Frames"{
                string = "eyeglasses"
            } else {
                string = collection.name
            }
            InventoryFrameHelper().searchInventory(searchString: string!, completionHandler: { (inventoryFrames, error) in
                self.collectionframe = inventoryFrames
            })
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {        
        switch collectionView.tag {
        case 1:
            //Collection Overall
            let actualRow = self.additionalRows + indexPath.row
            filter(indexpath: indexPath.row)
            
            self.performSegue(withIdentifier: "collectionToResultSegue", sender: actualRow)

        default:
            //Collection Detail
            let inventoryFrame = self.collectionFrameData[collectionView.tag]![indexPath.row]
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)

            if inventoryFrame.isTryonCreated {
                if self.tryon3D.isUserSelectedByAppUser {
                    self.performSegue(withIdentifier: "collectionToModelDetailSegue", sender: inventoryFrame)
                } else {
                    self.performSegue(withIdentifier: "collectionToModelSelectionSegue", sender: inventoryFrame)
                }
                UserDefaults.standard.set(true, forKey: "glassInfo")
            } else {
                self.performSegue(withIdentifier: "collectionToFrameDetailSegue", sender: inventoryFrame)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let modelChooseController = segue.destination as? ModelChooseController {
            if let inventoryFrame = sender as? InventoryFrame {
                modelChooseController.frame = inventoryFrame
            }
        } else if let detailModelController = segue.destination as? DetailModelController {
            if let inventoryFrame = sender as? InventoryFrame {
                detailModelController.frame = inventoryFrame
            }
        } else if let resultController = segue.destination as? ResultController {
            if let row = sender as? Int {
                resultController.resultInputType = .frames
//                    if self.flag == false {
//                         if let collectionFrames = self.collectionFrameData[row] {
//                            resultController.inventoryFrames = collectionFrames
//                        }
//                    } else {
                        resultController.inventoryFrames = collectionframe
//                    }
                let collections = self.collectionData[1] as! [CollectionDistributor]
                let collection = collections[row - self.additionalRows]
                resultController.title = collection.name.uppercased()
            } else if let brand = sender as? CategoryBrand {
                resultController.resultInputType = .filterData
                resultController.title = brand.name.uppercased()
                resultController.filterData = [FilterList.brand: [brand.id]]
            }
        } else if let detailFrameController = segue.destination as? DetailFrameController {
            if let inventoryFrame = sender as? InventoryFrame {
                detailFrameController.frame = inventoryFrame
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)

    }
    
//    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//
//        let urls = imageUrls.map { URL(string: $0)! }
//        let prefetcher = ImagePrefetcher(urls: urls) {
//            skippedResources, failedResources, completedResources in
//            print("These completed resources are prefetched: \(completedResources)")
//        }
//        prefetcher.start()
//    }
}

extension CollectionController: CollectionBannerDelegate {
    func collectionBannerShootDidTap() {
        if let tabBarController = self.tabBarController as? MainTabBarController {
            tabBarController.menuTabBarView?.selectIndex(newIndex: TabBarList.shoot.rawValue)
        }
    }
    
    func collectionBannerDidTap(currentPage: Int) {
        DispatchQueue.global(qos: .background).sync {
            let bannerCollections = self.collectionData[0] as! [CollectionDistributor]
            let bannerCollection = bannerCollections[currentPage]
            let collectionDistributors = self.collectionData[1] as! [CollectionDistributor]
            var actualRow: Int = 0

            var i = 0
            for collection in collectionDistributors {
                if collection.id == bannerCollection.id {
                    actualRow = self.additionalRows + i
                    break
                }
                i = i + 1
            }
         //  self.performSegue(withIdentifier: "collectionToResultSegue", sender: actualRow)
        }
    }
}

extension CollectionController: CollectionBrandDelegate {
    func collectionBrandDidTap(currentPage: Int) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)

      self.performSegue(withIdentifier: "collectionToResultSegue", sender: self.brandData[currentPage])
    }
}
