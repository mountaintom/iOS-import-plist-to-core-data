//
//  ImportToCoreDataFromPlist.h
//
//  Copyright (c) 2013 Mountain Tom. All rights reserved.
//  Available under the MIT license.
//  mtm{removethis}@mountaintom.com
//

#import <Foundation/Foundation.h>

#define MTERROR_PLIST_OPEN_FAIL 1
#define MTERROR_PLIST_READ_FAIL 2
#define MTERROR_CD_NEWOBJ_FAIL  4

@interface ImportToCoreDataFromPlist : NSObject

- (BOOL) importFromPlistNamed:(NSString *)plistName
      inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
              andEntityNamed:(NSString *)entityName
                 withMapping:(NSDictionary *)mapping
                 onlyIfEmpty:(BOOL) onlyIfEmpty
                       error:(NSError **)externalError;


@end

