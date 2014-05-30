#import <Cordova/CDV.h>
#import "CDVFileMetadata.h"

@implementation CDVFileMetadata

- (id)initWithWebView:(UIWebView*)theWebView
{
    self = (CDVFile*)[super initWithWebView:theWebView];
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
	[r setObject:YES forKey:@"done"];

	result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:r];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end
