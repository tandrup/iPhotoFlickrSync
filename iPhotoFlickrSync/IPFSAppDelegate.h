//
//  IPFSAppDelegate.h
//  iPhotoFlickrSync
//
//  Created by Mads Mætzke Tandrup on 20/06/13.
//  Copyright (c) 2013 Mads Mætzke Tandrup. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ObjectiveFlickr/ObjectiveFlickr.h>

@interface IPFSAppDelegate : NSObject <NSApplicationDelegate, OFFlickrAPIRequestDelegate>
{
    OFFlickrAPIContext *_flickrContext;
    OFFlickrAPIRequest *_flickrRequest;
    
    NSString *_frob;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSButton *oauthAuthButton;
@property (assign) IBOutlet NSButton *testLoginButton;
@property (assign) IBOutlet NSTextField *progressLabel;
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

- (IBAction)oauthAuthenticationAction:(id)sender;

@end
