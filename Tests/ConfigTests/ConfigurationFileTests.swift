//
//  ConfigurationFileTests.swift
//  ConfigTests
//
//  Created by David Hardiman on 25/04/2019.
//

@testable import Config
import Foundation
import Nimble
import XCTest

class ConfigurationFileTests: XCTestCase {
    func testItCanHandleAnyConfiguration() {
        expect(ConfigurationFile.canHandle(config: [:])).to(beTrue())
    }

    func testItCanBeInitialisedFromAnEmptyConfiguration() throws {
        let config = try ConfigurationFile(config: givenAConfigDictionary(), name: "Test", scheme: "any", source: URL(fileURLWithPath: "/"))
        expect(config.name).to(equal("Test"))
        expect(config.scheme).to(equal("any"))
        let testIV = try IV(dict: [:])
        expect(config.iv.hash).to(equal(testIV.hash))
        expect(config.filename).to(beNil())
        let expectedOutput = """
        /* Test.swift auto-generated from any */

        import Foundation

        // swiftlint:disable force_unwrapping type_body_length file_length superfluous_disable_command
        public enum Test {
            public static let schemeName: String = "any"
        }

        // swiftlint:enable force_unwrapping type_body_length file_length superfluous_disable_command

        """
        expect(config.description).to(equal(expectedOutput))
    }

    func testItCanOutputAnExtension() throws {
        let dict = givenAConfigDictionary(withTemplate: extensionTemplate)
        let config = try ConfigurationFile(config: dict, name: "Test", scheme: "any", source: URL(fileURLWithPath: "/"))
        let testIV = try IV(dict: dict)
        expect(config.iv.hash).to(equal(testIV.hash))
        expect(config.filename).to(equal("UIColor+Test"))
        let expectedOutput = """
        /* UIColor+Test.swift auto-generated from any */

        import Foundation

        // swiftlint:disable force_unwrapping type_body_length file_length superfluous_disable_command
        public extension UIColor {

        }

        // swiftlint:enable force_unwrapping type_body_length file_length superfluous_disable_command

        """
        expect(config.description).to(equal(expectedOutput))
    }

    func testItCanOutputAdditionalImports() throws {
        let dict = givenAConfigDictionary(withTemplate: importsTemplate)
        let config = try ConfigurationFile(config: dict, name: "Test", scheme: "any", source: URL(fileURLWithPath: "/"))
        let expectedOutput = """
        /* Test.swift auto-generated from any */

        import AnotherFramework
        import Foundation
        import SomeFramework

        // swiftlint:disable force_unwrapping type_body_length file_length superfluous_disable_command
        public enum Test {
            public static let schemeName: String = "any"
        }

        // swiftlint:enable force_unwrapping type_body_length file_length superfluous_disable_command

        """
        expect(config.description).to(equal(expectedOutput))
    }

    func testItCanOutputEncryptedValues() throws {
        let config = try ConfigurationFile(config: configWithEncryption, name: "Test", scheme: "any", source: URL(fileURLWithPath: "/"))
        let expectedOutput = """
        /* Test.swift auto-generated from any */

        import Foundation

        // swiftlint:disable force_unwrapping type_body_length file_length superfluous_disable_command
        public enum Test {
            public static let encryptionKey: [UInt8] = [UInt8(116), UInt8(104), UInt8(101), UInt8(45), UInt8(107), UInt8(101), UInt8(121), UInt8(45), UInt8(116), UInt8(111), UInt8(45), UInt8(116), UInt8(104), UInt8(101), UInt8(45), UInt8(115), UInt8(101), UInt8(99), UInt8(114), UInt8(101), UInt8(116)]

            public static let encryptionKeyIV: [UInt8] = [UInt8(97), UInt8(53), UInt8(101), UInt8(49), UInt8(49), UInt8(97), UInt8(100), UInt8(57), UInt8(98), UInt8(53), UInt8(56), UInt8(55), UInt8(52), UInt8(56), UInt8(101), UInt8(48), UInt8(52), UInt8(56), UInt8(57), UInt8(57), UInt8(56), UInt8(97), UInt8(102), UInt8(53), UInt8(55), UInt8(55), UInt8(97), UInt8(55), UInt8(98), UInt8(97), UInt8(48), UInt8(102)]

            public static let schemeName: String = "any"

            public static let somethingSecret: [UInt8] = [UInt8(72), UInt8(248), UInt8(24), UInt8(73), UInt8(30), UInt8(207), UInt8(159), UInt8(0), UInt8(65), UInt8(147), UInt8(20), UInt8(183), UInt8(214), UInt8(231), UInt8(169), UInt8(3)]
        }

        // swiftlint:enable force_unwrapping type_body_length file_length superfluous_disable_command

        """
        expect(config.description).to(equal(expectedOutput))
    }

    func testItUsesOverridesAndOrdersProperties() throws {
        let config = try ConfigurationFile(config: configWithOverride, name: "Test", scheme: "scheme", source: URL(fileURLWithPath: "/"))
        let expectedOutput = """
        /* Test.swift auto-generated from scheme */

        import Foundation

        // swiftlint:disable force_unwrapping type_body_length file_length superfluous_disable_command
        public enum Test {
            public static let anotherProperty: Int = 1

            public static let schemeName: String = "scheme"

            public static let testProperty: String = "A test"
        }

        // swiftlint:enable force_unwrapping type_body_length file_length superfluous_disable_command

        """
        expect(config.description).to(equal(expectedOutput))
    }

    func testItItCanWriteReferenceProperties() throws {
        let config = try ConfigurationFile(config: configWithReferenceProperty, name: "Test", scheme: "scheme", source: URL(fileURLWithPath: "/"))
        let expectedOutput = """
        /* Test.swift auto-generated from scheme */

        import Foundation

        // swiftlint:disable force_unwrapping type_body_length file_length superfluous_disable_command
        public enum Test {
            public static let property: String = "A test"

            public static let referenceProperty: String = property

            public static let schemeName: String = "scheme"
        }

        // swiftlint:enable force_unwrapping type_body_length file_length superfluous_disable_command

        """
        expect(config.description).to(equal(expectedOutput))
    }

    func testItCanWriteNonObjcProperties() throws {
        let config = try ConfigurationFile(config: givenAConfigDictionary(withTemplate: nonObjCTemplate), name: "Test", scheme: "any", source: URL(fileURLWithPath: "/"))
        let expectedOutput = """
        /* Test.swift auto-generated from any */

        import Foundation

        // swiftlint:disable force_unwrapping type_body_length file_length superfluous_disable_command
        public enum Test {
            @nonobjc public static var schemeName: String {
                return "any"
            }
        }

        // swiftlint:enable force_unwrapping type_body_length file_length superfluous_disable_command

        """
        expect(config.description).to(equal(expectedOutput))
    }

    func testItOutputsGroups() throws {
        let config = try ConfigurationFile(config: groupedConfig, name: "Test", scheme: "scheme", source: URL(fileURLWithPath: "/"))
        let expectedOutput = """
        /* Test.swift auto-generated from scheme */

        import Foundation

        // swiftlint:disable force_unwrapping type_body_length file_length superfluous_disable_command
        public enum Test {
            public static let schemeName: String = "scheme"

            public enum FirstGroup {
                public static let testProperty: String = "A test"
            }

            public enum SecondGroup {
                public static let anotherProperty: Int = 0
            }
        }

        // swiftlint:enable force_unwrapping type_body_length file_length superfluous_disable_command

        """
        expect(config.description).to(equal(expectedOutput))
    }

    func testAssociatedPropertiesAreOutputForDefaults() throws {
        let config = try ConfigurationFile(config: configWithAssociatedProperties, name: "Test", scheme: "scheme", source: URL(fileURLWithPath: "/"))
        let expectedOutput = """
        /* Test.swift auto-generated from scheme */

        import Foundation

        // swiftlint:disable force_unwrapping type_body_length file_length superfluous_disable_command
        public enum Test {
            /// API Host
            public static let host: String = "dev.dave.com"

            public static let hostKey: String = "a-secret-key"

            public static let schemeName: String = "scheme"
        }

        // swiftlint:enable force_unwrapping type_body_length file_length superfluous_disable_command

        """
        expect(config.description).to(equal(expectedOutput))
    }

    func testAssociatedPropertiesAreOutputForScheme() throws {
        let config = try ConfigurationFile(config: configWithAssociatedProperties, name: "Test", scheme: "prod", source: URL(fileURLWithPath: "/"))
        let expectedOutput = """
        /* Test.swift auto-generated from prod */

        import Foundation

        // swiftlint:disable force_unwrapping type_body_length file_length superfluous_disable_command
        public enum Test {
            /// API Host
            public static let host: String = "dave.com"

            public static let hostKey: String = "the-prod-key"

            public static let schemeName: String = "prod"
        }

        // swiftlint:enable force_unwrapping type_body_length file_length superfluous_disable_command

        """
        expect(config.description).to(equal(expectedOutput))
    }

    func testPropertiesAreOutputForVariousTypes() throws {
        let config = try ConfigurationFile(config: configurationWithDifferentTypes, name: "Test", scheme: "any", source: URL(fileURLWithPath: "/"))
        let expectedOutput = """
        /* Test.swift auto-generated from any */

        import Foundation

        // swiftlint:disable force_unwrapping type_body_length file_length superfluous_disable_command
        public enum Test {
            public static let bool: Bool = true

            public static let dictionary: [String: Any] = [:]

            public static let float: Float = 0.0

            public static let schemeName: String = "any"

            public static let stringArray: [String] = []
        }

        // swiftlint:enable force_unwrapping type_body_length file_length superfluous_disable_command

        """
        expect(config.description).to(equal(expectedOutput))
    }

    func givenAConfigDictionary(withTemplate template: [String: Any]? = nil) -> [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary["template"] = template
        return dictionary
    }
}

let extensionTemplate: [String: Any] = [
    "extensionOn": "UIColor",
    "extensionName": "Test"
]

let importsTemplate: [String: Any] = [
    "imports": [
        "SomeFramework",
        "AnotherFramework"
    ]
]

let configWithEncryption: [String: Any] = [
    "encryptionKey": [
        "type": "EncryptionKey",
        "defaultValue": "the-key-to-the-secret"
    ],
    "somethingSecret": [
        "type": "Encrypted",
        "defaultValue": "secret"
    ]
]

let configWithOverride: [String: Any] = [
    "testProperty": [
        "type": "String",
        "defaultValue": "A test"
    ],
    "anotherProperty": [
        "type": "Int",
        "defaultValue": 0,
        "overrides": [
            "scheme": 1
        ]
    ]
]

let configWithReferenceProperty: [String: Any] = [
    "property": [
        "type": "String",
        "defaultValue": "A test"
    ],
    "referenceProperty": [
        "type": "Reference",
        "defaultValue": "property"
    ]
]

let nonObjCTemplate: [String: Any] = [
    "requiresNonObjC": true
]

let groupedConfig: [String: Any] = [
    "firstGroup": [
        "testProperty": [
            "type": "String",
            "defaultValue": "A test"
        ]
    ],
    "secondGroup": [
        "anotherProperty": [
            "type": "Int",
            "defaultValue": 0
        ]
    ]
]

let configWithAssociatedProperties: [String: Any] = [
    "host": [
        "description": "API Host",
        "type": "String",
        "defaultValue": "dev.dave.com",
        "overrides": [
            "prod": "dave.com"
        ]
    ],
    "hostKey": [
        "type": "String",
        "associatedProperty": "host",
        "defaultValue": "a-secret-key",
        "overrides": [
            "dave.com": "the-prod-key"
        ]
    ]
]

let configurationWithDifferentTypes: [String: Any] = [
    "float": [
        "type": "Float",
        "defaultValue": 0.0
    ],
    "dictionary": [
        "type": "Dictionary",
        "defaultValue": [:]
    ],
    "bool": [
        "type": "Bool",
        "defaultValue": true
    ],
    "stringArray": [
        "type": "[String]",
        "defaultValue": []
    ]
]
