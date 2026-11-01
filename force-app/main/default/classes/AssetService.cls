
@RestResource(urlMapping='/lost/*')
global with sharing class AssetService {

    @HttpPost
    global static String reportLostDevice(String assetIdentifier) {

        // 1. Validar o identificador do dispositivo
        if (String.isBlank(assetIdentifier)) {
            return 'No device found.';
        }

        // 2. Localizar o dispositivo
        List<Asset> assets = [
            SELECT Id, Name, Asset_Identifier__c, Status, ContactId
            FROM Asset
            WHERE Asset_Identifier__c = :assetIdentifier
            LIMIT 1
        ];

        if (assets.isEmpty()) {
            return 'No device found.';
        }

        Asset device = assets[0];

        // 3. Atualizar o status do dispositivo
        device.Status = 'Lost';
        update device;

        // 4. Verificar seguro abrangente ativo
        List<Insurance__c> insurances = [
            SELECT Id, Name, Coverage__c, Active__c
            FROM Insurance__c
            WHERE Asset__c = :device.Id
            AND Active__c = true
            AND Coverage__c = 'Comprehensive'
            LIMIT 1
        ];

        // 5. Retornar mensagem caso não exista cobertura
        if (insurances.isEmpty()) {
            return 'No coverage. Asset status adjusted to Lost.';
        }

        // 6. Verificar se já existe um sinistro de perda
        List<Claim__c> existingClaims = [
            SELECT Id, Name, Type__c
            FROM Claim__c
            WHERE Asset__c = :device.Id
            AND Type__c = 'Loss'
            LIMIT 1
        ];

        if (!existingClaims.isEmpty()) {
            return existingClaims[0].Name + ' already filed.';
        }

        // 7. Criar novo sinistro
        Claim__c newClaim = new Claim__c();

        newClaim.Asset__c = device.Id;
        newClaim.Insurance__c = insurances[0].Id;
        newClaim.Contact__c = device.ContactId;
        newClaim.Type__c = 'Loss';

        insert newClaim;

        // 8. Recuperar o número gerado pelo Salesforce
        Claim__c savedClaim = [
            SELECT Name
            FROM Claim__c
            WHERE Id = :newClaim.Id
            LIMIT 1
        ];

        return savedClaim.Name;
    }
}
