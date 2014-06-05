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
