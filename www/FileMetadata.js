/**
 * Constructor.
 * localURL {DOMString}
 */
var FileMetadata = function (localURL) {
  this.localURL = localURL || null;

  this.metadata = function (filepath, successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'FileMetadata', 'metadata', [filepath]);
    return;
  };
};


/**
 * Prints on console the provided message.
 */
FileMetadata.prototype.test = function (msg) {
  console.log('FileMetadata MSG: ' + msg);
  return;
};

//FileMetadata.prototype.metadata = function (filepath, successCallback, errorCallback) {
//  exec(successCallback, errorCallback, 'FileMetadata', 'metadata', [filepath]);
//  return;
//};

module.exports = FileMetadata;
