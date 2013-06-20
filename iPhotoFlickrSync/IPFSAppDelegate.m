//
//  IPFSAppDelegate.m
//  iPhotoFlickrSync
//
//  Created by Mads Mætzke Tandrup on 20/06/13.
//  Copyright (c) 2013 Mads Mætzke Tandrup. All rights reserved.
//

#import "IPFSAppDelegate.h"
#import "FlickrAPIKey.h"

static NSString *kCallbackURLBaseString = @"iphotoflickrsync://callback";
static NSString *kOAuthAuth = @"OAuth";
static NSString *kFrobRequest = @"Frob";
static NSString *kTryObtainAuthToken = @"TryAuth";
static NSString *kTestLogin = @"TestLogin";

const NSTimeInterval kTryObtainAuthTokenInterval = 3.0;

@implementation IPFSAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleIncomingURL:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    
    
    _flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:OBJECTIVE_FLICKR_SAMPLE_API_KEY sharedSecret:OBJECTIVE_FLICKR_SAMPLE_API_SHARED_SECRET];
    
    _flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:_flickrContext];
    _flickrRequest.delegate = self;
    _flickrRequest.requestTimeoutInterval = 60.0;
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "org.tandrup.iPhotoFlickrSync" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"org.tandrup.iPhotoFlickrSync"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iPhotoFlickrSync" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"iPhotoFlickrSync.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

- (IBAction)oauthAuthenticationAction:(id)sender {
    NSLog(@"Authenticating");
    [_progressIndicator startAnimation:self];
    [_progressLabel setStringValue:@"Starting OAuth authentication..."];
    
    _flickrRequest.sessionInfo = kOAuthAuth;
    [_flickrRequest fetchOAuthRequestTokenWithCallbackURL:[NSURL URLWithString:kCallbackURLBaseString]];
    [_oauthAuthButton setEnabled:NO];

}

# pragma mark URL delegate

- (void)handleIncomingURL:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSURL *callbackURL = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
    NSLog(@"Callback URL: %@", [callbackURL absoluteString]);
    
    NSString *requestToken= nil;
    NSString *verifier = nil;
    
    BOOL result = OFExtractOAuthCallback(callbackURL, [NSURL URLWithString:kCallbackURLBaseString], &requestToken, &verifier);
    if (!result) {
        NSLog(@"Invalid callback URL");
    }
    
    [_flickrRequest fetchOAuthAccessTokenWithRequestToken:requestToken verifier:verifier];
}

# pragma mark OFFlickrAPIRequestDelegate

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthRequestToken:(NSString *)inRequestToken secret:(NSString *)inSecret;
{
    _flickrContext.OAuthToken = inRequestToken;
    _flickrContext.OAuthTokenSecret = inSecret;
    
    NSURL *authURL = [_flickrContext userAuthorizationURLWithRequestToken:inRequestToken requestedPermission:OFFlickrWritePermission];
    NSLog(@"Auth URL: %@", [authURL absoluteString]);
    [[NSWorkspace sharedWorkspace] openURL:authURL];
    
    [_progressLabel setStringValue:@"Waiting fo user authentication (OAuth)..."];
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthAccessToken:(NSString *)inAccessToken secret:(NSString *)inSecret userFullName:(NSString *)inFullName userName:(NSString *)inUserName userNSID:(NSString *)inNSID
{
    _flickrContext.OAuthToken = inAccessToken;
    _flickrContext.OAuthTokenSecret = inSecret;
    
    NSLog(@"Token: %@, secret: %@", inAccessToken, inSecret);
    
    [_progressLabel setStringValue:@"Authenticated"];
    [_progressIndicator stopAnimation:self];
    [_testLoginButton setEnabled:YES];
    NSRunAlertPanel(@"Authenticated", [NSString stringWithFormat:@"OAuth access token: %@, secret: %@", inAccessToken, inSecret], @"Dismiss", nil, nil);
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
    NSLog(@"%s, return: %@", __PRETTY_FUNCTION__, inResponseDictionary);
    
    [_progressIndicator stopAnimation:self];
    [_progressLabel setStringValue:@"API call succeeded"];
    
    if (inRequest.sessionInfo == kFrobRequest) {
        _frob = [[inResponseDictionary valueForKeyPath:@"frob._text"] copy];
        NSLog(@"%@: %@", kFrobRequest, _frob);
        
        NSURL *authURL = [_flickrContext loginURLFromFrobDictionary:inResponseDictionary requestedPermission:OFFlickrWritePermission];
        [[NSWorkspace sharedWorkspace] openURL:authURL];
        
        [self performSelector:@selector(tryObtainAuthToken) withObject:nil afterDelay:kTryObtainAuthTokenInterval];
        
        [_progressIndicator startAnimation:self];
        [_progressLabel setStringValue:@"Waiting for user authentication..."];
    }
    else if (inRequest.sessionInfo == kTryObtainAuthToken) {
        NSString *authToken = [inResponseDictionary valueForKeyPath:@"auth.token._text"];
        NSLog(@"%@: %@", kTryObtainAuthToken, authToken);
        
        _flickrContext.authToken = authToken;
        _flickrRequest.sessionInfo = nil;
        
        [_testLoginButton setEnabled:YES];
    }
    else if (inRequest.sessionInfo == kTestLogin) {
        _flickrRequest.sessionInfo = nil;
        [_testLoginButton setEnabled:YES];
        NSRunAlertPanel(@"Test OK!", @"API returns successfully", @"Dismiss", nil, nil);
    }
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
    NSLog(@"%s, error: %@", __PRETTY_FUNCTION__, inError);
    
    if (inRequest.sessionInfo == kTryObtainAuthToken) {
        [self performSelector:@selector(tryObtainAuthToken) withObject:nil afterDelay:kTryObtainAuthTokenInterval];
    }
    else {
        if (inRequest.sessionInfo == kOAuthAuth || inRequest.sessionInfo == kFrobRequest || inRequest.sessionInfo == kTryObtainAuthToken) {
            [_oauthAuthButton setEnabled:YES];
            [_testLoginButton setEnabled:NO];
        }
        else if (inRequest.sessionInfo == kTestLogin) {
            [_testLoginButton setEnabled:YES];
        }
        
        [_progressIndicator stopAnimation:self];
        [_progressLabel setStringValue:@"Error"];
        NSRunAlertPanel(@"API Error", [NSString stringWithFormat:@"An error occurred in the stage \"%@\", error: %@", inRequest.sessionInfo, inError], @"Dismiss", nil, nil);
    }
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest imageUploadSentBytes:(NSUInteger)inSentBytes totalBytes:(NSUInteger)inTotalBytes
{
    NSLog(@"%s %lu/%lu", __PRETTY_FUNCTION__, inSentBytes, inTotalBytes);
}

@end
