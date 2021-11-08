FROM --platform=${BUILDPLATFORM} \
    mcr.microsoft.com/dotnet/sdk:6.0.100 AS build-env
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
FROM mcr.microsoft.com/dotnet/runtime:6.0.0-alpine3.14
WORKDIR /app
VOLUME /app/database.db
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "Watchman.dll"]
