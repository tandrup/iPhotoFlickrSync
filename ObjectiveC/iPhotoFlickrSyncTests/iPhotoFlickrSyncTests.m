//
//  iPhotoFlickrSyncTests.m
//  iPhotoFlickrSyncTests
//
//  Created by Mads Mætzke Tandrup on 20/06/13.
//  Copyright (c) 2013 Mads Mætzke Tandrup. All rights reserved.
//

#import "iPhotoFlickrSyncTests.h"
#import "Photo.h"
#import "IPFSPhotoUploader.h"

@implementation iPhotoFlickrSyncTests

- (NSManagedObjectContext*)managedObjectContext {
    NSManagedObjectModel *mom = [NSManagedObjectModel mergedModelFromBundles:nil];
    STAssertNotNil(mom, @"Can not create MOM from main bundle");
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    STAssertNotNil(psc, @"Can not create persistent store coordinator");
    NSPersistentStore *store = [psc addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:0];
    STAssertNotNil(store, @"Can not create In-Memory persistent store");
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    moc.persistentStoreCoordinator = psc;
    
    return moc;
}

- (void)setUp
{
    [super setUp];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testBasicSaveLookup
{
    NSError* error = nil;
    
    NSManagedObjectContext* context = [self managedObjectContext];
    
    Photo *newPhoto = [NSEntityDescription
                       insertNewObjectForEntityForName:@"Photo"
                       inManagedObjectContext:context];
    newPhoto.flickrID = @"FOO";
    newPhoto.iPhotoID = [NSNumber numberWithInt:42];
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        STFail(@"Error");
    }

    NSManagedObjectModel* model = [[context persistentStoreCoordinator] managedObjectModel];
    NSFetchRequest* request = [model fetchRequestFromTemplateWithName:@"GetPhotoByIPhotoID"
                                                substitutionVariables:@{@"ID" : [NSNumber numberWithInt:42]}];
    NSArray* results = [context executeFetchRequest:request error:&error];

    STAssertEquals([results count], (NSUInteger)1, @"Expecting one element");
    
    Photo* savedPhoto = [results objectAtIndex:0];
    
    STAssertEqualObjects(savedPhoto.flickrID, @"FOO", @"flickrID");
    STAssertEqualObjects(savedPhoto.iPhotoID, [NSNumber numberWithInt:42], @"iPhotoID");
}

- (void)testUploadPhotos
{
    NSError* error = nil;
    NSManagedObjectContext* context = [self managedObjectContext];

    IPFSPhotoUploader* uploader = [[IPFSPhotoUploader alloc] initWithContext:context];
    [uploader uploadPhotos];
    
    NSManagedObjectModel* model = [[context persistentStoreCoordinator] managedObjectModel];
    NSFetchRequest* request = [model fetchRequestFromTemplateWithName:@"AllPhotos" substitutionVariables:nil];
    NSArray* results = [context executeFetchRequest:request error:&error];

    STAssertTrue([results count] > 0, @"Need some data");
}

@end
