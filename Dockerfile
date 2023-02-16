# Start with the appropriate base image
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS backend-builder
WORKDIR /backend

# Copy and restore the backend
COPY ./MNK-backend/backend.csproj .
RUN dotnet restore

# Copy the rest of the files
COPY ./MNK-backend .

# Generate and trust a development certificate
RUN dotnet dev-certs https --clean && \
    dotnet dev-certs https -ep ./https/aspnetapp.pfx -p password && \
    dotnet dev-certs https --trust

RUN dotnet publish . -c Release -o /backend/out

FROM node:lts-alpine AS frontend-builder
WORKDIR /frontend

# Install angular cli
RUN npm install -g @angular/cli

COPY ./MNK-frontend .
# Build the frontend
RUN npm install && ng build

# Build the runtime image
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS runtime
WORKDIR /app

# Copy the published output from the build image
COPY --from=backend-builder /backend/out .

# Copy the frontend build artifacts to the backend wwwroot folder
COPY --from=frontend-builder /frontend/dist ./wwwroot

# Copy the development certificate
COPY --from=backend-builder /backend/https .
# Set the ASP.NET Core environment to development
ENV ASPNETCORE_ENVIRONMENT Development

# Configure the application to use HTTPS
ENV ASPNETCORE_URLS https://+:5001;http://+:5000
ENV ASPNETCORE_HTTPS_PORT 5001
ENV ASPNETCORE_Kestrel__Certificates__Default__Password password
ENV ASPNETCORE_Kestrel__Certificates__Default__Path aspnetapp.pfx

# Expose the HTTP and HTTPS ports
EXPOSE 5000
EXPOSE 5001

# Start the backend
ENTRYPOINT ["dotnet", "backend.dll"]
