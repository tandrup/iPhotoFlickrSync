//
//  Album.h
//  iPhotoFlickrSync
//
//  Created by Mads Mætzke Tandrup on 21/06/13.
//  Copyright (c) 2013 Mads Mætzke Tandrup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Album : NSManagedObject

@property (nonatomic, retain) NSString * flickrID;
@property (nonatomic, retain) NSNumber * iPhotoID;
@property (nonatomic, retain) NSSet *photos;
@end

@interface Album (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
