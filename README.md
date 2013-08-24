Import To Core Data From Plist
=============================

A simple to use Objective-C class to import data from a plist into iOS Core Data. Such as seeding initial data on first use of App.

# How to use this class

The instructions will use the BearExample plist and Core Data entity Bears.

A simple way to try this class, is create a Master Detail project in Xcode, with Core Data. Then add the name and summary attributes to the events entity. Then modify the Master and detail views to display the new attributes.

* Add the files ImportToCoreDataFromPlist.h and ImportToCoreDataFromPlist.m to your project. 

* Add the BearsExample.plist file (in the BearsExamplePlister folder) to your project.

* Create a Core Data entity named Bears.
* Add the following attributes to the Bears entity: (or just use the Event entity if you use the Master Detail template)
      * name (type String)
      * summary (type String)
      * timeStamp (type Date)
 

* In your App Delegate file, in the didFinishLaunchingWithOptions method, add the following code (Shown with /*Add*/ on beginning of line):

```objective-c
//
//  AppDelegate.m
//

#import "AppDelegate.h"
/*Add*/ #import "ImportToCoreDataFromPlist.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
........
........   
    self.window.backgroundColor = [UIColor lightGrayColor];
    
    /*Add*/ ImportToCoreDataFromPlist *importData = [[ImportToCoreDataFromPlist alloc] init];
    /*Add*/ NSError *importError;

    /*Add*/ BOOL success = [importData importFromPlistNamed:@"BearsExample"
                                     inManagedObjectContext:self.managedObjectContext
                                             andEntityNamed:@"Bears"
                                                withMapping:@{@"name": @"name"
                                                        , @"summary" : @"description"
                                                      , @"timeStamp" : @"#timestamp"}
                                                onlyIfEmpty:YES
                                                      error:&importError];
    
    /*Add*/ if (!success) {
    /*Add*/     NSLog(@"Seed data import failed... %@ - %@", [importError localizedDescription], [importError userInfo]);
    /*Add*/ }

    return YES;
}
```
# BearsExample.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
    <dict>
                <key>description</key>
                <string>Picnic basket stealer extraordinaire</string>
                <key>name</key>
                <string>Yogi</string>
        </dict>
        <dict>
                <key>description</key>
                <string>Has on and off interest in Yogi</string>
                <key>name</key>
                <string>Cindy</string>
        </dict>
        <dict>
                <key>description</key>
                <string>Yogi’s faithful companion and conscience</string>
                <key>name</key>
                <string>Boo-Boo</string>
        </dict>
</array>
</plist>
```

# Class Documentation

Name of Class: ImportToCoreDataFromPlist
(Class has one method: importFromPlistNamed)

Arguments Description:

**importFromPlistNamed**: This is the name of the plist

**andEntityNamed**: This is the name of the Core Data entity

**onlyIfEmpty**: If YES will only seed data when database is empty. If NO, will load data every time App is run.

**error**: address (&error) of a NSError object pointer. See code example on how to use.

**withMapping**: This the mapping of the attribute names in the Core Data entity to the attribute names in the plist. In many case the names used in the plist wile be the same as the names used in the Core Data entity. This gives the chance to bridge the gap should they not be the same. This map is always required. And is a NSDictionary object. See code usage example.

**withMapping specials**: If #timestamp or #counter are supplied as the right hand (value) part of the map, the following special actions will take place:

 **#timestamp**: The current time will be inserted in the Core Data entity named by the left hand (key) part of the map.
 
 **#counter**: This will insert the current row number of the items being imported.

# Final Notes.

This is a data loader I wrote for one of my Apps. I’ve found this to be useful. I’m putting it out in the public in the hopes others may find it useful, too.

This loader was designed for the specific need I had to load a single entity (table) and has not been expanded to handle other situations. But you should be able to adapt it.

The NSLog statements are in the code for debug. Remove them for production code.

This code is available under the MIT License.

Mountain Tom
mtm{removethis}@mountaintom.com
