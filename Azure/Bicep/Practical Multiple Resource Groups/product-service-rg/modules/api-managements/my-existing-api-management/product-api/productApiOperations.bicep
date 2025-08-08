// Product API Operations Module
// This module creates operations for the Product API

@description('The name of the API Management service')
param apiManagementName string

@description('The name of the Product API')
param productApiName string

// Reference to existing API Management service (from base-services)
resource apiManagement 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementName
}

// Reference to existing Product API
resource productApi 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' existing = {
  parent: apiManagement
  name: productApiName
}

// Product API Operations
resource productApiGetOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: productApi
  name: 'get-products'
  properties: {
    displayName: 'Get Products'
    method: 'GET'
    urlTemplate: '/'
    description: 'Get all products with optional filtering'
  }
}

resource productApiPostOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: productApi
  name: 'post-product'
  properties: {
    displayName: 'Create Product'
    method: 'POST'
    urlTemplate: '/'
    description: 'Create a new product'
  }
}

resource productApiGetByIdOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: productApi
  name: 'get-product-by-id'
  properties: {
    displayName: 'Get Product by ID'
    method: 'GET'
    urlTemplate: '/{id}'
    description: 'Get a specific product by ID'
    templateParameters: [
      {
        name: 'id'
        description: 'Product ID'
        type: 'string'
        required: true
      }
    ]
  }
}

resource productApiPutOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: productApi
  name: 'put-product'
  properties: {
    displayName: 'Update Product'
    method: 'PUT'
    urlTemplate: '/{id}'
    description: 'Update an existing product'
    templateParameters: [
      {
        name: 'id'
        description: 'Product ID'
        type: 'string'
        required: true
      }
    ]
  }
}

resource productApiDeleteOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: productApi
  name: 'delete-product'
  properties: {
    displayName: 'Delete Product'
    method: 'DELETE'
    urlTemplate: '/{id}'
    description: 'Delete a product'
    templateParameters: [
      {
        name: 'id'
        description: 'Product ID'
        type: 'string'
        required: true
      }
    ]
  }
}

// Category Operations
resource categoryApiGetOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: productApi
  name: 'get-categories'
  properties: {
    displayName: 'Get Categories'
    method: 'GET'
    urlTemplate: '/categories'
    description: 'Get all product categories'
  }
}

resource categoryApiGetByIdOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: productApi
  name: 'get-category-by-id'
  properties: {
    displayName: 'Get Category by ID'
    method: 'GET'
    urlTemplate: '/categories/{categoryId}'
    description: 'Get a specific category by ID'
    templateParameters: [
      {
        name: 'categoryId'
        description: 'Category ID'
        type: 'string'
        required: true
      }
    ]
  }
}

resource productsByCategoryOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: productApi
  name: 'get-products-by-category'
  properties: {
    displayName: 'Get Products by Category'
    method: 'GET'
    urlTemplate: '/categories/{categoryId}/products'
    description: 'Get all products in a specific category'
    templateParameters: [
      {
        name: 'categoryId'
        description: 'Category ID'
        type: 'string'
        required: true
      }
    ]
  }
}

// Outputs
output productApiGetOperationName string = productApiGetOperation.name
output productApiPostOperationName string = productApiPostOperation.name
output productApiGetByIdOperationName string = productApiGetByIdOperation.name
output productApiPutOperationName string = productApiPutOperation.name
output productApiDeleteOperationName string = productApiDeleteOperation.name
output categoryApiGetOperationName string = categoryApiGetOperation.name
output categoryApiGetByIdOperationName string = categoryApiGetByIdOperation.name
output productsByCategoryOperationName string = productsByCategoryOperation.name
