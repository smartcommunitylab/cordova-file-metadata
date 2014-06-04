#import <Cordova/CDV.h>
#import "CDVFileMetadata.h"

#import <MagicKit/MagicKit.h>

@implementation CDVFileMetadata

- (id)initWithWebView:(UIWebView*)theWebView
{
    self = (CDVFileMetadata*)[super initWithWebView:theWebView];
   return self;
}

- (void)metadata:(CDVInvokedUrlCommand*)command
{
    NSArray* arguments = command.arguments;

    // arguments
    NSString* strFileUrl = [arguments objectAtIndex:0];
    NSLog(@"metadata(); file url: %@", strFileUrl);

	NSMutableDictionary* r = [NSMutableDictionary dictionaryWithCapacity:2];
	[r setObject:strFileUrl forKey:@"url"];

	GEMagicResult *magic = [GEMagicKit magicForFileAtPath:strFileUrl];
	[r setObject:magic.mimeType forKey:@"type"];

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
