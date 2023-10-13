using Xpirit.EscapeRoom.Api.EscapeRoom;
using Xpirit.EscapeRoom.Broker.StartupExtensions;
using Xpirit.EscapeRoom.Persistence.Configuration;

var builder = WebApplication.CreateBuilder(args);
const string myAllowSpecificOrigins = "_myAllowSpecificOrigins";

builder.Services.AddCors(options =>
{
    options.AddPolicy(name: myAllowSpecificOrigins,
        policy  =>
        {
            policy.AllowAnyOrigin()
                .AllowAnyHeader()
                .AllowAnyMethod();
        });
});

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddSingleton<IActiveEscapeRoom, ActiveEscapeRoom>();
builder.Services.AddTransient<IDateTimeProvider, DateTimeProvider>();
builder.Services.AddTransient<IRandomEscapeRoomPuzzlesProvider, RandomEscapeRoomPuzzlesProvider>();
builder.Services.AddSingleton<GameStateMachine>();

if (builder.Configuration.GetConnectionString("EscapeRoomDbConnectionString") != null)
{
    var connectionString = builder.Configuration.GetConnectionString("EscapeRoomDbConnectionString");
    var mongoDatabase = ServiceCollectionExtension.GetMongoDatabase(connectionString!);
    builder.Services.AddPersistence(mongoDatabase);
    builder.Services.ConfigureBroker();
}


var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();
app.UseCors(myAllowSpecificOrigins);
app.MapControllers();
app.Run();

// ReSharper disable once ClassNeverInstantiated.Global
namespace Xpirit.EscapeRoom.Api
{
    public partial class Program { }
}