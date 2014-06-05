/**
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

FileMetadata.prototype.getMetadataForFileURI = function (filepath, successCallback, errorCallback) {
  cordova.exec(successCallback, errorCallback, 'FileMetadata', 'getMetadataForFileURI', [filepath]);
  return;
};

FileMetadata.prototype.getMetadataForURL = function (remoteurl, successCallback, errorCallback) {
  cordova.exec(successCallback, errorCallback, 'FileMetadata', 'getMetadataForURL', [remoteurl]);
  return;
};

FileMetadata.prototype.setModifiedForFileURI = function (epochms, filepath, successCallback, errorCallback) {
  cordova.exec(successCallback, errorCallback, 'FileMetadata', 'setModifiedForFileURI', [epochms, filepath]);
  return;
};

module.exports = new FileMetadata();
