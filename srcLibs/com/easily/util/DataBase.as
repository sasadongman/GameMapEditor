package com.easily.util
{
    import com.easily.ds.DataBaseData;
    import com.maclema.mysql.Connection;
    import com.maclema.mysql.Field;
    import com.maclema.mysql.MySqlResponse;
    import com.maclema.mysql.MySqlToken;
    import com.maclema.mysql.ResultSet;
    import com.maclema.mysql.Statement;
     
    import flash.events.Event;
    import flash.events.EventDispatcher;
     
    //import mx.rpc.AsyncResponder;
    import com.easily.util.AsyncResponder;
 
    /**
     * @author Easily
     */
    public class DataBase extends EventDispatcher
    {
        private var mDataBase:DataBaseData;
        private var mConnection:Connection;
         
        public function DataBase(database:DataBaseData)
        {
            mDataBase = database;
        }
         
        public function connect():void
        {
            mConnection = new Connection(mDataBase.host, mDataBase.port, 
                mDataBase.username, mDataBase.password, mDataBase.database);
            mConnection.addEventListener(Event.CONNECT, onConnected);
             
            mConnection.connect();
             
            function onConnected(event:Event):void
            {
                mConnection.removeEventListener(Event.CONNECT, onConnected);
                 
                dispatchEvent(event);
            }
        }
         
        public function disconnect():void
        {
            mConnection.disconnect();
        }
         
        public function select(sql:String, completeHandler:Function, errorHandler:Function = null):void
        {
            var st:Statement = mConnection.createStatement();
            var token:MySqlToken = st.executeQuery(sql);
            var responder:AsyncResponder = new AsyncResponder(resultHandler, faultHandler, token);
            token.addResponder(responder);
             
            function resultHandler(result:Object/*ResultSet*/, token:Object/*MySqlToken*/):void
            {
                var data:Array = [];
                 
                if (result is ResultSet)
                {
                    var fieldList:Array = result.getColumns();
                    while (result.next())
                    {
                        var item:Object = {};
                        for each (var field:Field in fieldList)
                        {
                            item[field.getName()] = result.getString(field.getName());
                        }
                        data.push(item);
                    }
                }
                 
                completeHandler(data);
            }
             
            function faultHandler(info:Object, token:Object):void
            {
                if (errorHandler == null) return;
                 
                errorHandler();
            }
        }
         
        public function insert(sql:String, completeHandler:Function, errorHandler:Function = null):void
        {
            var st:Statement = mConnection.createStatement();
            var token:MySqlToken = st.executeQuery(sql);
            var responder:AsyncResponder = new AsyncResponder(resultHandler, faultHandler, token);
            token.addResponder(responder);
             
            function resultHandler(result:Object/*MySqlResponse*/, token:Object/*MySqlToken*/):void
            {
                completeHandler(result.insertID);
            }
             
            function faultHandler(info:Object, token:Object):void
            {
                if (errorHandler == null) return;
                 
                errorHandler();
            }
        }
         
        public function remove(sql:String, completeHandler:Function, errorHandler:Function = null):void
        {
            var st:Statement = mConnection.createStatement();
            var token:MySqlToken = st.executeQuery(sql);
            var responder:AsyncResponder = new AsyncResponder(resultHandler, faultHandler, token);
            token.addResponder(responder);
             
            function resultHandler(result:Object/*MySqlResponse*/, token:Object/*MySqlToken*/):void
            {
                completeHandler();
            }
             
            function faultHandler(info:Object, token:Object):void
            {
                if (errorHandler == null) return;
                 
                errorHandler();
            }
        }
    }
}