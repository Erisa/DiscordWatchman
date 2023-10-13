FROM --platform=${BUILDPLATFORM} \
    mcr.microsoft.com/dotnet/sdk:6.0.415 AS build-env
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY Watchman/*.vbproj ./
RUN dotnet restore

# Copy everything else and build
COPY Watchman ./
RUN dotnet build -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/runtime:6.0.23-alpine3.18
WORKDIR /app
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
RUN apk add --no-cache icu-libs
VOLUME /app/database.db
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "Watchman.dll"]
