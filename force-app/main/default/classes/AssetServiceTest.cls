
@IsTest
private class AssetServiceTest {

    // Teste 1: identificador de dispositivo inexistente
    @IsTest
    static void testDeviceNotFound() {

        Test.startTest();
        String result = AssetService.reportLostDevice('INVALID-123');
        Test.stopTest();

        System.assertEquals(
            'No device found.',
            result,
            'Should return an error when the asset does not exist.'
        );
    }

    // Teste 2: identificador vazio
    @IsTest
    static void testEmptyAssetIdentifier() {

        Test.startTest();
        String result = AssetService.reportLostDevice('');
        Test.stopTest();

        System.assertEquals(
            'No device found.',
            result,
            'Should return an error when the asset identifier is empty.'
        );
    }

    // Método auxiliar para criar um dispositivo de teste
    private static Asset createTestAsset() {

        Account account = new Account(
            Name = 'Test Account'
        );
        insert account;

        Contact contact = new Contact(
            LastName = 'Test Contact',
            AccountId = account.Id
        );
        insert contact;

        Asset device = new Asset(
            Name = 'Test Device',
            AccountId = account.Id,
            ContactId = contact.Id,
            Asset_Identifier__c = 'DEVICE-001',
            Status = 'Purchased'
        );
        insert device;

        return device;
    }

    // Método auxiliar para criar seguro abrangente ativo
    private static Insurance__c createTestInsurance(Asset device) {

        Insurance__c insurance = new Insurance__c(
            Asset__c = device.Id,
            Active__c = true,
            Coverage__c = 'Comprehensive',
            Start_Date__c = Date.today().addDays(-10),
            End_Date__c = Date.today().addDays(30)
        );

        insert insurance;

        return insurance;
    }

    // Teste 3: criação de sinistro com cobertura válida
    @IsTest
    static void testSuccessfulClaimCreation() {

        Asset device = createTestAsset();
        Insurance__c insurance = createTestInsurance(device);

        Test.startTest();
        String result = AssetService.reportLostDevice('DEVICE-001');
        Test.stopTest();

        List<Claim__c> claims = [
            SELECT Id, Name, Asset__c, Insurance__c,
                   Contact__c, Type__c
            FROM Claim__c
            WHERE Asset__c = :device.Id
        ];

        System.assertEquals(1, claims.size());
        System.assertEquals('Loss', claims[0].Type__c);
        System.assertEquals(device.Id, claims[0].Asset__c);
        System.assertEquals(insurance.Id, claims[0].Insurance__c);
        System.assertEquals(device.ContactId, claims[0].Contact__c);
        System.assertEquals(claims[0].Name, result);

        Asset updatedDevice = [
            SELECT Status
            FROM Asset
            WHERE Id = :device.Id
        ];

        System.assertEquals('Lost', updatedDevice.Status);
    }

    // Teste 4: sinistro de perda já existente
    @IsTest
    static void testExistingLossClaim() {

        Asset device = createTestAsset();
        Insurance__c insurance = createTestInsurance(device);

        Claim__c existingClaim = new Claim__c(
            Asset__c = device.Id,
            Insurance__c = insurance.Id,
            Contact__c = device.ContactId,
            Type__c = 'Loss'
        );
        insert existingClaim;

        existingClaim = [
            SELECT Id, Name
            FROM Claim__c
            WHERE Id = :existingClaim.Id
            LIMIT 1
        ];

        Test.startTest();
        String result = AssetService.reportLostDevice('DEVICE-001');
        Test.stopTest();

        System.assertEquals(
            existingClaim.Name + ' already filed.',
            result
        );

        List<Claim__c> claims = [
            SELECT Id
            FROM Claim__c
            WHERE Asset__c = :device.Id
            AND Type__c = 'Loss'
        ];

        System.assertEquals(
            1,
            claims.size(),
            'A duplicate claim should not be created.'
        );
    }

    // Teste 5: dispositivo sem cobertura de seguro
    @IsTest
    static void testNoInsuranceCoverage() {

        Asset device = createTestAsset();

        Test.startTest();
        String result = AssetService.reportLostDevice('DEVICE-001');
        Test.stopTest();

        System.assertEquals(
            'No coverage. Asset status adjusted to Lost.',
            result
        );

        Asset updatedDevice = [
            SELECT Status
            FROM Asset
            WHERE Id = :device.Id
        ];

        System.assertEquals(
            'Lost',
            updatedDevice.Status,
            'Asset status should be updated even without insurance coverage.'
        );

        List<Claim__c> claims = [
            SELECT Id
            FROM Claim__c
            WHERE Asset__c = :device.Id
        ];

        System.assertEquals(
            0,
            claims.size(),
            'No claim should be created without insurance coverage.'
        );
    }
}
