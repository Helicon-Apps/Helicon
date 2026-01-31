//
//  File.swift
//  Helicon
//
//  Created by Yuriy Nefedov on 31.01.2026.
//

import Foundation

public extension String {
    static func loremIpsum(_ excerpt: LoremIpsumExcerpt = .sentence) -> String {
        excerpt.text
    }
    
    enum LoremIpsumExcerpt {
        case phrase
        case sentence
        case shortParagraph
        case paragraph
        case page
        
        var text: String {
            switch self {
            case .phrase: "Lorem ipsum"
            case .sentence: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
            case .shortParagraph: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis semper aliquet ipsum ut venenatis. Suspendisse viverra commodo enim, in sagittis ex eleifend sit amet."
            case .paragraph: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis semper aliquet ipsum ut venenatis. Suspendisse viverra commodo enim, in sagittis ex eleifend sit amet. Fusce in tincidunt dolor. Duis ac nulla molestie, pellentesque nulla et, ultrices justo. Aenean feugiat dignissim porttitor. Pellentesque sollicitudin ultrices lectus id aliquam. Donec ac sodales nisl."
            case .page: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis semper aliquet ipsum ut venenatis. Suspendisse viverra commodo enim, in sagittis ex eleifend sit amet. Fusce in tincidunt dolor. Duis ac nulla molestie, pellentesque nulla et, ultrices justo. Aenean feugiat dignissim porttitor. Pellentesque sollicitudin ultrices lectus id aliquam. Donec ac sodales nisl.\n\nCras molestie sed risus sed fermentum. Vestibulum vitae est nunc. Aliquam sit amet accumsan velit. Praesent id posuere orci, faucibus maximus nibh. Donec ex mauris, tempus at lectus vitae, fermentum mattis ligula. Duis congue, diam sed rhoncus pharetra, lacus enim molestie quam, et semper turpis mi dignissim velit. Curabitur ut venenatis magna, pharetra sagittis mi. Vivamus dapibus lacus suscipit eros malesuada viverra. Cras viverra, risus eget euismod facilisis, nibh augue porta massa, dignissim blandit tortor turpis eget ex. Morbi vitae convallis lacus. Nulla viverra ligula ut risus efficitur, sed feugiat sapien sodales. Nullam interdum tristique libero, vitae fermentum purus consectetur ac.\n\nMorbi placerat laoreet ex, non fermentum massa pellentesque eget. In commodo aliquet faucibus. Proin et ultrices lorem, ac aliquet libero. Cras ullamcorper dapibus neque in convallis. Maecenas ullamcorper interdum sem in porta. Proin ullamcorper erat in risus convallis mollis. Fusce bibendum risus id metus tincidunt sodales.\n\nCurabitur sodales odio ac arcu lobortis, quis vulputate orci viverra. Duis in urna sit amet erat laoreet commodo. Sed et odio tellus. Vestibulum felis quam, ornare quis condimentum eget, suscipit nec tortor. Donec in neque lobortis, dapibus arcu sed, laoreet turpis. Nunc vel enim vel sem iaculis consequat. Nullam ut varius justo. Sed malesuada rhoncus est a pharetra. Donec ut elit rhoncus metus feugiat finibus sed quis tellus. Maecenas tortor urna, tempus eget risus at, eleifend tempor quam. Sed non urna volutpat, ultrices neque blandit, ultrices neque. Vestibulum sollicitudin odio at libero efficitur rutrum. Vestibulum fermentum erat et sapien condimentum semper quis vel nulla. Nullam at eros vel mi elementum ultrices vel vitae sapien. Pellentesque a vestibulum turpis, vitae accumsan risus. Nullam finibus enim est, ut congue elit porttitor a.\n\nDuis quis rhoncus dolor. Mauris eu dapibus nisi. Aliquam erat volutpat. Cras scelerisque fermentum posuere. Vestibulum vitae tincidunt nulla, eu bibendum quam. Curabitur suscipit ligula felis, et elementum purus viverra quis. Mauris mi odio, laoreet a venenatis non, fringilla at nisl. Nunc at ornare lorem."
            }
        }
    }
}
