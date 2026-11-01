
global with sharing class CredentialVerificationService {

    webservice static String verifyCredential(
        String lastName,
        String certificationName
    ) {

        // Validar os parâmetros recebidos
        if (String.isBlank(lastName) ||
            String.isBlank(certificationName)) {

            return 'No record found';
        }

        // Localizar o contato pelo sobrenome
        List<Contact> contacts = [
            SELECT Id
            FROM Contact
            WHERE LastName = :lastName
            LIMIT 1
        ];

        if (contacts.isEmpty()) {
            return 'No record found';
        }

        // Localizar a certificação vinculada ao contato
        List<Contact_Certification__c> certifications = [
            SELECT Id, Name, isActive__c
            FROM Contact_Certification__c
            WHERE Contact__c = :contacts[0].Id
            AND Name = :certificationName
            LIMIT 1
        ];

        if (certifications.isEmpty()) {
            return 'No record found';
        }

        // Verificar a situação da certificação
        if (certifications[0].isActive__c) {
            return 'Valid';
        }

        return 'Needs Renewal';
    }
}
