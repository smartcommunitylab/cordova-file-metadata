#import <Cordova/CDV.h>
#import "CDVFileMetadata.h"

#import <MagicKit/MagicKit.h>

@implementation CDVFileMetadata

- (id)initWithWebView:(UIWebView*)theWebView
{
    self = (CDVFileMetadata*)[super initWithWebView:theWebView];
   return self;
}

- (void)getMetadataForFileURI:(CDVInvokedUrlCommand*)command
{
    NSArray* arguments = command.arguments;
    NSString* strFileUrl = [arguments objectAtIndex:0];

	NSMutableDictionary* r = [NSMutableDictionary dictionaryWithCapacity:3];
	[r setObject:strFileUrl forKey:@"url"];

	if ([strFileUrl hasPrefix:@"file://"]) {
		NSURL* urlFile=[NSURL URLWithString:strFileUrl];
/*
		NSString* strFilePath = [strFileUrl substringFromIndex:7];
		NSLog(@"metadata(); file path: %@", strFilePath);
		[r setObject:strFilePath forKey:@"path"];

		unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:strFilePath error:nil] fileSize];
		NSLog(@"metadata(); file size: %llu", fileSize);
*/
		NSError *error = nil;
		NSNumber* fileSize;
		if (![urlFile getResourceValue:&fileSize forKey:NSURLFileSizeKey error:&error]) {
			NSLog(@"name: %@", [error localizedDescription]);
			[r setObject:[NSNumber numberWithInt:-1] forKey:@"size"];
			[r setObject:NULL forKey:@"type"];
		} else {
			NSLog(@"metadata(); file size: %@", fileSize);
			[r setObject:fileSize forKey:@"size"];

			GEMagicResult *magic = [GEMagicKit magicForFileAtURL:urlFile];
			NSString* fullMimeType = magic.mimeType;
			NSLog(@"metadata(); file type full: %@", fullMimeType);
			NSString* shortMimeType = [[fullMimeType componentsSeparatedByString:@";"][0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			NSLog(@"metadata(); file type short: %@", shortMimeType);
			[r setObject:shortMimeType forKey:@"type"];
		}
	} else {
		[r setObject:[NSNumber numberWithInt:-1] forKey:@"size"];
		[r setObject:NULL forKey:@"type"];
	}

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
