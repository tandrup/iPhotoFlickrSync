//
//  IPFSPhotoUploader.m
//  iPhotoFlickrSync
//
//  Created by Mads Mætzke Tandrup on 23/06/13.
//  Copyright (c) 2013 Mads Mætzke Tandrup. All rights reserved.
//

#import "IPFSPhotoUploader.h"
#import "iPhoto.h"
#import "Photo.h"

@implementation IPFSPhotoUploader

- (id) initWithContext:(NSManagedObjectContext *)theContext {
    if (self = [super init]) {
        context = theContext;
    }
    return self;
}

- (void) processAlbum: (iPhotoAlbum*)album {
    iPhotoAlTy type = [album type];
    char* str = calloc(sizeof(type) + 1, sizeof(char));
    int typeAsInteger = NSSwapInt((unsigned int)type);
    memcpy(str, (const void*)&typeAsInteger, sizeof(typeAsInteger));
    NSLog(@"%@: %s ", [album name], str);
    free(str);
    NSArray* children = [album children];
    for (iPhotoAlbum* childAlbum in children) {
        NSLog(@"Child %@", [childAlbum name]);
        [self processAlbum:childAlbum];
    }
}

- (void) uploadPhotos {
    NSError* error = nil;

    iPhotoApplication *iPhoto = [SBApplication applicationWithBundleIdentifier:@"com.apple.iPhoto"];
    
    if (! [iPhoto isRunning]) {
        @throw [NSException exceptionWithName:@"iPhotoNotRunning" reason:@"iPhoto is not running" userInfo:nil];
    }
    
    SBElementArray* iPhotoAlbums = [iPhoto albums];
    for (iPhotoAlbum* iPhotoAlbum in iPhotoAlbums) {
        [self processAlbum:iPhotoAlbum];
    }

    [self processAlbum:[iPhoto facesAlbum]];
    
    NSLog(@"Done");
//    SBElementArray* iPhotoPhotos = [iPhoto photos];
//    for (iPhotoPhoto* iPhotoPhoto in iPhotoPhotos) {
//        NSManagedObjectModel* model = [[context persistentStoreCoordinator] managedObjectModel];
//        NSFetchRequest* request = [model fetchRequestFromTemplateWithName:@"GetPhotoByIPhotoID"
//                                                    substitutionVariables:@{@"ID" : [NSNumber numberWithInteger:iPhotoPhoto.id]}];
//        NSArray* results = [context executeFetchRequest:request error:&error];
//
//        Photo *photo;
//        if ([results count] == 0) {
//            photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
//                                         inManagedObjectContext:context];
//            photo.iPhotoID = [NSNumber numberWithInteger:iPhotoPhoto.id];
//        } else {
//            photo = [results objectAtIndex:0];
//        }
//
//        if (photo.flickrID == nil) {
//            NSLog(@"Uploading %@ to flickr", iPhotoPhoto.originalPath);
//        }
//    }
}

@end
