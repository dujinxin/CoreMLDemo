//
//  DetailViewController.swift
//  CoreML-Demo
//
//  Created by 杜进新 on 2018/2/28.
//  Copyright © 2018年 dujinxin. All rights reserved.
//

import UIKit

import Vision


enum MLModelType : Int{
    case inceptionv3             =     0
    case googLeNetPlaces
    case mobileNet
    case resnet50
    case squeezeNet
    case vGG16
    
    case vision                  =     1000
    
    case visionRectangles        =     2000
    case visionFaceRectangles
    case visionFaceLandmarks
    case visionTextRectangles
    case visionBarcodes
    case visionHorizon
    
}

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    var type : MLModelType = .inceptionv3
    
    //MARK:mlmodel
    lazy var model_Inceptionv3: Inceptionv3 = {
        let ml = Inceptionv3()
        return ml
    }()
    lazy var model_GoogLeNetPlaces: GoogLeNetPlaces = {
        let ml = GoogLeNetPlaces()
        return ml
    }()
    lazy var model_MobileNet: MobileNet = {
        let ml = MobileNet()
        return ml
    }()
    lazy var model_Resnet50: Resnet50 = {
        let ml = Resnet50()
        return ml
    }()
    lazy var model_SqueezeNet: SqueezeNet = {
        let ml = SqueezeNet()
        return ml
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.contentLabel.text = "请打开相机/照片库选择一张图片"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //拍照
    @IBAction func takePhoto(_ sender: Any) {
        let vc = UIImagePickerController.init()
        vc.delegate = self
        vc.sourceType = .camera
        vc.allowsEditing = true
        self.present(vc, animated: true, completion: nil)
    }
    //选择图片
    @IBAction func selectPhoto(_ sender: Any) {
        let vc = UIImagePickerController.init()
        vc.delegate = self
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        self.present(vc, animated: true, completion: nil)
    }
    //翻译
    @IBAction func start(_ sender: Any) {
        
        let appid = "20180228000129130"
        let scre = "PLUj8TJgWQqoudvV1b60"
        let salt: Int64 = Int64(Int64(arc4random()) % Int64(10000000000) + Int64(1000000000))
        let text = self.contentLabel.text ?? ""
        
        let sign = appid + text + "\(salt)" + scre
        let data = sign.data(using: .utf8)
        let utf8Str = String.init(data: data!, encoding: .utf8)
        
        //let utf8Str = sign.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let md5Sign = MD5.encode(utf8Str!) //String.md5(utf8Str)
        
        
        let ssss = "https://api.fanyi.baidu.com/api/trans/vip/translate?q=\(text)&from=en&to=zh&appid=\(appid)&salt=\(salt)&sign=\(md5Sign)"
        let sssss = ssss.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        JXRequest.request(url: sssss!, param: [:], success: { (data, msg) in
            
            guard let data = data as? Dictionary<String,Any>, let trans_result = data["trans_result"] as? Array<Dictionary<String,Any>> ,let dict = trans_result.first,let _ = dict["src"],let dst = dict["dst"] else{
                return
            }
            let old = self.contentLabel.text
            self.contentLabel.text = old! + "\n\(dst)"
        }) { (msg, code) in
            //
            print(msg,code)
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension DetailViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    //图片处理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerEditedImage] as! UIImage

        var size : CGSize!
        switch type {
        case .inceptionv3:
            size = CGSize(width: 299, height: 299)
        case .squeezeNet:
            size = CGSize(width: 227, height: 227)
        case .mobileNet,.resnet50,.googLeNetPlaces:
            size = CGSize(width: 224, height: 224)
        default:
            size = CGSize(width: UIScreen.main.bounds.width, height:UIScreen.main.bounds.width)
        }
        guard let newImage = UIImage.image(originalImage: image, to: size.width, scaleHeight: size.height) else {
            return
        }
        
        if type == .vision {
            self.imageView.image = newImage
            self.visionPrediction(image: newImage.cgImage)
            picker.dismiss(animated: true, completion: nil)
            return
        }else if type.rawValue >= 2000 {
            self.imageView.image = newImage
            switch type {
            case .visionRectangles:
                self.rectangles(image: newImage.cgImage)
            default:
                print("未知类型")
            }
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        var pixelBuffer : CVPixelBuffer?
        let attributes = [kCVPixelBufferCGImageCompatibilityKey:kCFBooleanTrue,kCVPixelBufferCGBitmapContextCompatibilityKey:kCFBooleanTrue] as CFDictionary
        
        /*!
         @function   CVPixelBufferCreate
         @abstract   Call to create a single PixelBuffer for a given size and pixelFormatType.
         @discussion Creates a single PixelBuffer for a given size and pixelFormatType. It allocates the necessary memory based on the pixel dimensions, pixelFormatType and extended pixels described in the pixelBufferAttributes. Not all parameters of the pixelBufferAttributes will be used here.
         @param      width   Width of the PixelBuffer in pixels.
         @param      height  Height of the PixelBuffer in pixels.
         @param    pixelFormatType        Pixel format indentified by its respective OSType.
         @param    pixelBufferAttributes      A dictionary with additional attributes for a pixel buffer. This parameter is optional. See BufferAttributeKeys for more details.
         @param      pixelBufferOut          The new pixel buffer will be returned here
         @result    returns kCVReturnSuccess on success.
         */
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attributes, &pixelBuffer)
        guard status == kCVReturnSuccess else {
            return
        }
        
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) //3

        context?.translateBy(x: 0, y: newImage.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        self.imageView.image = newImage
        
        self.prediction(image: pixelBuffer!)
        
        
        picker.dismiss(animated: true, completion: nil)
    }
    //识别
    func prediction(image:CVPixelBuffer) {
        
    
        switch type {
        case .inceptionv3:
            guard
                let output = try? self.model_Inceptionv3.prediction(image: image) else {
                    
                    self.contentLabel.text = "失败"
                    return
            }
            self.contentLabel.text = "\(output.classLabel)\n识别率\(String.init(format: "%0.2f", Double(output.classLabelProbs[output.classLabel]!)))"
        case .googLeNetPlaces:
            guard
                let output = try? self.model_GoogLeNetPlaces.prediction(sceneImage: image) else {
                    
                    self.contentLabel.text = "失败"
                    return
            }
            self.contentLabel.text = "\(output.sceneLabel)\n识别率\(String.init(format: "%0.2f", Double(output.sceneLabelProbs[output.sceneLabel]!)))"
        case .mobileNet:
            guard
                let output = try? self.model_MobileNet.prediction(image: image) else {
                    
                    self.contentLabel.text = "失败"
                    return
            }
            self.contentLabel.text = "\(output.classLabel)\n识别率\(String.init(format: "%0.2f", Double(output.classLabelProbs[output.classLabel]!)))"
        case .resnet50:
            guard
                let output = try? self.model_Resnet50.prediction(image: image) else {
                    
                    self.contentLabel.text = "失败"
                    return
            }
            self.contentLabel.text = "\(output.classLabel)\n识别率\(String.init(format: "%0.2f", Double(output.classLabelProbs[output.classLabel]!)))"
        case .squeezeNet:
            guard
                let output = try? self.model_SqueezeNet.prediction(image: image) else {
                    
                    self.contentLabel.text = "失败"
                    return
            }
            self.contentLabel.text = "\(output.classLabel)\n识别率\(String.init(format: "%0.2f", Double(output.classLabelProbs[output.classLabel]!)))"
        default:
            self.contentLabel.text = "未集成"
        }
    }
    //MAEK: Vision
    //图片可以不用处理大小，不拘泥于CVPixelBuffer，也可以采用CGImage来识别
    //但是还是需要借助mlmodel来识别
    func visionPrediction(image:CGImage?) {
        //准备VNCoreMLModel
        let googleNetPlaces = GoogLeNetPlaces()
        guard let model = try? VNCoreMLModel.init(for: googleNetPlaces.model) else{
            return
        }
        //构建请求
        let request = VNCoreMLRequest(model: model) { (vnRequest, error) in
            if error == nil {
                guard let observation = vnRequest.results?.first as? VNClassificationObservation else{
                    return
                }
                print("result:",observation.identifier,observation.uuid,observation.confidence)
                DispatchQueue.main.async {
                    self.contentLabel.text = "\(observation.identifier)\n识别率\(String.init(format: "%0.2f", Double(observation.confidence)))"
                }
                
            }else {
                print("error:",error?.localizedDescription)
            }
        }
        //构建操作器
        let handler = VNImageRequestHandler(cgImage: image!, options: [:])
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
        
    }
    //原生检测
    //VNDetectRectanglesRequest 矩形检测
    //VNDetectFaceRectanglesRequest 人脸检测：支持检测笑脸、侧脸、局部遮挡脸部、戴眼镜和帽子等场景，可以标记出人脸的矩形区域
    //VNDetectFaceLandmarksRequest 人脸特征点：可以标记出人脸和眼睛、眉毛、鼻子、嘴、牙齿的轮廓，以及人脸的中轴线
    //VNDetectTextRectanglesRequest 文字检测：监测文字外框，和文字识别
    //VNDetectBarcodesRequest 二维码/条形码检测
    //VNDetectHorizonRequest  图像配准:检测图像是否水平倾斜
    func rectangles(image:CGImage?) {
        
        let request = VNDetectRectanglesRequest { (vnRequest, error) in
            print("result:",vnRequest.results)
            
            if error == nil {
                guard let observation = vnRequest.results?.first as? VNRectangleObservation else{
                    return
                }
                print("result:",observation.uuid,observation.confidence)
                DispatchQueue.main.async {
                    let Image = UIImage(cgImage: image!)
                    let ciImage = Image.ciImage
                    
                    let size = ciImage?.extent.size
                    
                    let boundingBox = self.scale(rect: observation.boundingBox, size: size!)
                    
                    let topLeft = self.scale(point: observation.topLeft, size: size!)
                    let topRight = self.scale(point: observation.topRight, size: size!)
                    let bottomLeft = self.scale(point: observation.bottomLeft, size: size!)
                    let bottomRight = self.scale(point: observation.bottomRight, size: size!)
                    
                    let cropImage = ciImage?.cropped(to: boundingBox)
                    
                    let dict = ["inputTopLeft":CIVector(cgPoint: topLeft),"inputTopRight":CIVector(cgPoint: topRight),"inputBottomLeft":CIVector(cgPoint: bottomLeft),"inputBottomRight":CIVector(cgPoint: bottomRight)]
                    let filterImage = cropImage?.applyingFilter("CIPerspectiveCorrection", parameters: dict)
                    filterImage?.applyingFilter("CIColorControls", parameters: [kCIInputSaturationKey:0,kCIInputContrastKey:32])
                    filterImage?.applyingFilter("CIColorInvert", parameters: [:])
                    let correctImage = UIImage(ciImage: filterImage!)
                    
                    DispatchQueue.main.async {
                        self.imageView.image = correctImage
                    }
                    
//                    let handler = VNImageRequestHandler(cgImage: filterImage?.cgImage!, options: [:])
//                    let model =
                    
                    //self.contentLabel.text = "\(observation.identifier)\n识别率\(String.init(format: "%0.2f", Double(observation.confidence)))"
                }
                
            }else {
                print("error:",error?.localizedDescription)
            }
        }
        let handler = VNImageRequestHandler(cgImage: image!, options: [:])
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
    func scale(rect:CGRect, size:CGSize) -> CGRect {
        let w = rect.size.width * size.width
        let h = rect.size.height * size.height
        let x = rect.origin.x * size.width
        let y = size.height - rect.origin.y * size.height - h
        
        return CGRect(x: x, y: y, width: w, height: h)
    }
    func scale(point:CGPoint, size:CGSize) -> CGPoint {
        let x = point.x * size.width
        let y = point.y * size.height
        
        return CGPoint(x: x, y: y)
    }
}

