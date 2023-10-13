using Xpirit.EscapeRoom.Api.EscapeRoom;

namespace Xpirit.EscapeRoom.IntegrationTests.Stubs;

public class DateTimeProviderStub : IDateTimeProvider
{
    private DateTime? NowOverride { get; set; }
    
    public DateTime Now()
    {
        if (NowOverride != null)
        {
            return (DateTime) NowOverride;
        }
        
        return DateTime.Now;
    }
    
    public void SetNow(DateTime now)
    {
        NowOverride = now;
    }
}