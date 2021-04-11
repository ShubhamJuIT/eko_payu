import UIKit
import CommonCrypto
import PayUCheckoutProKit
import PayUCheckoutProBaseKit
import PayUBizCoreKit
import CryptoKit
import Foundation

class Utils: NSObject {
    class func hexStringToUIColor(hex: String) -> UIColor? {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        cString = String(cString.prefix(6))

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
        class func generateHashFromSDK(
                paymentParams: String,
                salt: String
        ) -> String? {

            return calculateHash(type: "SHA-512",hashString: paymentParams+salt)
        }

        /**
         * Function to calculate the SHA-512 hash
         * @param hashString hash string for hash calculation
         * @return Post Data containig the
         * */
        class func calculateHash(type: String, hashString: String) -> String? {
            return hashString.data(using: .utf8)?.sha512.hexString;
//            val messageDigest =
//                    MessageDigest.getInstance(type)
//            messageDigest.update(hashString.toByteArray())
//            val mdbytes = messageDigest.digest()
//            return getHexString(mdbytes)
        }
        
}

import CommonCrypto

typealias CBridgeCryptoMethodType = (UnsafeRawPointer?,
                                 UInt32,
                                 UnsafeMutablePointer<UInt8>?)
-> UnsafeMutablePointer<UInt8>?

private enum HashType {

    // MARK: - Cases

    case md5
    case sha1
    case sha224
    case sha256
    case sha384
    case sha512
}

extension Data {
    var hexString: String {
        let localHexString = reduce("", { previous, current in
            return previous + String(format: "%02X", current)
        })
        return localHexString
    }
    var md5: Data {
        return hashed(for: .md5)
    }
    var sha1: Data {
        return hashed(for: .sha1)
    }
    var sha224: Data {
        return hashed(for: .sha224)
    }
    var sha256: Data {
        return hashed(for: .sha256)
    }
    var sha384: Data {
        return hashed(for: .sha384)
    }
    var sha512: Data {
        return hashed(for: .sha512)
    }

    private func hashed(for hashType: HashType) -> Data {
        return withUnsafeBytes { (rawBytesPointer: UnsafeRawBufferPointer) -> Data in
            guard let bytes = rawBytesPointer.baseAddress?.assumingMemoryBound(to: Float.self) else {
                return Data()
            }
            let hashMethod: CBridgeCryptoMethodType
            let digestLength: Int
            switch hashType {
            case .md5:
                hashMethod = CC_MD5
                digestLength = Int(CC_MD5_DIGEST_LENGTH)
            case .sha1:
                hashMethod = CC_SHA1
                digestLength = Int(CC_SHA1_DIGEST_LENGTH)
            case .sha224:
                hashMethod = CC_SHA224
                digestLength = Int(CC_SHA224_DIGEST_LENGTH)
            case .sha256:
                hashMethod = CC_SHA256
                digestLength = Int(CC_SHA256_DIGEST_LENGTH)
            case .sha384:
                hashMethod = CC_SHA384
                digestLength = Int(CC_SHA384_DIGEST_LENGTH)
            case .sha512:
                hashMethod = CC_SHA512
                digestLength = Int(CC_SHA512_DIGEST_LENGTH)
            }
            let result = UnsafeMutablePointer<UInt8>.allocate(capacity: digestLength)
            _ = hashMethod(bytes, CC_LONG(count), result)
            let md5Data = Data(bytes: result, count: digestLength)
            result.deallocate()
            return md5Data
        }
    }
}
