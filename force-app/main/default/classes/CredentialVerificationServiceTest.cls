
@IsTest
private class CredentialVerificationServiceTest {

    // Cria um contato para os testes
    private static Contact createTestContact() {

        Contact contact = new Contact(
            LastName = 'DroneOperator'
        );

        insert contact;

        return contact;
    }

    // Cria uma certificação e recupera seu nome automático
    
private static Contact_Certification__c createCertification(
    Contact contact,
    Boolean isActive
) {

    // Criar o registro pai Certification
    Certification__c parentCertification =
        new Certification__c(
            Name = 'Drone Pilot License',
            isActive__c = true
        );

    insert parentCertification;

    // Criar a certificação vinculada ao contato
    Contact_Certification__c certification =
        new Contact_Certification__c(
            Contact__c = contact.Id,
            Certification__c = parentCertification.Id,
            Issue_Date__c = Date.today(),
            isActive__c = isActive
        );

    insert certification;

    // Recuperar o nome gerado automaticamente
    certification = [
        SELECT Id, Name, Contact__c, isActive__c
        FROM Contact_Certification__c
        WHERE Id = :certification.Id
        LIMIT 1
    ];

    return certification;
}


    // Teste 1: certificação ativa
    @IsTest
    static void testActiveCertification() {

        Contact contact = createTestContact();

        Contact_Certification__c certification =
            createCertification(contact, true);

        Test.startTest();

        String result =
            CredentialVerificationService.verifyCredential(
                'DroneOperator',
                certification.Name
            );

        Test.stopTest();

        System.assertEquals('Valid', result);
    }

    // Teste 2: certificação inativa
    @IsTest
    static void testInactiveCertification() {

        Contact contact = createTestContact();

        Contact_Certification__c certification =
            createCertification(contact, false);

        Test.startTest();

        String result =
            CredentialVerificationService.verifyCredential(
                'DroneOperator',
                certification.Name
            );

        Test.stopTest();

        System.assertEquals('Needs Renewal', result);
    }

    // Teste 3: contato inexistente
    @IsTest
    static void testContactNotFound() {

        Test.startTest();

        String result =
            CredentialVerificationService.verifyCredential(
                'UnknownOperator',
                'CERT-001'
            );

        Test.stopTest();

        System.assertEquals('No record found', result);
    }

    // Teste 4: certificação inexistente
    @IsTest
    static void testCertificationNotFound() {

        Contact contact = createTestContact();

        Test.startTest();

        String result =
            CredentialVerificationService.verifyCredential(
                'DroneOperator',
                'CERT-NOT-FOUND'
            );

        Test.stopTest();

        System.assertEquals('No record found', result);
    }

    // Teste 5: parâmetros vazios
    @IsTest
    static void testEmptyParameters() {

        Test.startTest();

        String result =
            CredentialVerificationService.verifyCredential(
                '',
                ''
            );

        Test.stopTest();

        System.assertEquals('No record found', result);
    }

    // Teste 6: sobrenome vazio
    @IsTest
    static void testEmptyLastName() {

        Test.startTest();

        String result =
            CredentialVerificationService.verifyCredential(
                '',
                'CERT-001'
            );

        Test.stopTest();

        System.assertEquals('No record found', result);
    }

    // Teste 7: nome da certificação vazio
    @IsTest
    static void testEmptyCertificationName() {

        Test.startTest();

        String result =
            CredentialVerificationService.verifyCredential(
                'DroneOperator',
                ''
            );

        Test.stopTest();

        System.assertEquals('No record found', result);
    }
}
