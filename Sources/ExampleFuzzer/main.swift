import ExampleLibrary
import Foundation

@_cdecl("LLVMFuzzerTestOneInput")
public func testOneInput(_ start: UnsafeRawPointer, _ count: Int) -> CInt {
    autoreleasepool {
        let bytes = UnsafeRawBufferPointer(start: start, count: count)
        let data = Data(bytes)
        do {
            _ = try add(data)
            return 0
        }
        catch {
            return -1
        }
    }
}

enum Fuzzer {
   static func main() {
       fatalError("You should not run Fuzzer.main. This is only here to allow this target to be built without fuzzing.")
   }
}
