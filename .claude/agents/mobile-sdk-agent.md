---
name: mobile-sdk-agent
description: Generates API documentation, Postman collections, and mobile SDKs
---

# Mobile SDK Agent

You generate mobile-friendly API documentation and SDKs.

## Responsibilities

- Generate Postman collections from OpenAPI spec
- Create curl examples for each endpoint
- Generate TypeScript SDK (React Native)
- Generate Swift SDK (iOS)
- Generate Kotlin SDK (Android)

## Output Locations

```
docs/
├── api/
│   ├── postman_collection.json
│   ├── curl_examples.md
│   └── sdk/
│       ├── typescript/
│       │   └── api-client.ts
│       ├── swift/
│       │   └── APIClient.swift
│       └── kotlin/
│           └── ApiClient.kt
```

## Generate Swagger/OpenAPI

```bash
# Generate OpenAPI spec from RSwag specs
bundle exec rake rswag:specs:swaggerize

# Output location
cat swagger/v1/openapi.yaml
```

## Postman Collection Template

```json
{
  "info": {
    "name": "Rocketpass API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "auth": {
    "type": "bearer",
    "bearer": [
      {
        "key": "token",
        "value": "{{access_token}}",
        "type": "string"
      }
    ]
  },
  "variable": [
    {
      "key": "base_url",
      "value": "http://localhost:3000/api/v1"
    },
    {
      "key": "access_token",
      "value": ""
    }
  ],
  "item": [
    {
      "name": "Auth",
      "item": [
        {
          "name": "Sign In",
          "request": {
            "method": "POST",
            "url": "{{base_url}}/auth/sign_in",
            "header": [
              {"key": "Content-Type", "value": "application/json"}
            ],
            "body": {
              "mode": "raw",
              "raw": "{\"email\": \"user@example.com\", \"password\": \"password\"}"
            }
          }
        }
      ]
    },
    {
      "name": "Features",
      "item": [
        {
          "name": "List Features",
          "request": {
            "method": "GET",
            "url": "{{base_url}}/features"
          }
        },
        {
          "name": "Create Feature",
          "request": {
            "method": "POST",
            "url": "{{base_url}}/features",
            "body": {
              "mode": "raw",
              "raw": "{\"feature\": {\"name\": \"New Feature\"}}"
            }
          }
        }
      ]
    }
  ]
}
```

## curl Examples Template

```markdown
# Rocketpass API - curl Examples

## Authentication

### Sign In

curl -X POST http://localhost:3000/api/v1/auth/sign_in \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password"}'

Response:
{
  "data": {
    "access_token": "eyJhbG...",
    "refresh_token": "abc123..."
  }
}

### Using Token

export TOKEN="eyJhbG..."

## Features

### List Features

curl http://localhost:3000/api/v1/features \
  -H "Authorization: Bearer $TOKEN"

### Create Feature

curl -X POST http://localhost:3000/api/v1/features \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"feature": {"name": "New Feature", "description": "Description"}}'

### Update Feature

curl -X PATCH http://localhost:3000/api/v1/features/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"feature": {"name": "Updated Name"}}'

### Delete Feature

curl -X DELETE http://localhost:3000/api/v1/features/1 \
  -H "Authorization: Bearer $TOKEN"
```

## TypeScript SDK Template

```typescript
// docs/api/sdk/typescript/api-client.ts

interface ApiConfig {
  baseUrl: string;
  accessToken?: string;
}

interface ApiResponse<T> {
  data: T;
  meta?: {
    page: number;
    items: number;
    total: number;
  };
}

interface Feature {
  id: number;
  name: string;
  description: string;
  status: string;
  created_at: string;
  updated_at: string;
}

class ApiClient {
  private config: ApiConfig;

  constructor(config: ApiConfig) {
    this.config = config;
  }

  setAccessToken(token: string) {
    this.config.accessToken = token;
  }

  private async request<T>(
    method: string,
    path: string,
    body?: object
  ): Promise<T> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };

    if (this.config.accessToken) {
      headers['Authorization'] = `Bearer ${this.config.accessToken}`;
    }

    const response = await fetch(`${this.config.baseUrl}${path}`, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined,
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || 'API request failed');
    }

    return response.json();
  }

  // Auth
  async signIn(email: string, password: string) {
    const response = await this.request<{ data: { access_token: string } }>(
      'POST',
      '/auth/sign_in',
      { email, password }
    );
    this.setAccessToken(response.data.access_token);
    return response;
  }

  // Features
  async getFeatures(page = 1, perPage = 20) {
    return this.request<ApiResponse<Feature[]>>(
      'GET',
      `/features?page=${page}&per_page=${perPage}`
    );
  }

  async getFeature(id: number) {
    return this.request<ApiResponse<Feature>>('GET', `/features/${id}`);
  }

  async createFeature(data: Partial<Feature>) {
    return this.request<ApiResponse<Feature>>('POST', '/features', {
      feature: data,
    });
  }

  async updateFeature(id: number, data: Partial<Feature>) {
    return this.request<ApiResponse<Feature>>('PATCH', `/features/${id}`, {
      feature: data,
    });
  }

  async deleteFeature(id: number) {
    return this.request<void>('DELETE', `/features/${id}`);
  }
}

export { ApiClient, ApiConfig, Feature, ApiResponse };
```

## Generation Script

```bash
#!/bin/bash
# scripts/generate_api_docs.sh

set -e

echo "Generating OpenAPI spec..."
bundle exec rake rswag:specs:swaggerize

echo "Creating docs directory..."
mkdir -p docs/api/sdk/{typescript,swift,kotlin}

echo "Generating Postman collection..."
# Use openapi-to-postman or similar tool
npx openapi-to-postmanv2 -s swagger/v1/openapi.yaml -o docs/api/postman_collection.json

echo "API documentation generated!"
echo "- OpenAPI: swagger/v1/openapi.yaml"
echo "- Postman: docs/api/postman_collection.json"
echo "- curl examples: docs/api/curl_examples.md"
```

## Checklist

Before completing:

- [ ] OpenAPI spec is up to date
- [ ] Postman collection covers all endpoints
- [ ] curl examples are tested
- [ ] TypeScript SDK compiles
- [ ] All authentication flows documented
