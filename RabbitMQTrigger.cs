using System;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using RabbitMQ.Client;
using System.Text;
using System.Net.Http;
using System.Net.Http.Headers;

using Microsoft.Extensions.Configuration;

namespace rabbitmqfunction
{
    public static class RabbitMQEvent
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
            
            log.LogInformation($"Message received {inputMessage}.");
            log.LogInformation($"From {rabbitmqconnection}.");
            log.LogInformation($"To {url}.");

            var httpClient = new HttpClient();
            
            var content = new StringContent(inputMessage, Encoding.UTF8, "application/json");
            content.Headers.ContentType = new MediaTypeHeaderValue("application/json");
            var result = httpClient.PostAsync(url, content).Result;
            
            log.LogInformation(String.Format("{0}", result));
        }
    }
}
