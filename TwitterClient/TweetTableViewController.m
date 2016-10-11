//
//  TweetTableViewController.m
//  TwitterClient
//
//  Created by Tomás Garrido Sandino on 10/10/16.
//  Copyright © 2016 Tomás Garrido Sandino. All rights reserved.
//

#import "TweetTableViewController.h"
#import "Tweet.h"
#import "ModalStatusViewController.h"
#import "Utilities.h"
#import "Authorizer.h"
#import "TweetTableViewCell.h"

@interface TweetTableViewController ()
@property(nonatomic, strong) NSArray<Tweet *> *tweets;
@property(nonatomic,strong) ModalStatusViewController *statusModal;
@end

@implementation TweetTableViewController {
    BOOL firstTime;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    firstTime = true;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:NO];
    if (self.tweets.count ==0  && firstTime) {
        firstTime = false;
        self.statusModal = [Utilities showStatusModalWithMessage:@"Loading tweets" source:self];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self loadTweets:^ {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.statusModal dismissViewControllerAnimated:NO completion:nil];

                });
            }];
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Table view cells are reused and should be dequeued using a cell identifier.
    TweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweetTableViewCell" forIndexPath:indexPath];
    
    // Fetches the appropriate meal for the data source layout.
    Tweet *tweet = self.tweets[indexPath.row];
    
    cell.tweetContent.text = tweet.content;
    cell.tweetererLabel.text = [NSString stringWithFormat:@"%@ - %@",tweet.createdBy, tweet.createdAt];
    cell.tweetererPicture.image = [self loadPictureOfTweet:tweet];
    return cell;}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)loadTweets:(void(^)(void))completionHandler {
    Authorizer *authorizer = [Utilities authorizer];
    self.tweets = [authorizer getTweetsWithMaxId:nil sinceId:nil];
    completionHandler();
}

-(UIImage *)loadPictureOfTweet:(Tweet *)tweet {
    return nil;
}
@end
