//
//  EditFriendsViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "EditFriendsViewController.h"

@interface EditFriendsViewController ()

@end

@implementation EditFriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        else {
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendObjects = [result objectForKey:@"data"];
            self.allFriends = friendObjects;
            NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                [friendIds addObject:[friendObject objectForKey:@"id"]];
            }
            
            // Construct a PFUser query that will find friends whose facebook ids
            // are contained in the current user's friend list.
            PFQuery *friendQuery = [PFUser query];
            [friendQuery whereKey:@"fbId" containedIn:friendIds];
            
            // findObjects will return a list of PFUsers that are friends
            // with the current user
            NSArray *friendUsers = [friendQuery findObjects];
            self.availableFriends = friendUsers;
            
            [self.tableView reloadData];
        }
    }];
    
    self.currentUser = [PFUser currentUser];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return [self.availableFriends count];
        case 1:
            return [self.allFriends count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Return the number of rows in the section.
    if (indexPath.section == 0) {

            // Ze uses my app!
            PFUser *user = self.availableFriends[indexPath.row];
        // TODO use FB data to populate
            cell.textLabel.text = user.username;
            
            if ([self isFriend:user]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            return cell;
    }
    else if (indexPath.section == 1) {
            // Just a facebook user
            NSDictionary *friendObject = self.allFriends[indexPath.row];
            cell.textLabel.text = friendObject[@"name"];

            cell.accessoryType = UITableViewCellAccessoryNone;
            
            return cell;
    }
    else {
    return nil;
    }
    }

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
//    No actions should be possible
//    
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    
//    PFRelation *friendsRelation = [self.currentUser relationforKey:@"friendsRelation"];
//    PFUser *user = [self.allUsers objectAtIndex:indexPath.row];
//    
//    if ([self isFriend:user]) {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        
//        for(PFUser *friend in self.friends) {
//            if ([friend.objectId isEqualToString:user.objectId]) {
//                [self.friends removeObject:friend];
//                break;
//            }
//        }
//    
//        [friendsRelation removeObject:user];
//    }
//    else {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        [self.friends addObject:user];
//        [friendsRelation addObject:user];
//    }
//    
//    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (error) {
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        }
//    }];
}

#pragma mark - Helper methods

- (BOOL)isFriend:(PFUser *)user {
    for(PFUser *friend in self.friends) {
        if ([friend.objectId isEqualToString:user.objectId]) {
            return YES;
        }
    }
    
    return NO;
}

@end
