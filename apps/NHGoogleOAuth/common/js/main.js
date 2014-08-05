function wlCommonInit() {
    App.init(); //Call the init function to make your action receiver
    WL.App.sendActionToNative("initialize", {});
}

var App = (function() {
    function init() {
        WL.App.addActionReceiver("myActionReceiver", myActionReceiver);
    };

    function myActionReceiver(received) {
        switch (received.action) {
            case "authorized":
                localStorage["access_token"] = received.data.token; //Store the access token in the hybrid app local storage
                console.log("HELLO " + localStorage.getItem("access_token"));
                $('#gConnect').hide(); //Hide the google sign in button
                $('#authOps').show(); //show your loading icon or some other part of the screen
                break;
            case "error":
                // HANDLE THE ERROR HERE
                break;
            case "disconnected":
                console.log("GOODBYE");
                localStorage.clear(); //Clear local storage to get rid of user data
                $('#gConnect').show(); //Show the sign in button again
                $('#authOps').hide();
                break;
            case "notSignedIn":
            	$('#gConnect').show(); //Show the sign in button again
                $('#authOps').hide();
                break;
        }
    };

    return {
        init: init
    };
}());