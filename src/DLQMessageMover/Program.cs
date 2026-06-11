using Azure.Messaging.ServiceBus;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

public class DeadLetterReprocessorFast
{
    private const string ConnectionString = "Endpoint=sb://lm-p-aze2-sbns-001.servicebus.windows.net/;SharedAccessKeyName=ChangesetPropagation;SharedAccessKey=im8I2qDqv7YpU/s/Q0M57W03oZboCV4cK+ASbAXX+hE=\n ";
    private const string TopicName = "form-notification-events";
    private const string SubscriptionName = "form-notification-worker";
    private const int MaxBatchSize = 100; // máximo por llamada
    private const int Parallelism = 4; // cuántas tareas en paralelo

    public static async Task Main()
    {
        var client = new ServiceBusClient(ConnectionString);
        var dlqPath = $"{TopicName}/Subscriptions/{SubscriptionName}/$DeadLetterQueue";

        var receiver = client.CreateReceiver(dlqPath, new ServiceBusReceiverOptions
        {
            ReceiveMode = ServiceBusReceiveMode.PeekLock
        });

        var sender = client.CreateSender(TopicName);

        Console.WriteLine("Iniciando reenvío paralelo...");

        var tasks = new List<Task>();
        var lockObj = new object();

        for (int i = 0; i < Parallelism; i++)
        {
            tasks.Add(Task.Run(async () =>
            {
                while (true)
                {
                    IReadOnlyList<ServiceBusReceivedMessage> messages;

                    lock (lockObj)
                    {
                        messages = receiver.ReceiveMessagesAsync(MaxBatchSize, TimeSpan.FromSeconds(3)).Result;
                    }

                    if (messages == null || messages.Count == 0) break;

                    var newMessages = messages.Select(m =>
                    {
                        var msg = new ServiceBusMessage(m.Body)
                        {
                            MessageId = Guid.NewGuid().ToString(), // evita duplicados
                            Subject = m.Subject,
                            CorrelationId = m.CorrelationId,
                            ContentType = m.ContentType
                        };

                        foreach (var prop in m.ApplicationProperties)
                            msg.ApplicationProperties[prop.Key] = prop.Value;

                        return msg;
                    }).ToList();

                    await sender.SendMessagesAsync(newMessages);
                    foreach (var m in messages)
                        await receiver.CompleteMessageAsync(m);

                    Console.WriteLine($"[{Task.CurrentId}] Reenviados {newMessages.Count} mensajes.");
                }
            }));
        }

        await Task.WhenAll(tasks);

        await receiver.CloseAsync();
        await sender.CloseAsync();
        await client.DisposeAsync();

        Console.WriteLine("✅ Reenvío completado con paralelismo.");
    }
}
