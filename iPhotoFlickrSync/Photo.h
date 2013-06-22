//
//  Photo.h
//  iPhotoFlickrSync
//
//  Created by Mads Mætzke Tandrup on 21/06/13.
//  Copyright (c) 2013 Mads Mætzke Tandrup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photo : NSManagedObject

@property (nonatomic, retain) NSNumber * iPhotoID;
@property (nonatomic, retain) NSString * flickrID;
@property (nonatomic, retain) NSSet *albums;
@end

@interface Photo (CoreDataGeneratedAccessors)

- (void)addAlbumsObject:(NSManagedObject *)value;
- (void)removeAlbumsObject:(NSManagedObject *)value;
- (void)addAlbums:(NSSet *)values;
- (void)removeAlbums:(NSSet *)values;

@end
