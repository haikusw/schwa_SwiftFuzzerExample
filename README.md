https://download.swift.org/swift-5.8-release/xcode/swift-5.8-RELEASE/swift-5.8-RELEASE-osx.pkg

```shell
> just fuzz-one
xcrun --toolchain swift swift build --configuration debug  -Xswiftc -sanitize=fuzzer,address -Xswiftc -parse-as-library
Building for debugging...
ld: warning: undefined base symbol '_ExampleFuzzer_main' for alias '_main'
[3/3] Linking ExampleFuzzer
Build complete! (0.93s)
caffeinate -dis .build/debug/ExampleFuzzer -rss_limit_mb=4096 Corpus/New Corpus/Existing
INFO: Running with entropic power schedule (0xFF, 100).
INFO: Seed: 2689712323
INFO: Loaded 1 modules   (180 inline 8-bit counters): 180 [0x102ef4a78, 0x102ef4b2c),
INFO: Loaded 1 PC tables (180 PCs): 180 [0x102ef4b30,0x102ef5670),
INFO:        0 files found in Corpus/New
INFO:        0 files found in Corpus/Existing
INFO: -max_len is not provided; libFuzzer will not generate inputs larger than 4096 bytes
INFO: A corpus is not provided, starting from an empty corpus
#2      INITED cov: 35 ft: 35 corp: 1/1b exec/s: 0 rss: 67Mb
#4      NEW    cov: 36 ft: 36 corp: 2/3b lim: 4 exec/s: 0 rss: 67Mb L: 2/2 MS: 1 InsertByte-
#15     REDUCE cov: 36 ft: 36 corp: 2/2b lim: 4 exec/s: 0 rss: 67Mb L: 1/1 MS: 1 EraseBytes-
#132    NEW    cov: 38 ft: 38 corp: 3/4b lim: 4 exec/s: 0 rss: 67Mb L: 2/2 MS: 1 InsertByte-
#169    REDUCE cov: 38 ft: 38 corp: 3/3b lim: 4 exec/s: 0 rss: 67Mb L: 1/1 MS: 1 EraseBytes-
        NEW_FUNC[1/1]: 0x102eb4090 in outlined destroy of String? <compiler-generated>
#178    NEW    cov: 41 ft: 44 corp: 4/5b lim: 4 exec/s: 0 rss: 1861Mb L: 2/2 MS: 4 ChangeBit-CrossOver-InsertByte-ChangeByte-
#436    NEW    cov: 44 ft: 47 corp: 5/9b lim: 6 exec/s: 0 rss: 1861Mb L: 4/4 MS: 2 ShuffleBytes-CopyPart-
#943    REDUCE cov: 44 ft: 47 corp: 5/8b lim: 11 exec/s: 0 rss: 1861Mb L: 3/3 MS: 1 EraseBytes-
#1569   NEW    cov: 45 ft: 48 corp: 6/23b lim: 17 exec/s: 0 rss: 1861Mb L: 15/15 MS: 4 ChangeASCIIInt-InsertRepeatedBytes-ShuffleBytes-InsertByte-
Swift/IntegerTypes.swift:13899: Fatal error: Double value cannot be converted to Int because the result would be greater than Int.max
error: Recipe `fuzz-one` was terminated on line 9 by signal 5
```
