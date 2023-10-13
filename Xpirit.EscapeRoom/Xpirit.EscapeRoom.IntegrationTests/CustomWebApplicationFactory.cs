using System.Data.Common;
using Hypothesist;
using Hypothesist.Rebus;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Mongo2Go;
using MongoDB.Driver;
using Rebus.Activation;
using Rebus.Config;
using Rebus.DataBus.InMem;
using Rebus.Logging;
using Rebus.Persistence.InMem;
using Rebus.Routing.TypeBased;
using Rebus.Serialization.Json;
using Rebus.Transport.InMem;
using Xpirit.EscapeRoom.Api.EscapeRoom;
using Xpirit.EscapeRoom.Broker;
using Xpirit.EscapeRoom.Broker.Handlers.Events;
using Xpirit.EscapeRoom.Broker.Models;
using Xpirit.EscapeRoom.Broker.StartupExtensions;
using Xpirit.EscapeRoom.IntegrationTests.Stubs;
using Xpirit.EscapeRoom.Persistence;
using Xpirit.EscapeRoom.Persistence.Configuration;

namespace Xpirit.EscapeRoom.IntegrationTests;

public class CustomWebApplicationFactory<TProgram>
    : WebApplicationFactory<TProgram> where TProgram : class
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        var dataBaseName = Guid.NewGuid().ToString();
        builder.ConfigureTestServices(services =>
        {
            services.AddSingleton<IDateTimeProvider, DateTimeProviderStub>();
            services.AddSingleton<IRandomEscapeRoomPuzzlesProvider, RandomEscapeRoomPuzzlesProviderStub>();
            
            var mongoDbRunner = MongoDbRunner.StartForDebugging();
            //mongoDbRunner.Import("TestDatabase", "TestCollection", @"..\..\App_Data\test.json", true);

            MongoClient mongoClient = new MongoClient(mongoDbRunner.ConnectionString);
            IMongoDatabase database = mongoClient.GetDatabase(dataBaseName);
            services.AddPersistence(database);
            services.ConfigureBroker();

            var hypotheses = new List<IHypothesis<object>>();
            
            string queueName = "EscapeRoom";
            var someContainerAdapter = new BuiltinHandlerActivator();
            Configure.With(someContainerAdapter)
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
                        .MapAssemblyOf<GameCompletedHandler>(queueName);
                })
                .Events((e) => e.AfterMessageHandled += (bus, headers, message, context, exception) =>
                {
                    foreach (var hypothesis in hypotheses)
                    {
                        hypothesis.Test(message, CancellationToken.None);
                    }
                });
        });

        builder.UseEnvironment("IntegrationTest");
    }
}

public class MessageHandledListener : IOnHandled
{
    private readonly List<IHypothesis<object>> _hypotheses;

    public MessageHandledListener()
    {
        _hypotheses = new List<IHypothesis<object>>();
    }

    public void OnHandled(object message, CancellationToken cancellationToken)
    {
        foreach (var hypothesis in _hypotheses)
        {
            hypothesis.Test(message, cancellationToken);
        }
    }
        
    public void AddHypothesis(IHypothesis<object> hypothesis)
    {
        _hypotheses.Add(hypothesis);
    }
}

public interface IOnHandled
{
    void OnHandled(object message, CancellationToken cancellationToken)
    {
    }
}