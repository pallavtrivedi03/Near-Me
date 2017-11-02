//
//  ResultsViewController.swift
//  Near Me
//
//  Created by Pallav Trivedi on 31/10/17.
//  Copyright © 2017 Pallav Trivedi. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController
{
    
    @IBOutlet weak var resultsTableView: UITableView!
    var results:[Results]?
    override func viewDidLoad() {
        super.viewDidLoad()
        //results?.remove(at: 0)
        resultsTableView.register(UINib.init(nibName: "ResultTableViewCell", bundle: nil), forCellReuseIdentifier: kResultsCellIdentifier)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 

}

extension ResultsViewController:UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (results?.count)!
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kResultsCellIdentifier, for: indexPath) as? ResultTableViewCell
        let result = results![indexPath.row]
        cell?.siteNameLabel.text = result.name!
        cell?.siteRatingLabel.text = (result.rating != nil) ? String(describing: result.rating!) : "NA"
        cell?.siteAddressLabel.text = (result.vicinity != nil) ? String(describing: result.vicinity!) : "NA"
        
        if let photoRef = result.photos?[0].photo_reference
        {
        let imageUrl = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoRef)&key=AIzaSyDmqp0mfpQ9wedqw_b584OUdOy_LNzg1PE"
        ApplicationController.sharedInstance.webServiceHelper?.downloadImageFromURL(url: imageUrl, completionHandler: { (image) in
            DispatchQueue.main.async
                {
                    cell?.siteImageView.image = image
            }
        })
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: kDetailViewControllerStoryBoardId) as? DetailViewController
        detailVC?.selectedResult = results![indexPath.row]
       
            self.navigationController?.pushViewController(detailVC!, animated: true)
    }
}
