FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build-env
WORKDIR /App

# Copy necessary files and restore as distinct layer
COPY */*.csproj ./

RUN for file in $(ls *.csproj); do mkdir -p src/${file%.*}/ && mv $file src/${file%.*}/; done

RUN dotnet restore src/Xpirit.EscapeRoom.Api/*.csproj

# Copy everything else and build
COPY . ./
RUN dotnet publish ./Xpirit.EscapeRoom.Api -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS runtime
WORKDIR /App
COPY --from=build-env /App/out .

# Expose ports
EXPOSE 80
EXPOSE 8080
EXPOSE 443

# Configure environment variables
# ENV WEBSITE_SITE_NAME Xpirit.EscapeRoom.Api

# Start
ENTRYPOINT ["dotnet", "Xpirit.EscapeRoom.Api.dll"]