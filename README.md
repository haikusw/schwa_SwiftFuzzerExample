# Using LLVM's libfuzzer with Swift

## Background

I've been using LLVM's libfuzzer to generate tests for and discover bugs in an SVG rendering library I am working on. I've found that [LLVM's libfuzzer](https://www.llvm.org/docs/LibFuzzer.html) is the easiest fuzzer to use for Swift on macOS. Other tools seem to have a list of requirements that are difficult to meet. `libfuzzer`, on the other hand, is built into LLVM and is available on macOS in the custom Swift toolchains: <https://www.swift.org/download/>

In this document, I'll describe how to use `libfuzzer` with Swift and Swift Packages. I won't provide background on fuzzing; other sources, including Wikipedia, will give a much better background.

I used a setup similar to this to fuzz an SVG Renderer package I am building. I have found and fixed over ten serious, crashing bugs in my SVG parsing code using `libfuzzer`.

## This Repository

This repository provides a Swift Package Manager set up to work with `libfuzzer`. There is a [justfile](XXX) you can use to install the toolchain dependency and perform the fuzzing operation.

## How to use `libfuzzer`

`libfuzzer` is a special LLVM sanitizer mode you invoke from the command line when building your project. When invoked, `libfuzzer` will run a function you provide, passing in the fuzzed test cases. The function must be named `LLVMFuzzerTestOneInput` in C (in Swift, you can use XXX to expose your function with the correct name). In my case, I used this function to parse SVG documents and render them to (offscreen) images. The sample code in this repository performs basic parsing and math operations on the test data. When built - this project is a command line tool that provides a front end to `libfuzzer` - you pass flags to `libfuzzer` directly from the command line.

### Swift Toolchain

`libfuzzer` *is not* built into Xcode's LLVM toolchain but is built into custom toolchains available on [http://swift.org](https://www.swift.org/download/). Download and install the latest macOS Swift toolchain. (I downloaded and installed the latest Xcode 14.3 compatible toolchain). If you have `just` installed, you can install the newest toolchain (correct as of when I created this repository) with `just xxxx`.

### Swift Package Manager

I created a custom executable target in my `Package.swift` to integrate fuzzing with my project. The logic to test is in the library target, and the executable target imports that.

### Swift `LLVMFuzzerTestOneInput`

The executable target contained one source file: `main.swift`. This file imports the module with the logic to test, provides the fuzzing function (and uses the `@_cdecl` attribute to make it available to `libfuzzer` with the correct name.)

Note that this source file also contains a `main` entry point. This entry point is used when *NOT* building against `libfuzzer` as `libfuzzer` provides its own main.

You should also remember to wrap your Swift code in an autorelease pool. `libfuzzer` will call your fuzzing function repeatedly, and you don't want to leak memory between runs - the autorelease pool will guard against that. If you don't do this, your fuzzing sessions will quickly run out of memory. Similarly, testing and solving leaks before running `libfuzzer` is best.

### Building

I built my project with the following command line (again, you can use `just XXX` to run this for you). The `-parse-as-library` flag is in effect, telling the toolchain not to worry about `main` - which, as noted above, is provided by `libfuzzer`.

Here we use the XXXX flag to specify the fuzzer and the XXX checker. You can also use other checkers instead of XXX.

Note that the `toolchain` flag specifies the previously downloaded and installed toolchain.

### Running

Once built, you can run the fuzzer with the following command line.

See the `libfuzzer` documentation for more information on how you can invoke `libfuzzer`. One thing to note is that I provide two corpus directories. The first corpus directory passed to `libfuzzer` is the one where it will save newly generated test cases. The second corpus directory, in my case, contains a few hundred test cases (in my case, sample SVG files I've tested against manually and all the SVG files from a standard SVG test suite). `libfuzzer` will use its existing corpus of data to generate new test cases. You can decide not to provide a corpus, which will generate purely random test cases. `libfuzzer` is much more effective when it has an existing corpus of data.

I also provide a dictionary file, a text file containing a list of terms that `libfuzzer` will use to generate new test cases. `libfuzzer` dictionaries are in the same format as AFL (American Fuzzy Lop) dictionaries, and I copied this dictionary from the AFL repository.

Upon running, `libfuzzer` will start generating test cases. It will save these to the (first) corpus directory. Because `libfuzzer` uses code coverage to understand if test cases are exciting or not, it will only save test cases when it has found new code paths (i.e., it won't save multiple test cases that exercise the same code).

In my case, it generates a few hundred test cases in 15 minutes of running on 16 cores.

When `libfuzzer` finds a test case that causes a problem - either a hang, an out-of-memory event, or a crash it will (should: see issues) save the test case to the current working directory and exit. You can then use the crash logs (in `~/Library/Logs/DiagnosticReports/` or the Console app) and the test case to debug and fix the problem. Rebuild `libfuzzer` and rerun it.

Example output (just started a run):

Throughout a run, you'll see log lines like this:

These lines show `libfuzzer` reporting its progress. It has generated 756 test cases and is currently running at 256 test cases per second. It has been running for 126 seconds.

## Resource Usage

While for me - it found issues in just a few minutes of running. Expect fuzzing to be a task that can take hours. I run this on a 20 Core M1 Ultra Mac Studio with 128GB RAM. It's able to generate hundreds of test cases per second.

## Results

I found more than ten crashing bugs in just a few minutes of fuzzing. Some of these issues were obvious (fatalError() left in place to handle unimplemented features), but others were more subtle. Fuzzing found almost all problems in lines fully covered by traditional unit tests.

## Issues

### Out-of-Memory Errors

Despite wrapping my code in an `autoreleasePool` and testing for leaks using other tools - libfuzzer still reports out-of-memory errors and stops running after ~15 minutes. The test case it outputs does not cause an out-of-memory error when run manually, and this test case is merely the last test case that libfuzzer generated before it ran out of memory.

Update: After more testing and instrumenting, I've confirmed that my code isn't leaking under testing. Increasing the memory limit for libfuzzer to 4GB seems to solve the issue, and I've been able to run for over an hour without an out-of-memory error.

### Crash files aren't written

For me, libfuzzer fails to write the test case that causes the crash. I have been able to diagnose and solve issues from just the crash logs, but a bug in libfuzzer is preventing these crashes from being output. (conversely, out-of-memory and hang test cases are correctly written out.)

## Take Aways/Questions

libfuzzer is the easiest fuzzing method to use for Swift, with fewer dependencies or requirements. It is relatively straightforward to get working, but there are some subtleties that this document helps with.

If I can get past the out-of-memory issues and the lack of output for crashes, I should be able to find more bugs. Even with my relatively short time on this, I've seen a few bugs I may not have found otherwise.

It could be more explicit if providing just a dictionary of XML tags and attributes would help libfuzzer find more bugs with SVG. I should create a dictionary of SVG-specific tags and attributes.

It's unclear if `-ignore_ooms=1` works.

It may make sense to fuzz different parts of the codebase separately. For example, the CSS parser and process are good candidates for independent fuzzing (and provide a CSS dictionary).

If anyone with more experience with libfuzzer has any suggestions on how to get past these issues, I'd love to hear them.

## Links

General Wikipedia page on fuzzing
: <https://en.wikipedia.org/wiki/Fuzzing>

LLVM Libfuzzer documentation
: <https://www.llvm.org/docs/LibFuzzer.html>

Using libfuzzer with Swift
: <https://github.com/apple/swift/blob/main/docs/libFuzzerIntegration.md>

This a somewhat confusing blog post on using libfuzzer with Swift
: <https://grayson.github.io/ipspatcherFuzzer/>
