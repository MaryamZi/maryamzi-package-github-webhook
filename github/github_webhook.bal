//
// Copyright (c) 2018.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import ballerina/http;
import ballerina/websub;

documentation { The object representing the GitHub Webhook Service. }
public type WebhookService object {

    public function getEndpoint() returns (WebhookListener) {
        WebhookListener ep = new;
        return ep;
    }

};

documentation { Object representing the GitHub Webhook (WebSub Subscriber Service) Endpoint
    E{{}}
    F{{webhookListenerConfig}}             The configuration for the endpoint
}
public type WebhookListener object {

    public WebhookListenerConfiguration webhookListenerConfig;

    private websub:Listener websubListener;

    public new() {
        websubListener = new;
    }

    documentation { Gets called when the endpoint is being initialized during package init.
        P{{config}} The SubscriberServiceEndpointConfiguration of the endpoint
    }
    public function init(WebhookListenerConfiguration config);

    documentation { Gets called whenever a service attaches itself to this endpoint and during package init.
        P{{serviceType}}    The service attached
    }
    public function register(typedesc serviceType);

    documentation { Starts the registered service. }
    public function start();

    documentation { Returns the connector that client code uses.
        R{{}}   The connector that client code uses
    }
    public function getCallerActions() returns (http:Connection);

    documentation { Stops the endpoint. }
    public function stop();

};

documentation { Object representing the configuration for the GitHub Webhook Listener.
    F{{host}}   The host name/IP of the endpoint
    F{{port}}   The port to which the endpoint should bind to
}
public type WebhookListenerConfiguration record {
    string host,
    int port,
};

function WebhookListener::init(WebhookListenerConfiguration config) {
    self.webhookListenerConfig = config;
    websub:ExtensionConfig extensionConfig = {
        topicIdentifier: websub:TOPIC_ID_HEADER,
        topicHeader: GITHUB_TOPIC_HEADER,
        headerResourceMap: GITHUB_TOPIC_HEADER_RESOURCE_MAP
    };
    websub:SubscriberServiceEndpointConfiguration sseConfig = { host: config.host, port: config.port,
                                                                extensionConfig: extensionConfig };
    self.websubListener.init(sseConfig);
}

function WebhookListener::register(typedesc serviceType) {
    self.websubListener.register(serviceType);
}

function WebhookListener::start() {
    self.websubListener.start();
}

function WebhookListener::getCallerActions() returns (http:Connection) {
    return self.websubListener.getCallerActions();
}

function WebhookListener::stop () {
    self.websubListener.stop();
}

@final string GITHUB_TOPIC_HEADER = "X-GitHub-Event";

@final map<(string, typedesc)> GITHUB_TOPIC_HEADER_RESOURCE_MAP = {
    "ping" : ("onPing", PingEvent),
    "watch" : ("onWatch", WatchEvent)
};
