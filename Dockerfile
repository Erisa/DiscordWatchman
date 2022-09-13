FROM --platform=${BUILDPLATFORM} \
    mcr.microsoft.com/dotnet/sdk:6.0.401 AS build-env
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
FROM mcr.microsoft.com/dotnet/runtime:6.0.9-alpine3.16
WORKDIR /app
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
RUN apk add --no-cache icu-libs
VOLUME /app/database.db
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "Watchman.dll"]
