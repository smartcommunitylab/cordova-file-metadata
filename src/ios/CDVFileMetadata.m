#import <Cordova/CDV.h>
#import "CDVFileMetadata.h"

#import <MagicKit/MagicKit.h>
#import <AFNetworking/AFNetworking.h>

@implementation CDVFileMetadata

- (id)initWithWebView:(UIWebView*)theWebView
{
    self = (CDVFileMetadata*)[super initWithWebView:theWebView];
   return self;
}

- (void)getMetadataForURL:(CDVInvokedUrlCommand*)command
{
    NSArray* arguments = command.arguments;
    NSString* strUrl = [arguments objectAtIndex:0];

	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	[manager HEAD:strUrl parameters:nil success:^(AFHTTPRequestOperation *operation) {
		NSHTTPURLResponse *r = (NSHTTPURLResponse *)operation.response;
		NSLog(@"getMetadataForUrl(); modified: %@", [[r allHeaderFields] valueForKey:@"Last-Modified"]);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"getMetadataForUrl(); error: %@", error);
	}];
}

- (void)getMetadataForFileURI:(CDVInvokedUrlCommand*)command
{
    NSArray* arguments = command.arguments;
    NSString* strFileUri = [arguments objectAtIndex:0];

	NSMutableDictionary* r = [NSMutableDictionary dictionaryWithCapacity:2];
	[r setObject:strFileUri forKey:@"uri"];
    NSLog(@"metadata(); file uri: %@", strFileUri);

	NSNumber* fileSize=[NSNumber numberWithInt:-1];
	NSNumber* numModified=[NSNumber numberWithInt:-1];
	NSObject* mimeType=[NSNull null];

	if ([strFileUri hasPrefix:@"file://"]) {
		NSURL* urlFile=[NSURL URLWithString:strFileUri];
/*
		NSString* strFilePath = [strFileUri substringFromIndex:7];
		NSLog(@"metadata(); file path: %@", strFilePath);
		[r setObject:strFilePath forKey:@"path"];

		unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:strFilePath error:nil] fileSize];
		NSLog(@"metadata(); file size: %llu", fileSize);
*/
		NSError *error = nil;
		if (![urlFile getResourceValue:&fileSize forKey:NSURLFileSizeKey error:&error]) {
			NSLog(@"getMetadataForFileURI(); size error: %@", [error localizedDescription]);
		} else {
			NSLog(@"getMetadataForFileURI(); file size: %@", fileSize);

			NSDate* dateModified;
			if (![urlFile getResourceValue:&dateModified forKey:NSURLContentModificationDateKey error:&error]) {
				NSLog(@"getMetadataForFileURI(); modified error: %@", [error localizedDescription]);
			} else {
				long long modified=[@(floor([dateModified timeIntervalSince1970] * 1000)) longLongValue];
				NSLog(@"getMetadataForFileURI(); modified epoch (millis): %lli", modified);
				numModified=[NSNumber numberWithLongLong:modified];
			}

			GEMagicResult *magic = [GEMagicKit magicForFileAtURL:urlFile];
			NSString* fullMimeType = magic.mimeType;
			mimeType = [[fullMimeType componentsSeparatedByString:@";"][0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			NSLog(@"getMetadataForFileURI(); file mimetype (short): %@", mimeType);
		}
	}

	[r setObject:fileSize forKey:@"size"];
	[r setObject:numModified forKey:@"modified"];
	[r setObject:mimeType forKey:@"type"];
	CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:r];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)test:(CDVInvokedUrlCommand*)command
{
    NSArray* arguments = command.arguments;

    // arguments
    NSString* strMessage = [arguments objectAtIndex:0];
    NSLog(@"test(); msg: %@", strMessage);

	NSMutableDictionary* r = [NSMutableDictionary dictionaryWithCapacity:2];
	[r setObject:strMessage forKey:@"msg"];
	[r setObject:@"YES" forKey:@"done"];

	CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:r];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end
