namespace Xpirit.EscapeRoom.Api.EscapeRoom;

public class DateTimeProvider : IDateTimeProvider
{
    DateTime IDateTimeProvider.Now()
    {
        return DateTime.Now;
    }
}