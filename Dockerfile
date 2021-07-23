FROM mcr.microsoft.com/dotnet/sdk:5.0.302 AS build-env
WORKDIR /app

# We need Git for Cliptok builds now.
RUN apt-get update; apt-get install git

# Copy csproj and restore as distinct layers
COPY Watchman/*.vbproj ./
RUN dotnet restore

# Copy everything else and build
COPY Watchman ./
RUN dotnet build -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/runtime:5.0.8-alpine3.13
WORKDIR /app
VOLUME /app/database.db
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "Watchman.dll"]
