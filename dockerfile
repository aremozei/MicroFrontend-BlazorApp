FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

WORKDIR /LoadTest
COPY /LoadTest/LoadTest.csproj .
RUN dotnet restore "LoadTest.csproj"
COPY /LoadTest /LoadTest/

WORKDIR /ChatBox
COPY /ChatBox/ChatBox.csproj .
RUN dotnet restore "ChatBox.csproj"
COPY /ChatBox /ChatBox/

WORKDIR /MicroWasm
COPY /MicroWasm/MicroWasm.csproj .
RUN dotnet restore "MicroWasm.csproj"
COPY /MicroWasm /MicroWasm

RUN dotnet build "MicroWasm.csproj" -c Release -o ./app/build

FROM build AS publish
RUN dotnet publish "MicroWasm.csproj" -c Release -o ./app/publish

FROM nginx:alpine AS final
WORKDIR /usr/share/nginx/html
COPY --from=publish /MicroWasm/app/publish/wwwroot .
COPY nginx.conf /etc/nginx/nginx.conf
