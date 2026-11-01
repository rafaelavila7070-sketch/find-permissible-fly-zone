# Find the Permissible Fly Zone — Salesforce Apex

[🇧🇷 Português](README.md) | 🇺🇸 English

A Salesforce project developed as part of the **Find the Permissible Fly Zone Superbadge** on Salesforce Trailhead.

The solution implements REST and SOAP integration services using Apex, applying business rules, SOQL queries, record manipulation, and automated testing.

## Technologies

- Salesforce Platform
- Apex
- Apex REST
- Apex SOAP
- SOQL
- Salesforce DX
- Salesforce CLI
- Visual Studio Code

## Implemented Features

### 1. Product Zoning Service — REST

A REST service that determines the permissible fly zone for a product based on its product code, product family, and country.

**Endpoint:** `/services/apexrest/ProductZoning/`

**HTTP Method:** GET

**Business Rules:**
- Retrieves products using their ProductCode.
- Uses the `CountryCode` request header.
- Defaults to `US` when no country code is provided.
- Retrieves geographic rules from Custom Metadata Types.
- Returns the permissible fly zone or an appropriate message when information is unavailable.

### 2. Asset Service — REST

A REST service responsible for reporting lost devices and checking insurance coverage.

**Endpoint:** `/services/apexrest/lost/`

**HTTP Method:** POST

**Business Rules:**
- Finds devices using their asset identifier.
- Updates the device status to `Lost`.
- Checks for active comprehensive insurance coverage.
- Creates a `Claim__c` record when coverage is available.
- Prevents duplicate loss claims.
- Returns an appropriate message when no coverage exists.

### 3. Credential Verification Service — SOAP

A SOAP service that verifies certification status associated with contacts.

**Method:** `verifyCredential`

**Parameters:**
- `lastName`
- `certificationName`

**Business Rules:**
- Finds contacts by last name.
- Retrieves certifications associated with the contact.
- Returns `Valid` when the certification is active.
- Returns `Needs Renewal` when the certification is inactive.
- Returns `No record found` when the required records cannot be found.

## Automated Testing

Apex test classes were developed to validate positive and negative scenarios across all three services.

| Class | Code Coverage |
|---|---:|
| ProductZoningService | 100% |
| AssetService | 100% |
| CredentialVerificationService | 100% |

**Test results:** 17 test methods executed successfully, with no failures.

## Project Structure

```text
force-app/
└── main/
    └── default/
        └── classes/
            ├── AssetService.cls
            ├── AssetServiceTest.cls
            ├── CredentialVerificationService.cls
            ├── CredentialVerificationServiceTest.cls
            ├── ProductZoningService.cls
            └── ProductZoningServiceTest.cls
```

## Environment Setup

### Prerequisites

- Salesforce CLI
- Visual Studio Code
- Salesforce Extension Pack
- A Salesforce organization with Apex development permissions

### Clone the repository

```bash
git clone https://github.com/rafaelavila7070-sketch/find-permissible-fly-zone.git
```

Navigate to the project directory:

```bash
cd find-permissible-fly-zone
```

Authenticate your Salesforce organization:

```bash
sf org login web
```

Set your default organization:

```bash
sf config set target-org YOUR_ALIAS
```

Run Apex tests:

```bash
sf apex run test --target-org YOUR_ALIAS --result-format human --code-coverage
```

## Skills Demonstrated

- Apex REST and SOAP development.
- SOQL queries and data manipulation.
- Integration between standard and custom Salesforce objects.
- Custom Metadata Types.
- Business logic implementation.
- Error handling.
- Automated Apex testing.
- Code coverage analysis.
- Git and GitHub version control.

## About

This project was developed to strengthen practical skills within the Salesforce ecosystem, focusing on backend development, integrations, business logic, and software quality.

**Challenge:** Salesforce Trailhead — Find the Permissible Fly Zone.