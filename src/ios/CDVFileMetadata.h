#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

@interface CDVFileMetadata : CDVPlugin {
}

- (void)test:(CDVInvokedUrlCommand*)command;
- (void)getMetadataForURL:(CDVInvokedUrlCommand*)command;
- (void)getMetadataForFileURI:(CDVInvokedUrlCommand*)command;
- (void)setModifiedForFileURI:(CDVInvokedUrlCommand*)command;

@end
