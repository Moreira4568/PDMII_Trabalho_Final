
import UIKit
import AVFoundation

class QrCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var squareImageView: UIImageView!
    static let identifier = "QrCodeScannerViewController"
    
    let session = AVCaptureSession()
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do{
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            session.addInput(input)
        }catch{
            print("Erro scanner QR")
        }
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        
        squareImageView.layer.borderWidth = 4
        squareImageView.layer.borderColor = UIColor.green.cgColor
        
        self.view.bringSubviewToFront(squareImageView)
        session.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObject: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObject.first {
            guard let readbleObject = metadataObject as?
                    AVMetadataMachineReadableCodeObject else { return }
            print(readbleObject.stringValue)
            session.stopRunning()
        }
    }

    
}
