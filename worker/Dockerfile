FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY *.csproj ./
RUN dotnet restore Worker.csproj
COPY . ./
RUN dotnet publish --no-restore -c Release -o /app/publish
# adding args to support mulibile platform in the next update 
FROM mcr.microsoft.com/dotnet/aspnet:7.0
WORKDIR /app
RUN addgroup workergroup && adduser --no-create-home --disabled-login --ingroup workergroup workeruser
COPY --from=build /app/publish /app
RUN chown -R workeruser:workergroup /app
USER workeruser
CMD [ "dotnet","Worker.dll" ]

