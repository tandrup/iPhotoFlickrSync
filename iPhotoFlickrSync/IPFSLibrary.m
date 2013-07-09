//
//  IPFSLibrary.m
//  iPhotoFlickrSync
//
//  Created by Mads Mætzke Tandrup on 20/06/13.
//  Copyright (c) 2013 Mads Mætzke Tandrup. All rights reserved.
//

#import "IPFSLibrary.h"
#import "iPhoto.h"

@implementation IPFSLibrary

- (void) listAlbums {
    iPhotoApplication *iPhoto = [SBApplication applicationWithBundleIdentifier:@"com.apple.iPhoto"];

    if ([iPhoto isRunning]) {
        NSLog(@"Is running");
        
        SBElementArray *albums = [iPhoto albums];
        
        if ([albums count] > 0) {
            for (iPhotoAlbum *album in albums) {
                NSLog(@"%@", [album name]);
                SBElementArray *photos = [album photos];
                
                NSLog(@"%li", [photos count]);
                for (iPhotoPhoto *photo in photos) {
                    NSLog(@"Photo: %@", [photo imagePath]);
                }
            }
        }
    }

}

@end
