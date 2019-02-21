//
//  ViewController.swift
//  hot-desking
//
//  Created by i_cspeng on 2019/2/18.
//  Copyright © 2019 fet. All rights reserved.
//

import UIKit

struct statusData: Decodable {
    var created: String
    var prediction: Double

   
}
class ViewController: UIViewController{

    var gameTimer: Timer!
    
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var predictionLabel: UILabel?
    
    @IBOutlet weak var activityView:UIActivityIndicatorView?
    
    @objc func getStatusData() {
      
        activityView?.startAnimating()
        
        let address = "http://airg19-api2.southeastasia.cloudapp.azure.com/api/seat-status"
        if let url = URL(string: address) {
            // GET
            URLSession.shared.dataTask(with: url) { (data, response, error) in
          
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    // 取得 response 和 data
                } else if let response = response as? HTTPURLResponse,let data = data {
                    // 將 response 轉乘 HTTPURLResponse 可以查看 statusCode 檢查錯誤（ ex: 404 可能是網址錯誤等等... ）
                    print("Status code: \(response.statusCode)")
                    // 創建 JSONDecoder 實例來解析我們的 json 檔
                    let decoder = JSONDecoder()
                    
                    print(data)
                    
//                    // decode 從 json 解碼，返回一個指定類型的值，這個類型必須符合 Decodable 協議
                   if let statusData = try? decoder.decode(statusData.self, from: data) {
                       print("==============  data ==============")
                       print(statusData.prediction)
                       print("============== Weather data ==============")
                    
           
                DispatchQueue.main.async {
                 
               
            
                    
                  let aStr = String(format: "%.1f%@",(Float(statusData.prediction * 100)),"%")
                    
                //   let aStr = String(format: "%d%@",(Float(statusData.prediction * 100)),"%")
                    
                 
                        if(statusData.prediction>0){
                            
                            
                            self.imageView?.image =  UIImage(named: "sit_p_r")
                            self.predictionLabel?.text = aStr
                            self.predictionLabel?.isHidden =  false
                        }else {
                            self.imageView?.image =  UIImage(named: "sit_e_r")
                           self.predictionLabel?.isHidden =  true
                        }
                       self.activityView?.stopAnimating()
                    
                    }
                    
                    
                    
                   
                   }
                }
                }.resume()
        } else {
            print("Invalid URL.")
        }
    }
    
    
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       
        self.activityView?.hidesWhenStopped = true
        self.activityView?.backgroundColor = UIColor.lightGray
        self.predictionLabel?.isHidden =  true
        gameTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(getStatusData), userInfo: nil, repeats: true)
        getStatusData()
        
    }


    
    
}

