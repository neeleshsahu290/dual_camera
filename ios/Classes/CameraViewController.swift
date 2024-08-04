import UIKit
import AVFoundation
import CoreLocation


protocol CameraViewControllerDelegate: AnyObject {
    func didCapturePhoto(with filePath: String)
}

public var w: CGFloat {
    return UIScreen.main.bounds.width
}

// Screen height.
public var h: CGFloat {
    return UIScreen.main.bounds.height
}


class CameraViewController: UIViewController,AVCapturePhotoCaptureDelegate {
    private var captureSession: AVCaptureSession!
    private var isFirstImageClicked = false
    private var isBothCamera:Bool = false
    private var isGeoTagEnable = false
    private var longitude: Double?
    private var latitude: Double?
    private var firstImagePath: String?
    private var secondImagePath: String?
    private var photoOutput: AVCapturePhotoOutput?
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    private var  buttonView = UIView()
    private var  containerImageView = UIView()
    private var progressBar = UIActivityIndicatorView()
    private var imageView = UIImageView()
    
    private var isCreatingImage: Bool = false


    weak var delegate: CameraViewControllerDelegate?
    
    var receivedData: [String: Any]?
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        initAruguments()
        setupCamera()
        setupUI()
        setupImageUI()
    }
    
    private func initViews(){
        let layer1 = CALayer()
        layer1.frame = CGRect(x: 0, y: 0, width: w, height: h)
        layer1.backgroundColor = UIColor.black.cgColor
        view.layer.addSublayer(layer1)
        
        buttonView = UIView(frame: CGRect(x:0, y: h-200, width: w, height: 200))
        view.addSubview(buttonView)
    }
    
    private func initAruguments(){
        if let hashMap = receivedData {
            
            if let isBothCamera = hashMap["isBothCamera"] as? Bool {
                self.isBothCamera = isBothCamera
            }
            
            if let isGeoTagEnable = hashMap["isGeoTagEnable"] as? Bool {
                self.isGeoTagEnable = isGeoTagEnable
            }
            
            if let latitude = hashMap["latitude"] as? Double {
                self.latitude = latitude
            }
            
            if let longitude = hashMap["longitude"] as? Double {
                self.longitude = longitude
            }
        }
    }
    
    private func setupCamera(){
        DispatchQueue.global(qos: .background).async {
            
       let  captureSession = AVCaptureSession()

            guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera,for:.video,position: self.currentCameraPosition) else { return }
            let videoInput: AVCaptureDeviceInput
            
            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                return
            }
            
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                return
            }
            
            self.photoOutput = AVCapturePhotoOutput()
            if let photoOutput =  self.photoOutput {
                if captureSession.canAddOutput(photoOutput) {
                    captureSession.addOutput(photoOutput)
                }
            }
            DispatchQueue.main.async {
                let  videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                videoPreviewLayer.videoGravity = .resizeAspectFill
                videoPreviewLayer.frame = self.view.layer.bounds
                self.view.layer.insertSublayer(videoPreviewLayer, below:self.buttonView.layer)                                     
            }
            
            self.captureSession = captureSession
            
           
          
            self.captureSession.startRunning()
        }
        
    }
    
    private func setupCamera2(){
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let   captureSession = AVCaptureSession()
            
            guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera,for:.video,position:self.currentCameraPosition == .back ? .front : .back ) else { return }
            let videoInput: AVCaptureDeviceInput
            
            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                return
            }
            
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                return
            }
            
            self.photoOutput = AVCapturePhotoOutput()
            if let photoOutput = self.photoOutput {
                if captureSession.canAddOutput(photoOutput) {
                    captureSession.addOutput(photoOutput)
                }
            }
        
            if(self.captureSession.isRunning){
                self.captureSession.stopRunning()
            }
            
            self.captureSession = captureSession
            
            self.captureSession.startRunning()
            
            let settings = AVCapturePhotoSettings()
            self.photoOutput?.capturePhoto(with: settings, delegate: self)
        }
    }
    
    

        private func setupUI() {

            progressBar = UIActivityIndicatorView()
            if #available(iOS 13.0, *) {
                       progressBar.style = .large
                   } else {
                       progressBar.style = .whiteLarge
                   }
            progressBar.center = view.center
            
            progressBar.hidesWhenStopped = true
            view.addSubview(progressBar)
            
    
            let    captureButton = UIButton(frame: CGRect(x: w / 2 - 30, y: buttonView.bounds.height - 80, width: 60, height: 60))
            captureButton.backgroundColor = .red
            captureButton.layer.cornerRadius = 30
            captureButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
            buttonView.addSubview(captureButton)
    
            let cancelButton = UIButton(frame: CGRect(x: 20, y: buttonView.bounds.height - 80, width: 60, height: 60))
            cancelButton.setTitle("Cancel", for: .normal)
            cancelButton.addTarget(self, action: #selector(didTapCancelCamera), for: .touchUpInside)
            buttonView.addSubview(cancelButton)
    
            let toggleButton = UIButton(frame: CGRect(x: w - 80, y: buttonView.bounds.height - 80, width: 60, height: 60))
            toggleButton.setTitle("Toggle", for: .normal)
            toggleButton.addTarget(self, action: #selector(didTapSwitchCamera), for: .touchUpInside)
            buttonView.addSubview(toggleButton)
        }
    
    private func setupImageUI() {
        
        containerImageView = UIView(frame: CGRect(x:0, y: 0, width: w, height: h))
        view.addSubview(containerImageView)
        let layer1 = CALayer()
        layer1.frame = CGRect(x: 0, y: 0, width: w, height: h)
        layer1.backgroundColor = UIColor.black.cgColor
        containerImageView.layer.addSublayer(layer1)
       
        
        let imageV = UIImageView()
               
               // Set the image for the image view
//               if let image = UIImage(named: firstImagePath ?? "" ) {
//                   imageV.image = image
//               } else {
//                   print("Image not found")
//               }
               
               // Set the content mode
               imageV.contentMode = .scaleAspectFit
               
               // Set the frame or constraints for the image view
        imageV.frame = CGRect(x: 10, y: 0, width: w-20, height: h )
        imageView = imageV
                
               // Add the image view to the main view
        containerImageView.addSubview(imageView)
  

        let cancelButton = UIButton(frame: CGRect(x: 20, y: h - 80, width: 60, height: 60))
       // cancelButton.setTitle("Cancel", for: .normal)
        if #available(iOS 13.0, *) {
                let crossImage = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .bold))
            cancelButton.setImage(crossImage, for: .normal)
            } else {
                let crossImage = UIImage(named: "xmark")?.withRenderingMode(.alwaysTemplate)
                cancelButton.setImage(crossImage, for: .normal)
            }
             
               
        cancelButton.tintColor = .red // Set the color of the checkmark icon

        cancelButton.addTarget(self, action: #selector(didTapCancelImage), for: .touchUpInside)
        containerImageView.addSubview(cancelButton)

        let confirmButton = UIButton(frame: CGRect(x: w - 80, y: h - 80, width: 60, height: 60))
       // confirmButton.setTitle("Confirm", for: .normal)
        
        if #available(iOS 13.0, *) {
                let checkmarkImage = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .bold))
            confirmButton.setImage(checkmarkImage, for: .normal)
            } else {
                let checkmarkImage = UIImage(named: "checkmark")?.withRenderingMode(.alwaysTemplate)
                confirmButton.setImage(checkmarkImage, for: .normal)
            }
           
        confirmButton.tintColor = .systemGreen // Set the color of the checkmark icon

        confirmButton.addTarget(self, action: #selector(didTapConfirmImage), for: .touchUpInside)
        containerImageView.addSubview(confirmButton)
        containerImageView.isHidden = true
    }
    
    func addImagetoView(){
        // Set the image for the image view
        if let image = UIImage(named: firstImagePath ?? "" ) {
            imageView.image = image
        } else {
            print("Image not found")
        }
        progressBar.stopAnimating()
        containerImageView.isHidden = false
        if isBothCamera {
            setupCamera()
        }
    }
    
    @objc func didTapCancelImage() {
        isCreatingImage = false
        containerImageView.isHidden = true
       

       }
    
    @objc func didTapConfirmImage() {
        delegate?.didCapturePhoto(with: firstImagePath!)
        dismiss(animated: true, completion: nil)
    }


    @objc func didTapTakePhoto() {
        if isCreatingImage == false {
            isCreatingImage = true;
            progressBar.startAnimating()

            DispatchQueue.global(qos: .background).async {
                
                
                let settings = AVCapturePhotoSettings()
                self.photoOutput?.capturePhoto(with: settings, delegate: self)
                
                
            }
        }

    }
    @objc func didTapSwitchCamera() {
        if isCreatingImage == false {
            
            currentCameraPosition = (currentCameraPosition == .back) ? .front : .back
            setupCamera()
        }
       }
    
    @objc func didTapCancelCamera() {
        dismiss(animated: true, completion: nil)

       }
    
    @objc func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let image = UIImage(data: imageData)
    
        // Save the image to the temporary directory
          if let data = image?.jpegData(compressionQuality: 1.0) {
              let tempDirectory = FileManager.default.temporaryDirectory
              let fileName = UUID().uuidString + ".jpg"
              let fileURL = tempDirectory.appendingPathComponent(fileName)
              
              do {
                  try data.write(to: fileURL)
                  print("Image saved at: \(fileURL.path)")
                  
                 if  isBothCamera {
                     if isFirstImageClicked {
                         secondImagePath = fileURL.path
                             overlayImage()
                         addImagetoView()

                   
                     
                         
                     }else{
                         firstImagePath = fileURL.path
                         isFirstImageClicked = true
                             self.setupCamera2()
                     }
                     
                  }else{
                      firstImagePath = fileURL.path
                        if( isGeoTagEnable){
                             overlayImage()

                         }
                      addImagetoView()

                  }
                  
     
              } catch {
                  print("Error saving image: \(error.localizedDescription)")
              }

              
          }
    }
    
    
    func overlayImage() {
        
        
         let bottomImage = UIImage(contentsOfFile: firstImagePath!)
           

        let size = CGSize(width:  bottomImage!.size.width,
                         height:  bottomImage!.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false,
     0.0)
        defer { UIGraphicsEndImageContext() }
        bottomImage!.draw(in: CGRect(origin: .zero, size: bottomImage!.size))
        if isGeoTagEnable {
            let paint = NSMutableParagraphStyle()
            paint.alignment = .center
            let textRect = CGRect(origin: CGPoint(x: 20, y: bottomImage!.size.height-100),size: CGSize(width: bottomImage!.size.width, height: 200))
            let textStyle = NSMutableParagraphStyle()
            textStyle.alignment = .left
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 40),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paint
            ]
            let geoTag = "Lat: \(latitude ?? 0.0), Long: \(longitude ?? 0.0)"
            print(geoTag)
            geoTag.draw(in: textRect, withAttributes: attributes)
            
       }
        if isBothCamera {
            let topImage = UIImage(contentsOfFile: secondImagePath!)

            topImage!.draw(in: CGRect(origin: CGPoint(x: 20, y: 20), size: topImage!.size.applying(CGAffineTransform(scaleX: 0.3, y: 0.3))))
        }
          
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
        
        if let newImage = newImage, let imageData = newImage.jpegData(compressionQuality: 0.6) {
            do {
                try imageData.write(to: URL(fileURLWithPath: firstImagePath!))
                
            } catch {
                print("Failed to save image: \(error)")
            }
        }

    }

}




 
