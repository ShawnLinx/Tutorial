package org.robotlegs.base
{
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import org.robotlegs.core.IEventMap;
   
   public class EventMap implements IEventMap
   {
       
      
      protected var eventDispatcher:IEventDispatcher;
      
      protected var _dispatcherListeningEnabled:Boolean = true;
      
      protected var listeners:Array;
      
      public function EventMap(eventDispatcher:IEventDispatcher)
      {
         super();
         this.listeners = new Array();
         this.eventDispatcher = eventDispatcher;
      }
      
      public function get dispatcherListeningEnabled() : Boolean
      {
         return this._dispatcherListeningEnabled;
      }
      
      public function set dispatcherListeningEnabled(value:Boolean) : void
      {
         this._dispatcherListeningEnabled = value;
      }
      
      public function mapListener(dispatcher:IEventDispatcher, type:String, listener:Function, eventClass:Class = null, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true) : void
      {
         var params:Object = null;
         if(this.dispatcherListeningEnabled == false && dispatcher == this.eventDispatcher)
         {
            throw new ContextError(ContextError.E_EVENTMAP_NOSNOOPING);
         }
         var eventClass:Class = eventClass || Event;
         var i:int = this.listeners.length;
         while(i--)
         {
            params = this.listeners[i];
            if(params.dispatcher == dispatcher && params.type == type && params.listener == listener && params.useCapture == useCapture && params.eventClass == eventClass)
            {
               return;
            }
         }
         var callback:Function = function(event:Event):void
         {
            routeEventToListener(event,listener,eventClass);
         };
         params = {
            "dispatcher":dispatcher,
            "type":type,
            "listener":listener,
            "eventClass":eventClass,
            "callback":callback,
            "useCapture":useCapture
         };
         this.listeners.push(params);
         dispatcher.addEventListener(type,callback,useCapture,priority,useWeakReference);
      }
      
      public function unmapListener(dispatcher:IEventDispatcher, type:String, listener:Function, eventClass:Class = null, useCapture:Boolean = false) : void
      {
         var params:Object = null;
         eventClass = eventClass || Event;
         var i:int = this.listeners.length;
         while(i--)
         {
            params = this.listeners[i];
            if(params.dispatcher == dispatcher && params.type == type && params.listener == listener && params.useCapture == useCapture && params.eventClass == eventClass)
            {
               dispatcher.removeEventListener(type,params.callback,useCapture);
               this.listeners.splice(i,1);
               return;
            }
         }
      }
      
      public function unmapListeners() : void
      {
         var dispatcher:IEventDispatcher = null;
         var params:Object = this.listeners.pop();
         while(params)
         {
            dispatcher = params.dispatcher;
            dispatcher.removeEventListener(params.type,params.callback,params.useCapture);
            params = this.listeners.pop();
         }
      }
      
      protected function routeEventToListener(event:Event, listener:Function, originalEventClass:Class) : void
      {
         if(event is originalEventClass)
         {
            listener(event);
         }
      }
   }
}
