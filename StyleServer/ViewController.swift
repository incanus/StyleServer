import UIKit
import GCDWebServer
import Mapbox

class ViewController: UIViewController {

    var server: GCDWebServer!
    var map:    MGLMapView!
    var style:  NSMutableDictionary!

    let fetch = "http://localhost:8080/style.json"

    override func viewDidLoad() {
        super.viewDidLoad()

        style = try! NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile:
            NSBundle.mainBundle().pathForResource("style", ofType: "json")!)!,
            options: [ .MutableContainers, .MutableLeaves ]) as! NSMutableDictionary

        server = GCDWebServer()
        server.addDefaultHandlerForMethod("GET", requestClass: GCDWebServerRequest.self) {
            [unowned self] request in
            return GCDWebServerDataResponse(data:
                try! NSJSONSerialization.dataWithJSONObject(self.style, options: []),
                contentType: "application/json")
        }
        server.start()

        map = MGLMapView(frame: view.bounds, styleURL: NSURL(string: fetch))
        view.addSubview(map)

        map.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap"))
    }

    func handleTap() {
        if let layers = style["layers"] as? NSArray,
          let background = layers[0] as? NSMutableDictionary,
          let paint = background["paint"] as? NSMutableDictionary,
          let color = paint["background-color"] as? NSString {
            let newColor = (color == "#000" ? "#fff" : "#000")
            (((style["layers"] as! NSMutableArray)[0] as! NSMutableDictionary)["paint"] as! NSMutableDictionary)["background-color"] = newColor
            map.styleURL = NSURL(string: fetch + "?\(NSDate().timeIntervalSince1970)")
        }
    }

}
