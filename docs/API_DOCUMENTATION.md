# API Documentation

## Overview
This document describes the REST API endpoints for the POS & Self-Registration System.

## Base URL
- Development: `http://localhost:8080/api`
- Production: `https://api.pos-selfreg.example.com`

## Authentication
All API endpoints require JWT authentication except for login and registration.

### Headers
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

## Endpoints

### Authentication

#### POST /auth/login
Authenticate user and get JWT token.

**Request Body:**
```json
{
  "username": "admin",
  "password": "admin123"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "username": "admin",
    "email": "admin@posselfreg.com",
    "firstName": "Admin",
    "lastName": "User",
    "role": "ADMIN"
  }
}
```

#### POST /auth/register
Register a new user.

**Request Body:**
```json
{
  "username": "newuser",
  "email": "user@example.com",
  "password": "password123",
  "firstName": "John",
  "lastName": "Doe",
  "role": "EMPLOYEE"
}
```

### Products

#### GET /products
Get all products with pagination.

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Page size (default: 20)
- `category` (optional): Filter by category ID
- `search` (optional): Search by name or SKU

**Response:**
```json
{
  "content": [
    {
      "id": 1,
      "name": "iPhone 15",
      "description": "Latest iPhone model",
      "sku": "IPHONE-15-128",
      "barcode": "1234567890123",
      "category": {
        "id": 1,
        "name": "Electronics"
      },
      "price": 999.99,
      "costPrice": 800.00,
      "stockQuantity": 50,
      "minStockLevel": 10,
      "isActive": true,
      "imageUrl": "https://example.com/iphone15.jpg"
    }
  ],
  "totalElements": 100,
  "totalPages": 5,
  "currentPage": 0
}
```

#### POST /products
Create a new product.

**Request Body:**
```json
{
  "name": "New Product",
  "description": "Product description",
  "sku": "NEW-PROD-001",
  "barcode": "1234567890124",
  "categoryId": 1,
  "price": 29.99,
  "costPrice": 20.00,
  "stockQuantity": 100,
  "minStockLevel": 10
}
```

#### GET /products/{id}
Get product by ID.

#### PUT /products/{id}
Update product.

#### DELETE /products/{id}
Delete product.

### Orders

#### GET /orders
Get all orders with pagination.

**Query Parameters:**
- `page` (optional): Page number
- `size` (optional): Page size
- `status` (optional): Filter by order status
- `dateFrom` (optional): Filter from date (YYYY-MM-DD)
- `dateTo` (optional): Filter to date (YYYY-MM-DD)

#### POST /orders
Create a new order.

**Request Body:**
```json
{
  "customerId": 1,
  "items": [
    {
      "productId": 1,
      "quantity": 2
    },
    {
      "productId": 2,
      "quantity": 1
    }
  ],
  "paymentMethod": "CASH",
  "isSelfCheckout": false
}
```

#### GET /orders/{id}
Get order by ID.

#### PUT /orders/{id}/status
Update order status.

**Request Body:**
```json
{
  "status": "COMPLETED"
}
```

### Self Checkout

#### POST /self-checkout/start
Start a new self-checkout session.

**Response:**
```json
{
  "sessionId": "session-123",
  "qrCode": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...",
  "expiresAt": "2024-01-01T12:00:00Z"
}
```

#### POST /self-checkout/{sessionId}/scan
Scan a product in self-checkout.

**Request Body:**
```json
{
  "barcode": "1234567890123"
}
```

#### POST /self-checkout/{sessionId}/checkout
Complete self-checkout.

**Request Body:**
```json
{
  "paymentMethod": "CARD",
  "customerEmail": "customer@example.com"
}
```

### Inventory

#### GET /inventory/transactions
Get inventory transactions.

#### POST /inventory/adjust
Adjust inventory quantity.

**Request Body:**
```json
{
  "productId": 1,
  "quantity": 10,
  "reason": "Stock adjustment"
}
```

### Reports

#### GET /reports/sales
Get sales report.

**Query Parameters:**
- `dateFrom` (required): Start date (YYYY-MM-DD)
- `dateTo` (required): End date (YYYY-MM-DD)
- `groupBy` (optional): Group by day, week, month

#### GET /reports/inventory
Get inventory report.

#### GET /reports/customers
Get customer report.

### Error Responses

All endpoints may return the following error responses:

#### 400 Bad Request
```json
{
  "timestamp": "2024-01-01T12:00:00Z",
  "status": 400,
  "error": "Bad Request",
  "message": "Validation failed",
  "details": [
    {
      "field": "email",
      "message": "Email is required"
    }
  ]
}
```

#### 401 Unauthorized
```json
{
  "timestamp": "2024-01-01T12:00:00Z",
  "status": 401,
  "error": "Unauthorized",
  "message": "Invalid or expired token"
}
```

#### 403 Forbidden
```json
{
  "timestamp": "2024-01-01T12:00:00Z",
  "status": 403,
  "error": "Forbidden",
  "message": "Insufficient permissions"
}
```

#### 404 Not Found
```json
{
  "timestamp": "2024-01-01T12:00:00Z",
  "status": 404,
  "error": "Not Found",
  "message": "Resource not found"
}
```

#### 500 Internal Server Error
```json
{
  "timestamp": "2024-01-01T12:00:00Z",
  "status": 500,
  "error": "Internal Server Error",
  "message": "An unexpected error occurred"
}
```

## Rate Limiting
- 100 requests per minute per IP address
- 1000 requests per hour per user

## WebSocket Endpoints

### /ws/pos
Real-time updates for POS operations.

**Events:**
- `order.created`: New order created
- `order.updated`: Order status updated
- `inventory.updated`: Inventory quantity changed
- `payment.processed`: Payment completed

## SDKs and Libraries

### JavaScript/TypeScript
```bash
npm install @posselfreg/api-client
```

### Java
```xml
<dependency>
    <groupId>com.posselfreg</groupId>
    <artifactId>api-client</artifactId>
    <version>1.0.0</version>
</dependency>
```

### Android
```gradle
implementation 'com.posselfreg:api-client:1.0.0'
``` 