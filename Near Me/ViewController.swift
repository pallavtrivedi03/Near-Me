//
//  ViewController.swift
//  Near Me
//
//  Created by Pallav Trivedi on 30/10/17.
//  Copyright © 2017 Pallav Trivedi. All rights reserved.
//

import UIKit
import CoreLocation


class ViewController: UIViewController {
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var keywordTextField: UITextField!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var selectedCategoryLabel: UILabel!
    var locationManager:CLLocationManager?
    @IBOutlet weak var errorLabel: UILabel!
    var placesResponse:PlacesResponse?
    var dummyVO:DummyVO?
    var coordinates = ""
    var radius = "2500"
    var selectedCategoryIndex = -1
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        locationManager = CLLocationManager.init()
        self.locationManager?.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.startUpdatingLocation()
        }
        
        dummyVO = DummyVO()
       
        
        self.categoryCollectionView.register(UINib.init(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: kCategoryCollectionViewCell)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        keywordTextField.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didValueChangedOfSlider(_ sender: UISlider)
    {
        radius = String(Int(sender.value))
        distanceLabel.text = radius.appending(" m")
    }
    
    
    @IBAction func didClickOnSearchButton(_ sender: Any)
    {
        errorLabel.isHidden = true
        activityIndicator.isHidden = false
        keywordTextField.resignFirstResponder()
        //coordinates = "19.102769,73.009001"
        let selectedType = typeDict[selectedCategoryLabel.text!] ?? ""
        let params = ["location":coordinates,"radius":radius,"keyword":keywordTextField.text!,"type":selectedType,"key":"AIzaSyDmqp0mfpQ9wedqw_b584OUdOy_LNzg1PE"] as [String : Any]
        let placesUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        
        ApplicationController.sharedInstance.webServiceHelper?.getWebServiceWith(url: placesUrl, params: params as! [String : String], returningVO: dummyVO!, completionHandler: { (dict) in
            
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
            }
            self.dummyVO = dict as? DummyVO
            self.placesResponse = PlacesResponse.init(dictionary: (self.dummyVO?.responseDict!)! as NSDictionary)
            
            if self.placesResponse?.results?.count == 0
            {
                DispatchQueue.main.async {
                    self.errorLabel.isHidden = false
                }
            }
            else
            {
            let results = self.placesResponse?.results
                let resultsVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: kResultsViewControllerStroryBoardId) as? ResultsViewController
                resultsVC?.results = results
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(resultsVC!, animated: true)
                }

            }
        })
    }
}

extension ViewController:CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Failed-------->\(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        var locValue:CLLocationCoordinate2D = manager.location!.coordinate
        self.coordinates = "\(locValue.latitude),\(locValue.longitude)"
        userLatitude = locValue.latitude
        userLongitude = locValue.longitude
    }
}

extension ViewController:UICollectionViewDelegate,UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return (categoryTitles.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCategoryCollectionViewCell, for: indexPath) as? CategoryCollectionViewCell
        
        cell?.categoryTitleLabel.text = categoryTitles[indexPath.row]
        cell?.iconImageView.image = categoryImages[indexPath.row]
        cell?.backgroundColor = .clear
        cell?.categoryTitleLabel.textColor = .black
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        selectedCategoryLabel.text = categoryTitles[indexPath.row]
        if selectedCategoryIndex != -1 {
            let tempIndexPath = IndexPath(row: selectedCategoryIndex, section: 0)
                 if let previousCell = collectionView.cellForItem(at: tempIndexPath) as? CategoryCollectionViewCell
                 {
            previousCell.backgroundColor = .clear
            previousCell.categoryTitleLabel.textColor = .black
            }
        }
        let currentCell = collectionView.cellForItem(at: indexPath) as! CategoryCollectionViewCell
        currentCell.backgroundColor = #colorLiteral(red: 0.5490196078, green: 0.02745098039, blue: 0.01176470588, alpha: 1)
        currentCell.categoryTitleLabel.textColor = .white
        selectedCategoryIndex = indexPath.row
        
}
}

extension ViewController:UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
