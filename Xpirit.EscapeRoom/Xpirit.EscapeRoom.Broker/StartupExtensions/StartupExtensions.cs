using Microsoft.Extensions.DependencyInjection;
using MongoDB.Driver;
using Rebus.Config;
using Rebus.Handlers;
using Rebus.Logging;
using Rebus.Persistence.InMem;
using Rebus.Routing.TypeBased;
using Rebus.Serialization.Json;
using Rebus.Transport.InMem;
using Xpirit.EscapeRoom.Broker.Handlers.Events;
using Xpirit.EscapeRoom.Broker.Models;

namespace Xpirit.EscapeRoom.Broker.StartupExtensions;

public static class StartupExtensions
{

    public static IServiceCollection ConfigureBroker(this IServiceCollection services)
    {
        const string queueName = "EscapeRoom";
        services.AutoRegisterHandlersFromAssemblyOf<IQueue>();
        services.AutoRegisterHandlersFromAssemblyOf<GameCompletedHandler>();
        services.AutoRegisterHandlersFromAssemblyOf<GameCompleted>();

        services.AddRebus(x => x
            .Options(options =>
            {
                options.SetMaxParallelism(1);
                options.SetNumberOfWorkers(1);
                //options.SimpleRetryStrategy(maxDeliveryAttempts: 10, secondLevelRetriesEnabled: true);
            })
            .Logging(l => l.ColoredConsole(LogLevel.Warn))
            .Serialization(s => s.UseNewtonsoftJson())
            .Transport((c) => c.UseInMemoryTransport(new InMemNetwork(), queueName))
            .Subscriptions(s => s.StoreInMemory())
            .Routing(r =>
            {
                r.TypeBased()
                    .MapAssemblyOf<IQueue>(queueName)
                    .MapAssemblyOf<GameCompleted>(queueName)
                    .MapAssemblyOf<GameCompletedHandler>(queueName);
            })
            // .Events(ConfigureEvents)
        );

        return services
            .AddSingleton<IHandleMessages<GameCompleted>, GameCompletedHandler>()
            // .AutoRegisterHandlersFromAssemblyOf<GameSucceededHandler>()
            .AddTransient<IQueue, RebusQueue>();
    }
}