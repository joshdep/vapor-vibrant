//
//  VibrantColors.swift
//  swift-vibrant-ios
//
//  Created by Bryce Dougherty on 5/3/20.
//  Copyright © 2020 Bryce Dougherty. All rights reserved.
//

public typealias Vec3<T> = (T, T, T)
public typealias RGB = (r: UInt8, g: UInt8, b: UInt8)
public typealias HSL = (h: Double, s: Double, l: Double)
public typealias XYZ = (x: Double, y: Double, z: Double)
public typealias LAB = (L: Double, a: Double, b: Double)
public typealias HEX = String

public struct Palette: Codable {
    public var Vibrant: Swatch?
    public var Muted: Swatch?
    public var DarkVibrant: Swatch?
    public var DarkMuted: Swatch?
    public var LightVibrant: Swatch?
    public var LightMuted: Swatch?
}

public class Swatch: Codable, Equatable {
    
    private var _hsl: HSL?

    private var _rgb: RGB

    private var _yiq: Double?

    private var _population: Int

    private var _hex: HEX?

    var r: UInt8 { self._rgb.r }

    var g: UInt8 { self._rgb.g }

    var b: UInt8 { self._rgb.b }

    var rgb: RGB { self._rgb }

    public var hsl: HSL {
        if self._hsl == nil {
            let rgb = self._rgb
            self._hsl = apply(rgbToHsl, rgb)
        }
        return self._hsl!
    }

    public var hex: HEX {
        if self._hex == nil {
            let rgb = self._rgb
            self._hex = apply(rgbToHex, rgb)
        }
        return self._hex!
    }
    
    static func applyFilter(colors: [Swatch], filter: Filter)->[Swatch] {
        var colors = colors
        colors = colors.filter { (swatch) -> Bool in
            let r = swatch.r
            let g = swatch.g
            let b = swatch.b
            return filter.f(r, g, b, 255)
        }
        return colors
    }
    
    public var population: Int { self._population }

    
    func toDict() -> [String: Any] {
        return [
            "rgb": self.rgb,
            "population": self.population
        ]
    }
    
    var toJSON = toDict

    private func getYiq() -> Double {
        if self._yiq == nil {
            let (r,g,b) = self._rgb
            let mr = Int(r) * 299
            let mg = Int(g) * 598
            let mb = Int(b) * 114
            let mult = mr + mg + mb
            self._yiq =  Double(mult) / 1000
        }
        return self._yiq!
    }

    private var _titleTextColor: HEX?

    private var _bodyTextColor: HEX?

    public var titleTextColor: HEX {
        if self._titleTextColor == nil {
            self._titleTextColor = self.getYiq() < 200 ? "#FFF" : "#000"
        }
        return self._titleTextColor!
    }

    public var bodyTextColor: HEX {
        if self._bodyTextColor == nil {
            self._bodyTextColor = self.getYiq() < 150 ? "#FFF" : "#000"
        }
        return self._bodyTextColor!
    }

    public func getTitleTextColor() -> HEX {
        return self.titleTextColor
    }

    public func getBodyTextColor() -> HEX {
        return self.bodyTextColor
    }
    
    public static func == (lhs: Swatch, rhs: Swatch) -> Bool {
        return lhs.rgb == rhs.rgb
    }

    init(_ rgb: RGB, _ population: Int) {
        self._rgb = rgb
        self._population = population
    }
    
    enum CodingKeys: String, CodingKey {
        case rgb
        case population
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rgbString: String = try container.decode(String.self, forKey: .rgb)
        let rgbParts = rgbString.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").split(separator: ",")
        guard let r = UInt8(rgbParts[0]), let g = UInt8(rgbParts[1]), let b = UInt8(rgbParts[2]) else {
            throw DecodingError.valueNotFound(UInt8.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid rgb code: \(rgbString)"))
        }
        self._rgb = (r, g, b)
        self._population = try container.decode(Int.self, forKey: .population)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let (r,g,b) = self.rgb
        let rgbString = "[\(r),\(g),\(b)]"
        
        try container.encode(rgbString, forKey: .rgb)
        try container.encode(self._population, forKey: .population)
    }
}
