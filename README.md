# it.smartcampuslab.cordova.file

Cordova plugin to get/set filesystem entries metadata. Uses native implementations of libmagic unix

## Test it
window.FileMetadata.test('It works!');

## Use it
window.FileMetadata.getMetadataForFileURI("file:///url/to/file",onSuccessCallback,onErrorCallback);
window.FileMetadata.getMetadataForURL("http://example.com/path/to/file.ext",onSuccessCallback,onErrorCallback);
window.FileMetadata.setModifiedForFileURI(epochInMillis"file:///url/to/file",onSuccessCallback,onErrorCallback);

##iOS
https://github.com/grigutis/MagicKit
https://github.com/AFNetworking/AFNetworking/wiki/Getting-Started-with-AFNetworking

###Prerequisites for usage of iOS version of file-metadata plugin
- create file "platforms/ios/Podfile"
- insert line: platform :ios, '6.0'
- insert line: pod 'AFNetworking', '~> 2.2'
- from ios platform dir execute command: pod install
- download zip from https://github.com/grigutis/MagicKit
- move unzipped folder to "platforms/ios/MagicKit"
- drag xcode project inside moved folder over root node of Project Navigator file explorer in XCode
- in MagicKit-ios target "Build settings" pane, set "Recognize built-in functions" to "No"
- in MagicKit-ios target "Build settings" pane, set "Public headers folder path" to "/include/MagicKit"
- in MagicKit-ios target "Build settings" pane, set "Public headers folder path" to "/include/MagicKit"
- in main app target go to pane "Build Phases" and add library "MagicKit-ios" as "Target dependency"
- in main app target go to pane "Build Phases" and add library "MagicKit-ios.a" as "Link binary with libraries"
- in main app target go to pane "Build Phases" and add library "libz.dylib" as "Link binary with libraries"
- make a copy of the file platforms/ios/MagicKit/libmagic/magic.mgc inside project root
- drag file to rot node of project
- add magic.mgc to "Copy Bundle Resources" subpanel of app target "Build Phases"
