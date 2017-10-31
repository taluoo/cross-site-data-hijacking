package {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.external.ExternalInterface;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLVariables;
import flash.system.Security;
import flash.text.TextField;

public class flashRequest extends Sprite {

    public function flashRequest() {
        Security.allowDomain('*');
        Security.allowInsecureDomain('*');
        ExternalInterface.call('console.log', 'flashRequest preparing');
        var textField:TextField = new TextField();
        textField.text = "the quieter you become, the more you are able to hear";
        textField.width = 500;
        addChild(textField);
        addEventListener("enterFrame", registerExternalCallbacks);
    }

    private function registerExternalCallbacks(param1:Object):void {
        removeEventListener("enterFrame", registerExternalCallbacks);
        if (ExternalInterface.available) {
            ExternalInterface.addCallback('request', request);
            try {
                ExternalInterface.call('flashReady');
            }
            catch (e:Error) {
                ExternalInterface.call("alert", "can not set loaded");
            }
        }
    }

    public function request(url:String, data:Object = null, headers:Object = null, method:String = 'GET', contentType:String = 'application/x-www-form-urlencoded', dataFormat:String = 'text'):void {
        trace('request start');
        trace(method + ' ' + url);
        trace('contentType: ' + contentType);
        var request:URLRequest = new URLRequest(url);
        var variables:URLVariables = new URLVariables();
        request.method = method;  // GET or POST, 注意大小写
        request.contentType = contentType;// application/x-www-form-urlencoded,
        for (var key:String in data) {
            variables[key] = data[key];
        }
        request.data = variables;
        trace(request.data);

        for (var header:String in headers) {
            request.requestHeaders.push(new URLRequestHeader(header, headers[header]))
        }

        var loader:URLLoader = new URLLoader();
        loader.dataFormat = dataFormat; // text, binary, variables
        configureListeners(loader);

        try {
            loader.load(request);
        } catch (error:Error) {
            trace("Unable to load requested document.");
        }
    }


    private function configureListeners(dispatcher:IEventDispatcher):void {
        dispatcher.addEventListener(Event.COMPLETE, completeHandler);
        dispatcher.addEventListener(Event.OPEN, openHandler);
        dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
        dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
        dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
    }

    private function completeHandler(event:Event):void {
        var loader:URLLoader = URLLoader(event.target);
//        trace("completeHandler: " + loader.data);
        ExternalInterface.call('flashResponse', loader.data);
    }

    private function openHandler(event:Event):void {
        trace("openHandler: " + event);
    }

    private function progressHandler(event:ProgressEvent):void {
        trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
    }

    private function securityErrorHandler(event:SecurityErrorEvent):void {
        trace("securityErrorHandler: " + event);
    }

    private function httpStatusHandler(event:HTTPStatusEvent):void {
        trace("httpStatusHandler: " + event);
    }

    private function ioErrorHandler(event:IOErrorEvent):void {
        trace("ioErrorHandler: " + event);
    }
}
}
