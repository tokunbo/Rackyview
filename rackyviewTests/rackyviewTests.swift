

import UIKit
import XCTest
import Rackyview

class rackyviewTests: XCTestCase {
    var isTestComplete:Bool = false
    
    func waitForAsync() {
        var timeout = 30.0
        var startTime:NSTimeInterval = NSDate.timeIntervalSinceReferenceDate()
        while(!isTestComplete){
            NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow:1))
            var elapsedTime:NSTimeInterval = NSDate.timeIntervalSinceReferenceDate() - startTime
            if(elapsedTime > timeout) {
                XCTFail("This unittest took too long. More than "+String(format:"%f", timeout)+" seconds")
                self.isTestComplete = true
                break
            }
        }
    }
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        self.isTestComplete = false
    }
    
    override func tearDown() {
        //Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRNGcrypt() {
        var mySecretMessage:String = "Tatsunoko vs. Capcom"
        
        var rngDecrypt:(NSData!)->() = { cipherdata in
            var key = UIDevice().identifierForVendor.UUIDString
            var plaindata:NSData!
            var outputdata_length:CInt = 0
            var readonlybuf_ptr:UnsafePointer = UnsafePointer<UInt8>(cipherdata.bytes)
            var key_ptr = UnsafePointer<UInt8>((key.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)?.bytes)!)
            var key_buf = UnsafeMutablePointer<UInt8>.alloc(key.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)+1)
            memset(key_buf, 0, key.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)+1)//C string needs to be null-terminated
            memcpy(key_buf, key_ptr, key.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
            var writebuf_ptr:UnsafeMutablePointer<UInt8> = rackyDecrypt(readonlybuf_ptr, key_buf, Int32(cipherdata.length), &outputdata_length)
            free(key_buf)
            if(outputdata_length == 0) {
                XCTFail("Decryption returned 0 length buffer\n")
            }
            plaindata = NSData(bytesNoCopy: writebuf_ptr, length: Int(outputdata_length), freeWhenDone: true)
            println("Decrypted \(outputdata_length) bytes")
            println(plaindata)
            var decryptedMessage:String = NSString(data: plaindata, encoding: NSISOLatin1StringEncoding) as! String
            if(decryptedMessage != mySecretMessage) {
                XCTFail("Decrypted message: \(decryptedMessage), doesn't equal  original: \(mySecretMessage)")
            }
        }
        
        var plaindata:NSData! = mySecretMessage.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        var outputdata_length:CInt = 0
        var key = UIDevice().identifierForVendor.UUIDString
        var readonlybuf_ptr:UnsafePointer = UnsafePointer<UInt8>(plaindata.bytes)
        var key_ptr = UnsafePointer<UInt8>((key.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)?.bytes)!)
        var key_buf = UnsafeMutablePointer<UInt8>.alloc(key.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)+1)
        memset(key_buf, 0, key.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)+1)//C string needs to be null-terminated
        memcpy(key_buf, key_ptr, key.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        var writebuf_ptr:UnsafeMutablePointer<UInt8> = rackyEncrypt(readonlybuf_ptr, key_buf, Int32(plaindata.length), &outputdata_length)
        if(outputdata_length == 0) {
            XCTFail("Encryption returned 0 length buffer")
        }
        free(key_buf)
        rngDecrypt(NSData(bytesNoCopy: writebuf_ptr, length: Int(outputdata_length), freeWhenDone: true))
    }
    
    /*func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }*/
}