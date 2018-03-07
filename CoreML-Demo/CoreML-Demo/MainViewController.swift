//
//  MainViewController.swift
//  CoreML-Demo
//
//  Created by 杜进新 on 2018/2/28.
//  Copyright © 2018年 dujinxin. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {

    var dataArray: Array<Array<Dictionary<String,String>>> {
        let array = [
            [
                ["title":"Vision","detail":"模型检测"],
            ],
            [
                ["title":"VNDetectRectanglesRequest","detail":"矩形检测"],
                ["title":"VNDetectFaceRectanglesRequest","detail":"人脸检测：支持检测笑脸、侧脸、局部遮挡脸部、戴眼镜和帽子等场景，可以标记出人脸的矩形区域"],
                ["title":"VNDetectFaceLandmarksRequest","detail":"人脸特征点：可以标记出人脸和眼睛、眉毛、鼻子、嘴、牙齿的轮廓，以及人脸的中轴线"],
                ["title":"VNDetectTextRectanglesRequest","detail":"文字检测：监测文字外框，和文字识别"],
                ["title":"VNDetectBarcodesRequest","detail":"二维码/条形码检测"],
                ["title":"VNDetectHorizonRequest","detail":"图像配准:检测图像是否水平倾斜"]
            ],
            [
                ["title":"Inception v3","detail":"Detects the dominant objects present in an image from a set of 1000 categories such as trees, animals, food, vehicles, people, and more."],
                ["title":"Places205-GoogLeNet","detail":"Detects the scene of an image from 205 categories such as an airport terminal, bedroom, forest, coast, and more."],
                ["title":"MobileNet","detail":"MobileNets are based on a streamlined architecture that have depth-wise separable convolutions to build lightweight, deep neural networks.Detects the dominant objects present in an image from a set of 1000 categories such as trees, animals, food, vehicles, people, and more."],
                ["title":"ResNet50","detail":"Detects the dominant objects present in an image from a set of 1000 categories such as trees, animals, food, vehicles, people, and more."],
                ["title":"SqueezeNet","detail":"Detects the dominant objects present in an image from a set of 1000 categories such as trees, animals, food, vehicles, people, and more.With an overall footprint of only 5 MB, SqueezeNet has a similar level of accuracy as AlexNet but with 50 times fewer parameters."],
                ["title":"VGG16","detail":"Detects the dominant objects present in an image from a set of 1000 categories such as trees, animals, food, vehicles, people, and more."]
            ]
        ]
        return array
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "mlmodel"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let desVC = segue.destination as! DetailViewController
        let indexPath = sender as! IndexPath
        
        desVC.title = self.dataArray[indexPath.section][indexPath.row]["title"]
        if indexPath.section == 0 {
            desVC.type = MLModelType(rawValue: 1000 )!
        }else if indexPath.section == 1{
            desVC.type = MLModelType(rawValue: 2000 + indexPath.row)!
        }else {
            desVC.type = MLModelType(rawValue: indexPath.row)!
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return dataArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataArray[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "reuseIdentifier")
            cell?.detailTextLabel?.numberOfLines = 0
        }
        
        let dict = dataArray[indexPath.section][indexPath.row]
        
        cell?.textLabel?.text = dict["title"]
        cell?.detailTextLabel?.text = dict["detail"]
        // Configure the cell...

        return cell!
    }
    

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "detail", sender: indexPath)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
