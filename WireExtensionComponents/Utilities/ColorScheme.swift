//
// Wire
// Copyright (C) 2018 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import Foundation
import UIKit

public extension UIColor {
    @objc static var graphite: UIColor = UIColor.wr_color(from: "rgb(51, 55, 58)")
    static var graphiteAlpha8: UIColor = UIColor.wr_color(from: "rgb(51, 55, 58, 0.08)")
    static var graphiteAlpha16: UIColor = UIColor.wr_color(from: "rgb(51, 55, 58, 0.16)")
    static var graphiteAlpha40: UIColor = UIColor.wr_color(from: "rgb(51, 55, 58, 0.4)")

    static var backgroundLightGraphite: UIColor = UIColor.wr_color(from: "rgb(30, 32, 33)")

    @objc static var lightGraphite: UIColor = UIColor.wr_color(from: "rgb(141, 152, 159)")
    static var lightGraphiteAlpha8: UIColor = UIColor.wr_color(from: "rgb(141, 152, 159, 0.08)")
    static var lightGraphiteAlpha24: UIColor = UIColor.wr_color(from: "rgb(141, 152, 159, 0.24)")
    static var lightGraphiteAlpha48: UIColor = UIColor.wr_color(from: "rgb(141, 152, 159, 0.48)")
    static var lightGraphiteAlpha64: UIColor = UIColor.wr_color(from: "rgb(141, 152, 159, 0.64)")
    static var lightGraphiteWhite: UIColor = lightGraphiteAlpha8.removeAlphaByBlending(with: .white98)!
    static var lightGraphiteDark: UIColor = lightGraphiteAlpha8.removeAlphaByBlending(with: .backgroundGraphite)

    static var backgroundGraphite: UIColor = UIColor.wr_color(from: "rgb(22, 24, 25)")
    static var backgroundGraphiteAlpha40: UIColor = UIColor.wr_color(from: "rgb(22, 24, 25, 0.4)")

    static var white97: UIColor = UIColor(white: 0.97, alpha: 1)
    static var white98: UIColor = UIColor(white: 0.98, alpha: 1)

    static var whiteAlpha8: UIColor = UIColor(white: 1.0, alpha: 0.08)
    static var whiteAlpha16: UIColor = UIColor(white: 1.0, alpha: 0.16)
    static var whiteAlpha24: UIColor = UIColor(white: 1.0, alpha: 0.24)
    static var whiteAlpha40: UIColor = UIColor(white: 1.0, alpha: 0.4)
    static var whiteAlpha56: UIColor = UIColor(white: 1.0, alpha: 0.56)
    static var whiteAlpha64: UIColor = UIColor(white: 1.0, alpha: 0.64)
    static var whiteAlpha80: UIColor = UIColor(white: 1.0, alpha: 0.8)

    static var blackAlpha4: UIColor = UIColor(white: 0.0, alpha: 0.04)
    static var blackAlpha8: UIColor = UIColor(white: 0.0, alpha: 0.08)
    static var blackAlpha24: UIColor = UIColor(white: 0.0, alpha: 0.24)
    static var blackAlpha48: UIColor = UIColor(white: 0.0, alpha: 0.48)
    static var blackAlpha40: UIColor = UIColor(white: 0.0, alpha: 0.4)
    static var blackAlpha80: UIColor = UIColor(white: 0.0, alpha: 0.8)

    static var amberAlpha48: UIColor = UIColor.wr_color(from: "rgb(254, 191, 2, 0.48)")
    static var amberAlpha80: UIColor = UIColor.wr_color(from: "rgb(254, 191, 2, 0.8)")
}


@objc public enum ColorSchemeColor: Int {
    case textForeground
    case textBackground
    case textDimmed
    case textPlaceholder

    case iconNormal
    case iconSelected
    case iconHighlighted
    case iconBackgroundSelected
    case iconBackgroundSelectedNoAccent
    case iconShadow
    case iconHighlight
    case iconGuest

    case popUpButtonOverlayShadow

    case buttonHighlighted
    case buttonEmptyText
    case buttonFaded

    case tabNormal
    case tabSelected
    case tabHighlighted

    case background
    case contentBackground
    case barBackground
    case searchBarBackground
    case separator
    case cellSeparator
    case backgroundOverlay
    case backgroundOverlayWithoutPicture
    case placeholderBackground
    case avatarBorder
    case loadingDotActive
    case loadingDotInactive

    case paleSeparator
    case listAvatarInitials
    case audioButtonOverlay

    case sectionBackground
    case sectionText

    case tokenFieldBackground
    case tokenFieldTextPlaceHolder

    case selfMentionHighlight
    case cellHighlight
    
    case replyBorder
}

extension UIColor {

    @objc(wr_colorFromColorScheme:)
    public static func from(scheme: ColorSchemeColor) -> UIColor {
        return ColorScheme.default.color(named: scheme)
    }

    @objc(wr_colorFromColorScheme:variant:)
    public static func from(scheme: ColorSchemeColor, variant: ColorSchemeVariant) -> UIColor {
        return ColorScheme.default.color(named: scheme, variant: variant)
    }
}

fileprivate struct ColorPair {
    let light: UIColor
    let dark: UIColor
}

fileprivate extension ColorPair {
    init(both color: UIColor) {
        self.init(light: color, dark: color)
    }
}

extension ColorSchemeColor {

    fileprivate func colorPair(accentColor: UIColor) -> ColorPair  {
        switch self {
        case .textForeground:
            return ColorPair(light: .graphite, dark: .white)
        case .textBackground:
            return ColorPair(light: .white, dark: .backgroundGraphite)
        case .textDimmed:
            return ColorPair(both: .lightGraphite)
        case .textPlaceholder:
            return ColorPair(both: .lightGraphiteAlpha64)
        case .separator:
            return ColorPair(light: .lightGraphiteAlpha48, dark: .lightGraphiteAlpha24)
        case .barBackground:
            return ColorPair(light: .white, dark: .backgroundLightGraphite)
        case .background:
            return ColorPair(light: .white, dark: .backgroundGraphite)
        case .contentBackground:
            return ColorPair(light: .white97, dark: .backgroundGraphite)
        case .iconNormal:
            return ColorPair(light: .graphite, dark: .white)
        case .iconSelected:
            return ColorPair(light: .white, dark: .black)
        case .iconHighlighted:
            return ColorPair(both: .white)
        case .iconShadow:
            return ColorPair(light: .blackAlpha8, dark: .blackAlpha24)
        case .iconHighlight:
            return ColorPair(light: .white, dark: .whiteAlpha16)
        case .iconBackgroundSelected:
            return ColorPair(light: accentColor, dark: .white)
        case .iconBackgroundSelectedNoAccent:
            return ColorPair(light: .graphite, dark: .white)
        case .popUpButtonOverlayShadow:
            return ColorPair(light: .blackAlpha24, dark: .black)
        case .buttonHighlighted:
            return ColorPair(light: .whiteAlpha24, dark: .blackAlpha24)
        case .buttonEmptyText:
            return ColorPair(light: accentColor, dark: .white)
        case .buttonFaded:
            return ColorPair(light: .graphiteAlpha40, dark: .whiteAlpha40)
        case .tabNormal:
            return ColorPair(light: .blackAlpha48, dark: .whiteAlpha56)
        case .tabSelected:
            return ColorPair(light: .graphite, dark: .white)
        case .tabHighlighted:
            return ColorPair(light: .lightGraphite, dark: .lightGraphiteAlpha48)
        case .backgroundOverlay:
            return ColorPair(light: .blackAlpha24, dark: .blackAlpha48)
        case .backgroundOverlayWithoutPicture:
            return ColorPair(both: .blackAlpha80)
        case .avatarBorder:
            return ColorPair(light: .blackAlpha8, dark: .whiteAlpha16)
        case .audioButtonOverlay:
            return ColorPair(both: .lightGraphiteAlpha24)
        case .placeholderBackground:
            return ColorPair(light: .lightGraphiteWhite, dark: .lightGraphiteDark)
        case .loadingDotActive:
            return ColorPair(light: .graphiteAlpha40, dark: .whiteAlpha40)
        case .loadingDotInactive:
            return ColorPair(light: .graphiteAlpha16, dark: .whiteAlpha16)
        case .paleSeparator:
            return ColorPair(both: .lightGraphiteAlpha24)
        case .listAvatarInitials:
            return ColorPair(both: .blackAlpha40)
        case .sectionBackground:
            return ColorPair(both: .clear)
        case .sectionText:
            return ColorPair(light: .blackAlpha40, dark: .whiteAlpha40)
        case .tokenFieldBackground:
            return ColorPair(light: .blackAlpha4, dark: .whiteAlpha16)
        case .tokenFieldTextPlaceHolder:
            return ColorPair(light: .lightGraphite, dark: .whiteAlpha40)
        case .cellSeparator:
            return ColorPair(light: .graphiteAlpha8, dark: .whiteAlpha8)
        case .searchBarBackground:
            return ColorPair(light: .white, dark: .whiteAlpha8)
        case .iconGuest:
            return ColorPair(light: .backgroundGraphiteAlpha40, dark: .whiteAlpha64)
        case .selfMentionHighlight:
            return ColorPair(light: .amberAlpha48, dark: .amberAlpha80)
        case .cellHighlight:
            return ColorPair(light: .white97, dark: .whiteAlpha16)
        case .replyBorder:
            return ColorPair(light: UIColor(white: 233.0/255.0, alpha: 1),
                             dark: UIColor(white: 114.0/255.0, alpha: 1))
        }
    }
}

public extension ColorScheme {
    @objc(colorWithName:)
    public func color(named: ColorSchemeColor) -> UIColor {
        return color(named: named, variant: variant)
    }

    @objc(colorWithName:variant:)
    public func color(named: ColorSchemeColor, variant: ColorSchemeVariant) -> UIColor {
        let colorPair = named.colorPair(accentColor: accentColor)
        switch variant {
        case .dark:
            return colorPair.dark
        case .light:
            return colorPair.light
        }
    }

    @objc(nameAccentForColor:variant:)
    public func nameAccent(for color: ZMAccentColor, variant: ColorSchemeVariant) -> UIColor {
        return UIColor.nameColor(for: color, variant: variant)
    }

}