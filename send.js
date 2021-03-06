//npm install amqplib
var amqp = require('amqplib');
var queuename = "<QUEUENAME>"

amqp.connect('amqp://<USERNAME>:<PASSWORD>@<HOST>:5672').then(function(conn) {
  return conn.createChannel().then(function(ch) {
    var msg = '';

    var ok = ch.assertQueue(queuename, {durable: false});

    return ok.then(function(_qok) {
      var maxMessages = 1;
      
      for(i=0; i<maxMessages; ++i){
        msg = {
          firstName : "Pascal",
          lastName  : "van der Heiden",
          email     : "pascal@example.com"
      }

        ch.sendToQueue(queuename, Buffer.from(JSON.stringify(msg)));
      }

      console.log(" [x] Sent '%s'", msg);
      return ch.close();
    });
  }).finally(function() { conn.close(); });
}).catch(console.warn)