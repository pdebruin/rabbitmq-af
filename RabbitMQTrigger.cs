using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

using RabbitMQ.Client;
using System.Text;

using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;

using Microsoft.Extensions.Configuration;

namespace rabbitmq
{
    public static class RabbitMQTrigger
    {
        [FunctionName("RabbitMQTrigger")]
        public static void Run(
            [RabbitMQTrigger("%InputQueueName%", ConnectionStringSetting = "RabbitMqConnection")] string inputMessage,
            [RabbitMQ(ConnectionStringSetting = "RabbitMqConnection")] IModel client,
            ILogger log,
            ExecutionContext context)
        {
            var config = new ConfigurationBuilder()
                .SetBasePath(context.FunctionAppDirectory)
                .AddJsonFile("local.settings.json", optional: true, reloadOnChange: true) 
                .AddEnvironmentVariables() 
                .Build();
				
	        string url = config["LogicAppUri"];
            string rabbitmqconnection = config["RabbitMqConnection"];

            RMQMessage message = JsonConvert.DeserializeObject<RMQMessage>(inputMessage);
            
            log.LogInformation($"Message received {inputMessage}.");
            log.LogInformation($"From {rabbitmqconnection}.");
            log.LogInformation($"User {message.firstName} {message.lastName}.");
            log.LogInformation($"To {url}.");

            var httpClient = new HttpClient();
            
            var content = new StringContent(inputMessage, Encoding.UTF8, "application/json");
            content.Headers.ContentType = new MediaTypeHeaderValue("application/json");
            var result = httpClient.PostAsync(url, content).Result;
            
            log.LogInformation(String.Format("{0}", result));
        }
    }
}
