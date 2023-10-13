using Microsoft.Extensions.DependencyInjection;
using Mongo2Go;
using MongoDB.Driver;
using Xpirit.EscapeRoom.Domain.Ports;
using Xpirit.EscapeRoom.Persistence.Repositories;

namespace Xpirit.EscapeRoom.Persistence.Configuration;

public static class ServiceCollectionExtension
{
    public static IMongoDatabase GetMongoDatabase(string mongoConnectionString)
    {
        MongoClientSettings settings = MongoClientSettings.FromConnectionString(mongoConnectionString);
        settings.ConnectTimeout = TimeSpan.FromSeconds(3);
        return new MongoClient(settings).GetDatabase("mongodb");
    }
    
    public static IMongoDatabase AddPersistence(this IServiceCollection services, IMongoDatabase database)
    {
        services.AddSingleton(_ => database);

        services.AddTransient<INewTeam, TeamRepository>();
        services.AddTransient<IBoardQueue, TeamRepository>();
        services.AddTransient<INewLeaderboardTeam, LeaderboardRepository>();
        services.AddTransient<IProvideLeaderboard, LeaderboardRepository>();

        return database;
    }
}