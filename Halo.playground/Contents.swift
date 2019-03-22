import Halo
import UIKit
import PlaygroundSupport

let titleLabel: UILabel = Element.label(style: .autoresizing, text: "I'm a really long title").create()

let subtitleLabel: UILabel = Element.label(style: .autoresizing, text: "I'm a subtitle").create()

let iconView = Element.view(style: .concat(.autolayout, .backgroundColor(.blue), .cornerRadius(6), .square(20))).create()

Sizing.intrinsic(titleLabel).size
Sizing.intrinsic(iconView).size

Sizing.fits(.horizontal(width: 50), titleLabel).size
Sizing.fits(.horizontal(width: 50), iconView).size

Sizing.autolayout(.horizontal(width: 50), titleLabel).size
Sizing.autolayout(.horizontal(width: 50), iconView).size

Sizing.fix(CGSize(width: 10, height: 10), titleLabel).size
Sizing.fix(CGSize(width: 10, height: 10), iconView).size

let space: Layout = .space(CGSize(width: 8, height: 8))
let icon: Layout = .fix(CGSize(width: 20, height: 20), iconView)
let shortTitle: Layout = .fits(.horizontal(width: 80), titleLabel)

let long: Layout = .flow(icon, space, .intrinsic(titleLabel))
let short: Layout = .flow(icon, space, shortTitle)
let sub: Layout = .flow(.intrinsic(subtitleLabel))

let first: Layout = .stack(long, sub)
let second: Layout = .stack(short, sub)

let layout: Layout = .choice(first: first, second: second)
let result = layout.compute(origin: .zero, direction: .horizontal(width: 120))
//let result = layout.compute(origin: .zero, direction: .vertical(height: 120))
print(result)

let view = UIView(frame: result.frame)
view.backgroundColor = .white

result.views.forEach { view.addSubview($0) }

PlaygroundPage.current.liveView = view
