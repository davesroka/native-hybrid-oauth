//
//  MyAppDelegate.m
//  NHGoogleOAuth
//
//

#import "NHGoogleOAuth.h"
#import "WLWebFrameworkInitResult.h"
#import "WLActionReceiver.h"
#import "Cordova/CDVViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>

@interface Compatibility50ViewController : UIViewController <GPPSignInDelegate>
@end

@implementation Compatibility50ViewController
static NSString * const kClientId = @"267627951572-03umiau1849g88nt8bsdh3q0q1cr06la.apps.googleusercontent.com";

GPPSignIn *signIn = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    
    // Include Client ID
    signIn.clientID = kClientId;
    
    // Uncomment one of these two statements for the scope you chose in the previous step
    signIn.scopes = @[ @"https://www.googleapis.com/auth/plus.login" ];
    
    // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
    NSDictionary *data = [NSDictionary dictionaryWithObject:auth.accessToken forKey:@"token"];
    if (error) {
        // Do some error handling here.
    } else {
        // The user is signed in.
        if ([[GPPSignIn sharedInstance] authentication]) {
            [[WL sharedInstance]sendActionToJS:@"authorized" withData:data];
        }
    }
}

- (void)didDisconnectWithError:(NSError *)error {
    if (error) {
        NSLog(@"Received error %@", error);
    } else {
        // The user is signed out and disconnected.
        [[WL sharedInstance]sendActionToJS:@"disconnected"];
    }
}

/**
 In iOS 5 and earlier, the UIViewController class displays views in portrait mode only. To support additional orientations, you must override the shouldAutorotateToInterfaceOrientation: method and return YES for any orientations your subclass supports.
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}
@end

@implementation MyAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
	BOOL result = [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    // A root view controller must be created in application:didFinishLaunchingWithOptions:  
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController* rootViewController = [[Compatibility50ViewController alloc] init];     
    
    [self.window setRootViewController:rootViewController];
    [self.window makeKeyAndVisible];
   
    [[WL sharedInstance] showSplashScreen];
    // By default splash screen will be automatically hidden once Worklight JavaScript framework is complete. 
	// To override this behaviour set autoHideSplash property in initOptions.js to false and use WL.App.hideSplashScreen() API.

    [[WL sharedInstance] initializeWebFrameworkWithDelegate:self];

    [[WL sharedInstance] addActionReceiver:self];
    
    return result;
}

- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation {
    return [GPPURLHandler handleURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
}

// This method is called after the WL web framework initialization is complete and web resources are ready to be used.
-(void)wlInitWebFrameworkDidCompleteWithResult:(WLWebFrameworkInitResult *)result
{
    if ([result statusCode] == WLWebFrameworkInitResultSuccess) {
        [self wlInitDidCompleteSuccessfully];
    } else {
        [self wlInitDidFailWithResult:result];
    }
}

-(void)wlInitDidCompleteSuccessfully
{
    UIViewController* rootViewController = self.window.rootViewController;

    // Create a Cordova View Controller
    CDVViewController* cordovaViewController = [[CDVViewController alloc] init] ;

    cordovaViewController.startPage = [[WL sharedInstance] mainHtmlFilePath];
     
    // Adjust the Cordova view controller view frame to match its parent view bounds
    cordovaViewController.view.frame = rootViewController.view.bounds;

	// Display the Cordova view
    [rootViewController addChildViewController:cordovaViewController];    
    [rootViewController.view addSubview:cordovaViewController.view];
}

-(void)wlInitDidFailWithResult:(WLWebFrameworkInitResult *)result
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                  message:[result message]
                                                  delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
    [alertView show];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)onActionReceived:(NSString *)action withData:(NSDictionary *)data {
	
	SEL selector;
	
	if ([action isEqualToString:@"invokeSignIn"]){
		selector = @selector(invokeSignIn);
	}
	else if ([action isEqualToString:@"initialize"]){
		selector = @selector(initialize);
	}
    else if ([action isEqualToString:@"disconnect"]) {
        selector = @selector(disconnect);
    }
    
	[self performSelectorOnMainThread:selector withObject:data waitUntilDone:NO];
}

-(void)invokeSignIn{
    [signIn authenticate];
}

-(void) initialize {
    BOOL result = [signIn trySilentAuthentication];
    
    if (!result) {
        [[WL sharedInstance]sendActionToJS:@"notSignedIn"];
    }
}

-(void) disconnect {
    [signIn disconnect];
}

@end
