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

- (void)getMetadataForURL:(CDVInvokedUrlCommand*)command
{
    NSArray* arguments = command.arguments;
    NSString* strUrl = [arguments objectAtIndex:0];

	NSMutableDictionary* json = [NSMutableDictionary dictionaryWithCapacity:3];
	[json setObject:strUrl forKey:@"url"];
	//NSLog(@"getMetadataForUrl(); url: %@", strUrl);

	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	[manager HEAD:strUrl parameters:nil success:^(AFHTTPRequestOperation *operation) {
		[self.commandDelegate runInBackground:^{
			NSHTTPURLResponse *r = (NSHTTPURLResponse *)operation.response;
			NSDictionary* headers=[r allHeaderFields];

			NSString* strModified=[headers valueForKey:@"Last-Modified"];
			if (strModified!=nil) {
				//NSLog(@"getMetadataForUrl(); url modified: %@", strModified);

				NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
				[formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
				NSDate* dateModified=[formatter dateFromString:strModified];

				if (dateModified!=nil) {
					long long modified=[@(floor([dateModified timeIntervalSince1970] * 1000)) longLongValue];
					[json setObject:[NSNumber numberWithLongLong:modified] forKey:@"modified"];
					//NSLog(@"getMetadataForUrl(); url modified epoch (millis): %lli", modified);
				} else {
					NSLog(@"getMetadataForUrl(); unparsable Last-Modified header");
					[json setObject:[NSNumber numberWithInt:-1] forKey:@"modified"];
				}
			} else {
				NSLog(@"getMetadataForUrl(); no Last-Modified header");
				[json setObject:[NSNumber numberWithInt:-1] forKey:@"modified"];
			}

			NSString* fullMimeType = [headers valueForKey:@"Content-Type"];
			if (fullMimeType!=nil) {
				NSString* mimeType = [[fullMimeType componentsSeparatedByString:@";"][0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				[json setObject:mimeType forKey:@"type"];
				//NSLog(@"getMetadataForUrl(); url mimetype (short): %@", mimeType);
			} else {
				NSLog(@"getMetadataForUrl(); no Content-Type header");
				[json setObject:[NSNull null] forKey:@"type"];
			}

			NSString* strSize = [headers valueForKey:@"Content-Length"];
			if (strSize!=nil) {
				int size=[strSize intValue];
				[json setObject:[NSNumber numberWithInt:size] forKey:@"size"];
				//NSLog(@"getMetadataForUrl(); url size: %i", size);
			} else {
				NSLog(@"getMetadataForUrl(); no Content-Length header");
				[json setObject:[NSNull null] forKey:@"size"];
			}

			CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:json];
			[self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
		 }];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"getMetadataForUrl(); url error: %@", error);

		[json setObject:[NSNumber numberWithInt:-1] forKey:@"size"];
		[json setObject:[NSNumber numberWithInt:-1] forKey:@"modified"];
		[json setObject:[NSNull null] forKey:@"type"];
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:json];

		[self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
	}];
}

- (void)getMetadataForFileURI:(CDVInvokedUrlCommand*)command
{
	//canot work in a concurrent thread since libmagic is not thread safe!
	//[self.commandDelegate runInBackground:^{
		NSArray* arguments = command.arguments;
		NSString* strFileUri = [arguments objectAtIndex:0];

		NSMutableDictionary* r = [NSMutableDictionary dictionaryWithCapacity:3];
		[r setObject:strFileUri forKey:@"uri"];
		//NSLog(@"metadata(); file uri: %@", strFileUri);

		NSNumber* fileSize;
		NSNumber* numModified;
		NSObject* mimeType;

		NSURL* urlFile=[NSURL URLWithString:strFileUri];
		if (urlFile!=nil && [urlFile isFileURL]) {
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
				//NSLog(@"getMetadataForFileURI(); file size: %@", fileSize);

				NSDate* dateModified;
				if (![urlFile getResourceValue:&dateModified forKey:NSURLContentModificationDateKey error:&error]) {
					NSLog(@"getMetadataForFileURI(); modified error: %@", [error localizedDescription]);
				} else {
					long long modified=[@(floor([dateModified timeIntervalSince1970] * 1000)) longLongValue];
					//NSLog(@"getMetadataForFileURI(); modified epoch (millis): %lli", modified);
					numModified=[NSNumber numberWithLongLong:modified];
				}

				@try {
					GEMagicResult *magic = [GEMagicKit magicForFileAtURL:urlFile];
					NSString* fullMimeType = magic.mimeType;
					if (fullMimeType!=nil) {
						mimeType = [[fullMimeType componentsSeparatedByString:@";"][0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
						//NSLog(@"getMetadataForFileURI(); file mimetype (short): %@", mimeType);
					}
				}
				@catch (NSException *exception) {
						NSLog(@"getMetadataForFileURI(); GEMagic error!");
				}
			}
		}

		[r setObject:(fileSize!=nil?fileSize:[NSNumber numberWithInt:-1]) forKey:@"size"];
		[r setObject:(numModified!=nil?numModified:[NSNumber numberWithInt:-1]) forKey:@"modified"];
		[r setObject:(mimeType!=nil?mimeType:[NSNull null]) forKey:@"type"];
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:r];

		[self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
	//}];
}

- (void)setModifiedForFileURI:(CDVInvokedUrlCommand*)command
{
	[self.commandDelegate runInBackground:^{
		NSArray* arguments = command.arguments;
		NSString* strModified = [arguments objectAtIndex:0];
		NSString* strFileUri = [arguments objectAtIndex:1];
		//NSLog(@"setModifiedForFileURI(); passed modified: %@", strModified);
		//NSLog(@"setModifiedForFileURI(); file uri: %@", strFileUri);

		CDVPluginResult* result;

		NSURL* urlFile=[NSURL URLWithString:strFileUri];
		if (urlFile!=nil && [urlFile isFileURL]) {
			//NSLog(@"setModifiedForFileURI(); file path: %@", urlFile.path);
			
			long long modified=[strModified doubleValue]/1000;
			//NSLog (@"setModifiedForFileURI(); modified: %lli", modified);
			NSDate *dateModified = [[NSDate alloc] initWithTimeIntervalSince1970:modified];
			//NSLog (@"setModifiedForFileURI(); modified: %@", dateModified);

			NSDictionary* modDict = [NSDictionary dictionaryWithObject:dateModified forKey:NSFileModificationDate];
			NSFileManager *filemgr = [NSFileManager defaultManager];
			[filemgr setAttributes:modDict ofItemAtPath:urlFile.path error:nil];

			result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
		} else {
			NSLog(@"setModifiedForFileURI(); not a file uri");
			result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
		}

		[self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
	}];
}

@end
