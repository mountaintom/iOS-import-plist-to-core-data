//
//  ImportToCoreDataFromPlist.h
//
//  Copyright (c) 2013 Mountain Tom. All rights reserved.
//  Available under the MIT license.
//  mtm{removethis}@mountaintom.com
//
//

#import "ImportToCoreDataFromPlist.h"

NSString *Error_Domain = @"com.mountaintom.coredata.import";

@implementation ImportToCoreDataFromPlist

- (BOOL) importFromPlistNamed:(NSString *)plistName
      inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
              andEntityNamed:(NSString *)entityName
                 withMapping:(NSDictionary *)mapping
                 onlyIfEmpty:(BOOL) onlyIfEmpty
                       error:(NSError **)externalError
{
    NSInteger entitysInserted = 0;
    NSError *localError;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setIncludesPropertyValues:NO];
    [fetchRequest setIncludesSubentities:NO];
    
    // If requested, only load plist data if data store is currently empty
    if(onlyIfEmpty){
        
        NSUInteger count = [managedObjectContext countForFetchRequest: fetchRequest error:&localError];
     
        if (count == NSNotFound ) {
        
            NSLog(@"Error Getting entity count %@", [localError localizedDescription]);
            
            return([self returnSuccessFlagPossibilitySettingError:NO localError:&localError error:externalError]);
        }
        
        NSLog(@"Entity Count in data store = %d", count);
        
        if (count != 0) {
            // Return if records already in datastore. This is an exit point, but not an error
            return([self returnSuccessFlagPossibilitySettingError:YES localError:nil error:nil]);
        }
        
    }
    
    // Get plist with the name requested and load into array.
    // The array will contain dictionary objects. One for each item in the plist.
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    if (plistPath == nil) {
        NSError *theError = [self makeCustomErrorObjectWithCode:MTERROR_PLIST_OPEN_FAIL 
	                                       errorDescription:[NSString stringWithFormat:@"Failed to open plist file %@", plistName]];
        
        return([self returnSuccessFlagPossibilitySettingError:NO localError:&theError error:externalError]);
    }
    
    NSMutableArray *importItems = [NSMutableArray arrayWithContentsOfFile:plistPath];
    if (importItems == nil) {
        NSError *theError = [self makeCustomErrorObjectWithCode:MTERROR_PLIST_READ_FAIL 
	                                       errorDescription:[NSString stringWithFormat:@"Failed to read plist data for %@", plistName]];
        
        return([self returnSuccessFlagPossibilitySettingError:NO localError:&theError error:externalError]);
    }
    
    while ([importItems count]) {
        
        // Get one item from the list of plist items. Then remove it from list.
        NSDictionary *item = [importItems objectAtIndex:0];
        [importItems removeObjectAtIndex:0];
        
        // Doing this because I'm continuning from inside two loops.
        BOOL skipRecord = NO;
        
        // The mapping dictionary allows the attribute name of the Core Data
        // entity to be matched with a attribute name from the plist.
        // The keys match the attribute names in the core data model
        // The values in the mapping dictionary match the plist attributes.
        NSArray *mappingKeys = [mapping allKeys];
        
        // If there are attributes mapping that are missing in the plist record,
        // then ship this record.
        // The special case is any psudo-attributes startinq with a #.
        for (NSString *theCDKey in mappingKeys) {
            
            NSString *thePlistKey = [mapping objectForKey:theCDKey];
            
            if ([item objectForKey:thePlistKey] == nil) {
                if ([thePlistKey rangeOfString:@"#"].location != 0) {
                    skipRecord = YES;
                }
            }
        }
        if (skipRecord) {
            continue;
        }
        
        entitysInserted++;
        
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName 
	                                                                  inManagedObjectContext:managedObjectContext];
        
        if (newManagedObject == nil) {
            NSError *theError = [self makeCustomErrorObjectWithCode:MTERROR_CD_NEWOBJ_FAIL 
	                                           errorDescription:[NSString stringWithFormat:@"Failed to make new Managed Object for entity %@", entityName]];

            return([self returnSuccessFlagPossibilitySettingError:NO localError:&theError error:externalError]);
        }
        
        for (NSString *theCDKey in mappingKeys) {
            
            NSString *thePlistKey = [mapping objectForKey:theCDKey];
            
            // A couple of conveninces for time stamps or adding record counts
            if ([thePlistKey isEqualToString:@"#timestamp"]) {
                [newManagedObject setValue:[NSDate date] forKey:theCDKey];
            }else if ([thePlistKey isEqualToString:@"#counter"]){
                [newManagedObject setValue:[NSNumber numberWithInt:entitysInserted] forKey:theCDKey];
            }else{
                // Using KVC to avoid the need to add a custom class and accessor methods.
                [newManagedObject setValue:[item objectForKey:thePlistKey] forKey:theCDKey];
            }
        }
    }
        
    // Save the imported data.
    if (![managedObjectContext save:&localError]) {
        NSLog(@"Data save error %@, %@", [localError localizedDescription], [localError userInfo]);
        return([self returnSuccessFlagPossibilitySettingError:NO localError:&localError error:externalError]);
    }
    
    NSLog(@"Records Created = %d", entitysInserted);
    
    return([self returnSuccessFlagPossibilitySettingError:YES localError:nil error:nil]);
    
}

// Create a little wrapper for handling details of returning error object
- (BOOL) returnSuccessFlagPossibilitySettingError:(BOOL)successFlag
                                    localError:(NSError **)localError
                                            error:(NSError **)externalError{
    
    // Unless there is an error, just leave the external NSError pointer alone.
    // If external pointer is nill, the requester does not want an error object.
    if ((externalError != nil) && (localError != nil) && (successFlag == NO)) {

            *externalError = *localError;
    }
    return successFlag;
}

// Make an NSError object from an error code and description.
- (NSError *) makeCustomErrorObjectWithCode:(int)errorCode
                   errorDescription:(NSString *)errorDescription{
    
    NSString *localizedDescription = NSLocalizedString(errorDescription, @"");
    
    NSDictionary *userDict = @{NSLocalizedDescriptionKey : localizedDescription};

    NSError *customError = [[NSError alloc] initWithDomain:Error_Domain code:errorCode userInfo:userDict];
    
    return customError;
}

@end

