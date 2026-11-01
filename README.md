# Find the Permissible Fly Zone — Salesforce Apex

Projeto desenvolvido como parte do **Superbadge Find the Permissible Fly Zone**, da Salesforce Trailhead.

A solução implementa serviços de integração utilizando **Apex REST e Apex SOAP**, aplicando regras de negócio, consultas SOQL, manipulação de registros e testes automatizados.

## Tecnologias utilizadas

- Salesforce Platform
- Apex
- Apex REST
- Apex SOAP
- SOQL
- Salesforce DX
- Salesforce CLI
- Visual Studio Code

## Funcionalidades implementadas

### 1. Product Zoning Service — REST

Serviço responsável por consultar a zona de voo permitida para determinado produto, considerando seu código, sua família e o país informado.

**Endpoint:** `/services/apexrest/ProductZoning/`

**Método:** GET

**Principais regras:**
- Consulta produtos pelo ProductCode.
- Utiliza o país informado no cabeçalho `CountryCode`.
- Assume `US` como país padrão quando não informado.
- Consulta configurações geográficas em Custom Metadata Types.
- Retorna a zona de voo permitida ou mensagens específicas quando não encontra os dados.

### 2. Asset Service — REST

Serviço responsável por registrar a perda de dispositivos e verificar a cobertura de seguro.

**Endpoint:** `/services/apexrest/lost/`

**Método:** POST

**Principais regras:**
- Localiza dispositivos pelo identificador.
- Atualiza o status do dispositivo para `Lost`.
- Verifica a existência de seguro ativo com cobertura abrangente.
- Cria uma reivindicação (`Claim__c`) quando existe cobertura.
- Evita a criação de reivindicações duplicadas para perda.
- Informa quando não existe cobertura.

### 3. Credential Verification Service — SOAP

Serviço responsável por verificar a situação de certificações associadas a contatos.

**Método:** `verifyCredential`

**Parâmetros:**
- `lastName`
- `certificationName`

**Principais regras:**
- Localiza o contato pelo sobrenome.
- Consulta a certificação vinculada ao contato.
- Retorna `Valid` quando a certificação está ativa.
- Retorna `Needs Renewal` quando está inativa.
- Retorna `No record found` quando não encontra os registros necessários.

## Testes automatizados

Foram desenvolvidas classes de teste Apex para validar os cenários positivos e negativos dos três serviços.

| Classe | Cobertura |
|---|---:|
| ProductZoningService | 100% |
| AssetService | 100% |
| CredentialVerificationService | 100% |

**Resultado:** 17 métodos de teste executados com sucesso, sem falhas.

## Estrutura do projeto

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

## Configuração do ambiente

Requisitos:

- Salesforce CLI
- Visual Studio Code
- Salesforce Extension Pack
- Organização Salesforce com permissões para desenvolvimento Apex

Clone o repositório:

```bash
git clone URL_DO_REPOSITORIO
```

Entre na pasta:

```bash
cd find-permissible-fly-zone
```

Autentique uma organização Salesforce:

```bash
sf org login web
```

Configure a organização padrão:

```bash
sf config set target-org SEU_ALIAS
```

Para executar os testes Apex:

```bash
sf apex run test --target-org SEU_ALIAS --result-format human --code-coverage
```

## Aprendizados e competências desenvolvidas

- Desenvolvimento de serviços Apex REST e SOAP.
- Construção e execução de consultas SOQL.
- Integração entre objetos padrão e personalizados.
- Utilização de Custom Metadata Types.
- Implementação de regras de negócio.
- Tratamento de cenários de erro.
- Criação de testes automatizados Apex.
- Análise de cobertura de código.
- Versionamento com Git e GitHub.

## Sobre o projeto

Projeto acadêmico e prático desenvolvido para aprofundar conhecimentos no ecossistema Salesforce, com foco em desenvolvimento backend, integrações e qualidade de código.

**Desafio:** Salesforce Trailhead — Find the Permissible Fly Zone.