//
//  ColorWheel.swift
//  TodoLost
//
//  Created by Дмитрий Данилин on 23.06.2023.
//

import UIKit

struct ColorPath {
    var path:UIBezierPath
    var color:UIColor
}

final class ColorWheel: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        center = self.center
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
        center = self.center
    }
    
    private var image: UIImage? = nil
    private var imageView: UIImageView? = nil
    private var paths = [ColorPath]()
    
    var size:CGSize = CGSize.zero { didSet { setNeedsDisplay() } }
    var sectors:Int = 360 { didSet { setNeedsDisplay() } }
    
    func colorAtPoint(point: CGPoint) -> UIColor {
        for colorPath in 0..<paths.count {
            if paths[colorPath].path.contains(point) {
                return paths[colorPath].color
            }
        }
        return UIColor.clear
    }

    override func draw(_ rect: CGRect) {
        let radius = CGFloat(min(bounds.size.width, bounds.size.height) / 2.0 ) * 0.90
        let angle: CGFloat = CGFloat(2.0) * (.pi) / CGFloat(sectors)
        var colorPath:ColorPath = ColorPath(path: UIBezierPath(), color:UIColor.clear)
        
        self.center = CGPoint(x: self.bounds.width - (self.bounds.width / 2.0),y: self.bounds.height - (self.bounds.height / 2.0))
        UIGraphicsBeginImageContextWithOptions(CGSize(width: bounds.size.width, height: bounds.size.height), true, 0)
        
        UIColor.white.setFill()
        UIRectFill(frame)
        
        for sector in 0..<sectors {
            let center = self.center
            colorPath.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(sector) * angle, endAngle: (CGFloat(sector) + CGFloat(1)) * angle, clockwise: true)
            colorPath.path.addLine(to: center)
            colorPath.path.close()
            
            let color = UIColor(hue: CGFloat(sector)/CGFloat(sectors), saturation: CGFloat(1), brightness: CGFloat(1), alpha: CGFloat(1))
            color.setFill()
            color.setStroke()
            
            colorPath.path.fill()
            colorPath.path.stroke()
            colorPath.color = color

            paths.append(colorPath)
        }
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard image != nil else { return }
        let imageView = UIImageView (image: image)
        self.addSubview(imageView)
        guard let oc = superview?.center else { return }
        self.center = oc
    }
}
