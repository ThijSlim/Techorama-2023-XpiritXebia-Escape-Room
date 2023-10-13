using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace Xpirit.EscapeRoom.Persistence.Models;

public class TeamModel
{
    [BsonId]
    public ObjectId Id { get; set; }
    
    public string Name { get; set; }
    
    public List<string> PlayerNames { get; set; }
    
    public DateTime CreationTime { get; set; }
}