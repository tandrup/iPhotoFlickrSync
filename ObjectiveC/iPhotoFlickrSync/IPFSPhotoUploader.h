//
//  IPFSPhotoUploader.h
//  iPhotoFlickrSync
//
//  Created by Mads Mætzke Tandrup on 23/06/13.
//  Copyright (c) 2013 Mads Mætzke Tandrup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPFSPhotoUploader : NSObject
{
    NSManagedObjectContext* context;
}

- (id) initWithContext: (NSManagedObjectContext*) context;

- (void) uploadPhotos;

@end
