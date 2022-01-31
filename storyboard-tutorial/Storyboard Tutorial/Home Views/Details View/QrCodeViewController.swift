
import UIKit

class QrCodeViewController: UIViewController {

    
    @IBOutlet weak var myImageView: UIImageView!
    static let identifier = "QrCodeViewController"
    var imageUrl = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myImageView.image = generateQRCode(from: String(describing: imageUrl ?? "error"))

    }
    
    func generateQRCode(from string:String) -> UIImage? {
        
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator"){
            
            filter.setValue(data, forKey: "inputMessage")
            
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
            
        }
        
        return nil
        
    }
    
}
