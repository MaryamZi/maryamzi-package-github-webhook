A basic webhook accepting GitHub star events.

# Package Overview

This `github` package implements a simple webhook service, extending Ballerina's WebSub implementation, to accept 
notifications from GitHub once a repository is starred.

## Compatibility

|                                 |       Version                  |
|  :---------------------------:  |  :---------------------------: |
|  Ballerina Language             |   0.982.0                      |

## Sample

```ballerina
import ballerina/http;
import ballerina/io;
import ballerina/websub;
import maryamzi/github;

endpoint github:WebhookListener githubListenerEP {
   port:8181
};

@websub:SubscriberServiceConfig {
   path:"/github",
   subscribeOnStartUp: true,
   hub: "https://api.github.com/hub",
   topic: "https://github.com/<ORG_NAME>/<REPOSITORY_NAME>/events/*.json",
   secret: "<SECRET>",
   callback: "<OPTIONAL_ABSOLUTE_URL>",
   auth: {
       scheme:http:OAUTH2,
       accessToken:"<ACCESS_TOKEN>"
   }
}
service<github:WebhookService> githubWebhook bind githubListenerEP {

   onPing(websub:Notification notification, github:PingEvent event) {
       io:println("GitHub Notification Received, X-GitHub-Event header: ", notification.getHeaders("X-GitHub-Event"));
       io:println("Webhook added with URL: ", event.hook.config.url);
   }

   onWatch(websub:Notification notification, github:WatchEvent event) {
       io:println("GitHub Notification Received, X-GitHub-Event header: ", notification.getHeaders("X-GitHub-Event"));
       io:println(event.sender.login, " just starred ", event.repository.full_name);
   }

}
```