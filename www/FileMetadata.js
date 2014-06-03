cordova.define("it.smartcampuslab.cordova.file-metadata.FileMetadata", function(require, exports, module) { /**
 * Constructor.
 * localURL {DOMString}
 */
var FileMetadata = function (localURL) {
  this.localURL = localURL || null;
};


/**
 * Prints on console the provided message.
 */
FileMetadata.prototype.test = function (msg) {
  console.log('FileMetadata MSG: ' + msg);
  cordova.exec(null,null,'FileMetadata','test',[msg]);
  return;
};

FileMetadata.prototype.metadata = function (filepath, successCallback, errorCallback) {
  cordova.exec(successCallback, errorCallback, 'FileMetadata', 'metadata', [filepath]);
  return;
};

module.exports = new FileMetadata();

});
